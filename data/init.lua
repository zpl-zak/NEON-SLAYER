-- Deps
hh = require "helpers".global()
cols = require "collisions"

-- Common
dofile("utils.lua")

config = {
    hostPort = "",
    host = "",
    port = "",
    nickname = "",
    volume = {
        music = 0.50,
        sound = 0.75,
    },
}

-- Modules
nativedll = require "slayernative"
music = require "music"
world = require "world"
state = require "state"
notify = require "notify"
gameVersion = require "version"

-- Game
Tank = require "tank"
Player = require "player"

-- Globals
time = 0
tanks = {}

local res = GetResolution()
screenRT = RenderTarget(res[1], res[2])
local aspect = res[1] / res[2]
local hAdd = aspect * 150.0
invTexSize = Vector3(
    1.0 / res[1],
    1.0 / (res[2] + hAdd),
    0.0
)

fxaaShader = Effect("fx/fxaa.fx")
localPlayer = Player()

sun = Light()
sun:setDirection(Vector(-0.6,-1,-0.7))
sun:setSpecular(0)
sun:setDiffuse(0xffcc99)
sun:setType(LIGHTKIND_DIRECTIONAL)
sun:enable(true, 0)

RegisterFontFile("assets/slkscr.ttf")

-- Set up nativedllwork update event
nativedll.setUpdate(function (entity_id, x, y, z, r, color, islocal, serverTrail)
    if state:is("connecting") then
        state:switch("game")
    end

    if islocal == 1 then
        if serverTrail ~= nil then
            tanks[-1].serverTrail = serverTrail
        end
        tanks[-1].entity_id = entity_id
        if tanks[-1].color ~= color then
            tanks[-1].color = color
            tanks[-1]:refreshMaterial()
        end
        return
    end

    if tanks[entity_id] == nil then
        tanks[entity_id] = Tank(entity_id, color)
        tanks[entity_id].pos = Vector3(x, y, z)
    end

    local tank = tanks[entity_id]

    tank.color = color
    -- tank.pos = Vector3(x,y,z)
    local nx = lerp(tank.pos:x(), x, 1.05)
    local ny = lerp(tank.pos:y(), y, 1.05)
    local nz = lerp(tank.pos:z(), z, 1.05)
    tank.pos = Vector3(nx, ny, nz)
    tank.rot = Matrix():rotate(r+math.rad(90),0,0)
    tank.aliveTime = getTime() + 5
    tank.heading = r
    tank.entity_id = entity_id

    if serverTrail ~= nil then
        tank.serverTrail = serverTrail
    end
    tank:updateTrail()
end)

nativedll.setCollide(function(killer_id, victim_id)
    -- ignore state switch when paused
    if not state:is("game") then
        return
    end

    if victim_id == -1 then
        state:switch("death")
        LogString("BOOM WE GOT KILLED BY " .. killer_id)
        playSFX(localPlayer.soundDeath, 0.25)
    else
        if tanks[victim_id] ~= nil then
            if tanks[-1].entity_id == killer_id then
                notify:push("You've annihilated another player")
                playSFX(localPlayer.soundKill, 0.25)
            end
            tanks[victim_id].alive = false
            tanks[victim_id].tails = {}
        end
    end
end)

nativedll.setRespawn(function(entity_id)
    LogString("SPAWNING PLAYERS STUFF: " .. entity_id)
    local tank = tanks[entity_id]

    if tank == nil then return end
    tank.alive = true
    tank.tails = {}
end)

-- TODO: Figure out better place for this
if LoadState() ~= nil then
    config = merge(config, decode(LoadState()))
end

state:add("menu", require "states/menu" ())
state:add("game", require "states/game" ())
state:add("death", require "states/death" ())
state:add("pause", require "states/pause" ())
state:add("connecting", require "states/connecting" ())
state:add("settings", require "states/settings" ())
state:switch("menu")
ui.init()

function _destroy()
    SaveState(encode(config))
    nativedll.disconnect()
    nativedll.serverStop()
end

function _update(dt)
    nativedll.update()
    music:update(dt)

    if GetKey(KEY_CONTROL) and GetKeyDown("R") then
        RestartGame()
    end

    if IsFocused() and not state.showingCursor then
        ShowCursor(false)
        SetCursorMode(CURSORMODE_CENTERED)
    else
        ShowCursor(true)
        SetCursorMode(CURSORMODE_DEFAULT)
    end

    for _, t in pairs(tanks) do
        t:update(dt)
    end

    localPlayer:update(dt)

    time = time + dt

    ui.update()
    state:update(dt)
end

function _charInput(key)
    ui.input(key)
    state:input(key)
end

function _render()
    screenRT:bind()
    EnableLighting(true)
    ClearScene(15,0,15)
    AmbientColor(0x773377)
    CameraPerspective(75, 1.0, 25000)
    Matrix():bind(WORLD)
    localPlayer.cam:bind(VIEW)
    world:draw()
    for _, t in pairs(tanks) do
        t:draw()
    end

    local wmat = Matrix():scale(WORLD_TILES[1], WORLD_TILES[1], WORLD_TILES[1])
    CullMode(CULLKIND_NONE)
    world.boundsMesh:draw(wmat)
    CullMode(CULLKIND_CCW)
    ClearTarget()

    drawEffect(fxaaShader, "FXAA", function (fx)
        fx:setTexture("srcTex", screenRT)
        fx:setVector3("inverseTexSize", invTexSize)
        fx:setFloat("fxaaReduceMul", 1.0 / 8.0)
        fx:setFloat("fxaaReduceMin", 1.0 / 128.0)
        fx:setFloat("fxaaSpanMax", 8.0)
        FillScreen()
    end)
end

function _render2d()
    state:draw2d()
    music:draw2d()

    ui.font:drawText(0xFFFFFFFF, "Version "..gameVersion, 5, 5 + (function() if IsDebugMode() then return 15 else return 0 end end)(), 0, 0, FF_NOCLIP)
end
