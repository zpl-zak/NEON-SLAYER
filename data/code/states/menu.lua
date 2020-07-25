local class = require("code/class")
local state = require("code/state")
local AbstractState = require("code/states/abstract")

dofile("code/ui.lua")

return class "MenuState" (AbstractState) {
    __init__ = function(self)
        AbstractState.__init__(self)

        self.elements = {}

        local padding = 8
        local groupMargin = 25
        local buttonHeight = 50
        local yoffset = 200

        -- self.layout = {
        --     "clientPort" = ui.Input("Port: 27666", self.resolution[1]/2-100, yoffset, 200, 50),

        -- }

        yoffset = yoffset + buttonHeight + padding
        local inpHostPort = uiInput("Port: 27666", self.resolution[1]/2-100, yoffset, 200, 50)

        yoffset = yoffset + buttonHeight + padding
        local btnHostStart = uiButton("Host game", self.resolution[1]/2-100, yoffset, 200, 50, function()
            local port = inpHostPort.value ~= "" and tonumber(inpHostPort.value) or 27666
            net.serverStart(port)
            net.connect("localhost", port)
            state:switch("game")
        end)

        yoffset = yoffset + groupMargin

        yoffset = yoffset + buttonHeight + padding
        local inpJoinHost = uiInput("Address: 127.0.0.1", self.resolution[1]/2-100, yoffset, 200, 50)

        yoffset = yoffset + buttonHeight + padding
        local inpJoinPort = uiInput("Port: 27666", self.resolution[1]/2-100, yoffset, 200, 50)

        yoffset = yoffset + buttonHeight + padding
        local btnJoinStart = uiButton("Join game", self.resolution[1]/2-100, yoffset, 200, 50, function()
            local host = inpJoinHost.value ~= "" and tonumber(inpJoinHost.value) or "inlife.no-ip.org"
            local port = inpJoinPort.value ~= "" and tonumber(inpJoinPort.value) or 27666
            net.connect(host, port)
            state:switch("game")
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

        table.insert(self.elements, inpHostPort)
        table.insert(self.elements, inpJoinHost)
        table.insert(self.elements, inpJoinPort)
        table.insert(self.elements, btnHostStart)
        table.insert(self.elements, btnJoinStart)
        table.insert(self.elements, btnDiscord)
        table.insert(self.elements, btnQuit)
    end,

    draw2d = function(self)
        local title = "Neon Slayer"
        local desc = "Description goes here (yes)"

        self.titleFont:drawText(ui.textColor, title, 0, 150, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        self.uiFont:drawText(ui.textColor, desc, 0, 200, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)

        for _,el in pairs(self.elements) do el:draw() end
    end,

    update = function(self, dt)
        for _,el in pairs(self.elements) do el:update(dt) end
    end,

    enter = function(self)
        ShowCursor(true)
        SetCursorMode(CURSORMODE_DEFAULT)
    end,
}
