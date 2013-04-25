describe("Rectangle", function() {
  
  it("class should be defined", function(){
    expect(Rectangle).toBeDefined();
  });
  
  it("should be able to create object with width and height", function() {
    var r = new Rectangle(20, 30);
    expect(r.width).toEqual(20);
  });
  
  it("should return area", function(){
    var r = new Rectangle(20,30);
    expect(r.area()).toEqual(600);
  });


  
});