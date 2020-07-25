MAX_TRAILS = 150.0
TRAIL_TIME = 0.05

local sqrt, sin, cos = math.sqrt, math.sin, math.cos
local pi = math.pi
local r1, r2 =  0          ,  1.0
local g1, g2 = -sqrt( 3 )/2, -0.5
local b1, b2 =  sqrt( 3 )/2, -0.5


--[[--
  @param h a real number between 0 and 2*pi
  @param s a real number between 0 and 1
  @param v a real number between 0 and 1
  @return r g b a
]]
local function HSVToRGB( h, s, v, a )
  h=h+pi/2--because the r vector is up
  local r, g, b = 1, 1, 1
  local h1, h2 = cos( h ), sin( h )
  
  --hue
  r = h1*r1 + h2*r2
  g = h1*g1 + h2*g2
  b = h1*b1 + h2*b2
  --saturation
  r = r + (1-r)*s
  g = g + (1-g)*s
  b = b + (1-b)*s
  
  r,g,b = r*v, g*v, b*v
  
  return r*255, g*255, b*255, (a or 1) * 255
end

function updateTrail(tank)
    local r, g, b = HSVToRGB(pi*2*(tank.color/360), 0.5, 1)
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
    local pos = t.pos + (trailNode:getFinalTransform():translate(0,t.hover:y(),0) * t.rot):row(4)
    return {pos:x(), pos:y(), pos:z()}
end

function handleTrails(t, trailNode)
    if t.trailTime < time then
        t.trailTime = time + TRAIL_TIME

        if #t.trails > MAX_TRAILS then
            table.remove(t.trails, 1)
        end
        table.insert(t.trails, getTrailPos(t, trailNode))
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
