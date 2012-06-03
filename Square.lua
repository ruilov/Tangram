Square = class(AShape)

function Square:init(x,y,side,angle,color)
    AShape.init(self,x,y,side,angle,color)
end

function Square:draw()
    pushStyle()
    pushMatrix() 
    translate(self.pos.x,self.pos.y)
    rotate(self.angle)
    fill(self:fillColor())
    rectMode(CORNER) 
    if self.drawBorder then
        strokeWidth(3)
        stroke(borderColor)
    else
        noStroke()
        strokeWidth(-1)
    end  
    rect(0,0,self.side,self.side) 
    popMatrix()
    popStyle()
end

function Square:isTouching(x,y)
    v = vec2(x,y)-self.pos
    rad = math.rad(self.angle)
    v = v:rotate(-rad)
    return( v.x > 0 and v.y > 0 and v.x < self.side and v.y < self.side)
end

-- rotates counter-clockwise about a center
function Square:actualRotate(angle)
    toMiddle = vec2(self.side/2,self.side/2)
    self:rotateCenter(angle,toMiddle)
end

function Square:sides() 
    sides = {vec2(0,0),vec2(0,self.side),vec2(self.side,0),vec2(self.side,self.side)}
    return(sides)
end
