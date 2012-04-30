#!/apps/ruby/current/bin/ruby
require_relative 'Grammar'
require_relative 'Node'
require_relative 'StackNode'
require 'set'
require_relative 'Utility'
require_relative 'HillClimbConfig'
#require 'MemoryProfiler'

class HillClimb

        attr_accessor :grammar,:cfactor,:no_nodes_factor,:weighted_function,:k_consecutive_touch,:search_mode,:fitness_type
        
	def initialize(grammar,cfactor,no_nodes_factor,weighted_function,k_consecutive_touch,search_mode,fitness_type)
                @@xx_count = 0
		@grammar = grammar
		@cfactor = cfactor.to_f
		@weighted_function = weighted_function
                @k_consecutive_touch = k_consecutive_touch
                @search_mode = search_mode
                @fitness_type = fitness_type
		@time_diff = 0
		@no_nodes_factor = no_nodes_factor
                @w_productions_used_count = {}
                @global_productions_touched = {}
                @global_production_combinations = {}
		if ( (1.0 * @grammar.terminal_productions_count)/@grammar.productions_count < 0.1)
			@no_nodes_factor /= 0.1
		end
                @grammar.productions.keys.each do |lhs|
                        __rhs = @grammar.productions[lhs]
                        __rhs_false_values = []
                        __rhs.each { |_a_rhs| __rhs_false_values << false }
                        @global_productions_touched[lhs] = __rhs_false_values
                end
                # A: a B B | c
                @grammar.productions.keys.each do |lhs|
                        rhs_array = @grammar.productions[lhs]
                        combination_rhs_array = []
                        rhs_array.each do |a_rhs|
                                combination_a_rhs = []
                                a_rhs.each do |token|
                                        token_array = []
                                        #token_array << []
                                        combination_a_rhs << token_array
                                end
                                # __a_rhs_value = [[],[],[]] for a B B
                                combination_rhs_array << combination_a_rhs
                        end
                        # __rhs_values = [[[],[],[]],[[]]]
                        @global_production_combinations[lhs] = combination_rhs_array
                end
#                 @global_production_combinations.keys.each do |lhs|
#                         puts "[#{lhs}]"
#                         @global_production_combinations[lhs].each do |_rhs|
#                                 puts "#{_rhs}"
#                         end
#                         puts "----"
#                 end                
	end

        def print_hc_details()
                puts "========= HillClimb Details ========="
                puts "grammar=[#{@grammar.grammar}]"
                puts "cfactor=[#{@cfactor}]"
                puts "no_nodes_factor=[#{@no_nodes_factor}]"
                puts "weighted_function=[#{@weighted_function}]"
                puts "fitness_type=[#{@fitness_type}]"
                puts "k_consecutive_touch=[#{@k_consecutive_touch}]"
                puts "search_mode=#{@search_mode}"
                puts "debug: #{@@debug}"
                puts "==================================="
        end
        
	def check_amb
		# create a lock file & check ambiguity
		puts "+++ [check_amb] Time: #{Time.now}"
		lock = File.open("logs/lock","w");lock.close # lock.write(@grammar);lock.close;
		while true do
			sleep(1)
			break if ! (File.exists?("logs/lock"))
		end
		(puts "There was a problem parsing the sentence. exiting...";exit) if (File.exists?("grammars/#{@grammar.grammar}/error"))

		ambiguous = true if (File.exists?("grammars/#{@grammar.grammar}/ambiguous"))
		puts "--- [check_amb] Time: #{Time.now}"
		return ambiguous
	end

	def fitness_function(new_sentence_nodes,productions_touched,new_productions_touched,k_consecutive_touched,new_k_consecutive_touched,new_production_combinations,type)
                #puts "inside ff -- #{type}"
		_fitness = false # indicates whether the new sentence has better fitness
		if type == "length"
			generate_sentence_only(new_sentence_nodes[0],'new_sentence')
			f_new_sentence = File.size("grammars/#{@grammar.grammar}/new_sentence")
			f_sentence = File.size("grammars/#{@grammar.grammar}/sentence")
			if (f_new_sentence > f_sentence)
				puts "length: new sentence ([#{f_new_sentence}]) > sentence ([#{f_sentence}])"
				_fitness = true
			elsif (f_new_sentence == f_sentence)
				puts "length: new_sentence ([#{f_new_sentence}]) == sentence ([#{f_sentence}])"
				if (new_productions_touched_factor >= productions_touched_factor)
					puts "No of productions touched in neighbour >="
					_fitness = true
				end
			else
				puts "[#{f_new_sentence} < #{f_sentence}] - new sentence is less fit!!"
			end
		elsif type == "productions_touched"
                        productions_touched_factor,k_consecutive_touch_count = Utility.calc_production_touched_factor(@grammar,productions_touched,nil)
                        new_productions_touched_factor,new_k_consecutive_touch_count = Utility.calc_production_touched_factor(@grammar,new_productions_touched,nil)
			if (new_productions_touched_factor >= productions_touched_factor)
				puts "No of productions touched in neighbour [#{new_productions_touched_factor}] >= [#{productions_touched_factor}]"
				_fitness = true
				#create the new_sentence
				generate_sentence_only(new_sentence_nodes[0],'new_sentence')
                        else
                                puts "[#{new_productions_touched_factor} < #{productions_touched_factor}] - new sentence is less fit!!"
			end
                elsif type == "consecutive_touch"
                        productions_touched_factor,k_consecutive_touch_count = Utility.calc_production_touched_factor(@grammar,nil,k_consecutive_touched)
                        new_productions_touched_factor,new_k_consecutive_touch_count = Utility.calc_production_touched_factor(@grammar,nil,new_k_consecutive_touched)
                        if new_k_consecutive_touch_count >= k_consecutive_touch_count
                                puts "K value in neighbour: [#{new_k_consecutive_touch_count} >= #{k_consecutive_touch_count}]"
                                _fitness = true
                                #create the new_sentence
                                generate_sentence_only(new_sentence_nodes[0],'new_sentence')
                        else
                                puts "[#{new_k_consecutive_touch_count} < #{k_consecutive_touch_count}] - new sentence is less fit!!"
                        end
                elsif type == "productions_touched_hc"
                        # if the productions_touched improves the @global_productions_touched set, then return true
                        # go over the productions touched for the current sentence and if it touches any of the productions from the global set
                        # that hasn't been touched before, then fitness is true.
                        new_productions_touched.keys.each do |lhs|
                                new_rhs = new_productions_touched[lhs]
                                global_rhs = @global_productions_touched[lhs]
                                #puts "++ [#{lhs} :: #{@productions[lhs]}] ++"
                                #puts "   [global_rhs: #{global_rhs}]"
                                #puts "   [new_rhs   : #{new_rhs}]"
                                new_rhs.each_with_index do |val,index|
                                        if val && (global_rhs[index] == false)
                                                _fitness = true
                                                #puts "new_rhs:[val: #{val}, index: #{index}]***"
                                                global_rhs[index] = true
                                                #puts "new_rhs: #{new_rhs} , global_rhs: #{global_rhs}"
                                                #puts "***************"
                                        end
                                end
                                #puts "-- global_rhs: #{global_rhs} --"
                        end
                        puts "### UNTOUCHED PRODUCTIONS ###"
                        @global_productions_touched.keys.each do |lhs|
                                _rhs = @global_productions_touched[lhs]
                                puts "#{lhs} : #{_rhs}" if _rhs.include? false
                        end
                        if _fitness
                                generate_sentence_only(new_sentence_nodes[0],'new_sentence')
                        else
                                productions_touched_factor,x = Utility.calc_production_touched_factor(@grammar,@global_productions_touched,nil)
                                if productions_touched_factor == 1.0
                                        puts "*** FITNESS = true, PROD TOUCHED FACTOR: #{productions_touched_factor}"
                                        _fitness = true
                                        generate_sentence_only(new_sentence_nodes[0],'new_sentence')
                                else 
                                        puts "*** LESS FIT ***"
                                end
                        end
                elsif type == 'production_combinations'
                        puts "-- in fitness function --"
                        ### TESTING ### TO BE REMOVED LATER ###
                        new_productions_touched.keys.each do |lhs|
                                new_rhs = new_productions_touched[lhs]
                                global_rhs = @global_productions_touched[lhs]
                                #puts "++ [#{lhs} :: #{@productions[lhs]}] ++"
                                #puts "   [global_rhs: #{global_rhs}]"
                                #puts "   [new_rhs   : #{new_rhs}]"
                                new_rhs.each_with_index do |val,index|
                                        if val && (global_rhs[index] == false)
                                                #_fitness = true
                                                #puts "new_rhs:[val: #{val}, index: #{index}]***"
                                                global_rhs[index] = true
                                                #puts "new_rhs: #{new_rhs} , global_rhs: #{global_rhs}"
                                                #puts "***************"
                                        end
                                end
                                #puts "-- global_rhs: #{global_rhs} --"
                        end
                        ### ### ###
                        count = Utility.calc_production_touched_factor(@grammar,nil,nil,@global_production_combinations)[2]
                        puts  "** before ** FITNESS: #{_fitness} -- #{count}"
                        new_production_combinations.keys.each do |lhs|
                                new_rhs_array = new_production_combinations[lhs]
                                global_rhs_array = @global_production_combinations[lhs]
                                new_rhs_array.each_with_index do |new_rhs,index|
                                        new_rhs.each_with_index do |token,token_index|
                                                global_rhs_token = global_rhs_array[index][token_index]
                                                #puts "[#{lhs}] new,global: #{token} , #{global_rhs_token}"
                                                if token.size > 0
                                                        if global_rhs_token.size > 0
                                                                diff = token.sort - global_rhs_token.sort
                                                                if diff.size > 0
                                                                        #modify the global one
                                                                        #puts "** before ** global: #{global_rhs_token}"
                                                                        puts "[#{lhs}]  diff - #{diff}"
                                                                        _fitness = true
                                                                        diff.each { |new_comb| global_rhs_token << new_comb }
                                                                        #puts "** after ** global: #{global_rhs_token}"
                                                                end
                                                        else
                                                                _fitness = true
                                                                #puts "** [else]before ** global: #{global_rhs_token}"
                                                                token.each { |new_comb| global_rhs_token << new_comb }
                                                                puts "  ** [else]after ** global: #{global_rhs_token}"
                                                        end
                                                end
                                        end
                                end
                        end
                        x1,x2,count = Utility.calc_production_touched_factor(@grammar,nil,nil,@global_production_combinations)
                        puts "** after ** FITNESS: #{_fitness} -- #{count}"
                        if _fitness
                                generate_sentence_only(new_sentence_nodes[0],'new_sentence')
                        end
		end
                #puts "-- ff : #{_fitness}"
		return _fitness
	end

	def print_stats(symbol,sentence_nodes,productions_used_count,w_productions_used_count)
		#puts "----"
		puts "[symbol=#{symbol}] sentence_nodes.size=[#{sentence_nodes.size}]"
		puts "nodes count ratio=[#{@no_nodes_factor * sentence_nodes.size}]"
		@grammar.productions.keys.each { |lhs|
			puts " +-- #{lhs} : #{@grammar.productions[lhs]} - REC : #{@grammar.productions_recursive[lhs]} : TOTAL = #{w_productions_used_count[lhs]} : CURRENT = #{productions_used_count[lhs]}"
		}
	end

        def process_k_logic(child_node,parent_node,k_consecutive_touched)
                if (child_node.lhs == parent_node.lhs)
                        current_child_node = child_node
                        current_parent_node = parent_node
                        #puts "  - [child,parent] : #{current_child_node},#{current_parent_node}"
                        k_counter = 1
                        k_matched = true
                        current_k_sequence = [current_child_node.rhsIndex,current_parent_node.rhsIndex]
                        # while loop for k > 1
                        while (k_counter < @k_consecutive_touch) do
                                current_child_node = current_parent_node
                                current_parent_node = current_parent_node.parentNode
                                (k_matched = false;break) if current_parent_node == nil  # when we are at the top of the tree
                                #puts "   - while[child,parent] : #{current_child_node},#{current_parent_node}"
                                if ! (current_child_node.lhs == current_parent_node.lhs)
                                        k_matched = false
                                        # we break because the k sequence is broken
                                        break
                                else
                                        # build the sequence
                                        current_k_sequence << current_parent_node.rhsIndex
                                end
                                k_counter += 1
                                #puts "   - end while"
                        end
                        if k_matched
                                #
                                if ! k_consecutive_touched.keys.include? child_node.lhs
                                        k_consecutive_touched[child_node.lhs] = []
                                end
                                if ! k_consecutive_touched[child_node.lhs].include? current_k_sequence
                                        k_consecutive_touched[child_node.lhs] << current_k_sequence
                                        #puts "current k seq for #{child_node.lhs} : #{k_consecutive_touched[child_node.lhs]}"
                                end
                        end
                end
        end

        def get_a_rhs_index(active_node,tokenIndex,symbol,type,production_combinations,productions_touched,productions_used_count,w_productions_used_count,nodes_count_weight)
                rhs_index = nil
                if type == 'FINAL'
                        lhs_route_terminals_indices = @grammar.lhs_route_terminals[symbol]
                        puts "#{symbol} -- lhs_route_terminals_indices: #{lhs_route_terminals_indices}"
                        lhs_route_terminals_indices_values = []
                        @grammar.lhs_route_terminals[symbol].size.times {|value| lhs_route_terminals_indices_values << 1.0 }
                        rhs_index = lhs_route_terminals_indices[Utility.weighted_random_production(lhs_route_terminals_indices_values)]
                        puts "rhs_index: #{rhs_index}"
                else
                        if @weighted_function == 'ratio'
                                ### TRY THIS: use global_productions_touched instead of the current productions_touched
                                ### you would need to modify the global_productions_touched as you go along, otherwise, you will reach BREAK=4000
                                rhs_index = Utility.weighted_random_production_current_to_total_ratio(active_node,tokenIndex,symbol,@fitness_type,@grammar,production_combinations,productions_touched,productions_used_count[symbol],w_productions_used_count[symbol],nodes_count_weight,@cfactor)
                        elsif @weighted_function == 'prod_count'
                                rhs_index = Utility.weighted_random_production_prod_count(symbol,@grammar,productions_used_count[symbol],w_productions_used_count[symbol],0.0,@cfactor)
                        end
                end
                return rhs_index
        end
        
	# generate sentence tree using DFS
	def generate_sentence_tree_by_dfs(symbol,type=nil,randomNode=nil)
		puts "+++ DFS #{Time.now},#{symbol},#{type} +++"
		sentence = ''
		active_nodes_stack,sentence_nodes,sentence_nodes_table = [],[],{}
		productions_touched,productions_used_count,w_productions_used_count = {},{},{}
                production_combinations = {}
                # for k = 1
                k_consecutive_touched = {} # [lhs]=>[[node1,node3],[node2,node7]]
		# initialise weights and productions_touched
		@grammar.productions.keys.each do |lhs|
			rhs_array = @grammar.productions[lhs]
			###productions_touched_rhs = [] if symbol == 'root'
			productions_used_count_rhs,w_productions_used_count_rhs = [],[]
                        production_combinations_a_rhs = []
			rhs_array.each do |a_rhs|
				###productions_touched_rhs << false if symbol == 'root'
				productions_used_count_rhs << 0
				w_productions_used_count_rhs << 0
                                _build_array_for_a_rhs = []
                                a_rhs.each do |token|
                                        _build_array_for_a_rhs << []
                                end
                                production_combinations_a_rhs << _build_array_for_a_rhs
                        end
			###productions_touched[lhs] = productions_touched_rhs ### if symbol == 'root'
                        sentence_nodes_table[lhs] = [] if symbol == 'root'
			productions_used_count[lhs] = productions_used_count_rhs
			w_productions_used_count[lhs] = w_productions_used_count_rhs
                        production_combinations[lhs] = production_combinations_a_rhs
                end
                # initialising productions_touched
                if ((@fitness_type == 'productions_touched_hc') || (@fitness_type == 'production_combinations'))
                        productions_touched = Marshal.load(Marshal.dump(@global_productions_touched))
                        production_combinations = Marshal.load(Marshal.dump(@global_production_combinations))
                else
                        if symbol == 'root'
                                @grammar.productions.keys.each do |lhs|
                                        rhs = @grammar.productions[lhs]
                                        productions_touched_rhs = []
                                        rhs.each do |a_rhs|
                                                productions_touched_rhs << false
                                        end
                                        productions_touched[lhs] = productions_touched_rhs
                                end
                        end
                end
		rhs = @grammar.productions[symbol]
                #### WE SHOULDNT PASS NIL for active_node ####
                rhs_index = get_a_rhs_index(nil,nil,symbol,type,production_combinations,productions_touched,productions_used_count,w_productions_used_count,0.0)
		rhs_selected = rhs[rhs_index]
		node = Node.new(symbol,rhs_selected,rhs_index)
		sentence_nodes << node
                (sentence_nodes_table[node.lhs] << node) if symbol == 'root'
		productions_touched[symbol][rhs_index] = true # if symbol == 'root'
		productions_used_count[symbol][rhs_index] += 1
		w_productions_used_count[symbol][rhs_index] += 1
		active_nodes_stack.push(StackNode.new(node,0,0)) # node, index, depth
		valid = true
		sentence_starttime = Time.now
		count,depth = 0,0
		begin
			while ((stack_node = active_nodes_stack.pop) != nil) do
				active_node = stack_node.activeNode
				has_NT = false
				has_NT = true if (stack_node.index > 0)
				#valid = terminate_search(stack_node,count)
				#break if !valid
				(valid = false;break) if Utility.limit_reached(@grammar.grammar,@@starttime)
                                if (stack_node.depth == HillClimbConfig::MAX_DEPTH)
                                        puts "** BREAK ** #{HillClimbConfig::MAX_DEPTH} reached"
                                        print_stats(symbol,sentence_nodes,productions_used_count,w_productions_used_count)
                                        exit
                                        valid = false; break
                                end
				(productions_used_count[active_node.lhs][active_node.rhsIndex] -= 1;next) if stack_node.index == active_node.rhs.length
				if ((count > 0) && (count % 500000 == 0))
					puts "count:[#{count}] depth: #{stack_node.depth}"
					print_stats(symbol,sentence_nodes,productions_used_count,w_productions_used_count)
				end
				active_node_rhs_index = 0
				found = false
				active_node.rhs.each do |char|
					if !found
						if (active_node_rhs_index < stack_node.index)
							active_node_rhs_index += 1;next
						elsif (active_node_rhs_index == stack_node.index)
							found = true
						end
					end
					if @grammar.productions.has_key?(char)
						has_NT = true
						rhs = @grammar.productions[char]
						begin
                                                        rhs_index = get_a_rhs_index(active_node,stack_node.index,char,type,production_combinations,productions_touched,productions_used_count,w_productions_used_count,sentence_nodes.size * @no_nodes_factor)
							rhs_selected = rhs[rhs_index]
							#puts "lhs:rhs - #{char} : #{rhs_selected}"
							child_node = Node.new(char,rhs_selected,rhs_index)
							active_node.childNodes << child_node
							child_node.parentNode = active_node
							sentence_nodes << child_node
                                                        sentence_nodes_table[child_node.lhs] << child_node if symbol == 'root'
							productions_touched[child_node.lhs][rhs_index] = true
							productions_used_count[char][rhs_index] += 1
							w_productions_used_count[char][rhs_index] += 1
                                                        # for k = 1
                                                        process_k_logic(child_node,active_node,k_consecutive_touched)
                                                        # for fitness - production_combinations
                                                        # whenever we create a node<->node link, we populate production_combinations
                                                        # parent -> child [invoked]
                                                        #### we now use stack_node.index too to locate the exact NT.
                                                        xx_1 = production_combinations[active_node.lhs][active_node.rhsIndex][stack_node.index]
                                                        if ! xx_1.include? [child_node.lhs,child_node.rhsIndex]
                                                                (xx_1 << [child_node.lhs,child_node.rhsIndex])
                                                        end
#                                                         if active_node.lhs == 'simple_expr'
#                                                                 puts "++ #{active_node.lhs} : #{active_node.rhsIndex} :: #{production_combinations[active_node.lhs][active_node.rhsIndex]} ++"
#                                                         end
                                                        stack_node.index = stack_node.index + 1
                                                        active_nodes_stack.push(stack_node)
                                                        active_nodes_stack.push(StackNode.new(child_node,0,stack_node.depth+1))                                                        
                                                rescue Exception => ex
							puts "\n\n--- Exception inside ---"
							puts "Exception: #{ex.message}"
							puts "char: #{char} , rhs_index: #{rhs_index}"
							puts "stack node: #{stack_node}"
							puts "-- backtrace --"
							puts ex.backtrace
							puts "----"
							print_stats(symbol,sentence_nodes,productions_used_count,w_productions_used_count)
							puts "--- Exception inside ---"
							puts "*************************************************\n\n"
							exit
						end

						break
					else
						active_node.childNodes << nil
						productions_used_count[active_node.lhs][active_node.rhsIndex] -= 1 if (stack_node.index+1) >= active_node.rhs.length
					end
					stack_node.index += 1
				end
				count += 1
			end
		rescue Exception => e
			valid = false
			puts "++---------------------"
			puts e.backtrace
			puts "++---------------------"
			Process.exit
		end
                # return early when generating final ambiguous sentence
                (return [valid,sentence_nodes,productions_touched,k_consecutive_touched]) if (type == 'FINAL')
                (@w_productions_used_count = w_productions_used_count) if symbol == 'root'
		puts "--- DFS #{Time.now} ---"
		return [valid,sentence_nodes,sentence_nodes_table,productions_touched,k_consecutive_touched,production_combinations]
	end

        def generate_sentence_nodes(root_node)
                sentence_nodes,active_nodes_stack = [],[]
                active_nodes_stack.push([root_node,0])
                sentence_nodes << root_node
                while ((active_node,index=active_nodes_stack.pop) != nil) do
                        active_node.rhs[index,active_node.rhs.size].each do |token|
                                if @grammar.productions.has_key?(token)
                                        child_node = active_node.childNodes[index]
                                        active_nodes_stack.push([active_node,index+1]) if (index+1) < active_node.rhs.length
                                        active_nodes_stack.push([child_node,0])
                                        sentence_nodes << child_node
                                        break
                                end
                                index=index+1
                        end
                end
                return sentence_nodes               
        end
        
	def generate_sentence(root_node)
		puts "+++ generate_sentence #{Time.now} +++"
		sentence_nodes,active_nodes_stack,sentence_nodes_table = [],[],{}
		productions_touched,k_consecutive_touched = {},{} # k_consecutive_touched -- NT -> ??
                production_combinations = {}
		# initialise productions_touched
		@grammar.productions.keys.each do |lhs|
			rhs_array = @grammar.productions[lhs]
			productions_touched_rhs = []
                        combination_rhs_array = []
			rhs_array.each do |a_rhs|
                                productions_touched_rhs << false
                                combination_a_rhs = []
                                a_rhs.each do |token|
                                        token_array = []
                                        #token_array << []
                                        combination_a_rhs << token_array
                                end
                                combination_rhs_array << combination_a_rhs                                
                        end
			productions_touched[lhs] = productions_touched_rhs
                        sentence_nodes_table[lhs] = []
                        production_combinations[lhs] = combination_rhs_array
                end
		active_nodes_stack.push([root_node,0])
		sentence_nodes << root_node
                sentence_nodes_table[root_node.lhs] << root_node
                productions_touched[root_node.lhs][root_node.rhsIndex] = true
		while ((active_node,index=active_nodes_stack.pop) != nil) do
                        #puts " ;; active_node: #{active_node} ;; " if (index == 0)
			active_node.rhs[index,active_node.rhs.size].each do |token|
				if @grammar.productions.has_key?(token)
					child_node = active_node.childNodes[index]
                                        process_k_logic(child_node,active_node,k_consecutive_touched)
					sentence_nodes << child_node
                                        sentence_nodes_table[child_node.lhs] << child_node
					productions_touched[child_node.lhs][child_node.rhsIndex] = true
                                        #puts "** true ** : #{child_node.lhs}: #{child_node.rhsIndex} : #{@productions[child_node.lhs]}"
					#puts "-- prod touched: #{productions_touched.to_a}"
                                        # for fitness - production_combinations
                                        # whenever we create a node<->node link, we populate production_combinations
                                        # parent -> child [invoked]
#                                         xx_1 = production_combinations[active_node.lhs][active_node.rhsIndex]
#                                         (xx_1 << [child_node.lhs,child_node.rhsIndex]) if ! xx_1.include? [child_node.lhs,child_node.rhsIndex]
                                        xx_1 = production_combinations[active_node.lhs][active_node.rhsIndex][index]
                                        if ! xx_1.include? [child_node.lhs,child_node.rhsIndex]
                                                (xx_1 << [child_node.lhs,child_node.rhsIndex])
                                        end
                                        # child -> parent [invoked from]
                                        #yy_1 = production_combinations[child_node.lhs][child_node.rhsIndex]
                                        #(yy_1 << [active_node.lhs,active_node.rhsIndex]) if ! yy_1.include? [active_node.lhs,active_node.rhsIndex]
                                        active_nodes_stack.push([active_node,index+1]) if (index+1) < active_node.rhs.length
                                        active_nodes_stack.push([child_node,0])                                        
					break
				end
				index=index+1
                        end
		end
                #productions_touched.keys.each { |lhs| puts "#{lhs} : #{@grammar.productions[lhs]} : #{productions_touched[lhs]}" }
		return sentence_nodes,sentence_nodes_table,productions_touched,k_consecutive_touched,production_combinations
	end

	def generate_sentence_only(root_node,sentence_filename)
		active_nodes_stack = []
		active_nodes_stack.push([root_node,0])
		puts "+++ [generate_sentence_only] Time: #{Time.now}"
		sentence_file = File.open("grammars/#{@grammar.grammar}/#{sentence_filename}","w")
		while ((active_node,index=active_nodes_stack.pop) != nil) do
			active_node.rhs[index,active_node.rhs.size].each { |token|
				if @grammar.productions.has_key?(token)
					child_node = active_node.childNodes[index]
					active_nodes_stack.push([active_node,index+1]) if (index+1) < active_node.rhs.length
					active_nodes_stack.push([child_node,0])
					break
				else
					sentence_file.write(token + " ")
				end
				index=index+1
			}
		end
		puts "grammars/#{@grammar.grammar}/#{sentence_filename} written."
		sentence_file.close
		puts "--- [generate_sentence_only] Time: #{Time.now}"
	end

	def generate_ambiguous_sentence()
                ambiguity_type,ambiguous_non_terminal,ambiguous_part_in_rule,rhsIndex = Utility.retrieve_parse_tree_info(@grammar)
                route_to_root_stack = Utility.give_route_to_root_stack(ambiguous_non_terminal,rhsIndex,@grammar.productions)
                puts "route_to_root_stack: #{route_to_root_stack}"
                ambiguous_sub_sentence_size = File.size("grammars/#{@grammar.grammar}/ambiguous_sub_sentence")
                if ambiguous_sub_sentence_size == 0
                        puts "** ambiguous_sub_sentence_size == 0 **"
                        sub_sentence = ""
                else
                        sub_sentence_file = File.open("grammars/#{@grammar.grammar}/ambiguous_sub_sentence")
                        sub_sentence = sub_sentence_file.readline()
                        sub_sentence_file.close
                end
                puts "ambiguous_sub_sentence: #{sub_sentence}"
                previous_LHS,current_LHS,active_node = nil,nil,nil
                active_sentence_string = ""
                if (ambiguity_type == "disjunctive")
                        #puts "** disjunctive **"
                        # we can replace it as at is
                        active_sentence_string = sub_sentence
                        active_node = route_to_root_stack.pop
                        current_LHS = active_node.lhs
                else
                        #puts "** conjuctive **"
                        # for conjuctive ambiguity, ambiguous part can just be sub-part of a rule
                        active_node = route_to_root_stack.pop
                        active_node_rhs = @grammar.productions[active_node.lhs][active_node.rhsIndex].join(" ")
                        puts "active_node_rhs: #{active_node_rhs}"
                        #modify the ambiguous_part_in_rule to use the lex tokens
                        xx_new,modified_ambiguous_part_in_rule = [],""
                        ambiguous_part_in_rule.split.each do |token|
                                #puts " -- token : #{token}"
                                if @grammar.token_to_terminals.keys.include? token
                                        #puts " --- match "
                                        xx_new << @grammar.token_to_terminals[token]
                                else
                                        xx_new << token
                                end
                        end
                        #puts "xx_new: #{xx_new}"
                        modified_ambiguous_part_in_rule = xx_new.join(" ")
                        puts "modified_ambiguous_part_in_rule : #{modified_ambiguous_part_in_rule}"
                        active_sentence_string = active_node_rhs.sub(modified_ambiguous_part_in_rule,sub_sentence)
                        #puts "sub_sentence: #{sub_sentence}"
                        #puts "*replace* active_sentence_string: #{active_sentence_string}"
                        current_LHS = active_node.lhs
                end
                #puts "before : active_sentence_string: #{active_sentence_string}"
                current_rhs_string = ""
                while ((active_node = route_to_root_stack.pop) != nil) do
                        previous_LHS = current_LHS
                        current_LHS = active_node.lhs
                        current_rhs_string = ""
                        @grammar.productions[active_node.lhs][active_node.rhsIndex].each do |token|
                                if token == previous_LHS
                                        current_rhs_string = current_rhs_string + active_sentence_string
                                else
                                        current_rhs_string = current_rhs_string + " " + token
                                end
                        end
                        active_sentence_string = current_rhs_string
                        #puts "p_LHS: #{previous_LHS}, c_LHS: #{current_LHS}, #{active_sentence_string}"
                end
                active_sentence_string = active_sentence_string + " "
                puts "after :  active_sentence_string: #{active_sentence_string}"
                # now replace the non-terminals in the active_sentence_string
                nt_list = []
                @grammar.productions.keys.each do |key|
                        nt_list << key if (active_sentence_string.include? " #{key} ")
                end
                puts "list of nt's: #{nt_list}"
                
                nt_list.each do |key|
                        puts "#{key} : #{@w_productions_used_count[key]}"
                        valid,sentence_nodes,productions_touched_factor = generate_sentence_tree_by_dfs(key,'FINAL',nil)
                        generate_sentence_only(sentence_nodes[0],"#{key}_sentence")
                        key_sentence_file = File.new("grammars/#{@grammar.grammar}/#{key}_sentence")
                        if ! (key_sentence_file.eof?)
                                key_sentence = key_sentence_file.readline()
                        else
                                key_sentence = ""
                        end
                        #puts "readline done...."
                        key_sentence_file.close if key_sentence_file != nil
                        active_sentence_string = active_sentence_string.gsub(" #{key} "," #{key_sentence} ")
                end
                puts "before token: #{active_sentence_string}"
                # now replace all the tokens with their values
                active_sentence_string_array = active_sentence_string.split
                active_sentence_string_array_new = []
                active_sentence_string_array.each do |token|
                        if @grammar.token_to_terminals.keys.include? token
                                active_sentence_string_array_new << @grammar.token_to_terminals[token]
                        else
                                active_sentence_string_array_new << token
                        end
                end
                active_sentence_string = active_sentence_string_array_new.join(" ")
                #puts "after token: #{active_sentence_string}"
                ambiguous_sentence = File.new("grammars/#{@grammar.grammar}/ambiguous_sentence","w")
                ambiguous_sentence.write(active_sentence_string)
                ambiguous_sentence.close if ambiguous_sentence != nil
                puts "FINAL: #{active_sentence_string}"
	end

        ##
        # for complex mode, there are two possibilites: productions_touched_hc and production_combinations
        # productions_touched_hc -- create a list of LHS (unused_lhs) that have untouched productions 
        # production_combinations -- create a list of LHS (unused_lhs) that have untouched production_combinations
        # ----
        # if (unused_lhs) is 0, then we create a list of LHS that have been used and pick one LHS.
        # otherwise, we pick an LHS from (unused_lhs) and then find a node from the sentence_nodes_table
        #  -- if for that random LHS, there are no nodes, then we use lhs_invoked_from to determine which calls this LHS.
        ###
        def get_a_random_node(sentence_nodes,sentence_nodes_table)
                puts "+++ get_a_random_node  +++"
                # iterate through the @global_productions_touched, find LHS that have parts of RHS untouched
                # for those LHS, find a random node in the sentence_nodes_table_copy, and return.
                random_node,unused_lhs,reached_root = nil,[],false
                if (@search_mode == 'simple')
                        random_node = sentence_nodes[rand(sentence_nodes.size)]
                elsif (@search_mode == 'complex')
                        ## split the logic for the two fitness functions
                        # production_combinations - should use @global_production_combinations (LHS that still has untouched combinations)
                        # productions_touched_hc - should use @global_productions_touched (LHS that still has unused RHS)
                        if @fitness_type == 'productions_touched_hc'
                                @global_productions_touched.keys.each do |lhs|
                                        _rhs = @global_productions_touched[lhs]
                                        # we should only use those LHS that are invoked in the grammar (e.g: amb3:H is not invoked at all)
                                        (unused_lhs << lhs) if ((_rhs.include? false) && (@grammar.lhs_invoked_from.keys.include? lhs))
                                end
                        elsif @fitness_type == 'production_combinations'
                                # compile a list of LHS that have untouched productions (diff between @global_production_combinations
                                # and @grammar.global_production_combinations)
                                diff_combinations = {}
#                                __count = 0
                               used_combinations = 0
                                list_of_keys = @grammar.global_production_combinations.keys
                                list_of_keys.each do |lhs|
                                        is_diff_rhs,used_combinations,diff_rhs_array,diff_rhs_indices = Utility.find_diff_combinations(@grammar,@global_production_combinations,lhs)
                                        # indicating that there is at least one rhs for which we have a difference
                                        (diff_combinations[lhs] = diff_rhs_array) if is_diff_rhs 
                                end
                               puts "used_combinations: #{used_combinations}"
                                ### For now, we only require the LHS part.
                                diff_combinations.keys.each do |lhs|
                                        unused_lhs << lhs if (@grammar.lhs_invoked_from.keys.include? lhs)
                                end
                                puts "unused_lhs: #{unused_lhs}"
                                @@xx_count += 1
                                #                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               exit if (@@xx_count == 2)
                        end
                        ## we pick a random node -- when unused_lhs == 0 or when we have a case like roor: 'l' (i.e used_combinations is 0)
                        if ((unused_lhs.size == 0) || (used_combinations == 0))
                                puts "unused_lhs is ZERO; picking a random node ..."
                                sentence_nodes_table_keys = sentence_nodes_table.keys
                                #puts "sentence_nodes_table_keys: #{sentence_nodes_table_keys}"
                                # we only want to select those LHS from sentence_nodes_table that have RHS.
                                lhs_with_rhs_in_sentence_nodes_table = []
                                sentence_nodes_table_keys.each do |_lhs|
                                        __rhs = sentence_nodes_table[_lhs]
                                        (lhs_with_rhs_in_sentence_nodes_table << _lhs) if __rhs.size > 0
                                end
                                puts "lhs_with_rhs_in_sentence_nodes_table: #{lhs_with_rhs_in_sentence_nodes_table}"
                                _random_lhs = lhs_with_rhs_in_sentence_nodes_table[rand(lhs_with_rhs_in_sentence_nodes_table.size)]
                                puts "_random_lhs: #{_random_lhs}"
                                _rhs_in_sentence_nodes_table = sentence_nodes_table[_random_lhs]
                                random_node = _rhs_in_sentence_nodes_table[rand(_rhs_in_sentence_nodes_table.size)]
                                puts "random_node: #{random_node}"
                                ## or pick a random lhs and then pick a random node
                        else
                                _found_lhs_in_table = false
                                puts "search mode: #{@search_mode}, unused_lhs[#{unused_lhs.size}]: #{unused_lhs}"
                                while (! _found_lhs_in_table) do
                                        _random_lhs = unused_lhs[rand(unused_lhs.size)]
                                        _rhs_in_sentence_nodes_table = sentence_nodes_table[_random_lhs]
                                        puts "_random_lhs: #{_random_lhs} :: size: #{_rhs_in_sentence_nodes_table.size}"
                                        if (_rhs_in_sentence_nodes_table.size > 0)
                                                # there are nodes for this LHS
                                                random_node = _rhs_in_sentence_nodes_table[rand(_rhs_in_sentence_nodes_table.size)]
                                                #puts "random_node: #{random_node}"
                                                _found_lhs_in_table = true
                                        else
                                                # when an lhs from unused_lhs is not used in the current sentence. then
                                                # we look for an LHS (in the grammar) that invokes the current LHS
                                                # A: B C | D; B : 'd', if we cant find for B, then try A[0].
                                                current_lhs = _random_lhs
                                                while (! _found_lhs_in_table) do
                                                        puts "current_lhs: #{current_lhs}"
                                                        current_lhs_invoked_from_options = @grammar.lhs_invoked_from[current_lhs] # [[A,0],[B,1]]
                                                        valid_lhss = []
                                                        invoked_from_root_only = true
                                                        current_lhs_invoked_from_options.each do |a_option|
                                                                (valid_lhss << a_option[0]) if @grammar.lhs_invoked_from.keys.include? a_option[0]
                                                                (invoked_from_root_only = false) if a_option[0] != 'root'
                                                        end
                                                        #puts "valid_lhss: #{valid_lhss}"
                                                        #puts "[invoked_from_root_only:#{invoked_from_root_only}] -- valid_lhss is EMPTY!!"
                                                        # if a LHS in invoked only from root (such as J in amb2), then valid_lhss will be empty
                                                        if ((valid_lhss.size == 0)  && invoked_from_root_only)
                                                                puts "setting LHS to ** root **"
                                                                _rhs_in_sentence_nodes_table = sentence_nodes_table['root']
                                                                random_node = _rhs_in_sentence_nodes_table[rand(_rhs_in_sentence_nodes_table.size)]
                                                                puts "random_node: #{random_node}"
                                                                _found_lhs_in_table = true
                                                                break
                                                        end
                                                        valid_lhss.each do |a_option|
                                                                #
                                                                a_option_lhs = a_option
                                                                _rhs_in_sentence_nodes_table = sentence_nodes_table[a_option_lhs]
                                                                #puts "a_option_lhs: #{a_option_lhs} :: size: #{_rhs_in_sentence_nodes_table.size}"
                                                                if (_rhs_in_sentence_nodes_table.size > 0)
                                                                        random_node = _rhs_in_sentence_nodes_table[rand(_rhs_in_sentence_nodes_table.size)]
                                                                         _found_lhs_in_table = true
                                                                         break
                                                                end
                                                        end
                                                        puts "--- #{current_lhs}: #{_found_lhs_in_table} ---"
                                                        # if we still havent found a randome node, we go up the invoked_from list
                                                        if ! _found_lhs_in_table
                                                                current_lhs = valid_lhss[rand(valid_lhss.size)]
                                                                puts "GOING UP to : #{current_lhs}" if @@debug
                                                        end
                                                        (reached_root = true;break) if current_lhs == 'root'
                                                end
                                        end
                                        break if reached_root
                                end
                        end
                end
                (puts "reached root;can't find a random node!! exiting ...";exit) if reached_root
                puts "--- get_a_random_node[#{random_node}] ---"
                return random_node
        end
                
	def hillclimb()
		puts "++ HILLCLIMB:: grammar:#{@grammar.grammar} cfactor=#{@cfactor} no_nodes_factor=#{@no_nodes_factor} ++"
		valid,ambiguous = false,false
		message,sentence,sentence_nodes,hc_iter_count,productions_touched_factor,sentence_size = "not found",nil,nil,0,0.0,0
		valid,sentence_nodes,sentence_nodes_table,productions_touched,k_consecutive_touched,production_combinations = generate_sentence_tree_by_dfs('root',nil,nil)
                ## either we do this or call fitness_function (for populating these two variables)
                @global_productions_touched = productions_touched
                @global_production_combinations = production_combinations
                prod_touched_f,k_cnt,combi_cnt = Utility.calc_production_touched_factor(@grammar,@global_productions_touched,nil,@global_production_combinations)
                puts "*** PROD TOUCHED /F=[#{prod_touched_f}],COMBINATIONS=[#{combi_cnt}] ***"
                (message = 'failed to generate a valid sentence';return [message,hc_iter_count,n/a,n/a,n/a]) if ! valid
		generate_sentence_only(sentence_nodes[0],'sentence')
		ambiguous = check_amb
		while (!ambiguous && !Utility.limit_reached(@grammar.grammar,@@starttime)) do
			# create a deep copy and work with that copy
			hc_iter_count += 1
			puts "\n** HILLCLIMB[#{hc_iter_count}] ** \n[Time taken: #{Time.now - @@starttime}]\n"
                        sentence_nodes_table_copy = Marshal.load(Marshal.dump(sentence_nodes_table))
                        sentence_nodes = generate_sentence_nodes(sentence_nodes_table_copy['root'][0])
			random_node = get_a_random_node(sentence_nodes,sentence_nodes_table_copy)
			random_node_replacement = nil
			sub_sentence,sub_sentence_nodes,sub_productions_touched,sub_k_consecutive_touched,sub_production_combinations = nil,nil,nil,nil,nil
			valid = false
                        # passing random_node's parent node and token index from parent node's RHS so that 
			while (!Utility.limit_reached(@grammar,@@starttime)) do
				valid,sub_sentence_nodes,sub_sentence_nodes_table,sub_productions_touched,sub_k_consecutive_touched,sub_production_combinations = generate_sentence_tree_by_dfs(random_node.lhs,nil,nil)
				break if valid
			end
			(next) if ! valid
			new_sentence,new_sentence_nodes,new_sentence_nodes_table,new_productions_touched,new_k_consecutive_touched,new_production_combinations = nil,nil,nil,nil,nil
			if random_node.lhs != 'root'
				# find the random node's location in its parent node
				cnt=0
                                puts "random_node: #{random_node}, its parent: #{random_node.parentNode} "
				random_node.parentNode.childNodes.each do |node|
					break if node.eql? random_node
                                        cnt = cnt + 1
                                end
                                puts "cnt: #{cnt}"
				random_node.parentNode.childNodes[cnt] = sub_sentence_nodes[0]
				sub_sentence_nodes[0].parentNode = random_node.parentNode
				random_node.parentNode = nil
				new_sentence_nodes,new_sentence_nodes_table,new_productions_touched,new_k_consecutive_touched,new_production_combinations = generate_sentence(sentence_nodes_table_copy['root'][0])
			else
				new_sentence_nodes = sub_sentence_nodes
                                new_sentence_nodes_table = sub_sentence_nodes_table
                                new_productions_touched,new_k_consecutive_touched = sub_productions_touched,sub_k_consecutive_touched
                                new_production_combinations  = sub_production_combinations
			end
			fitness = fitness_function(new_sentence_nodes,productions_touched,new_productions_touched,k_consecutive_touched,new_k_consecutive_touched,new_production_combinations,@fitness_type)
			if fitness
				#
				File.rename("grammars/#{@grammar.grammar}/new_sentence","grammars/#{@grammar.grammar}/sentence")
				sentence_nodes = new_sentence_nodes
                                sentence_nodes_table = new_sentence_nodes_table
				productions_touched = new_productions_touched
                                k_consecutive_touched = new_k_consecutive_touched
                                production_combinations = new_production_combinations
				puts "checking for ambiguity..."
				ambiguous = check_amb
			end
			prod_touched_f,k_cnt,combi_cnt = Utility.calc_production_touched_factor(@grammar,@global_productions_touched,nil,@global_production_combinations)
                        puts "***HILLCLIMB[#{hc_iter_count}], PROD TOUCHED /F=[#{prod_touched_f}],COMBINATIONS=[#{combi_cnt}/#{@grammar.global_production_combinations_count}] ***"
		end
		sentence_size = File.size("grammars/#{@grammar.grammar}/sentence") if File.exists? "grammars/#{@grammar.grammar}/sentence"
                puts "sentence size: #{sentence_size}"
		if ambiguous
			message = "yes"
                        if ((@grammar.recursive) || (sentence_size == 0)) # sometimes an empty sentence has an ambiguous parse.
                                # we just copy the file
                                puts "recursive or sentence size is zero -- renaming..."
                                File.copy_stream("grammars/#{@grammar.grammar}/sentence","grammars/#{@grammar.grammar}/ambiguous_sentence")
                        else
                                generate_ambiguous_sentence()
                        end
		end
                if File.exists? "grammars/#{@grammar.grammar}/ambiguous_sentence"
                        ambiguous_sentence_size = File.size("grammars/#{@grammar.grammar}/ambiguous_sentence")
                end
                prod_touched_f,k_cnt,combi_cnt = Utility.calc_production_touched_factor(@grammar,@global_productions_touched,nil,@global_production_combinations)
                puts "### UNTOUCHED PRODUCTIONS ###"
                @global_productions_touched.keys.each do |lhs|
                        _rhs = @global_productions_touched[lhs]
                        puts "#{lhs} : #{_rhs}" if _rhs.include? false
                end
                puts "--- UNTOUCHED PRODUCTION COMBINATIONS"
                @grammar.global_production_combinations.keys.each do |lhs|
                        rhs_array = @grammar.global_production_combinations[lhs]
                        rhs_array.each_with_index do |a_rhs,rhs_index|
                                current_rhs = @global_production_combinations[lhs][rhs_index]
                                a_rhs.each_with_index do |token,token_index|
                                        diff_token = token.sort - current_rhs[token_index].sort
                                        if diff_token.size > 0
                                                puts "#{lhs} : #{@grammar.productions[lhs][rhs_index]} : t_i=#{token_index}"
                                                puts " -- #{diff_token}"
                                        end
                                end
                        end
                end
		return [message,hc_iter_count,prod_touched_f,combi_cnt,sentence_size,ambiguous_sentence_size]
	end

end