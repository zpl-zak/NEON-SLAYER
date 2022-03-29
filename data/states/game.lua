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
            local off = math.floor(self.resolution[2]/8.0)
            ui.drawTextShadow(self.titleFont, title, 0, off, self.resolution[1], 25, FF_SINGLELINE|FF_CENTER|FF_NOCLIP)
        else
            local title = "Kills: " .. kills .. " Deaths: " .. deaths
            local off = math.floor(self.resolution[2]/16.0)
            ui.drawTextShadow(self.titleFont, title, 0, off, self.resolution[1], 25, FF_SINGLELINE|FF_CENTER|FF_NOCLIP)

            off = off + 50
            local desc = "You're doing well, keep it up!"
            if deaths > 0 then
                local ratio = kills / (deaths*2)

                if ratio < 0.10 then
                    desc = "Try avoiding other players' trails! :)"
                elseif ratio < 0.25 then
                    desc = "You're doing pretty bad, try harder!"
                elseif ratio < 0.5 then
                    desc = "You're losing your grip, focus!"
                end
            elseif kills == 0 then
                desc = "Try to eliminate other players! :)"
            end

            ui.drawTextShadow(self.uiFont, desc, 0, off, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        end
    end,
}

