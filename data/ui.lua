ui = {}
local uiButtonImpl = {}

uiButtonImpl.__index = uiButtonImpl
uiButtonImpl.buttons = {}

function uiButtonImpl.handleInput()
  for _,btn in pairs(uiButtonImpl.buttons) do
    local pos = GetMouseXY()
    local pressLeft = GetMouse(MOUSE_LEFT_BUTTON)
    local releaseLeft = GetMouseUp(MOUSE_LEFT_BUTTON)

    if pos[1] > btn.x and pos[1] < btn.xw
      and pos[2] > btn.y and pos[2] < btn.yh then
      btn.hovered = true
    else
      btn.hovered = false
    end

    if btn.hovered and pressLeft then
      btn.clicked = true
    else
      btn.clicked = false
    end

    if btn.hovered and releaseLeft then
      btn:callback()
    end
  end
end

function uiButton(text, x, y, w, h, callback)
  local self = setmetatable({}, uiButtonImpl)
  self.text = text
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.xw = x+w
  self.yh = y+h
  self.hovered = false
  self.clicked = false
  self.callback = callback
  table.insert(uiButtonImpl.buttons, self)
  return self
end

function uiButtonImpl.draw(self)
  local brd = 2
  local x = self.x
  local y = self.y
  local w = self.x+self.w
  local h = self.y+self.h

  local colorBorder = 0xff221d68
  local colorMain = 0xff58548e

  if self.hovered then
    colorMain = 0xff7672ad
  end

  if self.clicked then
    colorMain = 0xff6e6b9e
  end

  DrawQuad(x, w, y, h, colorBorder, 0)
  DrawQuad(x+brd, w-brd, y+brd, h-brd, colorMain, 0)

  uiFont:drawText(0xffe2e2e2, self.text, x, y, self.w, self.h, FONTFLAG_VCENTER|FONTFLAG_CENTER|FONTFLAG_SINGLELINE)
end

local ser
local cli
local resolution = GetResolution()

function ui.init()
  ser = uiButton("Host game", resolution[1]/2-100, 400, 200, 50, function()
    LogString("sukableat")
  end)

  cli = uiButton("Join game", resolution[1]/2-100, 458, 200, 50, function()
    LogString("sukableat")
  end)
end

function ui.input()
  uiButtonImpl.handleInput()
end

function ui.draw()
  titleFont:drawText(0xffe2e2e2, "Neon Slayer", 0, 300, resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
  -- FillScreen(0xFFFFFFFF, false)
  ser:draw()
  cli:draw()
end
