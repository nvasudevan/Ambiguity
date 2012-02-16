#!/apps/ruby/current/bin/ruby

class Utility

	def self.limit_reached(grammar,starttime)
		if HillClimbConfig::TERMINATE_BY == 'memory'
			return true if (File.exists?("grammars/#{grammar}/memlimit"))
		end
		return true if (((Time.now - starttime)/60).to_i > HillClimbConfig::MAX_TIME.to_i)
	end

	def self.recursion_details(productions)
		productions_recursive = {}
		total_prods,recursive_prods=0,0
		productions.keys.each { |lhs|
			rhs_array = productions[lhs]
			rhs_array_recursive=[]
			rhs_array.each { |rhs_array_alternative|
				if rhs_array_alternative.index(lhs) != nil
					rhs_array_recursive << 'X'
					recursive_prods += 1
				else
					rhs_array_recursive << ''
				end
				total_prods += 1
			}
			productions_recursive[lhs] = rhs_array_recursive
			#puts "#{lhs} : #{productions_recursive[lhs]}"
		}
		#puts "[total_prods: #{total_prods}, recursive_prods: #{recursive_prods}]"
		return productions_recursive
	end

        # v2 of check_recursive
        # 1) 
        def self.route_to_terminals_and_invoked_from(productions)
                productions_reduced = Marshal.load(Marshal.dump(productions))
                recursive=false
                # remove all terminals
                nt_set = productions_reduced.keys
                productions_reduced.keys.each { |lhs|
                        rhs_array = productions_reduced[lhs]
                        rhs_array.each { |a_rhs|
                                terminals = []
                                a_rhs.each { |token|
                                        (terminals << token) if ! (nt_set.include? token)
                                }
                                terminals.each { |term| a_rhs.delete(term)}
                        }
                }
                puts "------------++++++--------------"
                productions_reduced.keys.each { |_key| puts "#{_key} : #{productions_reduced[_key]}" }
                puts "----- PRODUCTION COMBINATIONS -------"
                production_combinations = {}
                if (productions_reduced.size > 0)
                        productions_reduced.keys.each do |lhs|
                                rhs_array = productions_reduced[lhs]
                                combination_rhs_array = []
                                rhs_array.each do |a_rhs|
                                        combination_a_rhs = []
                                        a_rhs.each do |token|
                                                rhs_for_token = productions_reduced[token]
                                                rhs_for_token.size.times do |ind|
                                                        combination_a_rhs << [token,ind]
                                                end
                                        end
                                        combination_rhs_array << combination_a_rhs
                                end
                                production_combinations[lhs] = combination_rhs_array
                        end
                end
                count = 0
                production_combinations.keys.each do |lhs|
                        __rhs = production_combinations[lhs]
                        puts "#{lhs} :: #{__rhs}"
                        __rhs.each do |a_rhs|
                                count += a_rhs.size
                        end
                end
                puts "TOTAL COMBINATIONS: #{count}"
                puts "----- INVOKED FROM -------"
                # A: 'b' B | 'c'  C --> A: B | | C
                lhs_route_terminals,lhs_invoked_from = {},{}
                # build lhs_invoked_from
                if (productions_reduced.size > 0)
                        productions_reduced.keys.each do |lhs|
                                rhs_array = productions_reduced[lhs]
                                rhs_array.each_with_index do |a_rhs,index|
                                        a_rhs.each do |token|
                                                if productions_reduced.keys.include? token
                                                        if (lhs_invoked_from.keys.include? token)
                                                                lhs_invoked_from[token] << [lhs,index]
                                                                #puts "(if)lhs_invoked_from: #{lhs_invoked_from[token]}"
                                                        else
                                                                lhs_invoked_from[token] = []
                                                                lhs_invoked_from[token] << [lhs,index]
                                                                #puts "(else)lhs_invoked_from: #{lhs_invoked_from[token]}"
                                                        end
                                                else
                                                        # we should never be here. this means after deleting all terminals, there are
                                                        # tokens that are not NT's
                                                end                                                
                                        end
                                end
                        end
                        #lhs_invoked_from.keys.each { |_key| puts "#{_key} : #{lhs_invoked_from[_key]}" }
                else
                        puts "Grammar contains only terminals!!"
                end
                #puts "------"        
                productions_reduced.keys.each do |_lhs|
                        _rhs_array = productions_reduced[_lhs]
                        a_rhs_terminals_only = []
                        _rhs_array.each_with_index do |a_rhs,index|
                                (a_rhs_terminals_only << index) if (a_rhs.size == 0)
                        end
                        (lhs_route_terminals[_lhs] = a_rhs_terminals_only) if a_rhs_terminals_only.size > 0
                end
                lhs_route_terminals.keys.each { |_lhs| productions_reduced.delete(_lhs) }
                #productions_reduced.keys.each { |_key| puts "#{_key} : #{productions_reduced[_key]}" }
                #puts "----"
                #p lhs_route_terminals
                if lhs_route_terminals.size == 0
                        # we should exit ideally as we can't reduce the productions at all.
                        recursive=true;
                else
                        # build lhs_route_terminals
                        while (productions_reduced.size > 0)
                                #puts "** while loop **"
                                to_delete = false
                                lhs_route_terminals_keys = lhs_route_terminals.keys
                                productions_reduced.keys.each do |lhs|
                                        rhs_array = productions_reduced[lhs]
                                        rhs_array.each_with_index do |a_rhs,index|
                                                tokens_to_delete = []
                                                a_rhs.each do |token|
                                                        tokens_to_delete << token if lhs_route_terminals_keys.include? token
                                                end
                                                tokens_to_delete.each do |_token|
                                                        a_rhs.delete(_token)
                                                end
                                        end
                                end
                                #productions_reduced.keys.each { |_key| puts "#{_key} : #{productions_reduced[_key]}" }
                                productions_reduced.keys.each do |lhs|
                                        rhs_array = productions_reduced[lhs]
                                        a_rhs_terminals_only = []
                                        rhs_array.each_with_index do |a_rhs,index|
                                                (a_rhs_terminals_only << index;to_delete = true) if (a_rhs.size == 0)
                                        end
                                        (lhs_route_terminals[lhs] = a_rhs_terminals_only) if a_rhs_terminals_only.size > 0
                                end
                                (puts "no production to reduce! exiting...";recursive=true;break) if ! to_delete
                                lhs_route_terminals.keys.each { |_lhs| productions_reduced.delete(_lhs) }
                                #productions_reduced.keys.each { |_key| puts "#{_key} : #{productions_reduced[_key]}" }
                        end
                        #puts "--- ROUTE TO TERMINALS ---"
                        #lhs_route_terminals.each { |key| puts "#{key} -- #{lhs_route_terminals[key]}" }
                        #puts "----"
                end
                return recursive,lhs_route_terminals,lhs_invoked_from,production_combinations
        end
        
	def self.check_recursive(productions)
		productions_reduced = Marshal.load(Marshal.dump(productions))
		recursive=false
		# remove all terminals
		nt_set = productions_reduced.keys
		productions_reduced.keys.each { |lhs|
			rhs_array = productions_reduced[lhs]
			rhs_array.each { |a_rhs|
				terminals = []
				a_rhs.each { |token| (terminals << token) if ! (nt_set.include? token) }
				terminals.each { |term| a_rhs.delete(term)}
			}
		}
		factor = 1.0
		count = 0
		while (factor > 0.01) do
			lhs_to_reduce = ""
			productions_reduced.keys.each { |lhs|
				#puts "#{lhs} : #{productions_reduced[lhs]}"
				rhs_array = productions_reduced[lhs]
				terminal_rhs = []
				rhs_array.each { |a_rhs|
					has_NT = false
					a_rhs.each { |token|
						if productions_reduced.keys.include? token
							has_NT = true
							break
						end
					}
					(terminal_rhs << a_rhs) if ! has_NT
				}
				if (((terminal_rhs.size * 1.0)/rhs_array.size) >= factor)
					lhs_to_reduce = lhs
					#puts "FOUND:: [#{lhs_to_reduce} : #{terminal_rhs}]"
					break
				end
			}
			if (lhs_to_reduce == "")
				count += 1
				factor /= count
				#puts "== factor: #{factor} ==\n\n"
				next
			end

			productions_reduced.delete(lhs_to_reduce)
			productions_reduced.keys.each { |lhs|
				rhs_array = productions_reduced[lhs]
				rhs_array.each { |a_rhs| a_rhs.delete(lhs_to_reduce) }
			}
		end
		(recursive = true;puts "recursive: #{recursive} [#{productions_reduced}]";) if productions_reduced.size > 0
		return recursive
	end

        def self.retrieve_parse_tree_info(grammar)
                token_to_terminals,productions = grammar.token_to_terminals,grammar.productions
                ambiguity_type,ambiguous_non_terminal,line_no,column_no,end_line_no,end_column_no = "","",0,0,0,0

                parse_tree_file = File.open("grammars/#{grammar.grammar}/parse_tree.head","r").each do |line|
                        if (line.start_with?("Two different"))
                                ambiguity_type = "disjunctive"
                                ambiguous_non_terminal = line.split[2].gsub("`","").gsub("'","")
                        elsif (line.start_with?("There are two different parses"))
                                ambiguity_type = "conjuctive"
                        end
                        if (ambiguity_type == "conjuctive")
                                if (line.start_with?("for the beginning of"))
                                        ambiguous_non_terminal = line.split[4].gsub("`","").gsub("'","").gsub(",","")
                                        line_no = line.split[8].gsub(",","")
                                        column_no = line.split[10]
                                end
                                if (line.start_with?("upto and containing"))
                                        end_line_no = line.split[6].gsub(",","")
                                        end_column_no = line.split[8]
                                end
                        end
                        if ((ambiguity_type == "disjunctive") && (line.start_with?("#{ambiguous_non_terminal} alternative at line ")))
                                line_no = line.split[4].gsub(",","")
                                column_no = line.split[6]
                        end
                end
                parse_tree_file.close if parse_tree_file != nil
                puts "type:#{ambiguity_type}, NT: #{ambiguous_non_terminal}, line,col=[#{line_no},#{column_no} - #{end_line_no},#{end_column_no}]"

                # open the grammar file and obtain the line at line_no to create the leaf node
                line_index = 0
                rhsIndex = nil
                ambiguous_part_in_rule = ""

                grammarfile = File.open("grammars/" + grammar.grammar + "/" + grammar.grammar + ".spec").each do |line|
                        line_index += 1
                        puts "[#{line_index}] : #{line}"
                        if (line_index == line_no.to_i)
                                #puts "** matches 1 **"
                                if (ambiguity_type == "conjuctive")
                                        # we change the above value to determine the exact index of end of the current token
                                        column_no = line.rindex(" ", ((column_no.to_i-1) - (line.size-1))-1)
                                        column_no += 1 # don't want the whitespace in the front
                                        #
                                        end_column_no = end_column_no.to_i-1
                                        end_column_no = line.index(" ",end_column_no)
                                        if end_column_no == nil
                                                end_column_no = line.size-1
                                        end
                                        ambiguous_part_in_rule = (line[column_no.to_i..end_column_no.to_i-1]).strip
                                        ambiguous_part_in_rule = ambiguous_part_in_rule.gsub('\'','')
                                        puts "ambiguous_part_in_rule:++#{ambiguous_part_in_rule}++"
                                elsif (ambiguity_type == "disjunctive")
                                        #column_no = column_no.to_i-1
                                        column_no = line.rindex(" ", ((column_no.to_i-1) - (line.size-1))-1)
                                        column_no += 1 # don't want the whitespace in the front
                                end

                                if (line.split[0] == ambiguous_non_terminal)
                                        alternative,next_pipe = nil,line.index("|",column_no.to_i)  #-1)
                                        puts "** matches 2 [#{next_pipe}]**"
                                        if next_pipe == nil
                                                # last alternative
                                                alternative = line[column_no.to_i..-1].gsub("'","").split
                                                puts "*nil* alternative: #{alternative}"
                                        else
                                                #find the next | symbol
                                                alternative = line[column_no.to_i-1..next_pipe-1].gsub("'","").split
                                                puts "[#{column_no.to_i-1},#{next_pipe-1}] alternative: #{alternative}"
                                        end
                                        # modify the part that are lex tokens
                                        modified_alternative = []
                                        alternative.each do |token|
                                                if token_to_terminals.keys.include? token
                                                        modified_alternative << token_to_terminals[token]
                                                else
                                                        modified_alternative << token
                                                end
                                        end
                                        puts "modified_alternative: #{modified_alternative}"
                                        rhs = productions[ambiguous_non_terminal]
                                        puts "rhs: #{rhs}"
                                        rhs.each_with_index do |_rhs,_index|
                                                puts "#{_index} -> #{_rhs}"
                                                (rhsIndex = _index;break) if _rhs == modified_alternative # alternative
                                        end
                                end
                        end
                        break if rhsIndex != nil
                end
                grammarfile.close if grammarfile != nil
                return ambiguity_type,ambiguous_non_terminal,ambiguous_part_in_rule,rhsIndex 
        end

        def self.give_route_to_root_stack(ambiguous_non_terminal,rhsIndex,productions)
                ambiguous_node = Node.new(ambiguous_non_terminal,"",rhsIndex) #e.g:  [G,"",1]
                puts "ambiguous_node: #{ambiguous_node.lhs}, #{ambiguous_node.rhsIndex}"
                #(puts "in 'root' node!!";return) if ambiguous_node.lhs == 'root'
                active_nodes_stack,unique_LHS_stack,root_found = [],[],false
                active_nodes_stack.push(ambiguous_node)
                # so we also maintain a stack of what rules have been used. We do this so that we don't add a already traversed alternatives.
                (unique_LHS_stack << [ambiguous_node.lhs,ambiguous_node.rhsIndex]) if ! unique_LHS_stack.include? [ambiguous_node.lhs,ambiguous_node.rhsIndex]
                if (ambiguous_node.lhs != 'root')
                        # now find the path from ambiguous_non_terminal to "root"
                        while ((active_node = active_nodes_stack.shift) != nil) do
                                puts "active_node: #{active_node} , #{active_node.rhsIndex}"
                                productions.each do |lhs,rhs|
                                        #puts " -- #{lhs} , #{rhs}"
                                        rhs.each_with_index do |_rhs_alternative,_index|
                                                #puts "   + #{_rhs_alternative} == #{active_node.lhs}"
                                                if _rhs_alternative.include? (active_node.lhs)
                                                        # so we only add those nodes which haven't been traversed already
                                                        if (! unique_LHS_stack.include? [lhs,_index])
                                                                #
                                                                unique_LHS_stack << [lhs,_index]
                                                                # create a new node and then add it as a child node
                                                                child_node = Node.new(lhs,"",_index)
                                                                active_node.childNodes << child_node
                                                                child_node.parentNode = active_node
                                                                active_nodes_stack.push(child_node)
                                                                #puts " + child_node: #{child_node}"
                                                                # if the lhs is 'root' then we stop (as we found a path to 'root')
                                                                (root_found = true;puts "** root found!! **";break) if lhs == 'root'
                                                        end
                                                        #puts "unique_LHS_stack: #{unique_LHS_stack}"
                                                end
                                        end
                                        break if root_found
                                end
                                break if root_found
                                #break if active_nodes_stack.size > 100
                        end
                end
                puts "unique_LHS_stack: #{unique_LHS_stack}"
                route_to_root_stack = []
                current_node = active_nodes_stack.pop # root node
                route_to_root_stack.push(current_node)
                while (current_node.parentNode != nil)
                        puts "[#{current_node.lhs},#{current_node.rhsIndex} :: #{productions[current_node.lhs][current_node.rhsIndex]}]"
                        current_node = current_node.parentNode
                        route_to_root_stack.push(current_node)
                end
                return route_to_root_stack
        end
        
	def self.weighted_random_production(weighted_rhs, current_count=nil, to_terminate=false)
		_weighted_rhs = weighted_rhs
		sum_weights = 0
		_weighted_rhs.each { |value| sum_weights += value }

		# when values in weighted_rhs is 0 (w_productions_used_count can 0 values for an lhs)
		if (sum_weights == 0)
			new_weighted_rhs = []
			_weighted_rhs.size.times { |value| new_weighted_rhs << 1.0;sum_weights += 1.0 }
			_weighted_rhs = new_weighted_rhs
		end

		_rand = rand()
		rnd = _rand * sum_weights
		_weighted_rhs.each_with_index { |weight,index|
			rnd -= weight
			return index if rnd <= 0
		}
	end

        def self.weighted_random_production_prod_count(symbol,grammar,productions_used_count,w_productions_used_count,nodes_count_weight,cfactor)
                terminal_productions_indices = grammar.terminal_productions_indices[symbol]
                depth_no_nodes = []
                depth_no_nodes << 1.0
                #nodes_count_weight = (nodes_count * no_nodes_factor)
                depth_no_nodes << nodes_count_weight
                _index = weighted_random_production(depth_no_nodes)
                if _index == 0
                        __cnt = 0
                        weighted_rhs = []
                        productions_used_count.each {|count|
                                weight = cfactor ** count
                                weighted_rhs << weight
                        }
                        return weighted_random_production(weighted_rhs)
                else
                        # return a random index of a terminal
                        #terminal_indices = @terminal_productions_indices[char]
                        if terminal_productions_indices != nil
                                terminal_indices_values = []
                                terminal_productions_indices.size.times {|value| terminal_indices_values << 1.0 }
                                return terminal_productions_indices[weighted_random_production(terminal_indices_values)]
                        else
				return w_productions_used_count.find_index(w_productions_used_count.max)
                        end
                end
        end

	def self.weighted_random_production_current_to_total_ratio(active_node,symbol,fitness_type,grammar,production_combinations,productions_touched,productions_used_count,w_productions_used_count,nodes_count_weight,cfactor)
                productions = grammar.productions
                productions_recursive = grammar.productions_recursive[symbol]
                terminal_productions_indices = grammar.terminal_productions_indices[symbol]
		depth_no_nodes = []
		depth_no_nodes << 1.0
		depth_no_nodes << nodes_count_weight
		_index = weighted_random_production(depth_no_nodes)
		if _index == 0
                        __index = nil
                        if (fitness_type == 'production_combinations')
                                #puts "** production_combinations **"
                                if active_node != nil
                                        # find the difference between production_combinations and the one in @grammar (contains all the combinations)
                                        current_rhs = production_combinations[active_node.lhs][active_node.rhsIndex]  # ["B", 0], ["C", 2], ["A", 1]]
                                        global_rhs = grammar.global_production_combinations[active_node.lhs][active_node.rhsIndex]  # [[B,0]]
                                        diff_array = current_rhs.sort - global_rhs.sort   # diff [["A", 1], ["C", 2]]
                                        matched_entries = []
                                        diff_array.each do |a_diff|
                                                (matched_entries << a_diff) if a_diff[0] == symbol
                                        end
                                        if matched_entries.size > 0
                                                a_entry = matched_entries[rand(matched_entries.size)]
                                                __index = a_entry[1]
#                                                 if active_node.lhs == 'simple_expr'
#                                                         puts " -- #{active_node.lhs}:#{active_node.rhsIndex} --"
#                                                         puts "current_rhs: #{current_rhs.sort}"
#                                                         puts "global_rhs : #{global_rhs.sort}"
#                                                         puts "diff_array[#{active_node.rhsIndex}]: #{diff_array} *#{__index}*"
#                                                 end
                                                return __index
                                        end
                                end
                                # if there is a difference then we know that th
                                ## given a symbol, we look for 
                        elsif (fitness_type == 'productions_touched_hc')
                                # we now change this algorithm
                                # - we first try to find a unused production. if all have been used, then use weighted_random_production
                                # - otherwise, pick a random one from the usused list
                                ##puts " index == 0, #{char}, #{productions_touched[char]}"
                                _rhs = productions_touched[symbol]
                                unused_rhs = []
                                _rhs.each_with_index { |val,ind| (unused_rhs << ind) if val == false }
                                if unused_rhs.size > 0
                                        # some rhs parts are still unused
                                        unused_rhs_val = []
                                        unused_rhs.size.times { |v| unused_rhs_val << 1.0 }
                                        __index = unused_rhs[weighted_random_production(unused_rhs_val)]
                                        #puts "unused_rhs > 0, #{symbol}:#{productions[symbol]}, _rhs: #{_rhs}, unused_rhs: #{unused_rhs}, x1=#{x1}"
                                        return __index
                                end
                        end
                        ## if we are still nil, then we resort to a random one.
                        if __index == nil
                                # all parts have been used,then we resort to our original alogrighm: that is select one of them
                                #### ORIGINAL ####
                                #puts "** weighted_random_production **" if ((active_node != nil) && (active_node.lhs == 'simple_expr'))
                                __cnt = 0
                                weighted_rhs = []
                                productions_used_count.each {|count|
                                        weight = cfactor ** count #1.0/(count+1)
                                        weighted_rhs << weight
                                }
                                return weighted_random_production(weighted_rhs)
                                ##################
                        end
		else
                        # return a random index of a terminal
                        #terminal_indices = @terminal_productions_indices[char]
                        if terminal_productions_indices != nil
                                #puts "** terminal indices **"
                                terminal_indices_values = []
                                terminal_productions_indices.size.times {|value| terminal_indices_values << 1.0 }
                                return terminal_productions_indices[weighted_random_production(terminal_indices_values)]
			else
                                #puts "** terminal indices -- ELSE -- **"
				ratio_current_to_total = []
				productions_used_count.each_with_index { |value,index|
					#hack to add '1' to the current value so that when we have a case like this:
					# current=[0,0], total=[10,100], we have ratio=[1/11,1/101], rather than [0,0]
					#ratio_val = (w_productions_used_count[index] == 0) ? 0 : (value * 1.0)/w_productions_used_count[index]
					# to handle recursions
					if productions_recursive[index] == 'X'
						#then we insert a very high value so that this index is never selected
				                ratio_current_to_total << 100000                       
					else
						ratio_val = (w_productions_used_count[index] == 0) ? 0 : ((value+1) * 1.0)/(w_productions_used_count[index]+1)
						ratio_current_to_total << (ratio_val).round(6)
					end
				}
				## MODIFY to send a random one from the list rather than the first one
				min_value_indices = []
				min_value = ratio_current_to_total.min #ratio_current_to_total.find_index(ratio_current_to_total.min)
				#puts "min: #{min_value}, #{ratio_current_to_total}"
				ratio_current_to_total.each_with_index { |value,index|
					min_value_indices << index if (value == min_value)
				}
				# if size of min_value_indices is 1, then return the index, otherwise use the weighted_random_production
				if min_value_indices.size == 1
					#puts "0, ratio_current_to_total: #{ratio_current_to_total}" if ratio_current_to_total.max == 100000 
					return min_value_indices[0]
				else
					min_value_indices_values = []
					min_value_indices.size.times {|value| min_value_indices_values << 1.0 }
					#puts "min_value_indices_values: #{min_value_indices_values}"
					min_value_index = min_value_indices[weighted_random_production(min_value_indices_values)]
					puts "#{symbol}, #{min_value_index}, ratio_current_to_total: #{ratio_current_to_total}" if ratio_current_to_total.max == 100000
					return min_value_index
				end
			end
		end
	end

        def self.weighted_random_production_current_to_total_ratio_2(symbol,productions_recursive,terminal_productions_indices,productions_used_count,w_productions_used_count,nodes_count_weight,cfactor)

                if terminal_productions_indices != nil
                        terminal_indices_values = []
                        terminal_productions_indices.size.times {|value| terminal_indices_values << 1.0 }
                        return terminal_productions_indices[weighted_random_production(terminal_indices_values)]
                else
                        ratio_current_to_total = []
                        productions_used_count.each_with_index { |value,index|
                                #hack to add '1' to the current value so that when we have a case like this:
                                # current=[0,0], total=[10,100], we have ratio=[1/11,1/101], rather than [0,0]
                                #ratio_val = (w_productions_used_count[index] == 0) ? 0 : (value * 1.0)/w_productions_used_count[index]
                                # to handle recursions
                                if productions_recursive[index] == 'X'
                                        #then we insert a very high value so that this index is never selected
                                        ratio_current_to_total << 100000
                                else
                                        ratio_val = (w_productions_used_count[index] == 0) ? 0 : ((value+1) * 1.0)/(w_productions_used_count[index]+1)
                                        ratio_current_to_total << (ratio_val).round(6)
                                end
                        }
                        ## MODIFY to send a random one from the list rather than the first one
                        min_value_indices = []
                        min_value = ratio_current_to_total.min #ratio_current_to_total.find_index(ratio_current_to_total.min)
                        #puts "min: #{min_value}, #{ratio_current_to_total}"
                        ratio_current_to_total.each_with_index { |value,index|
                                min_value_indices << index if (value == min_value)
                        }
                        # if size of min_value_indices is 1, then return the index, otherwise use the weighted_random_production
                        if min_value_indices.size == 1
                                #puts "0, ratio_current_to_total: #{ratio_current_to_total}" if ratio_current_to_total.max == 100000
                                return min_value_indices[0]
                        else
                                min_value_indices_values = []
                                min_value_indices.size.times {|value| min_value_indices_values << 1.0 }
                                #puts "min_value_indices_values: #{min_value_indices_values}"
                                min_value_index = min_value_indices[weighted_random_production(min_value_indices_values)]
                                puts "#{symbol}, #{min_value_index}, ratio_current_to_total: #{ratio_current_to_total}" if ratio_current_to_total.max == 100000
                                return min_value_index
                        end
                end
        end
end