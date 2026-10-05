--!strict
--[[
Purpose: Hover and press effects on hub cards and buttons: a glow that follows the mouse, an accent outline, the
         card's title growing a little, and a ripple from the click point
Input: The library (ScreenGui, current Theme), and the context cleanup list; all optional outside Roblox
Output: attach() returns nothing; every connection and effect instance is removed by the cleanup
Dependencies: Theme
]]

local Theme = require("./Theme")
local ENV: { [string]: any } = getfenv()

local MIN_WIDTH = 110
local MIN_HEIGHT = 26
local MAX_HEIGHT = 200 -- taller buttons are containers (a card holding a list): hovering a row inside is not hovering the card
local GLOW_NAME = "ViperGlow"
local SCALE_NAME = "ViperTitleScale"
local GLOW_ALPHA = 0.8
local FADE_SECONDS = 0.18
local CORNER_RADIUS = 14
local MAX_DEPTH = 8
local SECTION_RATIO = 1.5
local EDGE_FADE = 0.55 -- gradient transparency at the card edges: the whole card tints, the cursor spot is brighter
local STROKE_ALPHA = 0.35 -- accent outline while hovered
local STROKE_THICKNESS = 1.5
local TITLE_SCALE = 1.06 -- the title grows from its left edge; the card itself never scales (scaled text shimmers)
local TITLE_SECONDS = 0.16
local RIPPLE_SECONDS = 0.5
local RIPPLE_ALPHA = 0.65

local HoverGlow = {}

local function isButton(object: any): boolean
    return object:IsA("TextButton") or object:IsA("ImageButton")
end

-- A card's UIPadding shrinks the area its children's scale sizes refer to; cancel it so the effects cover the box.
local function fit(frame: any, card: any)
    local pad: any = card:FindFirstChildOfClass("UIPadding")
    local width = card.AbsoluteSize.X
    local height = card.AbsoluteSize.Y
    local left, top = 0, 0
    if pad then
        left = pad.PaddingLeft.Scale * width + pad.PaddingLeft.Offset
        top = pad.PaddingTop.Scale * height + pad.PaddingTop.Offset
    end
    -- Fixed pixel size (not scale): a scale size inside an auto-sized card feeds back and grows the card forever.
    frame.Size = ENV.UDim2.fromOffset(width, height)
    frame.Position = ENV.UDim2.fromOffset(-left, -top)
end

local function corner(parent: any, radius: any)
    local item = ENV.Instance.new("UICorner")
    item.CornerRadius = radius
    item.Parent = parent
end

-- Builds the effect layer once per card: the glow fill and the accent outline.
local function buildGlow(card: any, color: any): any
    local create = ENV.Instance
    local glow = create.new("Frame")
    glow.Name = GLOW_NAME
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 0
    glow.ZIndex = 1
    glow.Active = false
    corner(glow, ENV.UDim.new(0, CORNER_RADIUS))
    local gradient = create.new("UIGradient")
    gradient.Transparency = ENV.NumberSequence.new({
        ENV.NumberSequenceKeypoint.new(0, EDGE_FADE),
        ENV.NumberSequenceKeypoint.new(0.5, 0),
        ENV.NumberSequenceKeypoint.new(1, EDGE_FADE),
    })
    gradient.Parent = glow
    local stroke = create.new("UIStroke")
    stroke.Name = "Edge"
    stroke.ApplyStrokeMode = ENV.Enum.ApplyStrokeMode.Border
    stroke.Color = color
    stroke.Thickness = STROKE_THICKNESS
    stroke.Transparency = 1
    stroke.Parent = glow
    glow.Parent = card
    fit(glow, card)
    return glow
end

-- The active theme's accent (WindUI's `library.Theme.Outline`), so the effects follow theme changes.
local function themeColor(library: any): any
    local theme: any = if type(library) == "table" then library.Theme else nil
    local value: any = if type(theme) == "table" then theme.Outline else nil
    if type(value) == "userdata" or type(value) == "vector" then
        return value
    end
    return Theme.color("primary")
end

--- Starts the hover and press effects on every sizeable button under library.ScreenGui.
function HoverGlow.attach(library: any, cleanup: { add: (() -> ()) -> () })
    local gui: any = if type(library) == "table" then library.ScreenGui else nil
    local color = themeColor(library)
    if gui == nil or color == nil or ENV.Instance == nil or ENV.UDim2 == nil or ENV.NumberSequence == nil then
        return
    end
    local tweenService: any = nil
    local inputService: any = nil
    pcall(function()
        tweenService = (ENV.game :: any):GetService("TweenService")
        inputService = (ENV.game :: any):GetService("UserInputService")
    end)
    local connections: { any } = {}
    local created: { any } = {}
    -- Weak keys: a destroyed button must not be kept alive just because it was wired.
    local wired: { [any]: boolean } = setmetatable({}, { __mode = "k" }) :: any

    local function tween(object: any, seconds: number, goal: { [string]: any }, style: any?)
        if tweenService then
            pcall(function()
                local info = ENV.TweenInfo.new(
                    seconds,
                    style or ENV.Enum.EasingStyle.Quad,
                    ENV.Enum.EasingDirection.Out
                )
                tweenService:Create(object, info, goal):Play()
            end)
        else
            for key, value in goal do
                object[key] = value
            end
        end
    end

    local function wire(button: any)
        if wired[button] then
            return
        end
        wired[button] = true
        local glow: any = nil
        local scale: any = nil
        local hovered = false
        -- The card is the nearest ancestor (or the button itself) that is drawn as a card, so a collapsible
        -- section header glows alone, not its whole body. Elements whose card is not a drawn image fall back to
        -- the ancestor sitting directly in the page's scrolling list; else the button itself.
        local function card(): any
            local node: any = button
            for _ = 1, MAX_DEPTH do
                if node:IsA("ImageButton") and node.AbsoluteSize.X >= MIN_WIDTH then
                    return node
                end
                if node:IsA("ImageLabel") and node.AbsoluteSize.X >= MIN_WIDTH then
                    -- A label card much taller than the button wraps a whole section: glow the button only.
                    return if node.AbsoluteSize.Y <= button.AbsoluteSize.Y * SECTION_RATIO
                        then node
                        else button
                end
                local parent: any = node.Parent
                if parent == nil then
                    break
                end
                if parent:IsA("ScrollingFrame") then
                    return node
                end
                node = parent
            end
            return button
        end
        local function eligible(): boolean
            local owner: any = if glow and glow.Parent then glow.Parent else card()
            return owner.AutomaticSize == ENV.Enum.AutomaticSize.None
                and button.AutomaticSize == ENV.Enum.AutomaticSize.None
                and button.AbsoluteSize.X >= MIN_WIDTH
                and button.AbsoluteSize.Y >= MIN_HEIGHT
                and button.AbsoluteSize.Y <= MAX_HEIGHT
                and button:GetAttribute("NoGlow") ~= true
        end
        local function follow()
            if not glow or not inputService then
                return
            end
            local owner: any = glow.Parent
            local mouse = inputService:GetMouseLocation()
            local width = math.max(owner.AbsoluteSize.X, 1)
            local fraction = math.clamp((mouse.X - owner.AbsolutePosition.X) / width, 0, 1)
            local gradient: any = glow:FindFirstChildOfClass("UIGradient")
            if gradient then
                gradient.Offset = ENV.Vector2.new(fraction - 0.5, 0)
            end
        end
        -- The card's title: the label in its TitleFrame, else its largest visible label. It grows with its own
        -- UIScale (only when WindUI put none there); the card itself never scales.
        local title: any = nil
        local function titleOf(owner: any): any
            local frame: any = owner:FindFirstChild("TitleFrame", true)
            local found: any = frame and frame:FindFirstChildWhichIsA("TextLabel", true)
            if found then
                return found
            end
            local best: any = nil
            for _, descendant in owner:GetDescendants() do
                local item: any = descendant
                if item:IsA("TextLabel") and item.Visible and item.Text ~= "" then
                    if not best or item.TextSize > best.TextSize then
                        best = item
                    end
                end
            end
            return best
        end
        local function grow(target: number)
            local owner: any = glow and glow.Parent
            if not owner then
                return
            end
            if not title or not title.Parent then
                title = titleOf(owner)
                scale = nil
            end
            if not title then
                return
            end
            if not scale or scale.Parent ~= title then
                local existing: any = title:FindFirstChildOfClass("UIScale")
                if existing and existing.Name ~= SCALE_NAME then
                    return
                end
                scale = existing or ENV.Instance.new("UIScale")
                scale.Name = SCALE_NAME
                scale.Parent = title
                table.insert(created, scale)
            end
            tween(scale, TITLE_SECONDS, { Scale = target })
        end
        -- A circle that grows from the click point and fades, clipped to the rounded card by a CanvasGroup.
        local function ripple()
            if not glow or not inputService then
                return
            end
            local create = ENV.Instance
            local group = create.new("CanvasGroup")
            group.Name = "Ripple"
            group.BackgroundTransparency = 1
            group.Size = ENV.UDim2.fromScale(1, 1)
            group.Active = false
            corner(group, ENV.UDim.new(0, CORNER_RADIUS))
            local mouse = inputService:GetMouseLocation()
            local inset: any = nil
            pcall(function()
                inset = (ENV.game :: any):GetService("GuiService"):GetGuiInset()
            end)
            local origin = glow.AbsolutePosition
            local x = mouse.X - origin.X - (if inset then inset.X else 0)
            local y = mouse.Y - origin.Y - (if inset then inset.Y else 0)
            local circle = create.new("Frame")
            circle.AnchorPoint = ENV.Vector2.new(0.5, 0.5)
            circle.Position = ENV.UDim2.fromOffset(x, y)
            circle.Size = ENV.UDim2.fromOffset(0, 0)
            circle.BackgroundColor3 = themeColor(library)
            circle.BackgroundTransparency = RIPPLE_ALPHA
            circle.BorderSizePixel = 0
            corner(circle, ENV.UDim.new(0.5, 0))
            circle.Parent = group
            group.Parent = glow
            local reach = math.max(glow.AbsoluteSize.X, glow.AbsoluteSize.Y) * 2.2
            tween(
                circle,
                RIPPLE_SECONDS,
                { Size = ENV.UDim2.fromOffset(reach, reach), BackgroundTransparency = 1 }
            )
            local taskApi: any = ENV.task
            if type(taskApi) == "table" and type(taskApi.delay) == "function" then
                (taskApi.delay :: any)(RIPPLE_SECONDS + 0.05, function()
                    group:Destroy()
                end)
            end
        end
        local function enter()
            if not eligible() then
                return
            end
            hovered = true
            if not glow or not glow.Parent then
                glow = buildGlow(card(), color)
                table.insert(created, glow)
            end
            local accent = themeColor(library)
            glow.BackgroundColor3 = accent
            local edge: any = glow:FindFirstChild("Edge")
            if edge then
                edge.Color = accent
                tween(edge, FADE_SECONDS, { Transparency = STROKE_ALPHA })
            end
            fit(glow, glow.Parent)
            follow()
            tween(glow, FADE_SECONDS, { BackgroundTransparency = GLOW_ALPHA })
            grow(TITLE_SCALE)
        end
        local function leave()
            hovered = false
            if glow then
                tween(glow, FADE_SECONDS, { BackgroundTransparency = 1 })
                local edge: any = glow:FindFirstChild("Edge")
                if edge then
                    tween(edge, FADE_SECONDS, { Transparency = 1 })
                end
            end
            grow(1)
        end
        table.insert(connections, button.MouseEnter:Connect(enter) :: any)
        table.insert(connections, button.MouseLeave:Connect(leave) :: any)
        table.insert(
            connections,
            button.MouseMoved:Connect(function()
                follow()
            end) :: any
        )
        table.insert(
            connections,
            button.MouseButton1Down:Connect(function()
                if glow and hovered then
                    ripple()
                end
            end) :: any
        )
    end

    for _, object in gui:GetDescendants() do
        if isButton(object) then
            pcall(wire, object)
        end
    end
    table.insert(
        connections,
        gui.DescendantAdded:Connect(function(object: any)
            if isButton(object) then
                pcall(wire, object)
            end
        end) :: any
    )
    cleanup.add(function()
        for _, connection in connections do
            pcall(function()
                connection:Disconnect()
            end)
        end
        for _, item in created do
            pcall(function()
                item:Destroy()
            end)
        end
    end)
end

return HoverGlow
