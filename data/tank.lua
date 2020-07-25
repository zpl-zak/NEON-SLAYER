tankModel = {}
tanks = {}
local tankMaterial

local tankBody, tankCanon, tankCanonMat, trailPosNode

BOUNDS_PUSHBACK = 1

function initTankModel()
    tankModel = Model("assets/tank.fbx", false, false)
    local tankNode = tankModel:getRootNode()
    tankBody = tankNode:findNode("body")
    trailPosNode = tankNode:findNode("trailpos")
    tankMaterial = Material()
    tankMaterial:setDiffuse(0xe6cfff)
    tankMaterial:setEmission(0xe6cfff)
end

function addTank(id)
  t = {
    pos = Vector3(
      math.random(WORLD_SIZE/4.0,(WORLD_SIZE/4.0)*WORLD_TILES[1]),
      10,
      math.random(WORLD_SIZE/4.0,(WORLD_SIZE/4.0)*WORLD_TILES[2])
    ),
    movedir = Vector3(),
    hover = Vector3(),
    vel = Vector(),
    rot = Matrix(),
    heading = 0,
    trails = {},
    trailTime = 0,
    crot = 0,
    health = 100,
    alive = true,
  }

  l = Light()
  l:setType(LIGHTKIND_POINT)
  l:setPosition(t.pos)
  l:setDiffuse(0xff9933)
  l:setRange(80)
  l:setAttenuation(0,0.01,0)
  t.light = l

  -- table.insert(tanks, t)
  tanks[id] = t
  return t
end

function updateTanks(dt)
    local t = tanks["local"]

    for _, t in pairs(tanks) do
      handleTrails(t, trailPosNode)
    end

    if not t.alive then
      return
    end

      t.vel:y(t.vel:y() - 2*dt)

      if t.vel:y() > 5.0 then
        t.vel:y(5.0)
      end
      world:forEach(function (shape)
        shape:testSphere(t.pos, 5, t.vel+t.movedir-shape.pos:row(4), function (norm)
          norm = norm:normalize()
          p = norm * ((t.vel * norm) / (norm * norm))
          t.vel = (t.vel - p)
        end)
      end)
      local hoverFactor = 2
      t.vel = t.vel:lerp(t.movedir*1000, 0.01323)
      t.hover = Vector3(0,math.sin(time*4) * (hoverFactor - math.min(t.vel:magSq(), hoverFactor) / hoverFactor),0)
      t.pos = t.pos + t.vel
      t.crotm = t.rot
      
      if t.pos:x() <= 0 then
        t.vel:x(-t.vel:x() + BOUNDS_PUSHBACK)
        t.pos:x(t.pos:x()+t.vel:x())
      end
      
      if t.pos:z() <= 0 then
        t.vel:z(-t.vel:z() + BOUNDS_PUSHBACK)
        t.pos:x(t.pos:x()+t.vel:x())
      end
      
      if t.pos:x() >= WORLD_SIZE*WORLD_TILES[1] then
        t.vel:x(-t.vel:x() - BOUNDS_PUSHBACK)
        t.pos:x(t.pos:x()+t.vel:x())
      end
      
      if t.pos:z() >= WORLD_SIZE*WORLD_TILES[2] then
        t.vel:z(-t.vel:z() - BOUNDS_PUSHBACK)
        t.pos:z(t.pos:z()+t.vel:z())
      end
  
      if t.pos:y() < -0 then
        t.pos:y(-0)
        t.vel:y(0)
      end

end

function drawTanks()
    local i = 1
    for idx, t in pairs(tanks) do
      if t.alive then
        t.light:setPosition(t.pos+Vector3(0,5,0))
        t.light:enable(true, i)
        Matrix():bind(WORLD)
        BindTexture(0, tankMaterial)
        tankBody:draw(t.rot * Matrix():translate(t.pos+t.hover))
        BindTexture(0)
        drawTrails(t, 10, trailPosNode)
        i = i + 1
      end
    end
end
