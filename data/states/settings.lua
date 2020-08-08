local class = require "class"
local state = require("state")
local AbstractState = require("states/abstract")

return class "SettingsState" (AbstractState) {
    __init__ = function(self)
        AbstractState.__init__(self)
        self.elements = {}
        self.offsety = math.floor(self.resolution[2] / 3.0)

        local padding = 8
        local groupMargin = 25
        local buttonHeight = 50
        local yoffset = self.offsety + 50

        yoffset = yoffset + buttonHeight + padding
        local nickname = uiInput("Nickname", self.resolution[1]/2-100, yoffset, 200, 50, function(self, value)
            config.nickname = value
            SaveState(encode(config))
        end)
        nickname.value = config.nickname

        yoffset = yoffset + buttonHeight + padding
        local a1 = uiSlider({cur = config.volume.music}, "Music volume", self.resolution[1]/2-100, yoffset, 200, 50, function(self, value)
            config.volume.music = value
            SaveState(encode(config))
        end)

        yoffset = yoffset + buttonHeight + padding
        local a2 = uiSlider({cur = config.volume.sound}, "SFX volume", self.resolution[1]/2-100, yoffset, 200, 50, function(self, value)
            config.volume.sound = value
            SaveState(encode(config))
        end)

        yoffset = yoffset + groupMargin

        yoffset = yoffset + buttonHeight + padding
        local btnQuit = uiButton("< Back", self.resolution[1]/2-100, yoffset, 200, 50, function()
            state:switch("menu")
        end)

        table.insert(self.elements, a1)
        table.insert(self.elements, a2)
        table.insert(self.elements, nickname)
        table.insert(self.elements, btnQuit)
    end,

    enter = function(self)
        state:setCursor(true)
    end,

    update = function(self)
        for _,el in pairs(self.elements) do el:update(dt) end
    end,

    draw2d = function(self)
        local title = "Settings"
        local desc = "nickname, volume, etc."

        BindTexture(0)
        self.titleFont:drawText(ui.textColor, title, 0, self.offsety, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        self.uiFont:drawText(ui.textColor, desc, 0, self.offsety+50, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        for _,el in pairs(self.elements) do el:draw() end
    end,
}
