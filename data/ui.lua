ui = {
  -- containers
  buttons = {},
  inputs = {},

  -- settings
  borderWidth = 2,
  borderColor = 0xffA188C7,
  textColor = 0xffe2e2e2,

  -- internals
  focused = nil,
  blinker = 0,
}

-- BUTTONS

local uiButtonImpl = {}
uiButtonImpl.__index = uiButtonImpl

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
  table.insert(ui.buttons, self)
  return self
end

function uiButtonImpl.draw(self)
  local brd = ui.borderWidth
  local x = self.x
  local y = self.y
  local w = self.x+self.w
  local h = self.y+self.h

  local colorMain = 0xff58548e
  if self.hovered then colorMain = 0xff7672ad end
  if self.clicked then colorMain = 0xff6e6b9e end

  DrawQuad(x, w, y, h, ui.borderColor, 0)
  DrawQuad(x+brd, w-brd, y+brd, h-brd, colorMain, 0)

  uiFont:drawText(ui.textColor, self.text, x, y, self.w, self.h, FONTFLAG_VCENTER|FONTFLAG_CENTER|FONTFLAG_SINGLELINE)
end

-- INPUTS

local uiInputImpl = {}
uiInputImpl.__index = uiInputImpl

function uiInput(placeholder, x, y, w, h, callback)
  local self = setmetatable({}, uiInputImpl)
  self.text = placeholder
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.xw = x+w
  self.yh = y+h
  self.hovered = false
  self.focused = false
  self.value = ""
  self.callback = callback
  table.insert(ui.inputs, self)
  return self
end

function uiInputImpl.draw(self)
  local brd = ui.borderWidth
  local padding = 8
  local x = self.x
  local y = self.y
  local w = self.x+self.w
  local h = self.y+self.h

  local colorMain = 0xffBDBBDC
  if self.hovered then colorMain = 0xffC5C4E0 end
  if ui.focused == self then colorMain = 0xffE6E4FF end

  DrawQuad(x, w, y, h, ui.borderColor, 0)
  DrawQuad(x+brd, w-brd, y+brd, h-brd, colorMain, 0)

  if self.value == "" then
    uiFont:drawText(0xff9085AA, self.text, x+padding+4, y, self.w-padding*2, self.h, FONTFLAG_VCENTER|FONTFLAG_LEFT|FONTFLAG_SINGLELINE)
  else
    uiFont:drawText(0xff5C4E7D, self.value, x+padding, y, self.w-padding*2, self.h, FONTFLAG_VCENTER|FONTFLAG_LEFT|FONTFLAG_SINGLELINE)
  end

  if ui.focused == self then
    local blinkerAlpha = 0x0058548e + Color(0, 0, 0, math.abs(math.sin(ui.blinker / 60)) * 255)
    local size = uiFont:measureText(self.value, 0)
    local cursorPos = x + padding + size[1] + 2
    DrawQuad(cursorPos, cursorPos+2, y+brd+16, h-brd-16, blinkerAlpha, 0)
  end
end

-- GENERAL UI

local resolution = GetResolution()

function ui.input()
  local pos = GetMouseXY()

  -- handle buttons
  for _,obj in pairs(ui.buttons) do
    local pressLeft = GetMouse(MOUSE_LEFT_BUTTON)
    local releaseLeft = GetMouseUp(MOUSE_LEFT_BUTTON)

    if pos[1] > obj.x and pos[1] < obj.xw
      and pos[2] > obj.y and pos[2] < obj.yh then
      obj.hovered = true
    else
      obj.hovered = false
    end

    if obj.hovered and pressLeft then
      obj.clicked = true
    else
      obj.clicked = false
    end

    if obj.hovered and releaseLeft and obj.callback then
      obj:callback()
    end
  end

  -- handle inputs
  for _,obj in pairs(ui.inputs) do
    local pressLeft = GetMouse(MOUSE_LEFT_BUTTON)
    local releaseLeft = GetMouseUp(MOUSE_LEFT_BUTTON)

    if pos[1] > obj.x and pos[1] < obj.xw
      and pos[2] > obj.y and pos[2] < obj.yh then
      obj.hovered = true
    else
      obj.hovered = false
    end

    if obj.hovered and pressLeft then
      ui.focused = obj
    end

    if not obj.hovered and pressLeft and ui.focused == obj then
      ui.focused = nil
    end
  end

  -- special hanlding for input fields
  if ui.focused ~= nil then
    if GetKeyDown(KEY_BACK) then
      ui.focused.value = ui.focused.value:sub(1, -2)
    end

    if GetKeyDown(KEY_RETURN) and ui.focused.callback then
      ui.focused:callback(ui.focused.value)
      ui.focused = nil
    end
  end
end

function ui.keypress(key)
  if ui.focused ~= nil then
    ui.focused.value = ui.focused.value .. key
  end
end

function ui.init()
  local padding = 8
  local groupMargin = 25
  local buttonHeight = 50
  local yoffset = 200

  yoffset = yoffset + buttonHeight + padding
  uiInput("Port: 27666", resolution[1]/2-100, yoffset, 200, 50, function(self, value)
    LogString("user submitted string:" .. value)
  end)

  yoffset = yoffset + buttonHeight + padding
  uiButton("Host game", resolution[1]/2-100, yoffset, 200, 50, function()
    LogString("sukableat")
  end)

  yoffset = yoffset + groupMargin

  yoffset = yoffset + buttonHeight + padding
  uiInput("Address: 127.0.0.1", resolution[1]/2-100, yoffset, 200, 50, function(self, value)
    LogString("user submitted string:" .. value)
  end)

  yoffset = yoffset + buttonHeight + padding
  uiInput("Port: 27666", resolution[1]/2-100, yoffset, 200, 50, function(self, value)
    LogString("user submitted string:" .. value)
  end)

  yoffset = yoffset + buttonHeight + padding
  uiButton("Join game", resolution[1]/2-100, yoffset, 200, 50, function()
    LogString("sukableat")
  end)

  yoffset = yoffset + groupMargin

  yoffset = yoffset + buttonHeight + padding
  uiButton("Our discord", resolution[1]/2-100, yoffset, 200, 50, function()
    net.openLink()
  end)

  yoffset = yoffset + buttonHeight + padding
  uiButton("Quit", resolution[1]/2-100, yoffset, 200, 50, function()
    ExitGame()
  end)

  ShowCursor(true)
  SetCursorMode(CURSORMODE_DEFAULT)
end

function ui.draw()
  local title = "Neon Slayer"
  local desc = "Description goes here (yes)"

  titleFont:drawText(ui.textColor, title, 0, 150, resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
  uiFont:drawText(ui.textColor, desc, 0, 200, resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)

  for _,el in pairs(ui.buttons) do el:draw() end
  for _,el in pairs(ui.inputs) do el:draw() end

  ui.blinker = (ui.blinker + 4)
end
