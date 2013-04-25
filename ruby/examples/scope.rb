# local variable
n = 10 
puts "n = #{10}" 

#local
m = 100

def foo
  #function scoope -  local variable
  n = 20
  puts "n (from foo) = #{n}"  
  
  #global variable
  $m = 200
end

foo
puts "n = #{10}" 

puts "m = #{$m}"
puts "m = #{m}"