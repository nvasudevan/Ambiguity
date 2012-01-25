#!/apps/ruby/current/bin/ruby

require 'set'

NT = Set.new
T = Set.new

#GRAMMAR = "GPL_grammar/#{ARGV[0]}/#{ARGV[0]}_grammar"
GRAMMAR = "grammars/#{ARGV[0]}/#{ARGV[0]}.spec"
puts "GRAMMAR: #{GRAMMAR}"
#if ARGV[0] == "converge"
#	SEPARATOR = "::="
#else
#	SEPARATOR = ":"
#end 
SEPARATOR = ":"
grammar = File.open(GRAMMAR).each { |line|
	#puts "line: #{line}"
	if line.index(SEPARATOR) != nil
		lhs_rhs = line.split(SEPARATOR)
		NT << lhs_rhs[0].strip
		#puts "NT: #{lhs_rhs[0].strip}"
	end
}

grammar.close
t_count,nt_count,t_only_count,total_prod = 0,0,0,0
t_only_lhs = Set.new
recursive_NT = []
productions = {}

grammar = File.open(GRAMMAR).each { |line|
	#puts "line:: #{line}"
	next if line.strip == ";"
	lhs,rhs = "",""
	if line.index(SEPARATOR) != nil
		lhs_rhs = line.split(SEPARATOR)
		lhs = lhs_rhs[0].strip
		rhs = lhs_rhs[1].strip
		productions[lhs] = rhs
	end
	rhs_array = rhs.split('|')
	total_prod += rhs_array.size
	recursive_rhs = []
	rhs_array.each { |a_rhs|
		#puts " rhs:[#{a_rhs}]"
		any_NT = false
		is_recursive = false
		a_rhs.split.each { |token|
			(next) if ( (token == "(") || (token == ")") || (token == ")*") )
			#puts "token: #{token}"
			if (NT.include? token)
				#puts "    NT -- #{token}"
				any_NT = true
				nt_count += 1
			else
				#puts "    T  -- #{token}"
				T << token.strip
				t_count += 1 if token != ""
			end
			# check for recursiveness
			if lhs.eql? token
				is_recursive = true
			end
		}	
		if is_recursive
			recursive_rhs << lhs #if rhs_array.size == 1
			puts "recursive rule: #{line}"
			#puts "recursive_NT: #{recursive_NT}"			
#			if recursive_prods.keys.include? lhs
#				recursive_prods[lhs] << a_rhs
#			else
#				recursive_prods[lhs] = a_rhs
#			end
		end
		t_only_count += 1 if !any_NT
		t_only_lhs << lhs if (!any_NT) and (NT.include? lhs) 
	}
	(puts "#{lhs} : #{rhs_array}";recursive_NT << lhs) if ((lhs != "") && (recursive_rhs.size == rhs_array.size))
	
	#puts "non-term: #{nt_count}, term: #{t_count}, term-only: #{t_only_count}, total_prod: #{total_prod} } \n\n"
}

puts "\n================ \n"
puts "+- non-terminals used in this grammar: #{NT.size}"
p NT
puts "+- Terminals used in this grammar: #{T.size}"
p T
puts "+- no of times non-term and term used in the grammar: non-terminals: #{nt_count}, terminals: #{t_count}"
puts "+- non-terminals used as a %age: #{(nt_count * 1.0)/(nt_count + t_count)}"
puts "+- terminal-only productions: #{t_only_count}, total productions: #{total_prod} , as a factor - #{(t_only_count * 1.0)/total_prod}"
puts "+- as a factor - non-terminals that have terminals-only productions: #{t_only_lhs.to_a} , #{t_only_lhs.size * 1.0/NT.size}"

if recursive_NT.size > 0
	print "+- recursive: yes"
	recursive_NT.each{ |x| print " [#{x} : #{productions[x]}]" }
	puts 
else
	puts "+- recursive: no"
end

