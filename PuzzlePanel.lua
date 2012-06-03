PuzzlePanel = class()

puzzleStrs = {
"200&200&45&200&200&135&395&5&90&300&300&-45&200&200&-135&300&100&45&" ..
"100&100&-135&400&",

"318.533&289.033&-90&315.599&289.033&-180&249.566&0&0&509.066&468.5&-135&" ..
"391.567&150&-135&429.533&288.967&0&106.066&297.467&0&300&",

"200&200&45&200&200&135&400&1.52588e-05&90&300&300&-45&200&200&-135&300&100&45&" ..
"100&100&-135&400&",

"318.533&289.033&-90&315.599&289.033&-180&244.566&0&0&509.066&468.5&-135&" ..
"391.567&150&-135&429.533&288.967&0&106.066&297.467&0&300&",

"318.533&289.033&-90&315.599&289.033&-180&244.566&0&0&509.066&468.5&-135&" ..
"391.567&150&-135&429.533&288.967&0&106.066&297.467&0&300&",

"318.533&289.033&-90&315.599&289.033&-180&244.566&0&0&509.066&468.5&-135&" ..
"391.567&150&-135&429.533&288.967&0&106.066&297.467&0&300&",

"318.533&289.033&-90&315.599&289.033&-180&244.566&0&0&509.066&468.5&-135&" ..
"391.567&150&-135&429.533&288.967&0&106.066&297.467&0&300&",

"200&200&45&200&200&135&395&5&90&300&300&-45&200&200&-135&300&100&45&" ..
"100&100&-135&400&",

"318.533&289.033&-90&315.599&289.033&-180&244.566&0&0&509.066&468.5&-135&" ..
"391.567&150&-135&429.533&288.967&0&106.066&297.467&0&300&",

"200&200&45&200&200&135&395&5&90&300&300&-45&200&200&-135&300&100&45&" ..
"100&100&-135&400&",

"200&200&45&200&200&135&395&5&90&300&300&-45&200&200&-135&300&100&45&" ..
"100&100&-135&400&",

}

puzzles = {}
function PuzzlePanel:init(x)
    self.width = 200
    self.maxX = self.width*.65
    self.maxY = HEIGHT / 5
    self.marginY = self.maxY * .1
    self.posY = 0 -- get track of y position
    self.speedY = 0

    for j,pstr in ipairs(puzzleStrs) do
        coords = strTokenize(pstr,"&")  
        if table.maxn(coords) ~= 22 then
            print("couldn't parse puzzle string")
            for k,t in ipairs(coords) do
                print(k,t)
            end
        end
        
        -- scale the coords by the puzzleScale vs the scale used here
        pScale = coords[22]
        for i = 1,21 do 
            if i%3 ~= 0 then  -- every third coord is an angle
                coords[i] = coords[i]
            end
        end
        
        local largeSide = 1/math.sqrt(2) * pScale
        local mediumSide = pScale / 2
        local smallSide = math.sqrt(2)/4 * pScale
        thisPuzzle = Puzzle( {
            Triangle(coords[1],coords[2],largeSide,coords[3],color(0,0,0,alpha)),
            Triangle(coords[4],coords[5],largeSide,coords[6],color(0,0,0,alpha)),
            Triangle(coords[7],coords[8],mediumSide,coords[9],color(0,0,0,alpha)),
            Triangle(coords[10],coords[11],smallSide,coords[12],color(0,0,0,alpha)),
            Triangle(coords[13],coords[14],smallSide,coords[15],color(0,0,0,alpha)),
            Square(coords[16],coords[17],smallSide,coords[18],color(0,0,0,alpha)),
            Parallelogram(coords[19],coords[20],smallSide,coords[21],color(0,0,0,alpha)),
        }, color(0, 0, 0, 255) )
      
        -- scale the puzzle  
        box = thisPuzzle:boundingBox()
        s = 1
        if self.maxX < box[3] - box[1] then s = math.min(s,self.maxX/(box[3] - box[1])) end
        if self.maxY < box[4] - box[2] then s = math.min(s,self.maxY/(box[4] - box[2])) end
        thisPuzzle:scale(s)
        -- center around the middle
        box = thisPuzzle:boundingBox()
        slackX = self.maxX - (box[3]-box[1])
        slackY = self.maxY - (box[4]-box[2])
        thisPuzzle:translate(-box[1]+slackX/2,-box[2]+slackY/2)
        table.insert(puzzles,thisPuzzle)
    end
end

function strTokenize(str,token)
    local tokens = {}
    local i = 1
    local tok = ""
    while i < string.len(str) do
        local c = string.sub(str,i,i)
        if c == token then
            table.insert(tokens,tok)
            tok = ""
        else
            tok = tok .. c
        end
        i = i + 1
    end
    if string.len(tok) then table.insert(tokens,tok) end
    return(tokens)
end

function PuzzlePanel:draw()
    pushMatrix()
    pushStyle()
    stroke(30, 38, 25, 255)
    strokeWidth(5)
    fill(225, 230, 224, 255)
    rectMode(CORNER)
    lineCapMode(PROJECT)
    rect(-1,-2,self.width,HEIGHT+4)    
    
    marginX = (self.width-self.maxX)/2
    onePuzzleY = 2*self.marginY + self.maxY
    currentY = HEIGHT + self.posY
    translate(marginX,currentY)
    for p,puzzle in ipairs(puzzles) do
        translate(0,-self.marginY-self.marginY - self.maxY)
        if currentY > 0 and currentY < HEIGHT+onePuzzleY*2 then 
            puzzle:draw()
        end
        translate(0,-self.marginY)
        line(-1-marginX,-1,self.width - marginX-4,-1)
        currentY = currentY - onePuzzleY
    end
    popStyle()
    popMatrix()
end

function PuzzlePanel:touched(dy)
    self.posY = self.posY + dy
    self.speedY = 0
    --print("touched")
end

function PuzzlePanel:flicked(dy)
    self.speedY = self.speedY + dy*20
    --print("flicked")
end

function PuzzlePanel:moveToTarget()
    --print(self.speedY)
    dSpeed = 30
    self.speedY = self.speedY * .99
    if self.speedY > 0 then self.speedY = self.speedY - 10
    elseif self.speedY < 0 then self.speedY = self.speedY + 10 end
    if math.abs(self.speedY) < dSpeed then self.speedY = 0 end
    
    self.posY = self.posY + self.speedY * DeltaTime
    self.posY = math.max(self.posY,0)
end


