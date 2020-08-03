local class = require("code/class")
local state = require("code/state")
local AbstractState = require("code/states/abstract")

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

