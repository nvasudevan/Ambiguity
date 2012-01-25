#!/apps/ruby/current/bin/ruby
require_relative 'Node'
require_relative 'StackNode'
require 'set'
#require 'MemoryProfiler'

STDOUT.sync = true
QUOTE = "\'"

class Grammar
	attr_accessor :productions, :weights

	def initialize(grammar,cfactor,no_nodes_factor)
		@grammar = grammar
		@cfactor = cfactor.to_f
		@productions = {}
		@terminal_productions_indices = {}
		@productions_count = 0
		@time_diff = 0
		@recursive = false
		@no_nodes_factor = no_nodes_factor
		@token_list = ""
		@token_to_terminals = {}
		
		# obtain the list of tokens - later we replace these tokens with their values
		grammarfile = File.open("grammars/" + grammar + "/" + grammar + ".spec").each { |line|
			if line.start_with? "%token"
				puts line
				@token_list = line.gsub("%token","").gsub(" ","").split(",");
		                puts "token_list: #{@token_list}"                                                              
			end
 			
		}
		grammarfile.close
		#puts "token_list: #{@token_list}"
		
		# process lex file - get the values for these tokens
		lexfile = File.open("grammars/" + grammar + "/" + grammar + ".lex").each { |line|
			#puts "lex line: #{line}"
			if line.include? "return"
		               token_key = line.slice(line.index("return")+7..line.index(";")-1)
		               token_value = line.slice(0,line.index("{ return")).strip.gsub("\"","")
		               @token_to_terminals[token_key]=token_value                                                          
		               puts "-+ #{token_key} : #{token_value}+-"
		        end
		                                                                          
		}
		lexfile.close
		@token_to_terminals.each { |k,v| puts "#{k}, #{v}"}
		
		grammarfile = File.open("grammars/" + grammar + "/" + grammar + ".spec").each { |line|
			# replace some of the parts of the line - either we don't need them or they conflict with other parts
			line = line.gsub("':'","'RHSCOLON'")
		        line = line.gsub(/%prio [0-9]*/,'')
		        line = line.gsub("%long ","")
		        line = line.gsub("%short ","")
			if line.index(':') != nil
				lhs_rhs = line.split(':')
				lhs = lhs_rhs[0].strip
				rhs = lhs_rhs[1].strip #gsub('\'','')
				#rhs = rhs.gsub(' ','')
				rhs_alternatives = (rhs.strip).split('|') # e.g: ["aAb","cDE"]
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
		                                        if token == "INT"
								a_rhs_array << "1"
		                                         elsif token == "ID"
								a_rhs_array << "abcd"
# 		                                         elsif token == "aString"
# 								a_rhs_array << "\"aString\""
		                                         else
								puts "match found: #{token} : #{@token_to_terminals[token]}"
								a_rhs_array << @token_to_terminals[token]
		                                         end
						else
							a_rhs_array << token
						end
					}
                                        rhs_alternatives_array << a_rhs_array
				}
				@productions[lhs] = rhs_alternatives_array
				puts "#{lhs} : #{rhs_alternatives_array}"
			end
		}
		grammarfile.close
		#exit
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
	end
	
	def check_recursive
		productions_reduced = Marshal.load(Marshal.dump(@productions))
		# remove all terminals
		nt_set = productions_reduced.keys
		productions_reduced.keys.each { |lhs|
			rhs_array = productions_reduced[lhs]
			rhs_array.each { |a_rhs|
				#puts "++a_rhs: #{a_rhs}"
				terminals = []
				a_rhs.each { |token|
					#puts "token: #{token}" 
					(terminals << token) if ! (nt_set.include? token)
				}
				#puts "terminals: #{terminals}"
				terminals.each { |term| a_rhs.delete(term)} 
				#puts "-- #{lhs} : #{a_rhs}"
			}
		}
		factor = 1.0
		count = 0
		while (factor > 0.1) do
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
				rhs_array.each { |a_rhs|
					a_rhs.delete(lhs_to_reduce)			
				}		
			}		
		end
		
		(@recursive = true) if productions_reduced.size > 0
		puts "#{@grammar} : #{@recursive} : #{productions_reduced}"
		return @recursive
	end
	
	def check_amb
		# create a lock file & check ambiguity
		puts "+++ [check_amb] Time: #{Time.now}"
		lock = File.open("/logs/lock","w");lock.write(@grammar);lock.close;
		while true do 
			sleep(1)		
			break if ! (File.exists?("/logs/lock"))
		end
		(puts "There was a problem parsing the sentence. exiting...";exit) if (File.exists?("grammars/#{@grammar}/error"))
		ambiguous = true if (File.exists?("grammars/#{@grammar}/ambiguous"))
		puts "--- [check_amb] Time: #{Time.now}"
		return ambiguous	
	end
	
	def get_cfactor
		return @cfactor # return 0.99 if @recursive
	end

	def weighted_random_production_prod_count(char,productions_used_count,w_productions_used_count,nodes_count)
		depth_no_nodes = []
		depth_no_nodes << 1.0
		nodes_count_weight = (nodes_count * @no_nodes_factor)
		depth_no_nodes << nodes_count_weight
		_index = weighted_random_production(depth_no_nodes)
		if _index == 0
			__cnt = 0
			weighted_rhs = [] 
			productions_used_count.each {|count| 
				#(__cnt=count;puts "++ [#{char}]=#{productions_used_count}, #{get_cfactor ** count}") if (count >= 322)
				weight = get_cfactor ** count #1.0/(count+1)
				weighted_rhs << weight
				#puts "-- [#{char}]=#{productions_used_count}, #{weighted_rhs}" if (count >= 322)
			}
			yy = weighted_random_production(weighted_rhs)
			#puts "after yy: #{yy}" if (__cnt >= 322)
			return yy	
		else
			# return a random index of a terminal
			terminal_indices = @terminal_productions_indices[char]
			if terminal_indices != nil
				terminal_indices_values = []
				terminal_indices.size.times {|value| terminal_indices_values << 1.0 }
				return terminal_indices[weighted_random_production(terminal_indices_values)]
			else
				return_index = weighted_random_production(w_productions_used_count,true)
				#puts "_index=[#{_index}] [#{w_productions_used_count}] return=[#{return_index}]"
				return return_index
			end		
						
		end
	end
	
	#def weighted_random_production(productions_used_count,n_count)
	def weighted_random_production(weighted_rhs, to_terminate=false)
		if to_terminate
			return weighted_rhs.find_index(weighted_rhs.max)
		end
	
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
		#puts "_xxx=#{_xxx}, _rand=#{_rand}, rnd=#{rnd}" if (_xxx >=322)
		_weighted_rhs.each_with_index { |weight,index|
			rnd -= weight
			#puts "  rnd=#{rnd}" if (_xxx >= 322)
			return index if rnd <= 0
		}
	end

	def print_stats(symbol,sentence_nodes,productions_used_count,w_productions_used_count)
		#puts "----"
		puts "[symbol=#{symbol}] sentence_nodes.size=[#{sentence_nodes.size}]"
		puts "nodes count ratio=[#{@no_nodes_factor * sentence_nodes.size}]"
		@productions.keys.each { |lhs| 
			puts " +-- #{lhs} : #{@productions[lhs]} - TOTAL = #{w_productions_used_count[lhs]} : CURRENT = #{productions_used_count[lhs]}"
		}
		#puts "GC report: "
		#GC::Profiler.report
		#puts "GC total time: #{GC::Profiler.total_time}"		
		#puts ":: TOTAL: #{ObjectSpace.count_objects[:TOTAL]}, FREE: #{ObjectSpace.count_objects[:FREE]},OBJECT: #{ObjectSpace.count_objects[:T_OBJECT]},ARRAY: #{ObjectSpace.count_objects[:T_ARRAY]}"
		#puts "----"
	end
	# generate sentence tree using DFS
	def generate_sentence_tree_by_dfs(symbol)
		puts "+++ DFS #{Time.now} +++"
		sentence = ''
		active_nodes_stack,sentence_nodes = [],[]
		productions_touched,productions_used_count,w_productions_used_count = {},{},{}
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
		rhs = @productions[symbol]
		rhs_index = weighted_random_production_prod_count(symbol,productions_used_count[symbol],w_productions_used_count[symbol],0)
		rhs_selected = rhs[rhs_index]
		node = Node.new(symbol,rhs_selected,rhs_index)		
		sentence_nodes << node
		productions_touched[symbol][rhs_index] = true if symbol == 'root'
		productions_used_count[symbol][rhs_index] += 1
		w_productions_used_count[symbol][rhs_index] += 1 
		active_nodes_stack.push(StackNode.new(node,0,0)) # node, index, depth		
		valid = true
		sentence_starttime = Time.now
		count,depth = 0,0
		#puts "enabled GC profiler.."
		#GC::Profiler.enable
		begin
## CHANGED
			while ((stack_node = active_nodes_stack.pop) != nil) do
				active_node = stack_node.activeNode
				has_NT = false
				has_NT = true if (stack_node.index > 0)
				(valid = false;puts "TIME EXCEEDED! (> #{@@max_duration} mins)";break) if (((Time.now - @@starttime)/60).to_i > @@max_duration)
				(valid = false;puts "** BREAK ** depth=[#{stack_node.depth}] count=[#{count}]";break) if (stack_node.depth == 4000) 
				(productions_used_count[active_node.lhs][active_node.rhsIndex] -= 1;next) if stack_node.index == active_node.rhs.length
				if ((count > 0) && (count % 500000 == 0))
					puts "count:[#{count}] depth: #{stack_node.depth}"
					print_stats(symbol,sentence_nodes,productions_used_count,w_productions_used_count)
				end
				active_node_rhs_index = 0
				found = false
				active_node.rhs.each { |char|

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
							rhs_index = weighted_random_production_prod_count(char,productions_used_count[char],w_productions_used_count[char],sentence_nodes.size)
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
				}
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
		if symbol == 'root'
			productions_touched_count=0
			productions_touched.keys.each { |lhs| 
				productions_touched_rhs = productions_touched[lhs]
				puts "prod used count : lhs: #{lhs}, rhs: #{@productions[lhs]} , #{productions_used_count[lhs]}" if ! valid
				productions_touched_rhs.each { |a_rhs| productions_touched_count += 1 if a_rhs  }
			}
			productions_touched_factor = (productions_touched_count * 1.0) / @productions_count
		end
		
		puts "--- DFS #{Time.now} ---"
		valid ? [valid,sentence_nodes,productions_touched_factor] : [valid,nil,nil]
	end
	
	def generate_sentence(root_node)
		#puts "+++ generate_sentence #{Time.now} +++"
		sentence_nodes,active_nodes_stack = [],[]
		productions_touched = {} 
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
			active_node.rhs[index,active_node.rhs.size].each { |token|
				if @productions.has_key?(token)
					child_node = active_node.childNodes[index]
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
			}		
		end
		productions_touched_factor,productions_touched_count = 0.0,0
		productions_touched.keys.each { |lhs| 
			productions_touched_rhs = productions_touched[lhs]
			productions_touched_rhs.each { |a_rhs| productions_touched_count += 1 if a_rhs  }
		}
		productions_touched_factor = (productions_touched_count * 1.0) / @productions_count
		#puts "--- generate_sentence #{Time.now} ---"
		return sentence_nodes,productions_touched_factor
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
	
	# hillclimb - run for 10 hours - for terminating grammars
	# sub sentence generation - 10 hours (max) + try 3 times - for non-terminating grammars
	def hillclimb
		puts "++ HILLCLIMB:: grammar:#{@grammar} cfactor=#{@cfactor} no_nodes_factor=#{@no_nodes_factor} ++"
		valid,ambiguous = false,false
		sentence,sentence_nodes,productions_touched_factor = nil,nil,0.0
		# depth
		valid,sentence_nodes,productions_touched_factor = generate_sentence_tree_by_dfs('root')
		return 'failed to generate a valid sentence' if ! valid
		generate_sentence_only(sentence_nodes[0],'sentence')
		ambiguous = check_amb
		hc_starttime = Time.now
		hc_iter_count = 0		
		while (!ambiguous && ((Time.now - @@starttime)/60).to_i < @@max_duration) do
			# create a deep copy and work with that copy
			puts "\n** HILLCLIMB[#{hc_iter_count}] ** \n\n"
			sentence_nodes_copy = Marshal.load(Marshal.dump(sentence_nodes))
			random_node = sentence_nodes_copy[rand(sentence_nodes_copy.size)]
			random_node_replacement = nil
			sub_sentence,sub_sentence_nodes = nil,nil
			while (((Time.now - @@starttime)/60).to_i < @@max_duration) do
				valid,sub_sentence_nodes,sub_productions_touched_factor = generate_sentence_tree_by_dfs(random_node.lhs)
				break if valid
			end
			(next) if ! valid
			new_sentence,new_sentence_nodes,new_productions_touched_factor = nil,nil,nil
			if random_node.lhs != 'root'
				# find the random node's location in its parent node
				cnt=0
				random_node.parentNode.childNodes.each { |node| 
					break if node.eql? random_node; cnt = cnt + 1				
				}
				random_node.parentNode.childNodes[cnt] = sub_sentence_nodes[0]
				sub_sentence_nodes[0].parentNode = random_node.parentNode
				random_node.parentNode = nil
				new_sentence_nodes,new_productions_touched_factor = generate_sentence(sentence_nodes_copy[0])
			else
				new_sentence_nodes,new_productions_touched_factor = sub_sentence_nodes,sub_productions_touched_factor
			end
			# create new_sentence file
			generate_sentence_only(new_sentence_nodes[0],'new_sentence')
			f_new_sentence = File.size("grammars/#{@grammar}/new_sentence")
			f_sentence = File.size("grammars/#{@grammar}/sentence")
			puts "+--- sentence nodes size=[#{sentence_nodes.size}] ---+"
			if (f_new_sentence > f_sentence)
				puts "length: new sentence ([#{f_new_sentence}]) > sentence ([#{f_sentence}])"
				File.rename("grammars/#{@grammar}/new_sentence","grammars/#{@grammar}/sentence")
				sentence_nodes = new_sentence_nodes
				productions_touched_factor = new_productions_touched_factor
				puts "checking for ambiguity..."
				ambiguous = check_amb
			elsif (f_new_sentence == f_sentence)
				puts "length: new_sentence ([#{f_new_sentence}]) == sentence ([#{f_sentence}])" 
				if (new_productions_touched_factor >= productions_touched_factor)
					puts "No of productions touched in neighbour >="
					File.rename("grammars/#{@grammar}/new_sentence","grammars/#{@grammar}/sentence")
					sentence_nodes = new_sentence_nodes
					productions_touched_factor = new_productions_touched_factor
					puts "checking for ambiguity..."
					ambiguous = check_amb
				end
			else
				puts "No of nodes in new sentence is less!!"
			end
			hc_iter_count += 1
		end
		ambiguous ? "ambiguous sentence found!" : "could not find an ambiguous sentence in #{@@max_duration}"
	end

end

grammar_file = ARGV[0]
cfactor = ARGV[1]
no_nodes_factor = ARGV[2].to_f #0.00001

grammar = Grammar.new(grammar_file,cfactor,no_nodes_factor)
#(puts "grammar is non-terminating; exiting.";exit) if grammar.check_recursive

@@max_duration = 60 # minutes
# delete files -- sentence and ambiguous -- before hill climbing
File.delete("grammars/#{grammar_file}/new_sentence") if File.exists?("grammars/#{grammar_file}/new_sentence")
File.delete("grammars/#{grammar_file}/sentence") if File.exists?("grammars/#{grammar_file}/sentence")
File.delete("grammars/#{grammar_file}/ambiguous") if File.exists?("grammars/#{grammar_file}/ambiguous")
File.delete("grammars/#{grammar_file}/error") if File.exists?("grammars/#{grammar_file}/error")
@@starttime = Time.now

# total duration - 1 hour
# hill climb duration - 30 mins
# sentence generate duration - 15 mins
while (((Time.now - @@starttime)/60).to_i < @@max_duration) do # 60, 600
	begin 
		puts "grammar=#{grammar_file} cfactor=#{cfactor} no_nodes_factor=#{no_nodes_factor}"
		message = grammar.hillclimb()
	rescue Exception => e
		puts "exception::: #{e.message}"
		exit
	end
	#break
	puts "message: #{message}"
	(puts "ambiguous sentence generated in #{Time.now - @@starttime} seconds";break) if File.exists?("grammars/#{grammar_file}/ambiguous")
end
