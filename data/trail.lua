local trailMaterial
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

function setupTrail()
    trailMaterial = Material("assets/trail.png")
    local r, g, b = HSVToRGB(pi*2*(math.random(0, 360)/360), 0.5, 1)
    trailMaterial:setDiffuse(r,g,b)
    trailMaterial:setEmission(r,g,b)
    trailMaterial:setAmbient(r,g,b)
    trailMaterial:setOpacity(1)
    trailMaterial:setShaded(false)
    trailMaterial:alphaIsTransparency(true)
end

function getTrailPos(t, trailNode)
    return t.pos + (trailNode:getFinalTransform():translate(0,t.hover:y(),0) * t.rot):row(4)
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

function drawTrails(tank, height, trailNode)
    local trails = tank.trails
    for i=1,#trails,1 do
        local tr1 = trails[i]
        local tr2 = trails[i+1]
        
        local alpha = math.min(i, 20.0) / 20.0

        if tr1 ~= nil then
            if #trails > MAX_TRAILS then
                trailMaterial:setOpacity(alpha)
            end
            if tr2 == nil then
                tr2 = getTrailPos(tank, trailNode)
                trailMaterial:setOpacity(1)
            end
            
            BindTexture(0, trailMaterial)
            Matrix():bind(WORLD)
            CullMode(CULLKIND_NONE)
            DrawPolygon(
                Vertex(tr1:x(), tr1:y()-height, tr1:z(), 0, 0),
                Vertex(tr1:x(), tr1:y()+height, tr1:z(), 0, 1),
                Vertex(tr2:x(), tr2:y()-height, tr2:z(), 1, 0)
            )
            DrawPolygon(
                Vertex(tr1:x(), tr1:y()+height, tr1:z(), 0, 1),
                Vertex(tr2:x(), tr2:y()-height, tr2:z(), 1, 0),
                Vertex(tr2:x(), tr2:y()+height, tr2:z(), 1, 1)
            )
            BindTexture(0)
        end
    end
end
