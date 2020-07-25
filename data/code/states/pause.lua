local class = require("code/class")
local state = require("code/state")
local AbstractState = require("code/states/abstract")

return class "PausedState" (AbstractState) {
    __init__ = function(self)
        AbstractState.__init__(self)
        self.elements = {}

        local padding = 8
        local groupMargin = 25
        local buttonHeight = 50
        local yoffset = 200

        yoffset = yoffset + buttonHeight + padding
        local btnDisconnect = uiButton("Disconnect", self.resolution[1]/2-100, yoffset, 200, 50, function()
            net.disconnect()
            net.serverStop()
            state:switch("menu")
        end)

        yoffset = yoffset + groupMargin

        yoffset = yoffset + buttonHeight + padding
        local btnDiscord = uiButton("Our discord", self.resolution[1]/2-100, yoffset, 200, 50, function()
            net.openLink()
        end)

        yoffset = yoffset + buttonHeight + padding
        local btnQuit = uiButton("Quit", self.resolution[1]/2-100, yoffset, 200, 50, function()
            ExitGame()
        end)

        table.insert(self.elements, btnDisconnect)
        table.insert(self.elements, btnDiscord)
        table.insert(self.elements, btnQuit)
    end,

    enter = function(self)
        ShowCursor(true)
        SetCursorMode(CURSORMODE_DEFAULT)
    end,

    update = function(self)
        if GetKeyDown(KEY_ESCAPE) then
            state:switch("game")
        end

        for _,el in pairs(self.elements) do el:update(dt) end
    end,

    draw2d = function(self)
        local title = "You are paused"
        local desc = "(Not really)"

        self.titleFont:drawText(ui.textColor, title, 0, 150, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        self.uiFont:drawText(ui.textColor, desc, 0, 200, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        for _,el in pairs(self.elements) do el:draw() end
    end,
}

