BOUNDS_PUSHBACK = 1
localPlayerColor = 0
tanks = {}

local tankModel = Model("assets/sphere.fbx", false)
local borderHitSound = Sound("assets/sounds/wallhit.wav")
borderHitSound:setVolume(80)

local class = require "class"

class "Tank" {
  __init__ = function (self, id, color)
    self.id = id
    self.isLocal = id == -1
    self.pos = Vector3(
      math.random(WORLD_SIZE,(WORLD_SIZE)*WORLD_TILES[1]),
      10,
      math.random(WORLD_SIZE,(WORLD_SIZE)*WORLD_TILES[2])
    )
    self.movedir = Vector3()
    self.hover = Vector3()
    self.vel = Vector()
    self.rot = Matrix()
    self.trails = {}
    self.serverTrail = {}
    self.trailTime = 0
    self.crot = 0
    self.health = 100
    self.alive = true
    self.aliveTime = nil
    self.color = 0
    self.heading = 0

    if color ~= nil then
      t.color = color
      LogString("setting color for remote entity to:" .. color)
    end

    local l = Light()
    l:setType(LIGHTKIND_POINT)
    l:setPosition(self.pos)
    l:setDiffuse(0xff9933)
    l:setRange(80)
    l:setAttenuation(0,0.01,0)
    self.light = l

    self:refreshMaterial()

    tanks[id] = self
  end,

  refreshMaterial = function (self)
    local trailMaterial = Material("assets/trail.png")
    self.material = trailMaterial

    local r, g, b = HSVToRGB(math.pi*2*(self.color/360), 0.5, 1)
    self.material:setDiffuse(r,g,b)
    self.material:setEmission(r,g,b)
    self.material:setAmbient(r,g,b)

    setupTrail(self)
  end,

  update = function (self, dt)
    handleTrails(self)

    if not self.alive then
      return
    end

    if self.isLocal and self.color ~= localPlayerColor then
      self.color = localPlayerColor
      self:refreshMaterial()
    end

    self.vel:y(self.vel:y() - 2*dt)

    if self.vel:y() > 5.0 then
      self.vel:y(5.0)
    end

    world:forEach(function (shape)
      shape:testSphere(self.pos, 5, self.vel+self.movedir-shape.pos:row(4), function (norm)
        norm = norm:normalize()
        p = norm * ((self.vel * norm) / (norm * norm))
        self.vel = (self.vel - p)
      end)
    end)
    local hoverFactor = 2
    self.vel = self.vel:lerp(self.movedir*1000, 0.01323)
    self.hover = Vector3(0,math.sin(time*4) * (hoverFactor - math.min(self.vel:magSq(), hoverFactor) / hoverFactor),0)
    self.pos = self.pos + self.vel
    self.crotm = self.rot

    if self.pos:x() <= 0 then
      self.vel:x(-self.vel:x() + BOUNDS_PUSHBACK)
      self.pos:x(self.pos:x()+self.vel:x())
      borderHitSound:play()
    end

    if self.pos:z() <= 0 then
      self.vel:z(-self.vel:z() + BOUNDS_PUSHBACK)
      self.pos:x(self.pos:x()+self.vel:x())
      borderHitSound:play()
    end

    if self.pos:x() >= WORLD_SIZE*WORLD_TILES[1] then
      self.vel:x(-self.vel:x() - BOUNDS_PUSHBACK)
      self.pos:x(self.pos:x()+self.vel:x())
      borderHitSound:play()
    end

    if self.pos:z() >= WORLD_SIZE*WORLD_TILES[2] then
      self.vel:z(-self.vel:z() - BOUNDS_PUSHBACK)
      self.pos:z(self.pos:z()+self.vel:z())
      borderHitSound:play()
    end

    if self.pos:y() < -0 then
      self.pos:y(-0)
      self.vel:y(0)
    end

    if self.aliveTime ~= nil and self.aliveTime < getTime() then
      LogString("removing player " .. idx)
      self.alive = false
      tanks[idx] = nil
    end
  end,

  draw = function (self)
    if self.alive then
      self.light:setPosition(self.pos+Vector3(0,5,0))
      self.light:enable(true, self.id+2)
      Matrix():bind(WORLD)
      BindTexture(0, self.material)
      tankModel:draw(Matrix():scale(20.0,20.0,20.0):translate(self.pos+Vector3(0, 15, 0)))
      BindTexture(0)
      drawTrails(self, self.trails, 20, trailPosNode)
      ToggleWireframe(true)
      drawTrails(self, self.serverTrail, 30, trailPosNode)
      ToggleWireframe(false)
    end
  end
}

return Tank