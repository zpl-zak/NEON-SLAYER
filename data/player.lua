SPEED = 1

local class = require "class"

class "Player" {
    __init__ = function (self)
        self.pos = Vector3()
        self.cam = Matrix()
        self.tank = Tank(-1)
        self.angles = {0,0}
        self.heading = 0
        self.sendTime = 0
        self.soundEngine = Sound("assets/sounds/engine.wav")
        self.soundDeath = Sound("assets/sounds/death.wav")
        self.soundKill = Sound("assets/sounds/kill.wav")
        self.soundEngine:loop(true)
        tanks[-1] = self.tank
    end,

    soundPlay = function (self)
        playSFX(self.soundEngine, 0.85)
    end,

    soundStop = function (self)
        self.soundEngine:stop()
    end,

    draw = function (self)
        self.tank:draw()
    end,

    lookUpdate = function (self, dt)
        if GetCursorMode() == CURSORMODE_CENTERED then
            mouseDelta = GetMouseDelta()
            self.angles[1] = self.angles[1] + (mouseDelta[1] * dt * 0.15)
            self.angles[2] = self.angles[2] - (mouseDelta[2] * dt * 0.15)
        end

        self.angles[2] = hh.clamp(-1.15, self.angles[2], 0.15)

        if not GetMouse(MOUSE_RIGHT_BUTTON) then
            self.heading = hh.lerp(self.heading, self.angles[1], 0.1238772)
        end

        self.tank.rot = Matrix():rotate(self.heading+math.rad(90),0,0)

        if state:is("pause") or state:is("settings") then
            self.cam = Matrix():lookAt(
                Vector3(0,800,0),
                Vector3((WORLD_SIZE*WORLD_TILES[1])/2, 0, (WORLD_SIZE*WORLD_TILES[2])/2),
                Vector3(0,1,0)
            )
        elseif not state:is("game") then
            CameraPerspective(42, 1.0, 25000)
            self.cam = Matrix():lookAt(
                Vector3(10,200,10),
                Vector3((WORLD_SIZE*WORLD_TILES[1])/2, 0, (WORLD_SIZE*WORLD_TILES[2])/2),
                Vector3(0,1,0)
            )
        else
            self.cam = Matrix()
                :translate(self.pos+self.tank.vel)
                :rotate(-self.angles[1],0,0)
                :rotate(0,self.angles[2],0)
                :translate(Vector3(0,-40,100))
        end
    end,

    update = function (self, dt)
        self.pos = self.pos:lerp(self.tank.pos:neg(), 0.233589)

        local rotMat = Matrix()
        :rotate(-self.heading,0,0)

        local fwd = rotMat:col(3)
        local rhs = rotMat:col(1)

        self.tank.movedir = Vector()
        self.tank.movedir = self.tank.movedir + fwd*SPEED*dt*0.5

        if state:is("game") then
            if not GetMouse(MOUSE_RIGHT_BUTTON) then
                self.heading = hh.lerp(self.heading, self.angles[1], 0.1238772)
            end

            self.tank.rot = Matrix():rotate(self.heading+math.rad(90),0,0)

            if GetKey("w") then
                self.tank.movedir = self.tank.movedir + fwd*SPEED*dt*0.5
            end
            if GetKey("s") then
                self.tank.movedir = self.tank.movedir - fwd*SPEED*dt
            end
            if GetKey("a") then
                self.tank.movedir = self.tank.movedir - rhs*SPEED*dt
            end
            if GetKey("d") then
                self.tank.movedir = self.tank.movedir + rhs*SPEED*dt
            end

            if GetKey(KEY_SHIFT) then
                self.tank.vel = self.tank.vel:lerp(Vector3(0,--[[ self.tank.vel:y() ]] 0, 0), 0.04221)
            end

            self.soundEngine:setFrequency(44100 + math.floor(self.tank.vel:mag() * 4500))
        end
    end
}

return Player
