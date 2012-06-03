touches = {}
touchStarts = {}
hasTouch = false
puzzlePanel = nil
puzzle = nil
puzzleScale = 300

function setup()
    watch("dt")
    iparameter("alpha",0,255,255)
    iparameter("depth",0,8,3)
    iparameter("printPuzzle",0,1,0)

    alreadyPrinted = false
    
    local largeSide = 1/math.sqrt(2) * puzzleScale
    local mediumSide = puzzleScale / 2
    local smallSide = math.sqrt(2)/4 * puzzleScale
    puzzle = Puzzle( {
        Triangle(WIDTH/2+100,HEIGHT/2,largeSide,45,color(0,0,0,alpha)),
        Triangle(WIDTH/2+100,HEIGHT/2,largeSide,135,color(0,0,0,alpha)),
        Triangle(WIDTH/2+99+mediumSide,HEIGHT/2-mediumSide+1,mediumSide,90,color(0,0,0,alpha)),
        Triangle(WIDTH/2+100+mediumSide/2,HEIGHT/2+mediumSide/2,smallSide,-45,color(0,0,0,alpha)),
        Triangle(WIDTH/2+100,HEIGHT/2,smallSide,-135,color(0,0,0,alpha)),
        Square(WIDTH/2+100+mediumSide/2,HEIGHT/2-mediumSide/2,smallSide,45,color(0,0,0,alpha)),
        Parallelogram(WIDTH/2+100-mediumSide/2,HEIGHT/2-mediumSide/2,
            smallSide,-135,color(0,0,0,alpha)),
    }, color(71, 71, 71, 255) )
    
    puzzlePanel = PuzzlePanel()
end

function touched(touch)
    if touch.state == ENDED then
        touches[touch.id] = nil
        resetErrors()
        
        if touch.x < puzzlePanel.width then
            count = 1
            sum = touch.deltaY
            for t,dy in ipairs(touchStarts[touch.id]) do
                count = count + 1
                sum = sum + dy
            end
            dy = sum / count
            touchStarts[touch.id] = nil
            puzzlePanel:flicked(dy)
        end
    else
        touches[touch.id] = touch
        if touch.state == BEGAN then
            touchStarts[touch.id] = {touch.deltaY}
        else
            if table.maxn(touchStarts[touch.id]) > 2 then
                table.remove(touchStarts[touch.id],1)
            end
            table.insert(touchStarts[touch.id],touch.deltaY)
        end
    end
    hasTouch = true
end

function processTouches() 
    -- is it one or two touches
    local touch1 = nil
    local touch2 = nil
    for id,t in pairs(touches) do
        if not touch1 then touch1 = t
        elseif not touch2 then touch2 = t
        else break end
    end
        
    if touch1 then
        if touch1.x < puzzlePanel.width then
            puzzlePanel:touched(touch1.deltaY)
        elseif not touch2 then 
            -- translate the one we're touching
            alreadyMoved = false
            for i,tri in ipairs(puzzle.pieces) do
                if alreadyMoved then
                    tri.selected = false
                else 
                    tri.selected = tri:isTouching(touch1.x,touch1.y)
                    if tri.selected then
                        -- translate this one
                        dx = stepMove(touch1.deltaX,"dx",2)
                        dy = stepMove(touch1.deltaY,"dy",1) 
                        
                        tri:translate(dx,dy)
                        alreadyMoved = true
                        puzzle:pieceTouched(tri,i)
                    end  
                end
            end
        else
            -- we have two touches so it's a rotation
            alreadyMoved = false
            for i,tri in ipairs(puzzle.pieces) do
                if alreadyMoved then
                    tri.selected = false
                else 
                    tri.selected = tri:isTouching(touch1.x,touch1.y) or 
                        tri:isTouching(touch2.x,touch2.y)
                    if tri.selected then
                        -- rotate this one
                        -- horizontal is 90 or -90
                        -- vertical is 0 or 180
                        dx = touch2.x - touch1.x
                        dy = touch2.y - touch1.y
                        ang = math.deg( math.atan2(dx,dy) )
                        
                        oldDx = touch2.prevX - touch1.prevX
                        oldDy = touch2.prevY - touch1.prevY
                        oldAng = math.deg( math.atan2(oldDx,oldDy) )
                        
                        -- diffAng: positive is clockwise and negative is counter              
                        diffAng = stepMove(ang - oldAng,"da",7.5)
                        
                        --print(vec2(diffAng1,diffAng))
                        --[[
                        -- find the center of rotation     
                        center = intersection(
                            vec2(touch1.prevX,touch1.prevY),
                            vec2(touch2.prevX,touch2.prevY),
                            vec2(touch1.x,touch1.y),
                            vec2(touch2.x,touch2.y)
                        )
                       
                        if center.x > 0 and center.x < WIDTH then       
                            tri:rotate(-diffAng,center.x,center.y)
                            tri.x = tri.x + (touch1.deltaX + touch2.deltaX)/2
                            tri.y = tri.y + (touch1.deltaY + touch2.deltaY)/2
                        end
                        --]]       
                        
                        tri:rotate(-diffAng)
                        
                        dx = stepMove((touch1.deltaX + touch2.deltaX)/2,"dx",2)
                        dy = stepMove((touch1.deltaY + touch2.deltaY)/2,"dy",1)
                        --tri:translate(dx,dy)
                        
                        alreadyMoved = true
                        puzzle:pieceTouched(tri,i)
                    end  
                end
            end
        end
    end
end

errors = {}
function stepMove(change,tag,step)
    err = 0
    if errors[tag] then err = errors[tag] end
    change = change + err
    --if change < 0 then change2 = math.floor(change/step)*step
    --else change2 = math.ceil(change/step)*step end
    change2 = math.ceil(change/step)*step
    errors[tag] = change - change2
    return(change2)
end

function resetErrors()
    errors = {}
end

--[[
-- finds the intersection between the lines old1-old2 and new1-new2
function intersection(old1,old2,new1,new2)
    dx = new2.x - new1.x
    dy = new2.y - new1.y                                  
    m = dy/dx
    inter = new2.y - m * new2.x
                        
    oldDx = old2.x - old1.x
    oldDy = old2.y - old1.y
    oldM = oldDy/oldDx
    oldInter = old2.y - oldM * old2.x
                        
    centerX = (oldInter - inter)/(m-oldM)
    centerY = m * centerX + inter
    return(vec2(centerX,centerY))
end
--]]

function draw()
    background(255, 255, 255, 255)
    dt = DeltaTime*100

    if hasTouch then 
        processTouches() 
        hasTouch = false
    end
    
    for i,tri in ipairs(puzzle.pieces) do tri:moveToTarget() end
    puzzlePanel:moveToTarget()
    
    puzzle:draw() 
    puzzlePanel:draw()
    
    if printPuzzle == 0 then alreadyPrinted = false end
    if printPuzzle == 1 and not alreadyPrinted then
        puzzle:print()
        alreadyPrinted = true
    end
end



