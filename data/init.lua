net = require "linesnetworking"

time = 0
player = {}
testAI = {}
light = {}

WORLD_SIZE = 1000.0
WORLD_TILES = {5,5}

hh = require "helpers"
cols = require "collisions"

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

local state = require("code/state")


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
  testSnd = Sound("assets/test.wav")
  testSnd:setVolume(100)
  testSnd:loop(true)
  testSnd:play()
  
  initWorld()
  initTankModel()

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
    if islocal == 1 then
      if serverTrail ~= nil then
        tanks[-1].serverTrail = serverTrail
      end
      return
    end

    if tanks[entity_id] == nil then
      addTank(entity_id, c)
    end
  
    local tank = tanks[entity_id]
    
    -- detect if we started moving
    local tp = Vector3(x,y,z)
    if (tank.pos-tp):magSq() > 2.0 then
      tank.alive = true
    end

    tank.color = c
    -- tank.pos = Vector3(x,y,z)
    local nx = lerp(tank.pos:x(), x, 0.5)
    local ny = lerp(tank.pos:y(), y, 0.5)
    local nz = lerp(tank.pos:z(), z, 0.5)
    tank.pos = Vector3(nx, ny, nz)
    tank.rot = Matrix():rotate(r+math.rad(90),0,0)
    tank.aliveTime = getTime() + 5

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
        tanks[victim_id].alive = false
        tanks[victim_id].trails = {}
      end
    end
  end)

  -- ui.init()
  -- state.add("menu", createMenu())
  -- state.add("game", createGame())
  -- state.switch("menu")
  state:add("menu", require "code/states/menu" ())
  state:add("game", require "code/states/game" ())
  state:add("death", require "code/states/death" ())
  state:add("pause", require "code/states/pause" ())
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

  -- if IsFocused() then
  --   ShowCursor(false)
  --   SetCursorMode(CURSORMODE_CENTERED)
  -- else
  --   ShowCursor(true)
  --   SetCursorMode(CURSORMODE_DEFAULT)
  -- end

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
