local class = require("code/class")
local AbstractState = require("code/states/abstract")

return class "GameState" (AbstractState) {
    enter = function(self)
        ShowCursor(false)
        SetCursorMode(CURSORMODE_CENTERED)
    end
}

