--!strict
--[[
Purpose: A soft glow that follows the mouse over hub cards and buttons (dynamic hover feedback)
Input: The library (ScreenGui, current Theme), and the context cleanup list; all optional outside Roblox
Output: attach() returns nothing; every connection and glow instance is removed by the cleanup
Dependencies: Theme
]]

local Theme = require("./Theme")
local ENV: { [string]: any } = getfenv()

local MIN_WIDTH = 110
local MIN_HEIGHT = 26
local MAX_HEIGHT = 200 -- taller buttons are containers (a card holding a list): hovering a row inside is not hovering the card
local GLOW_NAME = "ViperGlow"
local GLOW_ALPHA = 0.8
local FADE_SECONDS = 0.18
local CORNER_RADIUS = 14
local GLOW_INSET = 0
local MAX_DEPTH = 8
local SECTION_RATIO = 1.5
local EDGE_FADE = 0.55 -- gradient transparency at the card edges: the whole card tints, the cursor spot is brighter

local HoverGlow = {}

local function isButton(object: any): boolean
    return object:IsA("TextButton") or object:IsA("ImageButton")
end

-- A card's UIPadding shrinks the area its children's scale sizes refer to; cancel it so the glow covers the whole box.
local function fit(glow: any, card: any)
    local pad: any = card:FindFirstChildOfClass("UIPadding")
    local width = card.AbsoluteSize.X
    local height = card.AbsoluteSize.Y
    local left, top = 0, 0
    if pad then
        left = pad.PaddingLeft.Scale * width + pad.PaddingLeft.Offset
        top = pad.PaddingTop.Scale * height + pad.PaddingTop.Offset
    end
    -- Fixed pixel size (not scale): a scale size inside an auto-sized card feeds back and grows the card forever.
    glow.Size = ENV.UDim2.fromOffset(width - GLOW_INSET * 2, height - GLOW_INSET * 2)
    glow.Position = ENV.UDim2.fromOffset(GLOW_INSET - left, GLOW_INSET - top)
end

-- Builds the glow once per card: a rounded frame under the content, brightest where the mouse is.
local function buildGlow(card: any, color: any): any
    local create = ENV.Instance
    local glow = create.new("Frame")
    glow.Name = GLOW_NAME
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 0
    glow.ZIndex = 1
    glow.Active = false
    local corner = create.new("UICorner")
    corner.CornerRadius = ENV.UDim.new(0, CORNER_RADIUS)
    corner.Parent = glow
    local gradient = create.new("UIGradient")
    gradient.Transparency = ENV.NumberSequence.new({
        ENV.NumberSequenceKeypoint.new(0, EDGE_FADE),
        ENV.NumberSequenceKeypoint.new(0.5, 0),
        ENV.NumberSequenceKeypoint.new(1, EDGE_FADE),
    })
    gradient.Parent = glow
    glow.Parent = card
    fit(glow, card)
    return glow
end

-- The active theme's accent (WindUI's `library.Theme.Outline`), so the glow follows theme changes.
local function themeColor(library: any): any
    local theme: any = if type(library) == "table" then library.Theme else nil
    local value: any = if type(theme) == "table" then theme.Outline else nil
    if type(value) == "userdata" or type(value) == "vector" then
        return value
    end
    return Theme.color("primary")
end

--- Starts glowing every sizeable button under library.ScreenGui when the mouse is over it.
function HoverGlow.attach(library: any, cleanup: { add: (() -> ()) -> () })
    local gui: any = if type(library) == "table" then library.ScreenGui else nil
    local color = themeColor(library)
    if gui == nil or color == nil or ENV.Instance == nil or ENV.UDim2 == nil or ENV.NumberSequence == nil then
        return
    end
    local tweenService: any = nil
    pcall(function()
        tweenService = (ENV.game :: any):GetService("TweenService")
    end)
    local connections: { any } = {}
    local glows: { any } = {}
    -- Weak keys: a destroyed button must not be kept alive just because it was wired.
    local wired: { [any]: boolean } = setmetatable({}, { __mode = "k" }) :: any
    local inputService: any = nil
    pcall(function()
        inputService = (ENV.game :: any):GetService("UserInputService")
    end)

    local function fade(glow: any, transparency: number)
        if tweenService then
            pcall(function()
                tweenService
                    :Create(glow, ENV.TweenInfo.new(FADE_SECONDS), { BackgroundTransparency = transparency })
                    :Play()
            end)
        else
            glow.BackgroundTransparency = transparency
        end
    end

    local function wire(button: any)
        if wired[button] then
            return
        end
        wired[button] = true
        local glow: any = nil
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
        local function follow()
            if not glow then
                return
            end
            local owner: any = glow.Parent
            if not inputService then
                return
            end
            local mouse = inputService:GetMouseLocation()
            local width = math.max(owner.AbsoluteSize.X, 1)
            local fraction = math.clamp((mouse.X - owner.AbsolutePosition.X) / width, 0, 1)
            local gradient: any = glow:FindFirstChildOfClass("UIGradient")
            if gradient then
                gradient.Offset = ENV.Vector2.new(fraction - 0.5, 0)
            end
        end
        table.insert(
            connections,
            button.MouseEnter:Connect(function()
                local owner: any = glow and glow.Parent or card()
                if
                    owner.AutomaticSize ~= ENV.Enum.AutomaticSize.None
                    or button.AutomaticSize ~= ENV.Enum.AutomaticSize.None
                then
                    return
                end
                if
                    button.AbsoluteSize.X < MIN_WIDTH
                    or button.AbsoluteSize.Y < MIN_HEIGHT
                    or button.AbsoluteSize.Y > MAX_HEIGHT
                    or button:GetAttribute("NoGlow") == true
                then
                    return
                end
                if not glow or not glow.Parent then
                    glow = buildGlow(card(), color)
                    table.insert(glows, glow)
                end
                glow.BackgroundColor3 = themeColor(library)
                fit(glow, glow.Parent)
                follow()
                fade(glow, GLOW_ALPHA)
            end) :: any
        )
        table.insert(
            connections,
            button.MouseMoved:Connect(function()
                follow()
            end) :: any
        )
        table.insert(
            connections,
            button.MouseLeave:Connect(function()
                if glow then
                    fade(glow, 1)
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
        for _, glow in glows do
            pcall(function()
                glow:Destroy()
            end)
        end
    end)
end

return HoverGlow
