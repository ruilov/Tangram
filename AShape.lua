AShape = class()

function AShape:init(x,y,side,angle,color)
    self.pos = vec2(x,y)
    self.angle = angle
    self.angleTarget = angle
    self.side = side 
    self.color = color
    self.selected = false
    self.drawBorder = true
end

function AShape:translate(x,y)
    self.pos = self.pos + vec2(x,y)
end

function AShape:scale(s)
    self.pos = self.pos * s
    self.side = self.side * s
end

function AShape:fillColor()
    fillC = self.color
    if self.selected then
        fillC = color( math.min(self.color.r+250,255), math.min(self.color.g+50,255),
            math.min(self.color.b+50,255), alpha )
    else
        fillC = color( math.min(self.color.r,255), math.min(self.color.g,255),
            math.min(self.color.b,255), alpha )
    end
    return(fillC)
end

-- rotates counter-clockwise 
function AShape:rotate(angle)
    self.angleTarget = self.angleTarget + angle
    while self.angleTarget < -180 do self.angleTarget = self.angleTarget + 360 end
    while self.angleTarget > 180 do self.angleTarget = self.angleTarget - 360 end
end

-- for animation, move it a little closer to the target position
function AShape:moveToTarget()
    da = self.angleTarget - self.angle
    while da < -180 do da = da + 360 end
    while da > 180 do da = da - 360 end
    da = da/5
    if da ~= 0 then
        self:actualRotate(da)
    end
end

-- same as actualrotate but given center of rotation
function AShape:rotateCenter(angle,toCenter)
    toCenter = toCenter:rotate(math.rad(self.angle))
    center = self.pos+toCenter
    corner = self.pos-center
    rad = math.rad(angle)
    corner = corner:rotate(rad)
    self.pos = corner + center
    self.angle = self.angle + angle  
    while self.angle < -180 do self.angle = self.angle + 360 end
    while self.angle > 180 do self.angle = self.angle - 360 end
end

function AShape:vertices()
    sides = self:sides()
    rad = math.rad(self.angle)
    vs = {}
    for i,s in ipairs(sides) do
        table.insert(vs, s:rotate(rad)+self.pos)
    end
    return(vs)
end
