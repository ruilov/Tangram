Parallelogram = class(AShape)

function Parallelogram:init(x,y,side,angle,color)
    AShape.init(self,x,y,side,angle,color)
    self.tri1 = Triangle(x,y,side,angle,color)
    self.tri2 = Triangle(0,0,side,angle+180,color)  -- x,y will be fixed by actualRotate
    self.tri1.drawBorder = false
    self.tri2.drawBorder = false
    self:actualRotate(0)
end

function Parallelogram:draw()
    self.tri1.selected = self.selected
    self.tri2.selected = self.selected
    self.tri1:draw()
    self.tri2:draw()
    
    -- draw the borders
    if self.drawBorder then
        pushStyle()
        noSmooth()
        stroke(borderColor)
        strokeWidth(3) 

        pushMatrix() 
        translate(self.tri1.pos.x,self.tri1.pos.y)
        rotate(self.tri1.angle)
        line(-1,-1,self.side,-1)
        line(-1,self.side,self.side,-1)  
        popMatrix()
        
        pushMatrix()
        translate(self.tri2.pos.x,self.tri2.pos.y)
        rotate(self.tri2.angle)
        line(-1,-1,self.side,-1)
        line(-1,self.side,self.side,-1)  
        popMatrix()
        
        popStyle()
    end
end

function Parallelogram:isTouching(x,y)
    return(self.tri1:isTouching(x,y) or self.tri2:isTouching(x,y))
end

function Parallelogram:translate(x,y)
    AShape.translate(self,x,y)
    self.tri1:translate(x,y)
    self.tri2:translate(x,y)
end

function Parallelogram:scale(s)
    AShape.scale(self,s) 
    self.tri1:scale(s)
    self.tri2:scale(s)
    self:actualRotate(0)
end

-- rotates counter-clockwise about a center
function Parallelogram:actualRotate(angle)
    toMiddle = vec2(0,self.side/2)
    toMiddle2 = vec2(-1,self.side/2-2)
    self.tri1:rotateCenter(-self.angle,toMiddle)
    self.tri2:rotateCenter(-self.angle,toMiddle2)
    
    self:rotateCenter(angle,toMiddle)    
    
    -- tri2 adjustment
    errY = self.tri2.pos.y - self.tri2.side - self.tri1.pos.y
    errX = self.tri2.pos.x - self.tri1.pos.x
    self.tri2:translate(-errX-1,-errY-2) 
    self.tri1:rotateCenter(self.angle,toMiddle)
    self.tri2:rotateCenter(self.angle,toMiddle2) 
end

function Parallelogram:sides() 
    sides = {vec2(0,0),vec2(0,self.side),vec2(self.side,0),vec2(-self.side,self.side)}
    return(sides)
end
