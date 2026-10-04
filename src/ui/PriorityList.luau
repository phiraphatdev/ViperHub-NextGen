--!strict
--[[
Purpose: Shared drag-to-swap priority list (UI base for every game): a card with numbered rows, highest number on
         top; hold a row and drop it on another row to swap the two (mouse or touch). Rows can carry a colored tag
         (rarity, room kind), swaps slide into place and the scroll position is kept.
Input: A WindUI tab or section handle and options: title, desc, order, onSwap(from, to) -> newOrder?, optional tags
       ({ [name]: { text, color } } with a Theme color name or #hex) and visibleRows
Output: A handle with refresh(order) and the card; without the WindUI paragraph container (other libraries, mocks)
        the card only shows the order as text
Dependencies: ui/Theme (Roblox GUI instances inside the WindUI paragraph container)
]]

local Theme = require("./Theme")
local PriorityList = {}

local ROW_HEIGHT = 32
local ROW_GAP = 4
local NUMBER_WIDTH = 30
local STRIPE_WIDTH = 3
local TAG_WIDTH = 74
local DRAG_THRESHOLD = 4
local EDGE_SCROLL = 28
local SCROLL_STEP = 10
local SUMMARY_ENTRIES = 6
local DEFAULT_VISIBLE = 7
local SLIDE_SECONDS = 0.18
local MESSAGE_SECONDS = 4
-- Background transparency of a row: resting, hovered, the drop target and the dimmed source while dragging.
local ALPHA_REST = 0.93
local ALPHA_HOVER = 0.88
local ALPHA_TARGET = 0.8
local ALPHA_SOURCE = 0.97

export type Tag = { text: string, color: string }
export type Options = {
    title: string,
    desc: string,
    order: { string },
    onSwap: (string, string) -> { string }?,
    tags: { [string]: Tag }?,
    visibleRows: number?,
}
export type Handle = { refresh: ({ string }) -> (), card: any }

--- Row labels: the highest number first ("33. Limit Break", ..., "1. Military Training").
function PriorityList.labels(order: { string }): { string }
    local result = {}
    for index, name in order do
        table.insert(result, string.format("%d. %s", #order - index + 1, name))
    end
    return result
end

--- The one-line summary under the description: the first names, then how many follow.
function PriorityList.summary(order: { string }): string
    if #order <= SUMMARY_ENTRIES then
        return table.concat(order, " > ")
    end
    return table.concat(order, " > ", 1, SUMMARY_ENTRIES)
        .. string.format(" > … (+%d)", #order - SUMMARY_ENTRIES)
end

--- Top offset of each row inside the list (rows are placed by hand so swaps can slide).
function PriorityList.offsets(count: number): { number }
    local result = {}
    for index = 1, count do
        result[index] = (index - 1) * (ROW_HEIGHT + ROW_GAP)
    end
    return result
end

--- Index of the row under a vertical position, given each row's top and the row height; nil when between rows.
function PriorityList.rowAt(tops: { number }, height: number, y: number): number?
    for index, top in tops do
        if y >= top and y < top + height then
            return index
        end
    end
    return nil
end

local function containerOf(card: any): any
    local ok, container = pcall(function()
        return card.ParagraphFrame.UIElements.Container
    end)
    local kind: string = if ok then typeof(container) else ""
    return if kind == "Instance" then container else nil
end

--- Mounts the list; onSwap applies a swap and returns the new order (or nil to keep the current one).
function PriorityList.mount(host: any, options: Options): Handle
    local current = table.clone(options.order)
    local tags = options.tags or {}
    local message: string? = nil
    local card = host:Paragraph({
        Title = options.title,
        Desc = options.desc .. "\n" .. PriorityList.summary(current),
    })
    local function setDesc()
        local text = options.desc .. "\n" .. (message or PriorityList.summary(current))
        pcall(card.SetDesc, card, text)
    end

    local env: any = getfenv()
    local container = containerOf(card)
    local New: any = env.Instance
    if not container or not New or not env.game then
        return {
            refresh = function(newOrder: { string })
                current = table.clone(newOrder)
                setDesc()
            end,
            card = card,
        }
    end

    local UDim2: any = env.UDim2
    local UDim: any = env.UDim
    local Vector2: any = env.Vector2
    local Enum: any = env.Enum
    local Font: any = env.Font
    local taskApi: any = env.task
    local input: any = env.game:GetService("UserInputService")
    local guiService: any = env.game:GetService("GuiService")
    local tweens: any = env.game:GetService("TweenService")
    local slide = env.TweenInfo.new(SLIDE_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local titleLabel: any = card.ParagraphFrame.UIElements.Title
    local function textColor(): any
        local ok, color = pcall(function()
            return titleLabel.TextColor3
        end)
        return if ok and color then color else env.Color3.new(1, 1, 1)
    end
    local function fontWith(weight: any): any
        local ok, font = pcall(function()
            return Font.new(titleLabel.FontFace.Family, weight)
        end)
        return if ok then font else titleLabel.FontFace
    end

    local list = New.new("ScrollingFrame")
    list.Name = "PriorityList"
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.ScrollingDirection = Enum.ScrollingDirection.Y
    list.LayoutOrder = 100
    list.Parent = container

    local rows: { [string]: any } = {}
    local drag: any = nil
    local hovered: string? = nil

    -- The pointer in AbsolutePosition space: GUI AbsolutePositions start below the top bar inset (a ScreenGui that
    -- ignores the inset reports its own AbsolutePosition as minus the inset), so the inset is always removed.
    local function pointer(): any
        return input:GetMouseLocation() - guiService:GetGuiInset()
    end

    local function rowUnder(position: any): string?
        local tops = {}
        for index, name in current do
            local row = rows[name]
            local inside = row
                and position.X >= row.AbsolutePosition.X
                and position.X <= row.AbsolutePosition.X + row.AbsoluteSize.X
            tops[index] = if inside then row.AbsolutePosition.Y else -math.huge
        end
        local index = PriorityList.rowAt(tops, ROW_HEIGHT, position.Y)
        return if index then current[index] else nil
    end

    -- Colors and emphasis for every row from the drag/hover state (also re-run when the theme's text color changes).
    local function paint()
        local color = textColor()
        for name, row in rows do
            local isSource = drag ~= nil and drag.ghost ~= nil and drag.name == name
            local isTarget = drag ~= nil
                and drag.ghost ~= nil
                and drag.target == name
                and drag.target ~= drag.name
            row.BackgroundColor3 = color
            row.BackgroundTransparency = if isSource
                then ALPHA_SOURCE
                elseif isTarget then ALPHA_TARGET
                elseif hovered == name and not drag then ALPHA_HOVER
                else ALPHA_REST
            row.Number.TextColor3 = color
            row.Label.TextColor3 = color
            row.Grip.TextColor3 = color
            row.Number.TextTransparency = if isSource then 0.7 else 0
            row.Label.TextTransparency = if isSource then 0.7 else 0
            row.Grip.Text = if isTarget then "⇄" else "≡"
            row.Grip.TextTransparency = if isTarget then 0 else 0.55
            row.Stroke.Color = color
            row.Stroke.Transparency = if isTarget then 0.35 else 1
        end
    end

    -- Places every row at its slot and refreshes the numbers; animated after a swap, instant otherwise.
    local function place(animated: boolean)
        local tops = PriorityList.offsets(#current)
        for index, name in current do
            local row = rows[name]
            if row then
                row.Number.Text = tostring(#current - index + 1)
                local goal = UDim2.new(0, 0, 0, tops[index])
                if animated then
                    tweens:Create(row, slide, { Position = goal }):Play()
                else
                    row.Position = goal
                end
            end
        end
        local height = #current * (ROW_HEIGHT + ROW_GAP) - ROW_GAP
        list.CanvasSize = UDim2.new(0, 0, 0, math.max(height, 0))
        local visible = math.min(#current, options.visibleRows or DEFAULT_VISIBLE)
        list.Size = UDim2.new(1, 0, 0, math.max(visible * (ROW_HEIGHT + ROW_GAP) - ROW_GAP, 0))
    end

    local function showMessage(text: string)
        message = text
        setDesc()
        if taskApi and type(taskApi.delay) == "function" then
            (taskApi.delay :: any)(MESSAGE_SECONDS, function()
                if message == text then
                    message = nil
                    setDesc()
                end
            end)
        end
    end

    local function endDrag(position: any?)
        local active = drag
        drag = nil
        if not active then
            return
        end
        for _, connection in active.connections do
            connection:Disconnect()
        end
        if active.ghost then
            active.ghost:Destroy()
        end
        local target = if position and active.ghost then rowUnder(position) else nil
        if target and target ~= active.name then
            local newOrder = options.onSwap(active.name, target)
            if newOrder then
                current = table.clone(newOrder)
                place(true)
                showMessage(string.format("Swapped %s ⇄ %s", tostring(active.name), target))
            end
        end
        paint()
    end

    local function startDrag(name: string)
        if drag then
            return
        end
        local start = pointer()
        local state: any = { name = name, target = nil, ghost = nil, connections = {} }
        drag = state
        local moved: any = input.InputChanged:Connect(function(changed: any)
            local kind = changed.UserInputType
            if kind ~= Enum.UserInputType.MouseMovement and kind ~= Enum.UserInputType.Touch then
                return
            end
            local position = pointer()
            if not state.ghost then
                if (position - start).Magnitude < DRAG_THRESHOLD then
                    return
                end
                local source = rows[name]
                local ghost = source:Clone()
                ghost.Name = "PriorityListGhost"
                ghost.Size = UDim2.fromOffset(source.AbsoluteSize.X, source.AbsoluteSize.Y)
                ghost.AnchorPoint = Vector2.new(0, 0.5)
                ghost.BackgroundTransparency = ALPHA_TARGET
                ghost.Stroke.Transparency = 0.3
                ghost.ZIndex = 50
                for _, child in ghost:GetDescendants() do
                    if child:IsA("GuiObject") then
                        child.ZIndex = 51
                    end
                end
                ghost.Parent = list:FindFirstAncestorWhichIsA("ScreenGui")
                state.ghost = ghost
                state.offsetX = position.X - source.AbsolutePosition.X
            end
            local origin = state.ghost.Parent.AbsolutePosition
            state.ghost.Position =
                UDim2.fromOffset(position.X - state.offsetX - origin.X, position.Y - origin.Y)
            -- Scroll the list while dragging near its top or bottom edge.
            local top = list.AbsolutePosition.Y
            local bottom = top + list.AbsoluteSize.Y
            if position.Y < top + EDGE_SCROLL then
                list.CanvasPosition = Vector2.new(0, math.max(0, list.CanvasPosition.Y - SCROLL_STEP))
            elseif position.Y > bottom - EDGE_SCROLL then
                list.CanvasPosition = Vector2.new(0, list.CanvasPosition.Y + SCROLL_STEP)
            end
            state.target = rowUnder(position)
            paint()
        end)
        local released: any = input.InputEnded:Connect(function(ended: any)
            local kind = ended.UserInputType
            if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
                endDrag(pointer())
            end
        end)
        table.insert(state.connections, moved)
        table.insert(state.connections, released)
    end

    local function makeRow(name: string): any
        local tag = tags[name]
        local tagColor = if tag then Theme.color(tag.color) else nil
        local row = New.new("TextButton")
        row.Name = "Row"
        row.Text = ""
        row.AutoButtonColor = false
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, -8, 0, ROW_HEIGHT)
        local corner = New.new("UICorner")
        corner.CornerRadius = UDim.new(0, 7)
        corner.Parent = row
        local stroke = New.new("UIStroke")
        stroke.Name = "Stroke"
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Thickness = 1.5
        stroke.Transparency = 1
        stroke.Parent = row
        if tagColor then
            local stripe = New.new("Frame")
            stripe.Name = "Stripe"
            stripe.BorderSizePixel = 0
            stripe.BackgroundColor3 = tagColor
            stripe.Position = UDim2.fromOffset(4, 7)
            stripe.Size = UDim2.new(0, STRIPE_WIDTH, 1, -14)
            local round = New.new("UICorner")
            round.CornerRadius = UDim.new(1, 0)
            round.Parent = stripe
            stripe.Parent = row
        end
        local number = New.new("TextLabel")
        number.Name = "Number"
        number.BackgroundTransparency = 1
        number.Position = UDim2.fromOffset(10, 0)
        number.Size = UDim2.new(0, NUMBER_WIDTH, 1, 0)
        number.TextXAlignment = Enum.TextXAlignment.Right
        number.TextSize = 14
        number.FontFace = fontWith(Enum.FontWeight.Bold)
        number.Parent = row
        local label = New.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(10 + NUMBER_WIDTH + 10, 0)
        local reserved = if tag and tagColor then TAG_WIDTH + 8 else 0
        label.Size = UDim2.new(1, -(10 + NUMBER_WIDTH + 10 + reserved + 30), 1, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextSize = 14
        label.FontFace = fontWith(Enum.FontWeight.Medium)
        label.Text = name
        label.Parent = row
        if tag and tagColor then
            local chip = New.new("TextLabel")
            chip.Name = "Tag"
            chip.AnchorPoint = Vector2.new(1, 0.5)
            chip.Position = UDim2.new(1, -30, 0.5, 0)
            chip.Size = UDim2.fromOffset(TAG_WIDTH, 18)
            chip.BackgroundColor3 = tagColor
            chip.BackgroundTransparency = 0.82
            chip.TextColor3 = tagColor
            chip.TextSize = 11
            chip.FontFace = fontWith(Enum.FontWeight.Bold)
            chip.Text = string.upper(tag.text)
            local round = New.new("UICorner")
            round.CornerRadius = UDim.new(1, 0)
            round.Parent = chip
            chip.Parent = row
        end
        local grip = New.new("TextLabel")
        grip.Name = "Grip"
        grip.BackgroundTransparency = 1
        grip.AnchorPoint = Vector2.new(1, 0)
        grip.Position = UDim2.new(1, -6, 0, 0)
        grip.Size = UDim2.new(0, 20, 1, 0)
        grip.TextSize = 16
        grip.Text = "≡"
        grip.Parent = row
        row.MouseEnter:Connect(function()
            hovered = name
            paint()
        end)
        row.MouseLeave:Connect(function()
            if hovered == name then
                hovered = nil
                paint()
            end
        end)
        row.InputBegan:Connect(function(began: any)
            local kind = began.UserInputType
            if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
                startDrag(name)
            end
        end)
        row.Parent = list
        return row
    end

    -- Builds rows for names that have none and removes rows for names no longer listed.
    local function sync()
        endDrag(nil)
        for name, row in rows do
            if not table.find(current, name) then
                row:Destroy()
                rows[name] = nil
            end
        end
        for _, name in current do
            if not rows[name] then
                rows[name] = makeRow(name)
            end
        end
    end

    sync()
    place(false)
    paint()
    pcall(function()
        titleLabel:GetPropertyChangedSignal("TextColor3"):Connect(paint)
    end)

    return {
        refresh = function(newOrder: { string })
            current = table.clone(newOrder)
            message = nil
            sync()
            place(true)
            paint()
            setDesc()
        end,
        card = card,
    }
end

return PriorityList
