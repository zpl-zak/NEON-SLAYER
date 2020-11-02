local class = require "class"

local nowPlayingFont = Font("Silkscreen", 42)
local musicTitleFont = Font("Silkscreen", 35)

local DURATION_FADEINOUT = 2
local DURATION_FADESTAY = 5

local FADE_IN = 1
local FADE_STAY = 2
local FADE_OUT = 3

local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local function setupTrack(name)
    local snd = Music("assets/music/"..name..".ogg")
    snd:setVolume(69)
    return {name, snd}
end

class "MusicManager" {
    __init__ = function (self)
        self.tracks = {
            "Zodik - Cyborg Destiny",
            "Zodik - Driz",
            "Zodik - Future Travel",
            "Zodik - Technology 82",
            "Zodik - Tedox",
            "Zodik - Touch The Sky",
        }

        self.trackId = 0

        self.tracks = shuffle(self.tracks)

        self.music = {}

        for _, tr in pairs(self.tracks) do
            table.insert(self.music, setupTrack(tr))
        end

        self.playing = nil
        self.fade = 0
        self.fadestate = 1
        self.time = 0
        self.alpha = 0
    end,

    update = function (self, dt)
        self.time = self.time + dt
        local skip = false

        if GetKeyDown("n") then
            skip = true

            if self.playing ~= nil then
                self.playing[2]:stop()
            end
        end

        if skip or self.playing == nil or not self.playing[2]:isPlaying() then
            self.trackId = self.trackId + 1

            if self.trackId > #self.music then
                self.trackId = 1
            end

            self.playing = self.music[self.trackId]
            self.playing[2]:play()
            self.time = 0
            self.fade = self.time + DURATION_FADEINOUT
            self.fadestate = FADE_IN
        end

        self.playing[2]:setVolume(math.floor(config.volume.music*100))
    end,

    draw2d = function (self)
        local targetAlpha = 0
        if self.fade > 0 and self.fadestate == FADE_IN then
            local t = self.time/self.fade
            targetAlpha = 255

            if t > 1 then
                self.fadestate = FADE_STAY
                self.fade = self.time+DURATION_FADESTAY
            end
        end

        if self.fade > 0 and self.fadestate == FADE_OUT then
            local t = (self.time/self.fade)
            targetAlpha = 0

            if t > 1 then
                self.fadestate = FADE_IN
                self.fade = 0
            end
        end

        if self.fade > 0 and self.fadestate == FADE_STAY then
            local t = self.time/self.fade
            targetAlpha = 255

            if t > 1 then
                self.fadestate = FADE_OUT
                self.fade = self.time+DURATION_FADEINOUT
            end
        end

        self.alpha = lerp(self.alpha, targetAlpha, 0.015)

        if self.playing then
            nowPlayingFont:drawText(Color(255, 255, 255, math.floor(self.alpha)), "Now Playing", 15, 40, 0, 0, FONTFLAG_NOCLIP)
            musicTitleFont:drawText(Color(255, 255, 255, math.floor(self.alpha)), self.playing[1], 30, 80, 0, 0, FONTFLAG_NOCLIP)
        end
    end
}

return MusicManager()
