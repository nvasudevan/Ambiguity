#!/apps/ruby/current/bin/ruby
require_relative 'Node'
require_relative 'StackNode'
require 'set'
require_relative 'Utility'
require_relative 'HillClimbConfig'
#require 'MemoryProfiler'

STDOUT.sync = true
QUOTE = "\'"

class Grammar
	attr_accessor :productions, :weights, :inherent_ambiguity, :ambiguous_rule

	def initialize(grammar,cfactor,no_nodes_factor,weighted_function,k_consecutive_touch)
		@grammar = grammar
		@cfactor = cfactor.to_f
		@weighted_function = weighted_function
                @k_consecutive_touch = k_consecutive_touch
		@productions = {}
		@productions_recursive = {}
		@terminal_productions_indices = {}
		@productions_count = 0
		@time_diff = 0
		@recursive = false
		@no_nodes_factor = no_nodes_factor
		@token_to_terminals = {}
		@inherent_ambiguity = false
		@ambiguous_rule = ''
                @w_productions_used_count = {}
                
		# for GPL's we have a list of tokens that we wish replace with their values in RHS
		if ( grammar == 'C' || grammar == 'Java' || grammar == 'pascal' || grammar == 'sql' || grammar == 'converge' )
			# process lex file - get the values for these tokens
			lexfile = File.open("grammars/" + grammar + "/" + grammar + ".lex").each { |line|
				#puts "lex line: #{line}"
				if line.include? "return"
				token_key = line.slice(line.index("return")+7..line.index("; ")-1) ## ** CHECK ** always use "return 'X'; }" in lex file
				token_value = line.slice(0,line.index("{ return")).strip.gsub("\"","")
				@token_to_terminals[token_key]=token_value
				puts "-+ #{token_key} : #{token_value}+-"
				end

			}
			lexfile.close
			@token_to_terminals.each { |k,v| puts "#{k}, #{v}"}

			grammarfile = File.open("grammars/" + grammar + "/" + grammar + ".spec").each do |line|
				# replace some of the parts of the line - either we don't need them or they conflict with other parts
				line = line.gsub("':'","'RHSCOLON'")
				line = line.gsub(/%prio [0-9]*/,'')
				line = line.gsub("%long ","")
				line = line.gsub("%short ","")
				if line.index(':') != nil
					lhs_rhs = line.split(':')
					lhs = lhs_rhs[0].strip
					rhs = lhs_rhs[1].strip #gsub('\'','')
					rhs = rhs.strip
					#rhs_alternatives = (rhs.strip).split('|') # e.g: ["aAb","cDE"]
                                        rhs_alternatives = rhs.split('|') # e.g: ["aAb","cDE"]
                                        (rhs_alternatives << "") if rhs.end_with? "|"
					# check for inherent_ambiguity e.g: G : G | 'a'
					rhs_alternatives.each { |_rhs|
						(@inherent_ambiguity = true;@ambiguous_rule="#{lhs} : #{_rhs}";break) if lhs == _rhs
					}
					break if @inherent_ambiguity			                                                                              
					@productions_count += rhs_alternatives.size
					rhs_alternatives_array = []  # [[a,A,b],[c,D,E]]
					rhs_alternatives.each { |a_rhs|
						a_rhs = a_rhs.gsub("'('",'OBRACKET')
						a_rhs = a_rhs.gsub("')'",'CBRACKET')
						a_rhs = a_rhs.gsub('(','')
						a_rhs = a_rhs.gsub(')*','')
						a_rhs = a_rhs.gsub(')+','')
						a_rhs = a_rhs.gsub(QUOTE,'')
						a_rhs = a_rhs.gsub('OBRACKET','(')
						a_rhs = a_rhs.gsub('CBRACKET',')')
						a_rhs = a_rhs.gsub('RHSCOLON',':')
						# modify a_rhs - replace all keys from token_to_terminals to its values.
						a_rhs_array = []
						a_rhs.split.each { |token|
							if @token_to_terminals.keys.include? token
								a_rhs_array << @token_to_terminals[token]
							else
								a_rhs_array << token
							end
						}
						rhs_alternatives_array << a_rhs_array
					}
					@productions[lhs] = rhs_alternatives_array
					puts "#{lhs} : #{rhs_alternatives_array}"
				end
                        end
			grammarfile.close if grammarfile != nil
		else
			grammarfile = File.open("grammars/" + grammar + "/" + grammar + ".spec").each { |line|
				if line.index(':') != nil
					lhs_rhs = line.split(':')
					lhs = lhs_rhs[0].strip
					rhs = lhs_rhs[1].gsub('\'','')
					rhs = rhs.gsub(' ','')
					rhs_alternatives = (rhs.strip).split('|') # e.g: ["aAb","cDE"]
					# check for inherent_ambiguity e.g: G : G | 'a'
					rhs_alternatives.each { |_rhs|
						(@inherent_ambiguity = true;@ambiguous_rule="#{lhs} : #{_rhs}";break) if lhs == _rhs
					}
					break if @inherent_ambiguity
					@productions_count += rhs_alternatives.size
					rhs_alternatives_as_chars_array = []  # [[a,A,b],[c,D,E]]
					rhs_alternatives.each { |a_rhs|
						a_rhs_array = []
						a_rhs.chars { |char| a_rhs_array << char}
						rhs_alternatives_as_chars_array << a_rhs_array
					}
					@productions[lhs] = rhs_alternatives_as_chars_array
					puts "#{lhs} : #{@productions[lhs]}"
				end
			}
			grammarfile.close if grammarfile != nil
		end
		return if @inherent_ambiguity
		## terminal indices
		nt = @productions.keys
		terminal_productions_count = 0
		nt.each { |lhs|
			rhs_array = @productions[lhs]
			terminal_indices = []
			rhs_array.each_with_index { |a_rhs,index|
				has_NT = false
				a_rhs.each { |token|
					if (nt.include? token)
						has_NT = true
						break
					end
				}
				(terminal_indices << index)	if ! has_NT
			}
			if terminal_indices.size > 0
				@terminal_productions_indices[lhs] = terminal_indices
				terminal_productions_count += terminal_indices.size
			end
		}
		if ( (1.0 * terminal_productions_count)/@productions_count < 0.1)
			@no_nodes_factor /= 0.1
		end
		@terminal_productions_indices.keys.each { |lhs|
			puts "[#{lhs} : #{@terminal_productions_indices[lhs]}]"
		}
		puts "----"
		# recursion check
		@productions_recursive = Utility.recursion_details(@productions)
		@recursive = Utility.check_recursive(@productions)
		puts "weighted_function: #{@weighted_function}"
		#exit
	end
	
	def check_amb
		# create a lock file & check ambiguity
		puts "+++ [check_amb] Time: #{Time.now}"
		lock = File.open("/logs/lock","w");lock.close # lock.write(@grammar);lock.close;
		while true do
			sleep(1)
			break if ! (File.exists?("/logs/lock"))
		end
		(puts "There was a problem parsing the sentence. exiting...";exit) if (File.exists?("grammars/#{@grammar}/error"))

		ambiguous = true if (File.exists?("grammars/#{@grammar}/ambiguous"))
		puts "--- [check_amb] Time: #{Time.now}"
		return ambiguous
	end

	def fitness_function(grammar,new_sentence_nodes,productions_touched_factor,new_productions_touched_factor,k_count,new_k_count,type)
                #puts "inside ff -- #{type}"
		_fitness = false # indicates whether the new sentence has better fitness
		if type == "length"
			generate_sentence_only(new_sentence_nodes[0],'new_sentence')
			f_new_sentence = File.size("grammars/#{grammar}/new_sentence")
			f_sentence = File.size("grammars/#{grammar}/sentence")
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
			if (new_productions_touched_factor >= productions_touched_factor)
				puts "No of productions touched in neighbour [#{new_productions_touched_factor}] >= [#{productions_touched_factor}]"
				_fitness = true
				#create the new_sentence
				generate_sentence_only(new_sentence_nodes[0],'new_sentence')
                        else
                                puts "[#{new_productions_touched_factor} < #{productions_touched_factor}] - new sentence is less fit!!"
			end
                elsif type == "consecutive_touch"
                        if new_k_count >= k_count
                                puts "K value in neighbour: [#{new_k_count} >= #{k_count}]"
                                _fitness = true
                                #create the new_sentence
                                generate_sentence_only(new_sentence_nodes[0],'new_sentence')
                        else
                                puts "[#{new_k_count} < #{k_count}] - new sentence is less fit!!"
                        end
		end
                #puts "-- ff : #{_fitness}"
		return _fitness
	end

	def print_stats(symbol,sentence_nodes,productions_used_count,w_productions_used_count)
		#puts "----"
		puts "[symbol=#{symbol}] sentence_nodes.size=[#{sentence_nodes.size}]"
		puts "nodes count ratio=[#{@no_nodes_factor * sentence_nodes.size}]"
		@productions.keys.each { |lhs|
			puts " +-- #{lhs} : #{@productions[lhs]} - REC : #{@productions_recursive[lhs]} : TOTAL = #{w_productions_used_count[lhs]} : CURRENT = #{productions_used_count[lhs]}"
		}
	end

        def process_k_logic(child_node,parent_node,k_consecutive_touched)
                # a simple block for k=1
#                 if (child_node.lhs == parent_node.lhs)
#                         if ! k_consecutive_touched.keys.include? child_node.lhs
#                                 k_consecutive_touched[child_node.lhs] = []
#                         end
#                         k_consecutive_touched[child_node.lhs] << [child_node,parent_node]
#                 end
                # while loop for k > 1
                if (child_node.lhs == parent_node.lhs)
                        current_child_node = child_node
                        current_parent_node = parent_node
                        #puts "  - [child,parent] : #{current_child_node},#{current_parent_node}"
                        k_counter = 1
                        k_matched = true
                        current_k_sequence = [current_child_node.rhsIndex,current_parent_node.rhsIndex]
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
        
	# generate sentence tree using DFS
	def generate_sentence_tree_by_dfs(symbol,type=nil)
		puts "+++ DFS #{Time.now},#{symbol},#{type} +++"
		sentence = ''
		active_nodes_stack,sentence_nodes = [],[]
		productions_touched,productions_used_count,w_productions_used_count = {},{},{}
                # for k = 1
                k_consecutive_touched = {} # [lhs]=>[[node1,node3],[node2,node7]]
		# initialise weights and productions_touched
		@productions.keys.each { |lhs|
			rhs = @productions[lhs]
			productions_touched_rhs = [] if symbol == 'root'
			productions_used_count_rhs,w_productions_used_count_rhs = [],[]
			rhs.each {|a_rhs|
				productions_touched_rhs << false if symbol == 'root'
				productions_used_count_rhs << 0
				w_productions_used_count_rhs << 0
			}
			productions_touched[lhs] = productions_touched_rhs if symbol == 'root'
			productions_used_count[lhs] = productions_used_count_rhs
			w_productions_used_count[lhs] = w_productions_used_count_rhs
		}
                # a hack - for generating the final ambiguous sentence
                (w_productions_used_count = @w_productions_used_count;puts "** FINAL ** : #{w_productions_used_count[symbol]}") if (type == 'FINAL')
		rhs = @productions[symbol]
		if @weighted_function == 'ratio'
                        if type == 'FINAL'
                                rhs_index = Utility.weighted_random_production_current_to_total_ratio_2(symbol,@productions_recursive[symbol],@terminal_productions_indices[symbol],productions_used_count[symbol],w_productions_used_count[symbol],0.0,@cfactor)
                        else
                                rhs_index = Utility.weighted_random_production_current_to_total_ratio(symbol,@productions_recursive[symbol],@terminal_productions_indices[symbol],productions_used_count[symbol],w_productions_used_count[symbol],0.0,@cfactor)
                        end
			
		elsif @weighted_function == 'prod_count'
			rhs_index = Utility.weighted_random_production_prod_count(@terminal_productions_indices[symbol],productions_used_count[symbol],w_productions_used_count[symbol],0.0,@cfactor)
		end
		rhs_selected = rhs[rhs_index]
		node = Node.new(symbol,rhs_selected,rhs_index)
                puts " **check node: #{node}"
		sentence_nodes << node
		productions_touched[symbol][rhs_index] = true if symbol == 'root'
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
				(valid = false;break) if Utility.limit_reached(@grammar,@@starttime)
				(puts "** BREAK ** #{HillClimbConfig::MAX_DEPTH} reached";return false) if (stack_node.depth == HillClimbConfig::MAX_DEPTH)
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
					if @productions.has_key?(char)
						has_NT = true
						rhs = @productions[char]
						begin
							#rhs_index = Utility.weighted_random_production_current_to_total_ratio(@terminal_productions_indices[char],productions_used_count[char],w_productions_used_count[char],sentence_nodes.size * @no_nodes_factor,@cfactor)
							if @weighted_function == 'ratio'
                                                                if type == 'FINAL'
                                                                        rhs_index = Utility.weighted_random_production_current_to_total_ratio_2(char,@productions_recursive[char],@terminal_productions_indices[char],productions_used_count[char],w_productions_used_count[char],sentence_nodes.size * @no_nodes_factor,@cfactor)
                                                                else
                                                                        rhs_index = Utility.weighted_random_production_current_to_total_ratio(char,@productions_recursive[char],@terminal_productions_indices[char],productions_used_count[char],w_productions_used_count[char],sentence_nodes.size * @no_nodes_factor,@cfactor)
                                                                end
							elsif @weighted_function == 'prod_count'
								rhs_index = Utility.weighted_random_production_prod_count(@terminal_productions_indices[char],productions_used_count[char],w_productions_used_count[char],0.0,@cfactor)
							end
							rhs_selected = rhs[rhs_index]
							#puts "lhs:rhs - #{char} : #{rhs_selected}"
							child_node = Node.new(char,rhs_selected,rhs_index)
							active_node.childNodes << child_node
							child_node.parentNode = active_node
							stack_node.index = stack_node.index + 1
							active_nodes_stack.push(stack_node)
							active_nodes_stack.push(StackNode.new(child_node,0,stack_node.depth+1))
							sentence_nodes << child_node
							productions_touched[child_node.lhs][rhs_index] = true if symbol == 'root'
							productions_used_count[char][rhs_index] += 1
							w_productions_used_count[char][rhs_index] += 1
                                                        # for k = 1
                                                        process_k_logic(child_node,active_node,k_consecutive_touched)
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
                
		print_stats(symbol,sentence_nodes,productions_used_count,w_productions_used_count)
		productions_touched_factor = 0.0
                k_consecutive_touched_count = 0
                # return early when generating final ambiguous sentence
                (return [valid,sentence_nodes,productions_touched_factor,k_consecutive_touched_count]) if (type == 'FINAL')
		if symbol == 'root'
			productions_touched_count=0
			productions_touched.keys.each { |lhs|
				productions_touched_rhs = productions_touched[lhs]
				puts "prod used count : lhs: #{lhs}, rhs: #{@productions[lhs]} , #{productions_used_count[lhs]}" if ! valid
				productions_touched_rhs.each { |a_rhs| productions_touched_count += 1 if a_rhs  }
			}
			productions_touched_factor = (productions_touched_count * 1.0) / @productions_count
                        # we save the w_productions_used_count values so we can use it later for generate_ambiguous_sentence method!
                        @w_productions_used_count = w_productions_used_count

                        # K part
                        k_consecutive_touched.keys.each do |_key|
                                puts "-- #{_key}:#{k_consecutive_touched[_key].size} --"
                                #k_consecutive_touched[_key].each { |_val| puts "   :: #{_val}"}
                                k_consecutive_touched_count += k_consecutive_touched[_key].size
                        end
		end

		puts "--- DFS #{Time.now} ---"
		#valid ? [valid,sentence_nodes,productions_touched_factor] : [valid,nil,nil]
		return [valid,sentence_nodes,productions_touched_factor,k_consecutive_touched_count]
	end

	def generate_sentence(root_node)
		#puts "+++ generate_sentence #{Time.now} +++"
		sentence_nodes,active_nodes_stack = [],[]
		productions_touched,k_consecutive_touched = {},{} # k_consecutive_touched -- NT -> ??
		# initialise productions_touched
		@productions.keys.each { |lhs|
			rhs = @productions[lhs]
			productions_touched_rhs = []
			rhs.each {|a_rhs| productions_touched_rhs << false }
			productions_touched[lhs] = productions_touched_rhs
		}
		active_nodes_stack.push([root_node,0])
		sentence_nodes << root_node
		while ((active_node,index=active_nodes_stack.pop) != nil) do
			#active_node.rhs[index,active_node.rhs.size].chars.each { |char|
			active_node.rhs[index,active_node.rhs.size].each do |token|
				if @productions.has_key?(token)
					child_node = active_node.childNodes[index]
                                        # for K part
#                                         if child_node.lhs == active_node.lhs
#                                                 # any production for a NT
#                                                 if ! k_consecutive_touched.keys.include? child_node.lhs
#                                                         # create a dummy array
#                                                         k_consecutive_touched[child_node.lhs] = []
#                                                 end
#                                                 k_consecutive_touched[child_node.lhs] << [active_node,child_node]
#                                         end
                                        process_k_logic(child_node,active_node,k_consecutive_touched)
					#puts "pushing: #{active_node} , index: #{index+1}"
					active_nodes_stack.push([active_node,index+1]) if (index+1) < active_node.rhs.length
					#puts "pushing: #{child_node} , index: 0"
					active_nodes_stack.push([child_node,0])
					sentence_nodes << child_node
					productions_touched[child_node.lhs][child_node.rhsIndex] = true
					#puts "-- prod touched: #{productions_touched.to_a}"
					break
				end
				index=index+1
                        end
		end
		productions_touched_factor,productions_touched_count = 0.0,0
		productions_touched.keys.each { |lhs|
			productions_touched_rhs = productions_touched[lhs]
			productions_touched_rhs.each { |a_rhs| productions_touched_count += 1 if a_rhs  }
		}
		productions_touched_factor = (productions_touched_count * 1.0) / @productions_count
                # K part
                k_consecutive_touched_count = 0
                k_consecutive_touched.keys.each do |_key|
                        puts "-- #{_key}:#{k_consecutive_touched[_key].size} --"
                        #k_consecutive_touched[_key].each { |_val| puts "   :: #{_val}"}
                        k_consecutive_touched_count += k_consecutive_touched[_key].size
                end
                puts "consecutive_touch_count: #{k_consecutive_touched_count}"
		#puts "--- generate_sentence #{Time.now} ---"
		return sentence_nodes,productions_touched_factor,k_consecutive_touched_count
	end

	def generate_sentence_only(root_node,sentence_filename)
		active_nodes_stack = []
		active_nodes_stack.push([root_node,0])
		puts "+++ [generate_sentence_only] Time: #{Time.now}"
		sentence_file = File.open("grammars/#{@grammar}/#{sentence_filename}","w")
		while ((active_node,index=active_nodes_stack.pop) != nil) do
			active_node.rhs[index,active_node.rhs.size].each { |token|
				if @productions.has_key?(token)
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
		puts "grammars/#{@grammar}/#{sentence_filename} written."
		sentence_file.close
		puts "--- [generate_sentence_only] Time: #{Time.now}"
	end

	def generate_ambiguous_sentence()
                ambiguity_type,ambiguous_non_terminal,ambiguous_part_in_rule,rhsIndex = Utility.retrieve_parse_tree_info(@grammar,@token_to_terminals,@productions)
                route_to_root_stack = Utility.give_route_to_root_stack(ambiguous_non_terminal,rhsIndex,@productions)
                puts "route_to_root_stack: #{route_to_root_stack}"
                ambiguous_sub_sentence_size = File.size("grammars/#{@grammar}/ambiguous_sub_sentence")
                if ambiguous_sub_sentence_size == 0
                        puts "** ambiguous_sub_sentence_size == 0 **"
                        sub_sentence = ""
                else
                        sub_sentence_file = File.open("grammars/#{@grammar}/ambiguous_sub_sentence")
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
                        active_node_rhs = @productions[active_node.lhs][active_node.rhsIndex].join(" ")
                        puts "active_node_rhs: #{active_node_rhs}"
                        #modify the ambiguous_part_in_rule to use the lex tokens
                        xx_new,modified_ambiguous_part_in_rule = [],""
                        ambiguous_part_in_rule.split.each do |token|
                                #puts " -- token : #{token}"
                                if @token_to_terminals.keys.include? token
                                        #puts " --- match "
                                        xx_new << @token_to_terminals[token]
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
                        @productions[active_node.lhs][active_node.rhsIndex].each do |token|
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
                @productions.keys.each do |key|
                        nt_list << key if (active_sentence_string.include? " #{key} ")
                end
                puts "list of nt's: #{nt_list}"
                
                nt_list.each do |key|
                        puts "#{key} : #{@w_productions_used_count[key]}"
                        valid,sentence_nodes,productions_touched_factor = generate_sentence_tree_by_dfs(key,'FINAL')
                        generate_sentence_only(sentence_nodes[0],"#{key}_sentence")
                        key_sentence_file = File.new("grammars/#{@grammar}/#{key}_sentence")
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
                        if @token_to_terminals.keys.include? token
                                active_sentence_string_array_new << @token_to_terminals[token]
                        else
                                active_sentence_string_array_new << token
                        end
                end
                active_sentence_string = active_sentence_string_array_new.join(" ")
                #puts "after token: #{active_sentence_string}"
                ambiguous_sentence = File.new("grammars/#{@grammar}/ambiguous_sentence","w")
                ambiguous_sentence.write(active_sentence_string)
                ambiguous_sentence.close if ambiguous_sentence != nil
                puts "FINAL: #{active_sentence_string}"
	end
	
	def hillclimb(fitness_type,terminate_by)
		puts "++ HILLCLIMB:: grammar:#{@grammar} cfactor=#{@cfactor} no_nodes_factor=#{@no_nodes_factor} ++"
		valid,ambiguous = false,false
		message,sentence,sentence_nodes,hc_iter_count,productions_touched_factor,sentence_size = "not found",nil,nil,0,0.0,0
		valid,sentence_nodes,productions_touched_factor,k_consecutive_touched_count = generate_sentence_tree_by_dfs('root')
		(message = 'failed to generate a valid sentence';return [message,hc_iter_count,productions_touched_factor,sentence_size]) if ! valid
		generate_sentence_only(sentence_nodes[0],'sentence')
		ambiguous = check_amb
		while (!ambiguous && !Utility.limit_reached(@grammar,@@starttime)) do
			#(puts "Exceeded memory limit of 2GB. exiting...";exit) if limit_reached
			# create a deep copy and work with that copy
			hc_iter_count += 1
			puts "\n** HILLCLIMB[#{hc_iter_count}] ** \n[Time taken: #{Time.now - @@starttime}]\n"
			sentence_nodes_copy = Marshal.load(Marshal.dump(sentence_nodes))
			random_node = sentence_nodes_copy[rand(sentence_nodes_copy.size)]
			random_node_replacement = nil
			sub_sentence,sub_sentence_nodes = nil,nil
			valid = false
			while (!Utility.limit_reached(@grammar,@@starttime)) do
				valid,sub_sentence_nodes,sub_productions_touched_factor,sub_k_consecutive_touched_count = generate_sentence_tree_by_dfs(random_node.lhs)
				break if valid
			end
			#puts "before next in hillclimb: #{valid}"
			(next) if ! valid
			new_sentence,new_sentence_nodes,new_productions_touched_factor,new_k_consecutive_touched_count = nil,nil,nil,0
			if random_node.lhs != 'root'
				# find the random node's location in its parent node
				cnt=0
				random_node.parentNode.childNodes.each { |node|
					break if node.eql? random_node; cnt = cnt + 1
				}
				random_node.parentNode.childNodes[cnt] = sub_sentence_nodes[0]
				sub_sentence_nodes[0].parentNode = random_node.parentNode
				random_node.parentNode = nil
				new_sentence_nodes,new_productions_touched_factor,new_k_consecutive_touched_count = generate_sentence(sentence_nodes_copy[0])
			else
				new_sentence_nodes,new_productions_touched_factor,new_k_consecutive_touched_count = sub_sentence_nodes,sub_productions_touched_factor,sub_k_consecutive_touched_count
			end
			puts "+--- sentence nodes size=[#{sentence_nodes.size}] ---+"
			# create new_sentence file
			#generate_sentence_only(new_sentence_nodes[0],'new_sentence')
			fitness = fitness_function(@grammar,new_sentence_nodes,productions_touched_factor,new_productions_touched_factor,k_consecutive_touched_count,new_k_consecutive_touched_count,fitness_type)
			if fitness
				#
				File.rename("grammars/#{@grammar}/new_sentence","grammars/#{@grammar}/sentence")
				sentence_nodes = new_sentence_nodes
				productions_touched_factor = new_productions_touched_factor
                                k_consecutive_touched_count = new_k_consecutive_touched_count
				puts "checking for ambiguity..."
				ambiguous = check_amb
# 			else
# 				puts "new sentence has less fitness!"
			end
			
		end
		sentence_size = File.size("grammars/#{@grammar}/sentence") if File.exists? "grammars/#{@grammar}/sentence"
                puts "sentence size: #{sentence_size}"
		if ambiguous
			message = "yes"
                        if ((@recursive) || (sentence_size == 0)) # sometimes an empty sentence has an ambiguous parse.
                                # we just copy the file
                                puts "recursive or sentence size is zero -- renaming..."
                                File.copy_stream("grammars/#{@grammar}/sentence","grammars/#{@grammar}/ambiguous_sentence")
                        else
                                generate_ambiguous_sentence()
                        end
		end
                ambiguous_sentence_size = File.size("grammars/#{@grammar}/ambiguous_sentence") if File.exists? "grammars/#{@grammar}/ambiguous_sentence"
		return [message,hc_iter_count,productions_touched_factor,sentence_size,ambiguous_sentence_size]
	end

end

grammar_file = ARGV[0]

########## CONFIG ###########
cfactor = HillClimbConfig::CFACTOR # ARGV[1]
no_nodes_factor = HillClimbConfig::NO_NODES_FACTOR.to_f # ARGV[2].to_f #0.00001
weighted_function = HillClimbConfig::WEIGHTED_FUNCTION # "ratio" # options: ratio, prod_count
fitness_type = HillClimbConfig::FITNESS_TYPE # "productions_touched"
terminate_by = HillClimbConfig::TERMINATE_BY
k_consecutive_touch = HillClimbConfig::K_CONSECUTIVE_TOUCH
########## CONFIG ###########

puts "===\ncfactor=[#{cfactor}]\nno_nodes_factor=[#{no_nodes_factor}]\nweighted_function=[#{weighted_function}]\nfitness_type=[#{fitness_type}]\nk_consecutive_touch=[#{k_consecutive_touch}]\n==="

@@starttime = Time.now
message,hc_iter_count,productions_touched_factor,sentence_size,ambiguous_sentence_size,sub_sentence_details = "",0,0.0,0,0,",,"

# delete files -- sentence and ambiguous -- before hill climbing
File.delete("grammars/#{grammar_file}/new_sentence") if File.exists?("grammars/#{grammar_file}/new_sentence")
File.delete("grammars/#{grammar_file}/sentence") if File.exists?("grammars/#{grammar_file}/sentence")
File.delete("grammars/#{grammar_file}/ambiguous_sentence") if File.exists?("grammars/#{grammar_file}/ambiguous_sentence")
File.delete("grammars/#{grammar_file}/ambiguous") if File.exists?("grammars/#{grammar_file}/ambiguous")
File.delete("grammars/#{grammar_file}/error") if File.exists?("grammars/#{grammar_file}/error")
File.delete("grammars/#{grammar_file}/memlimit") if File.exists?("grammars/#{grammar_file}/memlimit")
File.delete("grammars/#{grammar_file}/sub_sentence_details") if File.exists?("grammars/#{grammar_file}/sub_sentence_details")

grammar = Grammar.new(grammar_file,cfactor,no_nodes_factor,weighted_function,k_consecutive_touch)
if grammar.inherent_ambiguity
	message = "#{grammar.ambiguous_rule} - inherently ambiguous!"
else
	logs_grammar_file = File.open("/logs/grammar_file","w"); logs_grammar_file.write(grammar_file);logs_grammar_file.close
	while (!Utility.limit_reached(grammar_file,@@starttime)) do # 60, 600
		begin
			puts "G=#{grammar_file} cfactor=#{cfactor} no_nodes_factor=#{no_nodes_factor} weighted_fn=#{weighted_function} fitness=#{fitness_type}"
			message,hc_iter_count,productions_touched_factor,sentence_size,ambiguous_sentence_size = grammar.hillclimb(fitness_type,terminate_by)
		rescue Exception => e
			puts "exception::: #{e.message}"
			e.backtrace
			exit
		end
		break if File.exists?("grammars/#{grammar_file}/ambiguous")
	end
	if File.exists? "grammars/#{grammar_file}/sub_sentence_details"
		sub_sentence_file = (File.open("grammars/#{grammar_file}/sub_sentence_details","r").each { |line| sub_sentence_details = line })
		sub_sentence_file.close
	end
end

puts "header:: grammar,message,time taken,productions touched factor,iteration count,sentence size,ambiguous sentence size,sub sentence size,parse1 -rules used,parse2"
puts "message:: #{grammar_file},#{message},#{(Time.now - @@starttime).round(4)},#{(productions_touched_factor).round(4)},#{hc_iter_count},#{sentence_size},#{ambiguous_sentence_size},#{sub_sentence_details}"
