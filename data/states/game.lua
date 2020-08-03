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
}

