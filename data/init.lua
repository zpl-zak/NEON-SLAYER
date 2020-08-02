net = require "slayernative"

time = 0
player = {}
testAI = {}
light = {}

WORLD_SIZE = 1000.0
WORLD_TILES = {5,5}

hh = require "helpers".global()
cols = require "collisions"

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

local sqrt, sin, cos = math.sqrt, math.sin, math.cos
local r1, r2 =  0          ,  1.0
local g1, g2 = -sqrt( 3 )/2, -0.5
local b1, b2 =  sqrt( 3 )/2, -0.5


--[[--
  @param h a real number between 0 and 2*pi
  @param s a real number between 0 and 1
  @param v a real number between 0 and 1
  @return r g b a
]]
function HSVToRGB( h, s, v, a )
  h=h+math.pi/2--because the r vector is up
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

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

world = nil

state = require("code/state")


-- dofile("code/state.lua")
-- dofile("code/states/menu.lua")
-- dofile("code/states/game.lua")
dofile("trail.lua")
dofile("tank.lua")
dofile("world.lua")
dofile("player.lua")

local testSnd

function lerp(v0, v1, t)
  return v0 + t * (v1 - v0);
end


function _init()
  RegisterFontFile("assets/slkscr.ttf")
  testSnd = Sound("assets/music/Zodik - Cyborg Destiny.ogg")
    -- testsnd4 = Sound("assets/music/Zodik - Future Travel.ogg")
    -- testsnd7 = Sound("assets/music/Zodik - Technology 82.ogg")
    -- testsnd8 = Sound("assets/music/Zodik - Tedox.ogg")
    -- testsnd9 = Sound("assets/music/Zodik - Touch The Sky.ogg")
  testSnd:setVolume(69)
  testSnd:loop(true)
  testSnd:play()

  initWorld()

  math.random()
  math.random()
  math.random()
  math.random()
  addTank(-1)
  -- testAI = addTank()

  setupPlayer()

  light = Light()
  light:setDirection(Vector(-1,-1,1))
  -- light:setSpecular(0xffffff)
  light:setSpecular(0)
  light:setDiffuse(0xffcc99)
  light:setType(LIGHTKIND_DIRECTIONAL)
  light:enable(true, 0)

  -- Set up network update event
  net.setUpdate(function (entity_id, x, y, z, r, c, islocal, serverTrail)
    if state:is("connecting") then
      state:switch("game")
    end

    if islocal == 1 then
      if serverTrail ~= nil then
        tanks[-1].serverTrail = serverTrail
      end
      return
    end

    if tanks[entity_id] == nil then
      addTank(entity_id, c)
      tanks[entity_id].pos = Vector3(x, y, z)
    end

    local tank = tanks[entity_id]

    tank.color = c
    -- tank.pos = Vector3(x,y,z)
    local nx = lerp(tank.pos:x(), x, 0.1)
    local ny = lerp(tank.pos:y(), y, 0.1)
    local nz = lerp(tank.pos:z(), z, 0.1)
    tank.pos = Vector3(nx, ny, nz)
    tank.rot = Matrix():rotate(r+math.rad(90),0,0)
    tank.aliveTime = getTime() + 5
    tank.heading = r

    if serverTrail ~= nil then
      tank.serverTrail = serverTrail
    end
    updateTrail(tank)

    -- LogString("_net_tankupdate: " .. entity_id .. " pos: " .. x .. " " .. y .. " " .. z)
  end)

  net.setCollide(function(killer_id, victim_id)
    if victim_id == -1 then
      state:switch("death")
      LogString("BOOM WE GOT KILLED BY " .. killer_id)
    else
      if tanks[victim_id] ~= nil then
        LogString("Removing PLAYERS TRAIL KILLING IT AND STUFF")
        tanks[victim_id].alive = false
        tanks[victim_id].trails = {}
      end
    end
  end)

  net.setRespawn(function(entity_id)
      LogString("SPAWNING PLAYERS  STUFF")
      local tank = tanks[entity_id]
      tank.alive = true
      tank.trails = {}
  end)

  -- ui.init()
  -- state.add("menu", createMenu())
  -- state.add("game", createGame())
  -- state.switch("menu")
  state:add("menu", require "code/states/menu" ())
  state:add("game", require "code/states/game" ())
  state:add("death", require "code/states/death" ())
  state:add("pause", require "code/states/pause" ())
  state:add("connecting", require "code/states/connecting" ())
  state:switch("menu")
  ui.init()
end

function _destroy()
   net.disconnect()
   net.serverStop()
end

function _update(dt)
  net.update()


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

  updateTanks(dt)
  -- updateTestAI()
  player:update(dt, net)

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
  player.cam:bind(VIEW)
  -- SetFog(VectorRGBA(0,0,25,255), FOGKIND_LINEAR, 600, 1300)
  light:setDirection(Vector(-0.6,-1,-0.7))
  drawWorld()
  drawTanks()
  local wmat = Matrix():scale(WORLD_TILES[1], WORLD_TILES[1], WORLD_TILES[1])
  boundsMesh:draw(wmat)
  -- state.draw()

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
--   titleFont:drawText(0xFFFFFFFF, [[
-- WASD - move
-- shift - brake
--   ]], 15, 30)


  state:draw2d()
end

function updateTestAI()
  testAI.movedir = (player.tank.pos - testAI.pos):normalize()*0.001
end
