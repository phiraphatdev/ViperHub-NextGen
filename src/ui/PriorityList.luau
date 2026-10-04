--!strict
--[[
Purpose: Shared drag-to-swap priority list (UI base for every game): a card with numbered rows, highest number on
         top; hold a row and drop it on another row to swap the two (mouse or touch)
Input: A WindUI tab or section handle, a title, a description, the current order and a swap callback
Output: A handle with refresh(order) and the card; without the WindUI paragraph container (other libraries, mocks)
        the card only shows the order as text
Dependencies: None (Roblox GUI instances inside the WindUI paragraph container)
]]

local PriorityList = {}

local ROW_HEIGHT = 30
local ROW_GAP = 4
local DRAG_THRESHOLD = 4
local EDGE_SCROLL = 24
local SCROLL_STEP = 10
local SUMMARY_ENTRIES = 6
local ROW_ALPHA = 0.93
local TARGET_ALPHA = 0.78
local MESSAGE_SECONDS = 4

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

--- Mounts the list; onSwap(fromName, toName) applies the swap and returns the new order (or nil to keep it).
function PriorityList.mount(
    host: any,
    title: string,
    desc: string,
    order: { string },
    onSwap: (string, string) -> { string }?
): Handle
    local current = table.clone(order)
    local message: string? = nil
    local card = host:Paragraph({ Title = title, Desc = desc .. "\n" .. PriorityList.summary(current) })
    local function setDesc()
        local text = desc .. "\n" .. (message or PriorityList.summary(current))
        pcall(card.SetDesc, card, text)
    end

    local env: any = getfenv()
    local container = containerOf(card)
    local Instance: any = env.Instance
    if not container or not Instance or not env.game then
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
    local taskApi: any = env.task
    local input: any = env.game:GetService("UserInputService")
    local guiService: any = env.game:GetService("GuiService")
    local titleLabel: any = card.ParagraphFrame.UIElements.Title
    local function textColor(): any
        local ok, color = pcall(function()
            return titleLabel.TextColor3
        end)
        return if ok and color then color else env.Color3.new(1, 1, 1)
    end

    local visible = math.min(#current, 7)
    local list = Instance.new("ScrollingFrame")
    list.Name = "PriorityList"
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.Size = UDim2.new(1, 0, 0, visible * (ROW_HEIGHT + ROW_GAP))
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollBarThickness = 4
    list.ScrollingDirection = Enum.ScrollingDirection.Y
    list.LayoutOrder = 100
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, ROW_GAP)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list
    list.Parent = container

    local rows: { any } = {}
    local drag: any = nil
    local render: () -> ()

    -- The pointer in AbsolutePosition space: GUI AbsolutePositions start below the top bar inset (a ScreenGui that
    -- ignores the inset reports its own AbsolutePosition as minus the inset), so the inset is always removed.
    local function pointer(): any
        return input:GetMouseLocation() - guiService:GetGuiInset()
    end

    local function rowUnder(position: any): number?
        local tops = {}
        for index, row in rows do
            local inside = position.X >= row.AbsolutePosition.X
                and position.X <= row.AbsolutePosition.X + row.AbsoluteSize.X
            tops[index] = if inside then row.AbsolutePosition.Y else -math.huge
        end
        return PriorityList.rowAt(tops, ROW_HEIGHT, position.Y)
    end

    local function paint()
        local color = textColor()
        for index, row in rows do
            row.BackgroundColor3 = color
            row.BackgroundTransparency = if drag
                    and drag.target == index
                    and drag.target ~= drag.index
                then TARGET_ALPHA
                else ROW_ALPHA
            local label = row:FindFirstChild("Label")
            if label then
                label.TextColor3 = color
            end
            local grip = row:FindFirstChild("Grip")
            if grip then
                grip.TextColor3 = color
            end
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
        if target and target ~= active.index then
            local from, to = current[active.index], current[target]
            local newOrder = onSwap(from, to)
            if newOrder then
                current = table.clone(newOrder)
                message = string.format("Swapped %s ↔ %s", from, to)
                local shown = message
                if taskApi and type(taskApi.delay) == "function" then
                    (taskApi.delay :: any)(MESSAGE_SECONDS, function()
                        if message == shown then
                            message = nil
                            setDesc()
                        end
                    end)
                end
                render()
            end
        end
        paint()
    end

    local function startDrag(index: number)
        if drag then
            return
        end
        local start = pointer()
        local state: any = { index = index, target = index, start = start, ghost = nil, connections = {} }
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
                local source = rows[index]
                local ghost = source:Clone()
                ghost.Name = "PriorityListGhost"
                ghost.Size = UDim2.fromOffset(source.AbsoluteSize.X, source.AbsoluteSize.Y)
                ghost.AnchorPoint = Vector2.new(0, 0.5)
                ghost.BackgroundTransparency = TARGET_ALPHA
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

    render = function()
        endDrag(nil)
        for _, row in rows do
            row:Destroy()
        end
        rows = {}
        local font = titleLabel.FontFace
        for index, label in PriorityList.labels(current) do
            local row = Instance.new("TextButton")
            row.Name = "Row"
            row.Text = ""
            row.AutoButtonColor = false
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, -8, 0, ROW_HEIGHT)
            row.LayoutOrder = index
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = row
            local text = Instance.new("TextLabel")
            text.Name = "Label"
            text.BackgroundTransparency = 1
            text.Position = UDim2.fromOffset(10, 0)
            text.Size = UDim2.new(1, -40, 1, 0)
            text.TextXAlignment = Enum.TextXAlignment.Left
            text.TextTruncate = Enum.TextTruncate.AtEnd
            text.TextSize = 14
            text.FontFace = font
            text.RichText = true
            local number, name = string.match(label, "^(%d+)%. (.+)$")
            text.Text = string.format("<b>%s</b>. %s", number or "", name or label)
            text.Parent = row
            local grip = Instance.new("TextLabel")
            grip.Name = "Grip"
            grip.BackgroundTransparency = 1
            grip.AnchorPoint = Vector2.new(1, 0)
            grip.Position = UDim2.new(1, -8, 0, 0)
            grip.Size = UDim2.new(0, 20, 1, 0)
            grip.Text = "≡"
            grip.TextSize = 16
            grip.TextTransparency = 0.5
            grip.Parent = row
            row.InputBegan:Connect(function(began: any)
                local kind = began.UserInputType
                if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
                    startDrag(index)
                end
            end)
            row.Parent = list
            rows[index] = row
        end
        paint()
        setDesc()
    end
    render()
    pcall(function()
        titleLabel:GetPropertyChangedSignal("TextColor3"):Connect(paint)
    end)

    return {
        refresh = function(newOrder: { string })
            current = table.clone(newOrder)
            message = nil
            render()
        end,
        card = card,
    }
end

return PriorityList
