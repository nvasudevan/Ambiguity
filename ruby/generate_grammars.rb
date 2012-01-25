#!/apps/ruby/current/bin/ruby

require 'set'

MAX_NO_GRAMMARS = 10
MAX_NO_PRODUCTIONS = 5
MAX_PRODUCTION_LENGTH = 7
#PRCT_TERMINAL_PRODUCTIONS = 0.2 # ratio of how many will be terminal-only productions
#PRCT_RULES_TERM_ONLY_PRODUCTIONS -  ratio of rules that has one or more terminal-only productions

T_NT_array = []
T_array = []
NT_set = Set.new
NT_set.add('root')
('A'..'Z').to_a.each { |alpha| T_NT_array << alpha;NT_set.add(alpha) }
('a'..'z').to_a.each { |alpha| T_NT_array << alpha;T_array << alpha }

#(1..MAX_NO_GRAMMARS).each { |i|
(3001..10000).each { |i|
	Dir::mkdir("grammars/" + i.to_s) if ! FileTest::directory?("grammars/" + i.to_s)
	filename = "grammars/" + i.to_s + "/" + i.to_s + ".spec"
#	PRCT_RULES_TERM_ONLY_PRODUCTIONS = 0.3 + (rand/10)
#	MAX_NO_OF_RULES_TERM_ONLY_PROD = (PRCT_RULES_TERM_ONLY_PRODUCTIONS * NT_set.size).ceil
#	puts "PRCT_RULES_TERM_ONLY_PRODUCTIONS: #{PRCT_RULES_TERM_ONLY_PRODUCTIONS}"
#	puts "MAX_NO_OF_RULES_TERM_ONLY_PROD: #{MAX_NO_OF_RULES_TERM_ONLY_PROD}"
	productions = {}
	total_no_of_productions, total_terminal_productions = 0,0
	lhs_with_term_only_prods = Set.new
	NT_set.to_a.each {|non_terminal|
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
	}
	puts "total: #{total_no_of_productions} , term-only prods: #{total_terminal_productions}"
	puts "LHS for term-only prods: #{lhs_with_term_only_prods.to_a}"
	##################################		
	# to add the extra terminal only productions if required	
#	extra_only_terminals_prod_needed = ((total_no_of_productions * PRCT_TERMINAL_PRODUCTIONS) - total_terminal_productions) / 
#										(1 - PRCT_TERMINAL_PRODUCTIONS)
#	count = 0
	
#	puts "MAX_NO_OF_RULES_TERM_ONLY_PROD: #{MAX_NO_OF_RULES_TERM_ONLY_PROD}"
#	# we don't want to add it to the root rule; if there are term-only prods, then leave it as it is
#	lhs_with_term_only_prods.delete('root') if lhs_with_term_only_prods.include? 'root'
#	puts "[root removed] LHS for term-only prods: #{lhs_with_term_only_prods.to_a}"
#	while (lhs_with_term_only_prods.size < MAX_NO_OF_RULES_TERM_ONLY_PROD) do
#		# we need more NT's that should be having term-only prods
#		_nt = NT_set.to_a[rand(NT_set.size)]
#		lhs_with_term_only_prods << _nt if _nt != "root"
#	end
#	puts "LHS for term-only prods: #{lhs_with_term_only_prods.to_a}"
#	puts "#{extra_only_terminals_prod_needed.ceil} terminal only productions are needed!"
	
#	while (count < extra_only_terminals_prod_needed.ceil) do
#		x_non_terminal = lhs_with_term_only_prods.to_a[rand(lhs_with_term_only_prods.size)]
#		production = ""
#		each_max_production_length = 1 + rand(MAX_PRODUCTION_LENGTH)
#		while (production.gsub('\'','').gsub(' ','').length < each_max_production_length) do
#			random_char = T_array[rand(T_array.size)]
#			production.concat('\'' + random_char + '\' ')
#		end
#		puts " -- #{x_non_terminal} : #{production}"
#		x_non_terminal_rhs_array = productions[x_non_terminal]
#		x_non_terminal_rhs_array.insert(rand(x_non_terminal_rhs_array.size),production)
#		count += 1
#	end
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
}

