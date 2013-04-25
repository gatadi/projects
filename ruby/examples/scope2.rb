class Rectangle
  def initialize(w, h)
    # instance variables
    @width = w
    @height = h
    # class variable
    @@MAX_WIDTH = 100000
    @@MAX_HEIGHT = 200000
  end  
  
  def print
    @@MAX_WIDTH = @@MAX_WIDTH + 1
    puts @@MAX_WIDTH 
  end
  
  def self.print_class_variables
    @@MAX_HEIGHT = @@MAX_HEIGHT + 1
    puts @@MAX_HEIGHT    
  end
  
end

r = Rectangle.new(10,20)
puts r.print
puts Rectangle.print_class_variables
