--!strict
--[[
Purpose: Gentle motion on the hub window: a softly rotating accent edge around the window and a slow drift of the
         backdrop gradient's angle
Input: The library (ScreenGui, current Theme) and the context cleanup list; does nothing outside Roblox
Output: attach() returns nothing; the edge, the tween and the frame connection are removed by the cleanup
Dependencies: Theme
]]

local Theme = require("./Theme")
local ENV: { [string]: any } = getfenv()

local EDGE_NAME = "ViperEdge"
local EDGE_THICKNESS = 1.4
local EDGE_ALPHA = 0.25
local EDGE_DEGREES_PER_SECOND = 40
local DRIFT_SECONDS = 9
local DRIFT_DEGREES = 18
local COLOR_REFRESH_SECONDS = 1

local Ambient = {}

local function themeColor(library: any): any
    local theme: any = if type(library) == "table" then library.Theme else nil
    local value: any = if type(theme) == "table" then theme.Outline else nil
    if type(value) == "userdata" or type(value) == "vector" then
        return value
    end
    return Theme.color("primary")
end

-- Bright accent spots on a faint ring: two highlights chase each other around the window.
local function edgeColors(accent: any): any
    local light = accent:Lerp(ENV.Color3.new(1, 1, 1), 0.55)
    return ENV.ColorSequence.new({
        ENV.ColorSequenceKeypoint.new(0, accent),
        ENV.ColorSequenceKeypoint.new(0.25, light),
        ENV.ColorSequenceKeypoint.new(0.5, accent),
        ENV.ColorSequenceKeypoint.new(0.75, light),
        ENV.ColorSequenceKeypoint.new(1, accent),
    })
end

--- Adds the moving edge and the backdrop drift to the window under library.ScreenGui.
function Ambient.attach(library: any, cleanup: { add: (() -> ()) -> () })
    local gui: any = if type(library) == "table" then library.ScreenGui else nil
    if gui == nil or ENV.Instance == nil or ENV.ColorSequence == nil then
        return
    end
    local fill: any = nil
    for _, object in gui:GetDescendants() do
        if object.Name == "Background" and object:IsA("ImageLabel") then
            fill = object
            break
        end
    end
    local window: any = fill and fill.Parent
    if not window or not window:IsA("GuiObject") or window:FindFirstChild(EDGE_NAME) then
        return
    end
    local accent = themeColor(library)
    local stroke = ENV.Instance.new("UIStroke")
    stroke.Name = EDGE_NAME
    stroke.ApplyStrokeMode = ENV.Enum.ApplyStrokeMode.Border
    stroke.Thickness = EDGE_THICKNESS
    stroke.Transparency = EDGE_ALPHA
    stroke.Color = ENV.Color3.new(1, 1, 1)
    local gradient = ENV.Instance.new("UIGradient")
    gradient.Color = edgeColors(accent)
    gradient.Parent = stroke
    stroke.Parent = window

    local runService: any = (ENV.game :: any):GetService("RunService")
    local lastColorCheck = 0
    local heartbeat = runService.Heartbeat:Connect(function(delta: number)
        gradient.Rotation = (gradient.Rotation + EDGE_DEGREES_PER_SECOND * delta) % 360
        lastColorCheck += delta
        if lastColorCheck >= COLOR_REFRESH_SECONDS then
            lastColorCheck = 0
            local current = themeColor(library)
            if current ~= accent then
                accent = current
                gradient.Color = edgeColors(accent)
            end
        end
    end)

    -- The backdrop's own gradient (set by the theme) leans back and forth a little.
    local drift: any = nil
    local backdrop: any = fill:FindFirstChildOfClass("UIGradient")
    if backdrop then
        pcall(function()
            local tweenService: any = (ENV.game :: any):GetService("TweenService")
            local info = ENV.TweenInfo.new(
                DRIFT_SECONDS,
                ENV.Enum.EasingStyle.Sine,
                ENV.Enum.EasingDirection.InOut,
                -1,
                true
            )
            drift = tweenService:Create(backdrop, info, { Rotation = backdrop.Rotation + DRIFT_DEGREES })
            drift:Play()
        end)
    end

    cleanup.add(function()
        pcall(function()
            heartbeat:Disconnect()
        end)
        if drift then
            pcall(function()
                drift:Cancel()
            end)
        end
        pcall(function()
            stroke:Destroy()
        end)
    end)
end

return Ambient
