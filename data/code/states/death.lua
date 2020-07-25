local class = require("code/class")
local state = require("code/state")
local AbstractState = require("code/states/abstract")

return class "DeathState" (AbstractState) {
    enter = function(self)
        AbstractState.__init__(self)

        ShowCursor(false)
        SetCursorMode(CURSORMODE_CENTERED)

        self.entertime = getTime() + 5

        tanks["local"].alive = false
    end,


    update = function(self, dt)
        if self.entertime < getTime() then
            state:switch("game")

            tanks["local"].pos = Vector3(
              math.random(WORLD_SIZE,(WORLD_SIZE)*WORLD_TILES[1]),
              20,
              math.random(WORLD_SIZE,(WORLD_SIZE)*WORLD_TILES[2])
            )

            tanks["local"].alive = true
            tanks["local"].trails = {}
        end
    end,

    draw2d = function(self)
        local title = "You've been vaporized"
        local desc = "Restructuing the nano-matter combination..."

        self.titleFont:drawText(ui.textColor, title, 0, 150, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        self.uiFont:drawText(ui.textColor, desc, 0, 200, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
    end,
}

