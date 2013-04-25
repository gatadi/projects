class Rectangle
	
	def initialize (w, h)
		@width = w
		@height = h
	end

	def width
		@width
	end
	
	def width=(w)
		@width = w 
	end
	
	def height
		@height
	end
	
	def height=(h)
		@height = h 
	end
	
	def area
		return @width * @height
	end
	
	def to_string
		return "\nWidth : #{@width}\n" +  "Height: #{@height}\n"  + "Area : #{self.area}\n"; 
	end
	
	def set_width_height(w,h)
		@width = w 
		@height = h 
	end
end


r = Rectangle.new(10,50);
puts "Width : #{r.width}"
puts "Height: #{r.height}"
puts "Area : #{r.area}\n\n"

r.width = 40
r.height = 60
puts r.to_string

r.set_width_height(25, 25)
puts r.to_string

