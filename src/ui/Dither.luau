--!strict
--[[
Purpose: Hide the banding lines of the window's dark gradient with a faint tiled noise (dithering)
Input: The library's ScreenGui and the context cleanup list; does nothing where EditableImage is unavailable
Output: attach() returns nothing; the noise layer is destroyed by the cleanup
Dependencies: None
]]

local ENV: { [string]: any } = getfenv()

local TILE = 128
local MAX_ALPHA = 7 -- per-pixel noise strength out of 255: about one color level either way
local CORNER_RADIUS = 14
local LAYER_NAME = "ViperDither"
local SEED = 20261004

local Dither = {}

-- Builds the noise tile: each pixel is white or black with a small random alpha; returns the EditableImage or nil.
local function buildTile(): any
    local service: any = (ENV.game :: any):GetService("AssetService")
    local image: any = service:CreateEditableImage({ Size = ENV.Vector2.new(TILE, TILE) })
    local bytes = ENV.buffer.create(TILE * TILE * 4)
    local random = ENV.Random.new(SEED)
    for pixel = 0, TILE * TILE - 1 do
        local value = if random:NextInteger(0, 1) == 1 then 255 else 0
        local offset = pixel * 4
        ENV.buffer.writeu8(bytes, offset, value)
        ENV.buffer.writeu8(bytes, offset + 1, value)
        ENV.buffer.writeu8(bytes, offset + 2, value)
        ENV.buffer.writeu8(bytes, offset + 3, random:NextInteger(0, MAX_ALPHA))
    end
    image:WritePixelsBuffer(ENV.Vector2.zero, ENV.Vector2.new(TILE, TILE), bytes)
    return image
end

--- Lays the noise over the window fill (the first "Background" image under gui).
function Dither.attach(gui: any, cleanup: { add: (() -> ()) -> () })
    if gui == nil or ENV.Instance == nil or ENV.buffer == nil or ENV.Random == nil or ENV.Content == nil then
        return
    end
    local function place()
        local fill: any = nil
        for _, object in gui:GetDescendants() do
            if object.Name == "Background" and object:IsA("ImageLabel") then
                fill = object
                break
            end
        end
        if not fill or fill:FindFirstChild(LAYER_NAME) then
            return false
        end
        local image = buildTile()
        local layer: any = ENV.Instance.new("ImageLabel")
        layer.Name = LAYER_NAME
        layer.BackgroundTransparency = 1
        layer.Size = ENV.UDim2.fromScale(1, 1)
        layer.ImageContent = ENV.Content.fromObject(image)
        layer.ScaleType = (ENV.Enum :: any).ScaleType.Tile
        layer.TileSize = ENV.UDim2.fromOffset(TILE, TILE)
        layer.ZIndex = 1
        layer.Active = false
        local corner: any = ENV.Instance.new("UICorner")
        corner.CornerRadius = ENV.UDim.new(0, CORNER_RADIUS)
        corner.Parent = layer
        layer.Parent = fill
        cleanup.add(function()
            pcall(function()
                layer:Destroy()
            end)
            pcall(function()
                image:Destroy()
            end)
        end)
        return true
    end
    pcall(place)
end

return Dither
