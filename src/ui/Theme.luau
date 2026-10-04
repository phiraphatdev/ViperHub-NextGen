--!strict
--[[
Purpose: Register the ViperHub theme collection with the pinned UI library and list every selectable theme
Input: WindUI export (AddTheme, Gradient and Themes are optional; older or mocked libraries fall back to Dark)
Output: The theme name to use for the window and the ordered list of theme names for the Settings dropdown
Dependencies: None
]]

local Theme = {}

Theme.DEFAULT = "Viper"

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

export type Spec = {
    name: string,
    accent: string, -- sidebar/active accent
    dialog: string,
    outline: string,
    text: string,
    placeholder: string,
    background: { string }, -- gradient top -> bottom
    button: { string }, -- gradient for buttons, toggles and checkboxes
    icon: string,
    element: string, -- card background
}

-- ViperHub themes (dark backgrounds, gradient controls). Built-in WindUI themes are listed after these.
Theme.SPECS = table.freeze({
    {
        name = "Viper",
        accent = "#0b3b2e",
        dialog = "#071a15",
        outline = "#34d399",
        text = "#ecfdf5",
        placeholder = "#6ee7b7",
        background = { "#030d0b", "#0a231d" },
        button = { "#059669", "#14b8a6" },
        icon = "#34d399",
        element = "#0f2a23",
    },
    {
        name = "Sakura",
        accent = "#4a1530",
        dialog = "#2a0b1b",
        outline = "#f9a8d4",
        text = "#fdf2f8",
        placeholder = "#f9a8d4",
        background = { "#14060d", "#2b0d1d" },
        button = { "#ec4899", "#f472b6" },
        icon = "#f472b6",
        element = "#2e1220",
    },
    {
        name = "Ocean",
        accent = "#0c3352",
        dialog = "#061a2b",
        outline = "#38bdf8",
        text = "#e0f2fe",
        placeholder = "#7dd3fc",
        background = { "#020b14", "#06223a" },
        button = { "#0284c7", "#06b6d4" },
        icon = "#38bdf8",
        element = "#0b2538",
    },
    {
        name = "Sunset",
        accent = "#4a1d12",
        dialog = "#2a0f0a",
        outline = "#fb923c",
        text = "#fff7ed",
        placeholder = "#fdba74",
        background = { "#140805", "#2e0f16" },
        button = { "#f97316", "#e11d48" },
        icon = "#fb923c",
        element = "#2c1612",
    },
    {
        name = "Galaxy",
        accent = "#2e1065",
        dialog = "#160734",
        outline = "#a78bfa",
        text = "#f5f3ff",
        placeholder = "#c4b5fd",
        background = { "#07041a", "#1a0b3d" },
        button = { "#7c3aed", "#4f46e5" },
        icon = "#a78bfa",
        element = "#1c1238",
    },
    {
        name = "Blood Moon",
        accent = "#450a0a",
        dialog = "#1f0505",
        outline = "#f87171",
        text = "#fef2f2",
        placeholder = "#fca5a5",
        background = { "#0a0202", "#230606" },
        button = { "#b91c1c", "#ef4444" },
        icon = "#f87171",
        element = "#2a0d0d",
    },
    {
        name = "Gold Rush",
        accent = "#3a2a06",
        dialog = "#1c1404",
        outline = "#fbbf24",
        text = "#fffbeb",
        placeholder = "#fcd34d",
        background = { "#0a0803", "#1f1706" },
        button = { "#d97706", "#facc15" },
        icon = "#fbbf24",
        element = "#26200f",
    },
    {
        name = "Frost",
        accent = "#16384a",
        dialog = "#0b1e29",
        outline = "#a5f3fc",
        text = "#f0fdff",
        placeholder = "#a5f3fc",
        background = { "#06121a", "#0f2a36" },
        button = { "#22d3ee", "#93c5fd" },
        icon = "#67e8f9",
        element = "#13303d",
    },
    {
        name = "Matrix",
        accent = "#052e16",
        dialog = "#021a0c",
        outline = "#22c55e",
        text = "#dcfce7",
        placeholder = "#4ade80",
        background = { "#000000", "#03140a" },
        button = { "#16a34a", "#22c55e" },
        icon = "#22c55e",
        element = "#071a0e",
    },
    {
        name = "Cyberpunk",
        accent = "#3b0a45",
        dialog = "#1d0624",
        outline = "#facc15",
        text = "#fefce8",
        placeholder = "#f0abfc",
        background = { "#0b0418", "#25082f" },
        button = { "#d946ef", "#facc15" },
        icon = "#f0abfc",
        element = "#22102c",
    },
    {
        name = "Lava",
        accent = "#4a1a04",
        dialog = "#260c02",
        outline = "#fb923c",
        text = "#fff7ed",
        placeholder = "#fdba74",
        background = { "#120501", "#2e0d02" },
        button = { "#dc2626", "#f97316" },
        icon = "#f97316",
        element = "#2d1408",
    },
    {
        name = "Royal",
        accent = "#2e1a4a",
        dialog = "#170c26",
        outline = "#fbbf24",
        text = "#faf5ff",
        placeholder = "#d8b4fe",
        background = { "#0b0614", "#1e1033" },
        button = { "#7e22ce", "#d97706" },
        icon = "#c084fc",
        element = "#201433",
    },
    {
        name = "Toxic",
        accent = "#283a06",
        dialog = "#141d03",
        outline = "#a3e635",
        text = "#f7fee7",
        placeholder = "#bef264",
        background = { "#070a01", "#172206" },
        button = { "#65a30d", "#a3e635" },
        icon = "#a3e635",
        element = "#1a240b",
    },
    {
        name = "Shadow",
        accent = "#1f1f23",
        dialog = "#111113",
        outline = "#a1a1aa",
        text = "#fafafa",
        placeholder = "#a1a1aa",
        background = { "#050505", "#141416" },
        button = { "#3f3f46", "#71717a" },
        icon = "#d4d4d8",
        element = "#18181b",
    },
} :: { Spec })

-- Library themes added after ours, in this order when present (the rest follow alphabetically).
local BUILT_IN_ORDER =
    { "Dark", "Light", "Emerald", "Midnight", "Crimson", "Rose", "Violet", "Indigo", "Sky", "Amber" }

local function customNames(): { string }
    local names: { string } = {}
    for _, spec in Theme.SPECS do
        table.insert(names, spec.name)
    end
    return names
end

--- Every selectable theme: ViperHub themes first, then the library's own themes.
function Theme.list(library: any): { string }
    local names = customNames()
    local themes = if type(library) == "table" and type(library.Themes) == "table"
        then library.Themes
        else nil
    if not themes then
        table.insert(names, "Dark")
        return names
    end
    for _, name in BUILT_IN_ORDER do
        if themes[name] ~= nil and not table.find(names, name) then
            table.insert(names, name)
        end
    end
    local rest: { string } = {}
    for name in themes do
        if type(name) == "string" and not table.find(names, name) then
            table.insert(rest, name)
        end
    end
    table.sort(rest)
    for _, name in rest do
        table.insert(names, name)
    end
    return names
end

--- Registers the ViperHub themes; returns the theme the window should use (falls back to Viper, then Dark).
function Theme.register(library: any, preferred: string?): string
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
    local function hex(value: string): any
        return color3.fromHex(value)
    end
    local function gradient(colors: { string }, rotation: number): any
        return (lib.Gradient :: any)(lib, {
            ["0"] = { Color = colors[1], Transparency = 0 },
            ["100"] = { Color = colors[2], Transparency = 0 },
        }, { Rotation = rotation })
    end
    for _, spec in Theme.SPECS do
        pcall(function()
            (lib.AddTheme :: any)(lib, {
                Name = spec.name,
                Accent = hex(spec.accent),
                Dialog = hex(spec.dialog),
                Outline = hex(spec.outline),
                Text = hex(spec.text),
                Placeholder = hex(spec.placeholder),
                Background = gradient(spec.background, 90),
                Button = gradient(spec.button, 45),
                Icon = hex(spec.icon),
                Toggle = gradient(spec.button, 45),
                Slider = hex(spec.button[1]),
                Checkbox = gradient(spec.button, 45),
                Primary = hex(spec.button[1]),
                SliderIcon = hex(spec.placeholder),
                PanelBackground = hex("#FFFFFF"),
                PanelBackgroundTransparency = 0.96,
                LabelBackground = hex("#000000"),
                LabelBackgroundTransparency = 0.78,
                ElementBackground = hex(spec.element),
                ElementBackgroundTransparency = 0,
            })
        end)
    end
    local themes = if type(lib.Themes) == "table" then lib.Themes else {}
    if preferred and themes[preferred] ~= nil then
        return preferred
    end
    return if themes[Theme.DEFAULT] ~= nil then Theme.DEFAULT else "Dark"
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
