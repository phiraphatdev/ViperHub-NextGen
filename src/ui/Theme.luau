--!strict
--[[
Purpose: Register the ViperHub look (emerald/teal "Viper" theme) with the pinned UI library
Input: WindUI export (AddTheme and Gradient are optional; older or mocked libraries fall back to Dark)
Output: The theme name to use for the window and the list of selectable theme names
Dependencies: None
]]

local Theme = {}

Theme.DEFAULT = "Viper"
Theme.NAMES = table.freeze({ "Viper", "Dark" })

-- Brand colors shared by window tags, tab icons and page accents.
Theme.colors = table.freeze({
    primary = "#10b981",
    secondary = "#2dd4bf",
    gold = "#fbbf24",
    blue = "#38bdf8",
    violet = "#a78bfa",
    rose = "#fb7185",
    orange = "#fb923c",
    slate = "#94a3b8",
})

--- Registers the Viper theme; returns the theme name the window should use ("Dark" when registration is impossible).
function Theme.register(library: any, preferred: string?): string
    local wanted = if preferred and table.find(Theme.NAMES, preferred) then preferred else Theme.DEFAULT
    if wanted ~= "Viper" then
        return wanted
    end
    local env: any = getfenv()
    local color3: any = env.Color3
    if
        type(library) ~= "table"
        or type(library.AddTheme) ~= "function"
        or type(library.Gradient) ~= "function"
        or color3 == nil
    then
        return "Dark"
    end
    local lib: any = library
    local ok = pcall(function()
        local function hex(value: string): any
            return color3.fromHex(value)
        end
        local function gradient(from: string, to: string, rotation: number): any
            return (lib.Gradient :: any)(lib, {
                ["0"] = { Color = from, Transparency = 0 },
                ["100"] = { Color = to, Transparency = 0 },
            }, { Rotation = rotation })
        end
        (lib.AddTheme :: any)(lib, {
            Name = "Viper",
            Accent = hex("#0b3b2e"),
            Dialog = hex("#071a15"),
            Outline = hex("#34d399"),
            Text = hex("#ecfdf5"),
            Placeholder = hex("#6ee7b7"),
            Background = gradient("#030d0b", "#0a231d", 90),
            Button = gradient("#059669", "#14b8a6", 45),
            Icon = hex("#34d399"),
            Toggle = gradient("#10b981", "#2dd4bf", 45),
            Slider = hex("#10b981"),
            Checkbox = gradient("#10b981", "#2dd4bf", 45),
            Primary = hex("#10b981"),
            SliderIcon = hex("#6ee7b7"),
            PanelBackground = hex("#FFFFFF"),
            PanelBackgroundTransparency = 0.96,
            LabelBackground = hex("#000000"),
            LabelBackgroundTransparency = 0.78,
            ElementBackground = hex("#0f2a23"),
            ElementBackgroundTransparency = 0,
        })
    end)
    return if ok then "Viper" else "Dark"
end

--- Returns a Color3 for a brand color name or "#rrggbb" text, or nil outside Roblox.
function Theme.color(value: string): any
    local env: any = getfenv()
    local color3: any = env.Color3
    if color3 == nil then
        return nil
    end
    local text = (Theme.colors :: any)[value] or value
    local ok, result = pcall(color3.fromHex, text)
    return if ok then result else nil
end

return Theme
