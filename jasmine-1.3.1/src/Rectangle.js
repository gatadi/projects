var Rectangle = (function(){

    function Rect(w,h){        
        this.width = w;
        this.height = h ;       
    }
    
    Rect.prototype.area = function(){        
        return this.width * this.height;
    }
    return Rect ;
})();


