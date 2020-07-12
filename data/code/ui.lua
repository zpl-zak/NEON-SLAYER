ui = {
  font = nil,

  -- settings
  borderWidth = 2,
  borderColor = 0xffA188C7,
  textColor = 0xffe2e2e2,

  -- internals
  focused = nil,
  blinker = 0,
}

function ui.init()
  ui.font = Font("Silkscreen", 14, 1, false)
end

function ui.update()
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

  ui.blinker = (ui.blinker + 4)
end

function ui.input(key)
  if ui.focused ~= nil then
    ui.focused.value = ui.focused.value .. key
  end
end

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

  ui.font:drawText(ui.textColor, self.text, x, y, self.w, self.h, FONTFLAG_VCENTER|FONTFLAG_CENTER|FONTFLAG_SINGLELINE)
end

function uiButtonImpl.update(self)
  local pos = GetMouseXY()
  local obj = self

  -- handle buttons
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
    ui.font:drawText(0xff9085AA, self.text, x+padding+4, y, self.w-padding*2, self.h, FONTFLAG_VCENTER|FONTFLAG_LEFT|FONTFLAG_SINGLELINE)
  else
    ui.font:drawText(0xff5C4E7D, self.value, x+padding, y, self.w-padding*2, self.h, FONTFLAG_VCENTER|FONTFLAG_LEFT|FONTFLAG_SINGLELINE)
  end

  if ui.focused == self then
    local blinkerAlpha = 0x0058548e + Color(0, 0, 0, math.abs(math.sin(ui.blinker / 60)) * 255)
    local size = ui.font:measureText(self.value, 0)
    local cursorPos = x + padding + size[1] + 2
    DrawQuad(cursorPos, cursorPos+2, y+brd+16, h-brd-16, blinkerAlpha, 0)
  end
end

function uiInputImpl.update(self)
  local pos = GetMouseXY()
  local obj = self
  local pressLeft = GetMouse(MOUSE_LEFT_BUTTON)

  -- handle inputs
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
