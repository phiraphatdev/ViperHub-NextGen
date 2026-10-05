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

local GHOST_SECONDS = 0.32
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
    local originalClose: any = window.Close
    local originalOpen: any = window.Open
    local quint = ENV.Enum.EasingStyle.Quint
    local quad = ENV.Enum.EasingStyle.Quad
    local back = ENV.Enum.EasingStyle.Back
    local inDir = ENV.Enum.EasingDirection.In
    local outDir = ENV.Enum.EasingDirection.Out
    -- Hiding and showing move a light "ghost" (a few frames) between the window and the open button, and keep the
    -- heavy window (thousands of elements) hidden while WindUI animates its size, so nothing re-lays out per frame.
    local gui: any = if type(library) == "table" then library.ScreenGui else nil
    local savedSize: any = frame and frame.Size
    local function pillRect(): (any, any)
        local openMain: any = window.OpenButtonMain
        local button: any = if type(openMain) == "table" then openMain.Button else nil
        if button and button.AbsoluteSize.X > 0 then
            return button.AbsolutePosition, button.AbsoluteSize
        end
        local viewport: any = (ENV.workspace :: any).CurrentCamera.ViewportSize
        return ENV.Vector2.new(viewport.X / 2 - 60, 74), ENV.Vector2.new(120, 44)
    end
    local function makeGhost(position: any, size: any): (any, any, any)
        local ghost = ENV.Instance.new("Frame")
        ghost.Name = "ViperGhost"
        ghost.BorderSizePixel = 0
        ghost.ZIndex = 500
        ghost.Active = false
        ghost.BackgroundColor3 = ENV.Color3.new(1, 1, 1)
        local origin: any = gui.AbsolutePosition
        ghost.Position = ENV.UDim2.fromOffset(position.X - origin.X, position.Y - origin.Y)
        ghost.Size = ENV.UDim2.fromOffset(size.X, size.Y)
        local cornerItem = ENV.Instance.new("UICorner")
        cornerItem.CornerRadius = ENV.UDim.new(0, 16)
        cornerItem.Parent = ghost
        local backdrop: any = nil
        for _, object in gui:GetDescendants() do
            if object.Name == "Background" and object:IsA("ImageLabel") then
                backdrop = object:FindFirstChildOfClass("UIGradient")
                break
            end
        end
        local fillGradient = ENV.Instance.new("UIGradient")
        if backdrop then
            fillGradient.Color = backdrop.Color
            fillGradient.Rotation = backdrop.Rotation
        else
            fillGradient.Color =
                ENV.ColorSequence.new(ENV.Color3.fromRGB(8, 14, 12), ENV.Color3.fromRGB(14, 32, 26))
        end
        fillGradient.Parent = ghost
        local ghostStroke = ENV.Instance.new("UIStroke")
        ghostStroke.ApplyStrokeMode = ENV.Enum.ApplyStrokeMode.Border
        ghostStroke.Thickness = 1.5
        ghostStroke.Color = themeColor(library)
        ghostStroke.Parent = ghost
        local label = ENV.Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = ENV.UDim2.fromScale(1, 1)
        label.Text = "ViperHub"
        label.TextColor3 = ENV.Color3.new(1, 1, 1)
        label.TextScaled = true
        label.Font = ENV.Enum.Font.GothamBold
        label.ZIndex = 501
        local limit = ENV.Instance.new("UITextSizeConstraint")
        limit.MaxTextSize = 22
        limit.MinTextSize = 8
        limit.Parent = label
        label.Parent = ghost
        ghost.Parent = gui
        return ghost, ghostStroke, label
    end
    local function fly(
        ghost: any,
        stroke: any,
        label: any,
        position: any,
        size: any,
        seconds: number,
        fadeOut: boolean
    )
        local origin: any = gui.AbsolutePosition
        local goal = {
            Position = ENV.UDim2.fromOffset(position.X - origin.X, position.Y - origin.Y),
            Size = ENV.UDim2.fromOffset(size.X, size.Y),
        }
        tweenOf(ghost, seconds, goal, quint, ENV.Enum.EasingDirection.InOut)
        if fadeOut then
            tweenOf(ghost, seconds, { BackgroundTransparency = 1 }, quad, inDir)
            tweenOf(stroke, seconds, { Transparency = 1 }, quad, inDir)
            tweenOf(label, seconds * 0.6, { TextTransparency = 1 }, quad, outDir)
        end
    end
    local busy = false
    local firstOpen = true
    if type(originalClose) == "function" and type(originalOpen) == "function" and frame and gui then
        window.Close = function(...)
            if window.Closed or busy then
                return (originalClose :: any)(...)
            end
            savedSize = frame.Size
            local fromPos, fromSize = frame.AbsolutePosition, frame.AbsoluteSize
            local ghost, ghostStroke, label = makeGhost(fromPos, fromSize)
            label.TextTransparency = 1
            local result = (originalClose :: any)(...)
            frame.Visible = false
            local toPos, toSize = pillRect()
            fly(ghost, ghostStroke, label, toPos, toSize, GHOST_SECONDS, true)
            local taskApi: any = ENV.task
            taskApi.delay(GHOST_SECONDS + 0.05, function()
                ghost:Destroy()
            end)
            return result
        end
        window.Open = function(...)
            -- The first open (right after the window is created) is WindUI's own.
            if firstOpen or not window.Closed or busy then
                firstOpen = false
                return (originalOpen :: any)(...)
            end
            busy = true
            local args = table.pack(...)
            local fromPos, fromSize = pillRect()
            local ghost, ghostStroke, label = makeGhost(fromPos, fromSize)
            ghost.BackgroundTransparency = 0.4
            ghostStroke.Transparency = 0.2
            -- Where the window will be: its last place at its full size.
            local toSize = ENV.Vector2.new(savedSize.X.Offset, savedSize.Y.Offset)
                * (if scaleObj then scaleObj.Scale else 1)
            local toPos = frame.AbsolutePosition
                - ENV.Vector2.new(0, (toSize.Y - frame.AbsoluteSize.Y) * frame.AnchorPoint.Y)
                - ENV.Vector2.new((toSize.X - frame.AbsoluteSize.X) * frame.AnchorPoint.X, 0)
            fly(ghost, ghostStroke, label, toPos, toSize, GHOST_SECONDS, false)
            tweenOf(ghost, GHOST_SECONDS, { BackgroundTransparency = 0 }, quad, outDir)
            tweenOf(label, GHOST_SECONDS * 0.5, { TextTransparency = 1 }, quad, outDir)
            local taskApi: any = ENV.task
            local result: any = nil
            taskApi.delay(GHOST_SECONDS, function()
                result = (originalOpen :: any)(table.unpack(args, 1, args.n))
                -- WindUI grows the window over 0.8 s, re-laying out every element each frame: finish it at once
                -- (a new tween on the same property cancels WindUI's).
                taskApi.delay(0.1, function()
                    tweenOf(frame, 0.05, { Size = savedSize }, quad, outDir)
                    tweenOf(ghost, 0.18, { BackgroundTransparency = 1 }, quad, outDir)
                    tweenOf(ghostStroke, 0.18, { Transparency = 1 }, quad, outDir)
                    if edge then
                        tweenOf(edge, 0.3, { Transparency = EDGE_ALPHA }, quad, outDir)
                    end
                    taskApi.delay(0.2, function()
                        ghost:Destroy()
                        busy = false
                    end)
                end)
            end)
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
