# ----------------- pringing -----------------------------------


puts "Hello World!"
puts "This is fun."
puts 'Yay! Print.'
puts "I'd much rather you'not'."
puts 'I "said" do not touch this.'

# -------------------math & string printing---------------------------------
puts "-------------------math & string printing---------------------------------"
puts "I will now count my chickens:"

puts "Hens", 25 + 30 / 6
puts "Roosters", 100 - 25 * 3 % 4

puts "Now I will count the eggs:"
 
puts 3 + 2 < 5 - 7

puts "Is it true that 3 + 2 < 5 - 7?"
puts "What is 5 - 7?", 5 - 7

puts "Oh, that's why it's false."
puts "Is it greater or equal?", 5 >= -2


# ------------------- Variables & Printing ---------------------------------
puts "------------------- Variables & Printing ----------------------"

my_name = "Snapfish"
my_age = 12 
my_employees = 250
my_admin = 50 
my_color = "Green"

puts "My name is #{my_name} and my age is #{my_age} and my employee count is #{my_employees + my_admin}"

puts "My name is %s" %my_name
puts "My age is %d" %my_age
puts "My name is %s" %'Snapfish again'

puts "My name is : %s, my age is : %d" %[my_name, my_age]
puts "My employee count is : %d" %[my_employees + my_admin]

puts my_name + " is " + my_color

print "print function does not insert new line "
print "where as put does\n"


# ------------------- Printing & Printing ---------------------------------
puts "------------------- Printing & Printing ----------------------"

formatter = "%s %s %s %s"

puts formatter % [1, 2, 3, 4]
puts formatter % ["one", "two", "three", "four"]
puts formatter % [true, false, false, true]
puts formatter % [formatter, formatter, formatter, formatter]
puts formatter % [
    "I had this thing.",
    "That you could type up right.",
    "But it didn't sing.",
    "So I said goodnight."
]

puts "\n-----------------PARAGRAPH Printing-------------\n"

my_paragraph = "Snapfish"
puts <<PARAGRAPH
\tThere's something going on here.
\tWith the PARAGRAPH thing
\tWe'll be able to type as much as we like.
\tEven 4 lines if we want, or 5, or 6.
#{my_paragraph}
PARAGRAPH

puts "\n-----------------Asking Questions (inputting from command line)-------------\n"

print "How old are you? "
#age = gets.chomp()
print "How tall are you? "
#height = gets.chomp()
print "How much do you weigh? "
#weight = gets.chomp()

#puts "So, you're #{age} old, #{height} tall and #{weight} heavy."


puts "\n-----------------Parameters from ARGV -------------\n"

first, second, third = ARGV 

puts "The script is called: #{$0}"
puts "Your first variable is: #{first}"
puts "Your second variable is: #{second}"
puts "Your third variable is: #{third}"


puts "\n-----------------Using Libraries-------------\n"

#require 'open-uri'

#open("http://www.ruby-lang.org/en") do |f|
 # f.each_line {|line| p line}
 # puts f.base_uri         # <URI::HTTP:0x40e6ef2 URL:http://www.ruby-lang.org/en/>
 # puts f.content_type     # "text/html"
 # puts f.charset          # "iso-8859-1"
 # puts f.content_encoding # []
 # puts f.last_modified    # Thu Dec 05 02:45:02 UTC 2002
  
#end

puts "\n-----------------Prompting and Passing-------------\n"
user = ARGV.first
prompt = '> '

puts "Hi #{user}, I'm the #{$0} script."
puts "I'd like to ask you a few questions."
puts "Do you like me #{user}?"
print prompt
likes = STDIN.gets.chomp()

puts "Where do you live #{user}?"
print prompt
lives = STDIN.gets.chomp()

puts "What kind of computer do you have?"
print prompt
computer = STDIN.gets.chomp()

puts <<MESSAGE
Alright, so you said #{likes} about liking me.
You live in #{lives}.  Not sure where that is.
And you have a #{computer} computer.  Nice.
MESSAGE