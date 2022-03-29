local class = require "class"

return class "State" {
    __init__ = function(self)
        self.resolution = GetResolution()
        self.titleFont = Font("Silkscreen", 36, 1, false)
        self.uiFont = Font("Silkscreen", 14, 1, false)
    end,

    enter = function(self) end,
    leave = function(self)
        ui.focusableElements = {}
        ui.tabIndex = 1
    end,

    draw = function(self) end,
    draw2d = function(self) end,
    update = function(self) end,
    input = function(self) end,
}

