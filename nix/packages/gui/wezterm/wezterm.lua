local wezterm = require("wezterm")

local config = {}

--
-- Multiplexing via a fixed unix socket
--
-- Use a deterministic socket path so both the GUI and `wezterm cli`
-- target the same instance reliably. The wrapper exports WEZTERM_UNIX_SOCKET
-- when connecting to an existing mux; see wrapped.nix.
do
	local runtime = os.getenv("XDG_RUNTIME_DIR")
	local user = os.getenv("USER") or "user"
	local host = wezterm.hostname()
	local socket_path

	if runtime and #runtime > 0 then
		socket_path = string.format("%s/wezterm-%s-%s.sock", runtime, user, host)
	else
		-- Fallback if XDG_RUNTIME_DIR is not set; avoid needing parent dirs
		socket_path = string.format("%s/.wezterm-%s.sock", wezterm.home_dir, host)
	end

	config.unix_domains = {
		{
			name = "unix",
			socket_path = socket_path,
		},
	}

	-- The wrapper marks the first invocation (or failed mux probing) with
	-- WEZTERM_DISABLE_STARTUP_CONNECT so the GUI boots a fresh server instead
	-- of trying to connect to a socket that does not exist yet.
	if not os.getenv("WEZTERM_DISABLE_STARTUP_CONNECT") then
		config.default_gui_startup_args = { "connect", "unix" }
	end
end

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
