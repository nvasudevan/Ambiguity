#!/apps/ruby/current/bin/ruby
require_relative 'Grammar'
require_relative 'HillClimb'
require_relative 'Node'
require_relative 'StackNode'
require 'set'
require_relative 'Utility'
require_relative 'HillClimbConfig'
#require 'MemoryProfiler'

grammar_file = ARGV[0]

########## CONFIG ###########
cfactor = HillClimbConfig::CFACTOR # ARGV[1]
no_nodes_factor = HillClimbConfig::NO_NODES_FACTOR.to_f # ARGV[2].to_f #0.00001
weighted_function = HillClimbConfig::WEIGHTED_FUNCTION # "ratio" # options: ratio, prod_count
fitness_type = HillClimbConfig::FITNESS_TYPE # "productions_touched"
terminate_by = HillClimbConfig::TERMINATE_BY
k_consecutive_touch = HillClimbConfig::K_CONSECUTIVE_TOUCH
search_mode = HillClimbConfig::SEARCH_MODE
@@debug = HillClimbConfig::DEBUG
########## CONFIG ###########

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

grammar = Grammar.new(grammar_file)
grammar.print_grammar_details()
puts "------------**--------------- "
hillClimb = HillClimb.new(grammar,cfactor,no_nodes_factor,weighted_function,k_consecutive_touch,search_mode,fitness_type)
hillClimb.print_hc_details
if grammar.inherent_ambiguity
	message = "#{grammar.ambiguous_rule} - inherently ambiguous!"
else
	logs_grammar_file = File.open("/logs/grammar_file","w"); logs_grammar_file.write(grammar_file);logs_grammar_file.close
	while (!Utility.limit_reached(grammar_file,@@starttime)) do # 60, 600
		begin
			puts "G=#{grammar_file} cfactor=#{cfactor} no_nodes_factor=#{no_nodes_factor} weighted_fn=#{weighted_function} fitness=#{fitness_type}"
			message,hc_iter_count,productions_touched_factor,combi_cnt,sentence_size,ambiguous_sentence_size = hillClimb.hillclimb()
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

puts "header:: grammar,message,time taken,productions touched factor,combinations_count,iteration count,sentence size,ambiguous sentence size,sub sentence size,parse1 -rules used,parse2"
puts "message:: #{grammar_file},#{message},#{(Time.now - @@starttime).round(4)},#{(productions_touched_factor).round(4)},#{combi_cnt}[#{grammar.global_production_combinations_count}],#{hc_iter_count},#{sentence_size},#{ambiguous_sentence_size},#{sub_sentence_details}"
