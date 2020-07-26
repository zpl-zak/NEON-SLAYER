MAX_TRAILS = 150.0
TRAIL_TIME = 0.05


function updateTrail(tank)
    local r, g, b = HSVToRGB(math.pi*2*(tank.color/360), 0.5, 1)
    tank.trailMaterial:setDiffuse(r,g,b)
    tank.trailMaterial:setEmission(r,g,b)
    tank.trailMaterial:setAmbient(r,g,b)
end

function setupTrail(tank)
    tank.trailMaterial = Material("assets/trail.png")
    updateTrail(tank)
    tank.trailMaterial:setOpacity(1)
    tank.trailMaterial:setShaded(false)
    tank.trailMaterial:alphaIsTransparency(true)
end

function getTrailPos(t, trailNode)
    local pos = t.pos
    return {pos:x(), pos:y()+15, pos:z()}
end

function handleTrails(t, trailNode)
    if t.trailTime < time and t.alive then
        t.trailTime = time + TRAIL_TIME

        if #t.trails > MAX_TRAILS then
            table.remove(t.trails, 1)
        end

        if t.pos:magSq() > 0.01 then
            table.insert(t.trails, getTrailPos(t, trailNode))
        end
    end
end

function drawTrails(tank, trails, height, trailNode)
    for i=1,#trails,1 do
        local tr1 = trails[i]
        local tr2 = trails[i+1]
        
        local alpha = math.min(i, 20.0) / 20.0

        if tr1 ~= nil then
            if #trails > MAX_TRAILS then
                tank.trailMaterial:setOpacity(alpha)
            end
            if tr2 == nil then
                tr2 = getTrailPos(tank, trailNode)
                tank.trailMaterial:setOpacity(1)
            end
            
            BindTexture(0, tank.trailMaterial)
            Matrix():bind(WORLD)
            CullMode(CULLKIND_NONE)
            AmbientColor(255, 255, 255)
            DrawPolygon(
                Vertex(tr1[1], tr1[2]-height, tr1[3], 0, 0),
                Vertex(tr1[1], tr1[2]+height, tr1[3], 0, 1),
                Vertex(tr2[1], tr2[2]-height, tr2[3], 1, 0)
            )
            DrawPolygon(
                Vertex(tr2[1], tr2[2]+height, tr2[3], 1, 1),
                Vertex(tr2[1], tr2[2]-height, tr2[3], 1, 0),
                Vertex(tr1[1], tr1[2]+height, tr1[3], 0, 1)
            )
            BindTexture(0)
        end
    end
end
