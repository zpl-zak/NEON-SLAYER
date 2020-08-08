local class = require "class"

class "StateManager" {
    __init__ = function(self)
        self.registry = {}
        self.history = {}
        self.current = nil
        self.showingCursor = true
    end,

    switch = function(self, newState)
        if newState ~= self.current then
            if self.current ~= nil then
                self.registry[self.current]:leave()
            end

            table.insert(self.history, 1, self.current)
            self.registry[newState]:enter()
            self.current = newState
        end
    end,

    setCursor = function(self, value)
        self.showingCursor = value
    end,

    is = function(self, state)
        return self.current == state
    end,

    previous = function(self, index)
        return self.history[index or 1]
    end,

    add = function(self, name, instance)
        self.registry[name] = instance
    end,

    update = function(self, dt)
        if self.current ~= nil then
            return self.registry[self.current]:update(dt)
        end
    end,

    draw = function(self, dt)
        if self.current ~= nil then
            return self.registry[self.current]:draw(dt)
        end
    end,

    draw2d = function(self, dt)
        if self.current ~= nil then
            return self.registry[self.current]:draw2d(dt)
        end
    end,

    input = function(self, dt)
        if self.current ~= nil then
            return self.registry[self.current]:input(dt)
        end
    end,
}

return StateManager()
