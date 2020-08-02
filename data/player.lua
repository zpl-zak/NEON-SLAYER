SPEED = 1
SEND_TIME = 0.05

function setupPlayer()
    player.pos = Vector3()
    player.cam = Matrix()
    player.tank = tanks[-1]
    player.angles = {0,0}
    player.heading = 0
    player.sendTime = 0
    player.soundEngine = Sound("assets/sounds/engine.wav")

    player.soundEngine:setVolume(85)
    player.soundEngine:loop(true)
end

function player.soundPlay()
    player.soundEngine:play()
end

function player.soundStop()
    player.soundEngine:stop()
end

function player.update(self, dt, net)
    if GetCursorMode() == CURSORMODE_CENTERED then
        mouseDelta = GetMouseDelta()
        self.angles[1] = self.angles[1] + (mouseDelta[1] * dt * 0.15)
        self.angles[2] = self.angles[2] - (mouseDelta[2] * dt * 0.15)
    end

    self.pos = self.pos:lerp(self.tank.pos:neg(), 0.233589)

    self.angles[2] = hh.clamp(-1.15, self.angles[2], 0.15)
    
    self.cam = Matrix()
        :translate(self.pos+self.tank.vel)
        :rotate(-self.angles[1],0,0)
        :rotate(0,self.angles[2],0)
        :translate(Vector3(0,-40,100))

    local rotMat = Matrix()
    :rotate(-self.heading,0,0)

    local fwd = rotMat:col(3)
    local rhs = rotMat:col(1)

    -- spectator cam
    --[[ self.cam = Matrix():lookAt(
        self.pos:neg()+Vector3(-250,500,-250),
        self.pos:neg(),
        Vector3(0,1,0)
    ) ]]

    self.tank.movedir = Vector()
    self.tank.movedir = self.tank.movedir + fwd*SPEED*dt*0.5

    if not state:is("game") then
        self.heading = self.heading + 1.65 * dt
        self.tank.movedir = self.tank.movedir + fwd*SPEED*dt*0.5
        self.tank.rot = Matrix():rotate(self.heading+math.rad(90),0,0)

        self.cam = Matrix():lookAt(
            Vector3(0,800,0),
            Vector3((WORLD_SIZE*WORLD_TILES[1])/2, 0, (WORLD_SIZE*WORLD_TILES[2])/2),
            Vector3(0,1,0)
        )
    else
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

        player.soundEngine:setFrequency(44100 + math.floor(self.tank.vel:mag() * 4500))
    end

    if self.sendTime < time then
        self.sendTime = time + SEND_TIME
        local npos = self.tank.pos
        net.send(npos:x(), npos:y(), npos:z(), self.heading)
    end
end

