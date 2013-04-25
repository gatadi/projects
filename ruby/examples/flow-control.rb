puts "for loop 1..5"
for i in 1..5
   puts i 
end

n = 20
puts "for loop 15..20"
for i in 15..n
	puts i
end

puts "while loop 5..10"
i = 5
n = 10
while i < n
	puts i
	i = i+1
end

puts "\ntimes method"
5.times { |i|   
  puts i
}

puts
cities = ["Fremont", "San Francisco", "San Jose", "Santa Clara"] 
cities.each do |x| 
	puts x 	
end

map = { "1"=> "One", "2" => "Two", "3" => "Three" }
puts 
map.each_key { |key| 
	print key, " -> ", map[key], "\n"
}


