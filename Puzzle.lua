Puzzle = class()

function Puzzle:init(pieces,borderColor)
    self.borderColor = borderColor
    self.pieces = {}
    self.piecesClone = {}
    for i,p in ipairs(pieces) do
        self.pieces[i] = p
        self.piecesClone[i] = p
    end
    
end

function Puzzle:pieceTouched(piece,idx)
    table.remove(self.pieces,idx)
    table.insert(self.pieces,1,piece)
end

function Puzzle:draw()
    borderColor = self.borderColor
    local ntris = table.maxn(self.pieces)
    for i = ntris,1,-1 do self.pieces[i]:draw() end 
end

-- returns array (left,bottom,right,top)
function Puzzle:boundingBox()
    left = 100000
    bottom = 100000
    right = 0
    top = 0
    for j,tri in ipairs(self.piecesClone) do
        for i,v in ipairs(tri:vertices()) do
            left = math.min(left,v.x)
            bottom = math.min(bottom,v.y)
            right = math.max(right,v.x)
            top = math.max(top,v.y)
        end
    end
    
    return({left,bottom,right,top})
end

function Puzzle:scale(s)
    for i,p in ipairs(self.pieces) do p:scale(s) end
end

function Puzzle:translate(x,y)
    for i,p in ipairs(self.pieces) do p:translate(x,y) end
end

function Puzzle:print()
    -- first find the bounding box so we can translate/scale
    box = self:boundingBox()
    self:translate(box[1],box[2])
    lineS = '"'
    for i,tri in ipairs(self.piecesClone) do
        lineS = lineS .. tri.pos.x .. "&" .. tri.pos.y .. "&" .. tri.angleTarget .. "&"
        if string.len(lineS) > 70 then
            lineS = lineS .. '" ..' 
            print(lineS)
            lineS = '"'
        end
    end
    self:translate(-box[1],-box[2])
    lineS = lineS .. puzzleScale .. "&"
    lineS = lineS .. '",' 
    print(lineS)
end
