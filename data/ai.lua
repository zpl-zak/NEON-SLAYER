-- experimental bot code

local Class = require "class"

Class "AI" {
    __init__ = function (self)
        self.bots = {}
    end,

    addBot = function (self, bot)
        table.insert(self.bots, bot)
    end,

    removeBots = function (self)
        self.bots = {}
    end,

    update = function (self, dt)
        for _, bot in pairs(self.bots) do
            --@todo run ai
        end
    end,
}

return AI()
