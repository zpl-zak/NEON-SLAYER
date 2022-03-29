local class = require "class"
local state = require("state")
local AbstractState = require("states/abstract")

dofile("ui.lua")

return class "MenuState" (AbstractState) {
    __init__ = function(self)
        AbstractState.__init__(self)

        self.elements = {}

        local padding = 8
        local groupMargin = 25
        local buttonHeight = 50
        local yoffset = 200

        local inpHostPort
        local inpJoinHost
        local inpJoinPort

        local function hostGame()
            local port = inpHostPort.value ~= "" and tonumber(inpHostPort.value) or 27666
            config.hostPort = port
            SaveState(encode(config))
            nativedll.serverStart(port)
            nativedll.connect("localhost", port)
            isConnected = true
            state:switch("game")
        end

        local function joinGame()
            local host = inpJoinHost.value
            local port = inpJoinPort.value ~= "" and tonumber(inpJoinPort.value) or 27666
            config.host = host
            config.port = port
            SaveState(encode(config))
            nativedll.connect(host, port)
            state:switch("connecting")
            LogString("Connecting to " .. host .. ":" .. port)
        end

        yoffset = yoffset + buttonHeight + padding
        inpHostPort = uiInput("Port: 27666", self.resolution[1]/2-100, yoffset, 200, 50, function ()
            if GetKeyDown(KEY_RETURN) then
                hostGame()
            end
        end)

        yoffset = yoffset + buttonHeight + padding
        local btnHostStart = uiButton("Host game", self.resolution[1]/2-100, yoffset, 200, 50, hostGame)

        yoffset = yoffset + groupMargin

        yoffset = yoffset + buttonHeight + padding
        inpJoinHost = uiInput("Address: 127.0.0.1", self.resolution[1]/2-100, yoffset, 200, 50, function ()
            if GetKeyDown(KEY_RETURN) then
                joinGame()
            end
        end)

        yoffset = yoffset + buttonHeight + padding
        inpJoinPort = uiInput("Port: 27666", self.resolution[1]/2-100, yoffset, 200, 50, function ()
            if GetKeyDown(KEY_RETURN) then
                joinGame()
            end
        end)

        yoffset = yoffset + buttonHeight + padding
        local btnJoinStart = uiButton("Join game", self.resolution[1]/2-100, yoffset, 200, 50, joinGame)

        yoffset = yoffset + groupMargin

        yoffset = yoffset + buttonHeight + padding
        local btnSettings = uiButton("Sound Settings", self.resolution[1]/2-100, yoffset, 200, 50, function()
            state:switch("settings")
        end)

        yoffset = yoffset + buttonHeight + padding
        local btnDiscord = uiButton("Our discord", self.resolution[1]/2-100, yoffset, 200, 50, function()
            nativedll.openLink()
        end)

        yoffset = yoffset + buttonHeight + padding
        local btnQuit = uiButton("Quit", self.resolution[1]/2-100, yoffset, 200, 50, function()
            ExitGame()
        end)

        inpJoinHost.value = tostring(config.host)
        inpJoinPort.value = tostring(config.port)
        inpHostPort.value = tostring(config.hostPort)

        table.insert(self.elements, inpHostPort)
        table.insert(self.elements, btnHostStart)
        table.insert(self.elements, inpJoinHost)
        table.insert(self.elements, inpJoinPort)
        table.insert(self.elements, btnJoinStart)
        table.insert(self.elements, btnSettings)
        table.insert(self.elements, btnDiscord)
        -- table.insert(self.elements, nickname)
        table.insert(self.elements, btnQuit)

        self.focusables = self.elements
    end,

    draw2d = function(self)
        local title = "Neon Slayer"
        local desc = "Description goes here (yes)"

        ui.drawTextShadow(self.titleFont, title, 0, 150, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        ui.drawTextShadow(self.uiFont, desc, 0, 200, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)

        for _,el in pairs(self.elements) do el:draw() end
    end,

    update = function(self, dt)
        for _,el in pairs(self.elements) do el:update(dt) end
    end,

    leave = function (self)
        ui.updateFocusables()
    end,

    enter = function(self)
        state:setCursor(true)

        ui.updateFocusables(self.focusables, 0)
    end,
}
