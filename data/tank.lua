BOUNDS_PUSHBACK = 1
MAX_TRAILS = 150.0
TRAIL_TIME = 0.05
SPHERE_BOUNCE_RADIUS = 50

localPlayerColor = 0

local tankModel = Model("assets/sphere.fbx", false)

-- Sounds
local borderHitSound = Sound("assets/sounds/wallhit.wav")
borderHitSound:setVolume(80)

-- Helpers
local function getTrailPos(t)
    local pos = t.pos
    return {pos:x(), pos:y()+15, pos:z()}
end

local function playHitBorderSound()
    if state.is("game") then playSFX(borderHitSound, 0.25) end
end

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
        self.entity_id = "0"
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
            self.color = color

        end

        local l = Light()
        l:setType(LIGHTKIND_POINT)
        l:setPosition(self.pos)
        l:setDiffuse(0xff9933)
        l:setRange(80)
        l:setAttenuation(0,0.01,0)
        self.light = l

        self:refreshMaterial()
    end,

    refreshMaterial = function (self)
        local trailMaterial = Material("assets/trail.png")
        self.material = trailMaterial

        local r, g, b = HSVToRGB(math.pi*2*(self.color/360), 0.5, 1)
        self.material:setDiffuse(r,g,b)
        self.material:setEmission(r,g,b)
        self.material:setAmbient(r,g,b)

        self.trailMaterial = Material("assets/trail.png")
        self.trailMaterial:setDiffuse(r,g,b)
        self.trailMaterial:setEmission(r,g,b)
        self.trailMaterial:setAmbient(r,g,b)
        self.trailMaterial:setOpacity(1)
        self.trailMaterial:setShaded(false)
        self.trailMaterial:alphaIsTransparency(true)
    end,

    updateTrail = function (self)
        if self.trailTime < time and self.alive then
            self.trailTime = time + TRAIL_TIME

            if #self.trails > MAX_TRAILS then
                table.remove(self.trails, 1)
            end

            if self.pos:magSq() > 0.01 then
                table.insert(self.trails, getTrailPos(self))
            end
        end
    end,

    update = function (self, dt)
        self:updateTrail()

        if not self.alive then
            return
        end

        if self.isLocal and self.color ~= localPlayerColor then
            self.color = localPlayerColor
            self:refreshMaterial()
        end

        if self.isLocal then
            self.vel:y(self.vel:y() - 2*dt)

            if self.vel:y() > 5.0 then
                self.vel:y(5.0)
            end

            world.colsys:forEach(function (shape)
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
                playHitBorderSound()
            end

            if self.pos:z() <= 0 then
                self.vel:z(-self.vel:z() + BOUNDS_PUSHBACK)
                self.pos:x(self.pos:x()+self.vel:x())
                playHitBorderSound()
            end

            if self.pos:x() >= WORLD_SIZE*WORLD_TILES[1] then
                self.vel:x(-self.vel:x() - BOUNDS_PUSHBACK)
                self.pos:x(self.pos:x()+self.vel:x())
                playHitBorderSound()
            end

            if self.pos:z() >= WORLD_SIZE*WORLD_TILES[2] then
                self.vel:z(-self.vel:z() - BOUNDS_PUSHBACK)
                self.pos:z(self.pos:z()+self.vel:z())
                playHitBorderSound()
            end

            if self.pos:y() < -0 then
                self.pos:y(-0)
                self.vel:y(0)
            end

            -- TODO handle proper shit
            for _, ot in pairs(tanks) do
                if ot.isLocal or not ot.alive then goto _ end
                local dist = (ot.pos - self.pos):mag()

                if dist <= SPHERE_BOUNCE_RADIUS then
                    self.vel:x(-self.vel:x()*5)
                    self.vel:z(-self.vel:z()*5)
                end
                ::_::
            end

            -- IMPORTANT: send data to server
            nativedll.send(self.pos:x(), self.pos:y(), self.pos:z(), 0)
        end

        if self.aliveTime ~= nil and self.aliveTime < getTime() then
            LogString("Alive time: " .. self.aliveTime .. " curr: " .. getTime())
            LogString("removing player " .. self.id)
            self.alive = false
            tanks[self.id] = nil
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
            self:drawTrails(self.trails, 20)
            ToggleWireframe(true)
            self:drawTrails(self.serverTrail, 30)
            ToggleWireframe(false)
        end
    end,

    drawTrails = function (self, trails, height)
        for i=1,#trails,1 do
            local tr1 = trails[i]
            local tr2 = trails[i+1]

            local alpha = math.min(i, 20.0) / 20.0

            if tr1 ~= nil then
                if #trails > MAX_TRAILS then
                        self.trailMaterial:setOpacity(alpha)
                end
                if tr2 == nil then
                        tr2 = getTrailPos(self)
                        self.trailMaterial:setOpacity(1)
                end

                BindTexture(0, self.trailMaterial)
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
}

return Tank
