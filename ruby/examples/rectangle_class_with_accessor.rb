class Rectangle
    attr_reader :width, :height
    attr_accessor :description
    
    def initialize(w, h)
        @width = w
        @height = h
    end
    
    def area
        @width * @height
    end
    
end

r = Rectangle.new(10, 25) ;
puts "Area(10,25) = #{r.area}"
r.description = "Message 1" 
puts r.description

