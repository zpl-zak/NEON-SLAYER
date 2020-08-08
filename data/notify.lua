local class = require("class")

local Notify = class "Notify" {
    __init__ = function(self)
        self.queue = {}
    end,

    push = function(self, message, alive)
        table.insert(self.queue, {
            text = message,
            expiresIn = getTime() + (alive or 5.0)
        })
    end,

    empty = function(self)
        return self:current() == nil
    end,

    current = function(self)
        local el = self.queue[1]

        if el ~= nil then
            if el.expiresIn < getTime() then
                table.remove(self.queue, 1)
                return self:current()
            end
        end

        return el
    end,
}

return Notify()
