local class = require "class"
local state = require("state")
local AbstractState = require("states/abstract")

return class "GameState" (AbstractState) {
    enter = function(self)
        state:setCursor(false)
        localPlayer:soundPlay()
    end,

    leave = function(self)
        localPlayer:soundStop()
    end,

    update = function(self)
        if GetKeyDown(KEY_ESCAPE) then
            state:switch("pause")
        end
    end,

    draw2d = function(self)
        if not notify:empty() then
            local msg = notify:current()
            local title = msg.text
            local off = math.floor(self.resolution[2]/4.0)
            self.titleFont:drawText(ui.textShadowColor, title, 2, off+4, self.resolution[1], 25, FF_SINGLELINE|FF_CENTER|FF_NOCLIP)
            self.titleFont:drawText(ui.textColor, title, 0, off, self.resolution[1], 25, FF_SINGLELINE|FF_CENTER|FF_NOCLIP)
        end
    end,
}

