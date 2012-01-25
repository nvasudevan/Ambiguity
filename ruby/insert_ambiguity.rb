#!/apps/ruby/current/bin/ruby

require 'set'

#ambiguous parts
#Type 1:

#A : 'a' | 'a'

#Type 2:

#A : B C
#B : 'a' 'b' | 'a'
#C : 'b' 'c' | 'c'

AMB_TYPE="2"
file_extn="_amb#{AMB_TYPE}"
grammar = ARGV[0]
Dir::mkdir("grammars/" + grammar + file_extn) if ! FileTest::directory?("grammars/" + grammar + file_extn)
amb_grammar_file = File.new("grammars/" + grammar + file_extn + "/" + grammar + file_extn + ".spec","w+")
AB_set = Set.new
ab_set = Set.new
AB_set << 'root'
('A'..'H').to_a.each {|alpha| AB_set << alpha}
('a'..'h').to_a.each {|alpha| ab_set << alpha}

if AMB_TYPE == "1"
  random_lower_char = ab_set.to_a[rand(ab_set.size)]
  random_upper_char = AB_set.to_a[rand(AB_set.size)]
  puts "random lower,upper char: #{random_lower_char} , #{random_upper_char}\n"
elsif AMB_TYPE == "2"
  random_lower_chars = Set.new
  while random_lower_chars.size < 3
    random_lower_chars << ab_set.to_a[rand(ab_set.size)]
  end
  ##
  _random_upper_chars, random_upper_chars,random_upper_chars_array = Set.new, Set.new,[]
  while _random_upper_chars.size < 3
    _random_upper_chars << AB_set.to_a[rand(AB_set.size)]
  end
  if _random_upper_chars.include?('root')
      puts "match *root* "
      random_upper_chars << 'root'
      puts "-- #{random_upper_chars.to_a}";
      _random_upper_chars.each { |x| random_upper_chars << x }
      random_upper_chars_array = random_upper_chars.to_a.sort.reverse
  else
      random_upper_chars = _random_upper_chars
      random_upper_chars_array = random_upper_chars.to_a
  end
  puts "random lower,upper chars: #{random_lower_chars.to_a} , #{random_upper_chars_array}\n"
else
  exit
end

if File.exists?("grammars/" + grammar + "/" + grammar + ".spec")
  File.open("grammars/" + grammar + "/" + grammar + ".spec").each { |line|
      if line.index(':') != nil
	lhs_rhs = line.split(':')
	lhs = lhs_rhs[0].strip
        rhs = lhs_rhs[1].strip
        rhs_array = rhs.split('|')
        print "lhs: #{lhs} rhs: #{rhs_array} \n"
	if AMB_TYPE == "1"
	    if lhs == random_upper_char
	      print "match!"
	      array_random_index = rand(rhs_array.size)
	      rhs_array.insert(array_random_index,"'" + random_lower_char + "'")
	      array_random_index = rand(rhs_array.size)
	      rhs_array.insert(array_random_index,"'" + random_lower_char + "'")
	      print "** lhs: #{lhs} rhs: #{rhs_array} \n"
	    end
	    amb_grammar_file.puts(lhs + " : " + rhs_array.join(' | ') + "\n")
        elsif AMB_TYPE == "2"
            if lhs == random_upper_chars_array[0]
               print "match! upper 0"
	       string_to_add = " " + random_upper_chars_array[1] + " " + random_upper_chars_array[2] + " "
	       array_random_index = rand(rhs_array.size)
               rhs_array.insert(array_random_index,string_to_add)
            elsif lhs == random_upper_chars_array[1]
               print "match! upper 1"
               string_to_add = " '" + random_lower_chars.to_a[0] + "' '" + random_lower_chars.to_a[1] + "' "
	       array_random_index = rand(rhs_array.size)
               rhs_array.insert(array_random_index,string_to_add)
               string_to_add = " '" + random_lower_chars.to_a[0] + "' "
	       array_random_index = rand(rhs_array.size)
               rhs_array.insert(array_random_index,string_to_add)
            elsif lhs == random_upper_chars_array[2]
               print "match! upper 2"
               string_to_add = " '" + random_lower_chars.to_a[1] + "' '" + random_lower_chars.to_a[2] + "' "
	       array_random_index = rand(rhs_array.size)
               rhs_array.insert(array_random_index,string_to_add)
               string_to_add = " '" + random_lower_chars.to_a[2] + "' "
	       array_random_index = rand(rhs_array.size)
               rhs_array.insert(array_random_index,string_to_add)
            end
            amb_grammar_file.puts(lhs + " : " + rhs_array.join(' | ') + "\n")                                                                  
	end
                                                                  
      else
        amb_grammar_file.puts(line)
      end
                                                                  
      
  }
end

amb_grammar_file.close


 
