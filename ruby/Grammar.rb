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
	attr_accessor :grammar,:productions,:productions_recursive,:terminal_productions_indices,:terminal_productions_count,:productions_count,:lhs_route_terminals,:recursive,:lhs_invoked_from,:global_production_combinations,:global_production_combinations_count,:token_to_terminals,:inherent_ambiguity,:ambiguous_rule
        
	def initialize(grammar)
		@grammar = grammar
		@productions = {}
		@productions_recursive = {}
		@terminal_productions_indices = {}
                @terminal_productions_count = 0
		@productions_count = 0
		@recursive = false
                @lhs_route_terminals = {}
                @lhs_invoked_from = {}
                @global_production_combinations = {}
                @global_production_combinations_count = 0
		@token_to_terminals = {}
		@inherent_ambiguity = false
		@ambiguous_rule = ''
                
		# for GPL's we have a list of tokens that we wish replace with their values in RHS
		if ( grammar == 'C' || grammar == 'Java' || grammar == 'pascal' || grammar == 'sql' || grammar == 'converge' )
			# process lex file - get the values for these tokens
			lexfile = File.open("grammars/" + grammar + "/" + grammar + ".lex").each { |line|
				#puts "lex line: #{line}"
				if line.include? "return"
				token_key = line.slice(line.index("return")+7..line.index("; ")-1) ## ** CHECK ** always use "return 'X'; }" in lex file
				token_value = line.slice(0,line.index("{ return")).strip.gsub("\"","")
				@token_to_terminals[token_key]=token_value
				#puts "-+ #{token_key} : #{token_value}+-"
				end

			}
			lexfile.close
			#@token_to_terminals.each { |k,v| puts "#{k}, #{v}"}

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
					#puts "#{lhs} : #{rhs_alternatives_array}"
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
					#puts "#{lhs} : #{@productions[lhs]}"
				end
			}
			grammarfile.close if grammarfile != nil
		end
		return if @inherent_ambiguity
		## terminal indices
		nt = @productions.keys
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
				@terminal_productions_count += terminal_indices.size
			end
		}
		# recursion check
		@productions_recursive = Utility.recursion_details(@productions)
                @recursive,@lhs_route_terminals,@lhs_invoked_from,@global_production_combinations = Utility.route_to_terminals_and_invoked_from(@productions)
                x,y,@global_production_combinations_count = Utility.calc_production_touched_factor(@grammar,nil,nil,@global_production_combinations)
                puts "TOTAL COMBINATIONS: #{@global_production_combinations_count}"
	end

        def print_grammar_details()
                puts "========= GRAMMAR DETAILS =========\n"
                puts "grammar=[#{@grammar}]"
                puts "recursive=#{@recursive}"
                puts "inherent_ambiguity=#{@inherent_ambiguity}"
                puts "ambiguous_rule: #{@ambiguous_rule}"
                puts "\n### TERMINAL INDICES ###\n"
                @terminal_productions_indices.keys.each { |lhs| puts "[#{lhs} : #{@terminal_productions_indices[lhs]}]" }
                puts "\n### ROUTE TO TERMINALS FOR LHS ###\n"
                @lhs_route_terminals.each { |key| puts "#{key} -- #{lhs_route_terminals[key]}" }
                puts "\n### LHS INVOKED FROM ###\n"
                @lhs_invoked_from.keys.each { |_key| puts "#{_key} : #{lhs_invoked_from[_key]}" }
                puts "\n===================================\n"
        end
end