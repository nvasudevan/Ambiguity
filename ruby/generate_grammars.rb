#!/apps/ruby/current/bin/ruby

require 'set'

MAX_NO_GRAMMARS = 1
MAX_NO_PRODUCTIONS = 5
MAX_PRODUCTION_LENGTH = 7
MIN_PRCT_EMPTY_LHS = 0.1
MAX_PRCT_EMPTY_LHS = 0.2
#PRCT_TERMINAL_PRODUCTIONS = 0.2 # ratio of how many will be terminal-only productions
#PRCT_RULES_TERM_ONLY_PRODUCTIONS -  ratio of rules that has one or more terminal-only productions

T_NT_array = []
T_array = []
NT_set = Set.new
NT_set.add('root')
('A'..'Z').to_a.each { |alpha| T_NT_array << alpha;NT_set.add(alpha) }
('a'..'z').to_a.each { |alpha| T_NT_array << alpha;T_array << alpha }

# We also want empty alternatives, 
MIN_EMPTY = (NT_set.size * MIN_PRCT_EMPTY_LHS).ceil
MAX_EMPTY = (NT_set.size * MAX_PRCT_EMPTY_LHS).ceil
EMPTY_LHS = MIN_EMPTY + rand(MAX_EMPTY-MIN_EMPTY)
puts "MIN_EMPTY: #{MIN_EMPTY}, MAX_EMPTY: #{MAX_EMPTY} -- #{EMPTY_LHS.ceil}"

#(1..MAX_NO_GRAMMARS).each { |i|
(201..202).each do |i|
	Dir::mkdir("grammars/" + i.to_s) if ! FileTest::directory?("grammars/" + i.to_s)
	filename = "grammars/" + i.to_s + "/" + i.to_s + ".spec"
	productions = {}
	total_no_of_productions, total_terminal_productions = 0,0
	lhs_with_term_only_prods = Set.new
	NT_set.to_a.each do |non_terminal|
		rhs_array = []
		rule_no_of_productions = 0
		rule_max_no_productions = 1 + rand(MAX_NO_PRODUCTIONS)
		while (rule_no_of_productions < rule_max_no_productions) do
			production = ""
			each_max_production_length = 1 + rand(MAX_PRODUCTION_LENGTH)
			any_NT = false
			while (production.gsub('\'','').gsub(' ','').length < each_max_production_length) do
				random_char = T_NT_array[rand(T_NT_array.size)]
				if (NT_set.include? random_char)
					any_NT = true
					production.concat(random_char + ' ')
				else
					production.concat('\'' + random_char + '\' ')
				end
			end
			(total_terminal_productions += 1;lhs_with_term_only_prods << non_terminal) if !any_NT
			rhs_array << production
			rule_no_of_productions += 1
		end
		total_no_of_productions += rule_no_of_productions
		productions[non_terminal] = rhs_array
        end
	puts "total: #{total_no_of_productions} , term-only prods: #{total_terminal_productions}"
	puts "LHS for term-only prods: #{lhs_with_term_only_prods.to_a}"

        # now randomly select LHS and introduce an empty alternative at the end
        __count = 0
        NT_array = NT_set.to_a
        NT_array.delete('root')
        empty_lhss = []
        while (__count < EMPTY_LHS)
                while true
                        lhs_index = rand(NT_array.size)
                        lhs = NT_array[lhs_index]
                        break if (! empty_lhss.include? lhs)
                end
                productions[lhs] << ""
                empty_lhss << lhs
                __count += 1
                puts "---"
        end
        
	##################################
	# create the grammar spec file
	grammarfile = File.open(filename,"w")
	grammarfile.puts("%nodefault\n\n")	
	productions.keys.each { |non_terminal|
		rhs = ''
		rhs_array = productions[non_terminal]
		rhs_array.each { |x| rhs += x + ' | ' }
		puts "lhs: #{non_terminal} , rhs: #{rhs[0,rhs.size-3]}"
		grammarfile.puts(non_terminal + ' : ' + rhs[0,rhs.size-3] + "\n;")
	}
	puts "grammar " + filename + " - done \n\n"
	grammarfile.close
end

