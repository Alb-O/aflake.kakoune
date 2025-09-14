local wezterm = require("wezterm")

local config = {}

config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"Noto Color Emoji",
})
config.font_size = 15.0

config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
-- If text looks too thin, try commenting out the line above and use:
-- config.freetype_render_target = 'Normal'

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_ease_in = "EaseOut"
config.cursor_blink_ease_out = "EaseOut"
config.cursor_blink_rate = 500

config.term = "wezterm"
config.scrollback_lines = 10000

-- Window & UI
config.window_decorations = "NONE"
config.enable_tab_bar = false
config.use_fancy_tab_bar = false

-- Colors: Gruvdark
config.colors = {
	foreground = "#E6E3DE",
	background = "#1E1E1E",
	cursor_bg = "#E6E3DE",
	cursor_border = "#E6E3DE",
	selection_bg = "#2A404F",
	ansi = {
		"#1E1E1E",
		"#E16464",
		"#72BA62",
		"#D19F66",
		"#579DD4",
		"#9266DA",
		"#00A596",
		"#D6CFC4",
	},
	brights = {
		"#9D9A94",
		"#F19A9A",
		"#9AD58B",
		"#E6BB88",
		"#8AC0EA",
		"#B794F0",
		"#2FCAB9",
		"#E6E3DE",
	},
}

return config
