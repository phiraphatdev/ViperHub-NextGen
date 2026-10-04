--!strict
--[[
Purpose: A soft glow that follows the mouse over hub cards and buttons (dynamic hover feedback)
Input: The library's ScreenGui, a brand color, and the context cleanup list; all optional outside Roblox
Output: attach() returns nothing; every connection and glow instance is removed by the cleanup
Dependencies: Theme
]]

local Theme = require("./Theme")
local ENV: { [string]: any } = getfenv()

local MIN_WIDTH = 110
local MIN_HEIGHT = 26
local GLOW_NAME = "ViperGlow"
local GLOW_ALPHA = 0.84
local FADE_SECONDS = 0.18
local CORNER_RADIUS = 10

local HoverGlow = {}

local function isButton(object: any): boolean
    return object:IsA("TextButton") or object:IsA("ImageButton")
end

-- Builds the glow once per card: a rounded frame under the content, brightest where the mouse is.
local function buildGlow(card: any, color: any): any
    local create = ENV.Instance
    local glow = create.new("Frame")
    glow.Name = GLOW_NAME
    glow.Size = ENV.UDim2.fromScale(1, 1)
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    glow.Active = false
    local corner = create.new("UICorner")
    corner.CornerRadius = ENV.UDim.new(0, CORNER_RADIUS)
    corner.Parent = glow
    local gradient = create.new("UIGradient")
    gradient.Transparency = ENV.NumberSequence.new({
        ENV.NumberSequenceKeypoint.new(0, 1),
        ENV.NumberSequenceKeypoint.new(0.5, 0),
        ENV.NumberSequenceKeypoint.new(1, 1),
    })
    gradient.Parent = glow
    glow.Parent = card
    return glow
end

--- Starts glowing every sizeable button under gui when the mouse is over it.
function HoverGlow.attach(gui: any, cleanup: { add: (() -> ()) -> () })
    local color = Theme.color("primary")
    if gui == nil or color == nil or ENV.Instance == nil or ENV.UDim2 == nil or ENV.NumberSequence == nil then
        return
    end
    local tweenService: any = nil
    pcall(function()
        tweenService = (ENV.game :: any):GetService("TweenService")
    end)
    local connections: { any } = {}
    local glows: { any } = {}
    local wired: { [any]: boolean } = {}

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
        -- The card is the button's parent when it is the squircle outline; otherwise the button itself.
        local function card(): any
            local parent: any = button.Parent
            if parent and parent:IsA("ImageLabel") and parent.AbsoluteSize.X >= button.AbsoluteSize.X then
                return parent
            end
            return button
        end
        local function follow()
            if not glow then
                return
            end
            local owner: any = glow.Parent
            local mouse = (ENV.game :: any):GetService("UserInputService"):GetMouseLocation()
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
                if button.AbsoluteSize.X < MIN_WIDTH or button.AbsoluteSize.Y < MIN_HEIGHT then
                    return
                end
                if not glow or not glow.Parent then
                    glow = buildGlow(card(), color)
                    table.insert(glows, glow)
                end
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
