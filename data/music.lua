local class = require "class"

local nowPlayingFont = Font("Silkscreen", 42)
local musicTitleFont = Font("Silkscreen", 35)

local DURATION_FADEINOUT = 2
local DURATION_FADESTAY = 5

local FADE_IN = 1
local FADE_STAY = 2
local FADE_OUT = 3

local tween = require "tween"
local musicTransition = tween.Layer("ui")
local musicAction = tween.Action(false)
local musicAnim = tween.Tween()
musicTransition:add(tween.Keyframe(0, tween.FramePose():withProp(0)))
musicTransition:add(tween.Keyframe(DURATION_FADEINOUT, tween.FramePose():withProp(255)))
musicTransition:add(tween.Keyframe(DURATION_FADESTAY, tween.FramePose():withProp(255)))
musicTransition:add(tween.Keyframe(DURATION_FADESTAY+DURATION_FADEINOUT, tween.FramePose():withProp(0)))
musicAction:add("ui", musicTransition)


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
            musicAnim:play(musicAction)
        end

        self.playing[2]:setVolume(math.floor(config.volume.music*100))
        musicAnim:update(dt)
    end,

    draw2d = function (self)
        local targetAlpha = musicAnim:getPose("ui"):getProp()
        self.alpha = lerp(self.alpha, targetAlpha, 0.015)

        if self.playing then
            nowPlayingFont:drawText(Color(255, 255, 255, math.floor(self.alpha)), "Now Playing", 15, 40, 0, 0, FONTFLAG_NOCLIP)
            musicTitleFont:drawText(Color(255, 255, 255, math.floor(self.alpha)), self.playing[1], 30, 80, 0, 0, FONTFLAG_NOCLIP)
        end
    end
}

return MusicManager()
