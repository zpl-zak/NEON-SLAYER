net = require "linesnetworking"

time = 0
player = {}
testAI = {}
light = {}

WORLD_SIZE = 1000.0
WORLD_TILES = {5,5}

hh = require "helpers"
cols = require "collisions"

world = nil

local state = require("code/state")
local MenuState = require("code/states/menu")
local GameState = require("code/states/game")

-- dofile("code/ui.lua")
-- dofile("code/state.lua")
-- dofile("code/states/menu.lua")
-- dofile("code/states/game.lua")
dofile("trail.lua")
dofile("tank.lua")
dofile("world.lua")
dofile("player.lua")

local testSnd

function _init()
  RegisterFontFile("assets/slkscr.ttf")
  testSnd = Sound("assets/test.wav")
  testSnd:setVolume(100)
  testSnd:loop(true)
  testSnd:play()
  
  initWorld()
  initTankModel()
  setupTrail()

  math.random()
  math.random()
  math.random()
  math.random()
  addTank("local")
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
  net.setUpdate(function (entity_id, x, y, z, r)
    if tanks[entity_id] == nil then
      addTank(entity_id)
    end
  
    local tank = tanks[entity_id]
  
    tank.pos = Vector3(x,y,z)
    tank.heading = r
  
    -- LogString("_net_tankupdate: " .. entity_id .. " pos: " .. x .. " " .. y .. " " .. z)
  end)

  net.setCollide(function(killer_id)
    LogString("BOOM WE GOT KILLED BY " .. killer_id)
  end)

  -- ui.init()
  -- state.add("menu", createMenu())
  -- state.add("game", createGame())
  -- state.switch("menu")
  state:add("menu", MenuState())
  state:add("game", GameState())
  state:switch("menu")
end


function _update(dt)
  net.update()

  -- if GetKeyDown(KEY_ESCAPE) then
  --     ExitGame()
  -- end

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

  -- ui.update()
  -- state.update(dt)
end

function _charInput(key)
  -- ui.input(key)
  -- state.input(key)
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


  -- state.draw2d()
end

function updateTestAI()
  testAI.movedir = (player.tank.pos - testAI.pos):normalize()*0.001
end
