local class = require("code/class")
local state = require("code/state")
local AbstractState = require("code/states/abstract")

return class "GameState" (AbstractState) {
    enter = function(self)
        ShowCursor(false)
        SetCursorMode(CURSORMODE_CENTERED)
    end,

    update = function(self)
        if GetKeyDown(KEY_ESCAPE) then
            state:switch("pause")
        end
    end,
}

