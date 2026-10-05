--!strict
--[[
Purpose: Gentle motion on the hub window: a softly rotating accent edge around the window, a slow drift of the
         backdrop gradient's angle, a shrink/pop animation when the window hides and shows, and a styled open button
         (the pill shown while the window is hidden)
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

local HIDE_SCALE = 0.9
local HIDE_SECONDS = 0.28
local SHOW_SECONDS = 0.45
local PILL_HOVER_SCALE = 1.07
local PILL_POP_FROM = 0.6
local PILL_HALO_ALPHA = 0.82
local PILL_HALO_PULSE_ALPHA = 0.68
local PILL_HALO_PULSE_SECONDS = 1.4

local function tweenOf(object: any, seconds: number, goal: { [string]: any }, style: any, direction: any): any
    local ok, result = pcall(function()
        local tweenService: any = (ENV.game :: any):GetService("TweenService")
        return tweenService:Create(object, ENV.TweenInfo.new(seconds, style, direction), goal)
    end)
    if ok and result then
        result:Play()
        return result
    end
    return nil
end

local function isColor(value: any): boolean
    return type(value) == "userdata" or type(value) == "vector"
end

--- Animates hiding and showing (window:Close/Open, used by the toggle key and the open button) and styles the
--- open button. The window's own UIScale shrinks while it hides and is restored to the user's scale afterwards.
function Ambient.window(window: any, library: any, cleanup: { add: (() -> ()) -> () })
    if type(window) ~= "table" or ENV.Instance == nil then
        return
    end
    local elements: any = window.UIElements
    local frame: any = if type(elements) == "table" then elements.Main else nil
    local scaleObj: any = frame and frame:FindFirstChildOfClass("UIScale")
    local edge: any = frame and frame:FindFirstChild(EDGE_NAME)
    local baseScale: number = if scaleObj then scaleObj.Scale else 1
    local originalClose: any = window.Close
    local originalOpen: any = window.Open
    local quint = ENV.Enum.EasingStyle.Quint
    local quad = ENV.Enum.EasingStyle.Quad
    local back = ENV.Enum.EasingStyle.Back
    local inDir = ENV.Enum.EasingDirection.In
    local outDir = ENV.Enum.EasingDirection.Out
    if type(originalClose) == "function" and type(originalOpen) == "function" and scaleObj then
        window.Close = function(...)
            if not window.Closed then
                baseScale = scaleObj.Scale
                tweenOf(scaleObj, HIDE_SECONDS, { Scale = baseScale * HIDE_SCALE }, quint, inDir)
                if edge then
                    tweenOf(edge, HIDE_SECONDS, { Transparency = 1 }, quad, outDir)
                end
            end
            return (originalClose :: any)(...)
        end
        window.Open = function(...)
            if window.Closed then
                scaleObj.Scale = baseScale * HIDE_SCALE
            end
            local result = (originalOpen :: any)(...)
            tweenOf(scaleObj, SHOW_SECONDS, { Scale = baseScale }, back, outDir)
            if edge then
                tweenOf(edge, SHOW_SECONDS, { Transparency = EDGE_ALPHA }, quad, outDir)
            end
            return result
        end
        cleanup.add(function()
            window.Close = originalClose
            window.Open = originalOpen
        end)
    end

    -- The open button: a dark glassy pill with a rotating accent ring, a pulsing halo, a pop when it appears and a
    -- small grow on hover.
    local openMain: any = window.OpenButtonMain
    local pill: any = if type(openMain) == "table" then openMain.Button else nil
    local holder: any = pill and pill.Parent
    if not pill or not holder then
        return
    end
    local accent = themeColor(library)
    local theme: any = if type(library) == "table" then library.Theme else nil
    local dark: any = if type(theme) == "table" and isColor(theme.Dialog)
        then theme.Dialog
        else ENV.Color3.fromRGB(12, 16, 20)
    pill.BackgroundColor3 = dark
    pill.BackgroundTransparency = 0.06
    local fill = ENV.Instance.new("UIGradient")
    fill.Name = "ViperFill"
    fill.Rotation = 90
    fill.Color = ENV.ColorSequence.new(dark:Lerp(accent, 0.18), dark)
    fill.Parent = pill
    local ring: any = pill:FindFirstChildOfClass("UIStroke")
    local ringGradient: any = ring and ring:FindFirstChildOfClass("UIGradient")
    if ring then
        ring.Thickness = 1.6
        ring.Transparency = 0.1
    end
    if ringGradient then
        ringGradient.Color = edgeColors(accent)
    end
    local halo = ENV.Instance.new("Frame")
    halo.Name = "ViperHalo"
    halo.AnchorPoint = ENV.Vector2.new(0.5, 0.5)
    halo.Position = ENV.UDim2.fromScale(0.5, 0.5)
    halo.Size = ENV.UDim2.new(1, 12, 1, 12)
    halo.BackgroundColor3 = accent
    halo.BackgroundTransparency = PILL_HALO_ALPHA
    halo.BorderSizePixel = 0
    halo.ZIndex = math.max((tonumber(pill.ZIndex) or 1) - 1, 0)
    halo.Active = false
    local haloCorner = ENV.Instance.new("UICorner")
    haloCorner.CornerRadius = ENV.UDim.new(1, 0)
    haloCorner.Parent = halo
    halo.Parent = holder
    local pulse: any = nil
    pcall(function()
        local tweenService: any = (ENV.game :: any):GetService("TweenService")
        local info = ENV.TweenInfo.new(
            PILL_HALO_PULSE_SECONDS,
            ENV.Enum.EasingStyle.Sine,
            ENV.Enum.EasingDirection.InOut,
            -1,
            true
        )
        pulse = tweenService:Create(halo, info, { BackgroundTransparency = PILL_HALO_PULSE_ALPHA })
        pulse:Play()
    end)
    local pillScale: any = pill:FindFirstChildOfClass("UIScale")
    local connections: { any } = {}
    local button: any = pill:FindFirstChildWhichIsA("TextButton")
    if pillScale and button then
        table.insert(
            connections,
            button.MouseEnter:Connect(function()
                tweenOf(pillScale, 0.18, { Scale = PILL_HOVER_SCALE }, back, outDir)
            end) :: any
        )
        table.insert(
            connections,
            button.MouseLeave:Connect(function()
                tweenOf(pillScale, 0.18, { Scale = 1 }, quad, outDir)
            end) :: any
        )
        table.insert(
            connections,
            holder:GetPropertyChangedSignal("Visible"):Connect(function()
                if holder.Visible then
                    pillScale.Scale = PILL_POP_FROM
                    tweenOf(pillScale, 0.4, { Scale = 1 }, back, outDir)
                end
            end) :: any
        )
    end
    local runService: any = (ENV.game :: any):GetService("RunService")
    table.insert(
        connections,
        runService.Heartbeat:Connect(function(delta: number)
            if holder.Visible and ringGradient then
                ringGradient.Rotation = (ringGradient.Rotation + EDGE_DEGREES_PER_SECOND * 1.5 * delta) % 360
            end
        end) :: any
    )
    cleanup.add(function()
        for _, connection in connections do
            pcall(function()
                connection:Disconnect()
            end)
        end
        if pulse then
            pcall(function()
                pulse:Cancel()
            end)
        end
        pcall(function()
            halo:Destroy()
            fill:Destroy()
        end)
    end)
end

return Ambient
