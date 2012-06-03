Triangle = class(AShape)

log2 = math.log(2)

-- angle in degrees and counter-clockwise from the positive x-axis
function Triangle:init(x,y,side,angle,color)
    AShape.init(self,x,y,side,angle,color)
end

function Triangle:draw()
    pushStyle()
    pushMatrix()
    
    translate(self.pos.x,self.pos.y)
    rotate(self.angle)
    fill(self:fillColor())
    rectMode(RADIUS)
    noStroke()
    noSmooth()
    
    niter = math.ceil(math.log(self.side)/log2)-2
    small = self.side/2^(depth+1) -- x radius of hyptonuse rectangle
    coverX = small * math.sqrt(2)  -- how much we need to cover with little squares in x dir
    for iter = 1,niter do
        nsq = 2^(iter-1)
    
        if iter <= depth then
            for sq = 0,nsq-1 do
                self:drawLittleSquare(sq,nsq)
            end
        else
            sqNeeded = math.ceil( coverX * nsq / self.side - .5 )
            for k=0,sqNeeded do
                self:drawLittleSquare(k,nsq)
                self:drawLittleSquare(nsq-1-k,nsq)
            end
        end
    end
    
    -- draw the hypothenuse, it's just an optimization so we don't have to draw too
    -- many little squares
    pushMatrix()
    translate(self.side/2,self.side/2)
    rotate(45)  
    rect(-small,0,small,self.side*math.sqrt(2)/2-2*small)
    popMatrix()
    
    if self.drawBorder then
        strokeWidth(3)
        stroke(borderColor)
        line(-1,-1,self.side,-1)
        line(-1,-1,-1,self.side)
        line(-1,self.side,self.side,-1)
    end
    
    popMatrix()
    popStyle()
end

-- private helper function
function Triangle:drawLittleSquare(sqNum,numSquares)
    temp = self.side/4/numSquares
    d = sqNum*temp*4
    x = temp+d
    y = self.side-3*temp-d
    rx = temp
    --  s/n * (1/2 + sqNum)
    
    ry = temp
    if x > 0 then
        x = x - 1
        rx = rx + 1
    end
    if y > 0 then
        y = y - 1
        ry = ry + 1
    end
    rect(x,y,rx,ry)
end

-- checks whether a touch at (x,y) is touching this triangle
function Triangle:isTouching(x,y)
    v = vec2(x,y) - self.pos
    rad = math.rad(self.angle)
    v = v:rotate(-rad)
    return( v.x > 0 and v.y > 0 and v.x+v.y < self.side)
end

function Triangle:actualRotate(angle)   
    toMiddle = vec2(self.side/4,self.side/4)
    self:rotateCenter(angle,toMiddle)
end

function Triangle:sides() 
    sides = {vec2(0,0),vec2(0,self.side),vec2(self.side,0)}
    return(sides)
end
