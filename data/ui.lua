local class = require "class"

ui = {
    font = nil,

    -- settings
    borderWidth = 2,
    borderColor = 0xffA188C7,
    textColor = 0xffe2e2e2,
    textShadowColor = 0xff770055,

    -- internals
    focused = nil,
    blinker = 0,
    tabIndex = 0,
    focusableElements = {},
    res = GetResolution(),
}

function ui.updateFocusables(focusables, idx)
    if idx == nil then
        idx = 1
    end
    focusables = focusables or {}
    ui.focusableElements = focusables
    ui.tabIndex = idx

    if #ui.focusableElements > 0 and idx == 0 then
        ui.tabIndex = ui.tabIndex + 1
        ui.focused = ui.focusableElements[ui.tabIndex]
    end
end

--ui.textShadowColor, desc, 1, off+2, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP
function ui.drawTextShadow(font, text, x, y, w, h, flags)
    font:drawText(ui.textShadowColor, text, x+1, y+2, w, h, flags)
    font:drawText(ui.textColor, text, x, y, w, h, flags)
end

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
            local oldFocus = ui.focused
            ui.focused:callback(ui.focused.value)

            if not oldFocus.keepFocus and ui.focused == oldFocus then
                ui.focused = nil
            end
        end
    end

    if GetKeyDown(KEY_TAB) and GetKey(KEY_SHIFT) then
        if #ui.focusableElements > 0 then
            ui.tabIndex = ui.tabIndex - 1
            if ui.tabIndex < 1 then
                ui.tabIndex = #ui.focusableElements
            end

            ui.focused = ui.focusableElements[ui.tabIndex]
        end
    elseif GetKeyDown(KEY_TAB) then
        if #ui.focusableElements > 0 then
            ui.tabIndex = ui.tabIndex + 1
            if ui.tabIndex > #ui.focusableElements then
                ui.tabIndex = 1
            end

            ui.focused = ui.focusableElements[ui.tabIndex]
        end
    end

    ui.blinker = (ui.blinker + 4)
end

function ui.input(key)
    if ui.focused ~= nil then
        ui.focused.value = ui.focused.value .. key
        if ui.focused.callback ~= nil then
            ui.focused:callback(ui.focused.value)
        end
    end
end

class "uiElem" {
    __init__ = function(self)
        self.keepFocus = false
    end,
}

-- BUTTONS

class "uiButton" (uiElem) {
    __init__ = function(self, text, x, y, w, h, callback)
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
    end,

    draw = function(self)
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
    end,

    update = function(self)
        local pos = GetMouseXY()
        local obj = self

        -- handle buttons
        local pressLeft = GetMouse(MOUSE_LEFT_BUTTON)
        local releaseLeft = GetMouseUp(MOUSE_LEFT_BUTTON)

        if (pos[1] > obj.x and pos[1] < obj.xw
            and pos[2] > obj.y and pos[2] < obj.yh) or ui.focused == self then
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
}

-- INPUTS

class "uiInput" (uiElem) {
    __init__ = function (self, placeholder, x, y, w, h, callback)
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
    end,

    draw = function(self)
        local brd = ui.borderWidth
        local padding = 8
        local x = self.x
        local y = self.y
        local w = self.x+self.w
        local h = self.y+self.h

        local colorMain = 0xffBDBBDC
        if self.hovered then colorMain = 0xffC5C4E0 end
        if ui.focused == self then colorMain = 0xffE6E4FF end

        BindTexture(0)
        DrawQuad(x, w, y, h, ui.borderColor, 0)
        DrawQuad(x+brd, w-brd, y+brd, h-brd, colorMain, 0)

        if self.value == "" then
            ui.font:drawText(0xff9085AA, self.text, x+padding+4, y, self.w-padding*2, self.h, FONTFLAG_VCENTER|FONTFLAG_LEFT|FONTFLAG_SINGLELINE)
        else
            ui.font:drawText(0xff5C4E7D, self.value, x+padding, y, self.w-padding*2, self.h, FONTFLAG_VCENTER|FONTFLAG_LEFT|FONTFLAG_SINGLELINE)
        end

        if ui.focused == self then
            local blinkerAlpha = 0x0058548e + Color(0, 0, 0, math.floor(math.abs(math.sin(ui.blinker / 60)) * 255))
            local size = ui.font:measureText(self.value, 0)
            local cursorPos = x + padding + size[1] + 2
            DrawQuad(cursorPos, cursorPos+2, y+brd+16, h-brd-16, blinkerAlpha, 0)
        end
    end,

    update = function(self)
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

            for i, focusable in ipairs(ui.focusableElements) do
                if focusable == ui.focused then
                    ui.tabIndex = i
                    break
                end
            end
        end

        if not obj.hovered and pressLeft and ui.focused == obj then
            ui.focused = nil
        end
    end
}

-- SLIDERS

class "uiSlider" (uiElem) {
    __init__ = function(self, values, text, x, y, w, h, callback)
        self.text = text
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.xw = x+w
        self.yh = y+h
        self.hovered = false
        self.clicked = false
        self.value = values.cur or 0
        self.minimum = values.min or 0
        self.maximum = values.max or 1
        self.step = values.step or 0.1
        self.callback = callback
        self.keepFocus = true
    end,

    draw = function (self)
        local brd = ui.borderWidth
        local x = self.x
        local y = self.y
        local w = self.x+self.w
        local h = self.y+self.h

        local colorMain = 0xff58548e
        if self.hovered then colorMain = 0xff7672ad end
        if self.clicked then colorMain = 0xff6e6b9e end

        DrawQuad(x, w, y, h, ui.borderColor, 0)

        local px = lerp(x+brd, w-brd-30, self.value)
        local pw = px+30
        DrawQuad(px, pw, y+brd, h-brd, colorMain, 0)

        ui.font:drawText(ui.textColor, self.text, x, y, self.w, self.h, FONTFLAG_VCENTER|FONTFLAG_CENTER|FONTFLAG_SINGLELINE)
    end,

    update = function (self)
        local pos = GetMouseXY()
        local obj = self

        -- handle Sliders
        local pressLeft = GetMouse(MOUSE_LEFT_BUTTON)
        local releaseLeft = GetMouseUp(MOUSE_LEFT_BUTTON)

        if (pos[1] > obj.x and pos[1] < obj.xw
            and pos[2] > obj.y and pos[2] < obj.yh) or obj.clicked or ui.focused == self then
            obj.hovered = true
        else
            obj.hovered = false
        end

        local v = clamp(0, scaleBetween(pos[1], self.minimum, self.maximum, obj.x, obj.xw), 1)

        if obj.hovered and pressLeft then
            obj.clicked = true
        else
            obj.clicked = false
        end

        if obj.clicked and self.value ~= v then
            self.value = v
            obj:callback(v)
        end

        if obj.hovered then
            if GetKeyDown(KEY_LEFT) then
                self.value = clamp(0, self.value - self.step, 1)
                obj:callback(self.value)
            elseif GetKeyDown(KEY_RIGHT) then
                self.value = clamp(0, self.value + self.step, 1)
                obj:callback(self.value)
            end
        end
    end
}
