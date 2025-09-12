# Gruvdark colorscheme for Kakoune
# Based on provided palette

# Palette options
declare-option str fg 'rgb:d6cfc4'
declare-option str fg_light 'rgb:e6e3de'
declare-option str blue 'rgb:579dd4'
declare-option str blue_dark 'rgb:2a404f'
declare-option str red 'rgb:e16464'
declare-option str red_dark 'rgb:b55353'
declare-option str green 'rgb:72ba62'
declare-option str pink 'rgb:d159b6'
declare-option str purple 'rgb:9266da'
declare-option str aqua 'rgb:00a596'
declare-option str orange 'rgb:d19f66'
declare-option str grey 'rgb:575757'
declare-option str grey_light 'rgb:9d9a94'

# Background ramp
declare-option str bg0 'rgb:191919' # Darkest bg for menus only
declare-option str bg1 'rgb:1e1e1e' # Primary bg
declare-option str bg2 'rgb:232323'
declare-option str bg3 'rgb:252525'
declare-option str bg4 'rgb:303030'
declare-option str bg5 'rgb:323232'
declare-option str bg6 'rgb:373737'
declare-option str bg7 'rgb:3c3c3c'

# Extras
declare-option str line_nr 'rgb:545454'
declare-option str cursor_line 'rgb:b1afa8'
declare-option str diff_add 'rgb:31392b'
declare-option str diff_delete 'rgb:382b2c'
declare-option str diff_change 'rgb:1c3448'
declare-option str diff_text 'rgb:2c5372'

# Builtin faces
set-face global Default            "%opt{fg},%opt{bg1}"
set-face global PrimarySelection   ",%opt{blue_dark}"
set-face global SecondarySelection ",%opt{blue_dark}"
set-face global PrimaryCursor      "%opt{bg1},%opt{blue}"
set-face global SecondaryCursor    "%opt{bg1},%opt{aqua}"
set-face global PrimaryCursorEol   "%opt{bg1},%opt{red}"
set-face global SecondaryCursorEol "%opt{bg1},%opt{orange}"
set-face global LineNumbers        "%opt{line_nr},%opt{bg1}"
set-face global LineNumberCursor   "%opt{fg_light},%opt{bg1}+b"
set-face global LineNumbersWrapped "%opt{bg5},%opt{bg1}+i"
set-face global StatusLine         "%opt{fg_light},%opt{bg4}"
set-face global StatusLineMode     "%opt{fg_light},%opt{blue_dark}"
set-face global StatusLineInfo     "%opt{fg_light},%opt{bg4}"
set-face global StatusLineValue    "%opt{fg_light},%opt{bg4}"
set-face global StatusCursor       "%opt{bg1},%opt{blue}"
set-face global Prompt             "%opt{fg_light},%opt{bg4}"
set-face global Error              "%opt{red},%opt{bg1}"
set-face global MatchingChar       "%opt{blue},%opt{bg1}"
set-face global Whitespace         "%opt{grey_light},%opt{bg1}+f"
set-face global WrapMarker         Whitespace
set-face global BufferPadding      "%opt{bg1},%opt{bg1}"
set-face global MenuForeground     "%opt{fg_light},%opt{blue_dark}+b"
set-face global MenuBackground     "%opt{fg_light},%opt{bg0}"
set-face global Information        "%opt{fg_light},%opt{bg3}"

# Code faces
set-face global value      "%opt{fg_light}"
set-face global type       "%opt{blue}"
set-face global variable   "%opt{fg}"
set-face global keyword    "%opt{purple}"
set-face global module     "%opt{orange}"
set-face global function   "%opt{blue}"
set-face global string     "%opt{green}"
set-face global builtin    "%opt{red}"
set-face global constant   "%opt{pink}"
set-face global comment    "%opt{grey_light}"
set-face global documentation comment
set-face global meta       "%opt{orange}"
set-face global operator   "%opt{aqua}"
set-face global attribute  "%opt{green}"
set-face global comma      "%opt{fg}"
set-face global bracket    "%opt{grey}"

# Markup faces
set-face global title      "%opt{orange}"
set-face global header     "%opt{fg_light}"
set-face global bold       "%opt{fg_light}+b"
set-face global italic     "%opt{fg_light}+i"
set-face global mono       "%opt{green}"
set-face global block      "%opt{blue}"
set-face global link       "%opt{aqua}"
set-face global bullet     "%opt{green}"
set-face global list       "%opt{fg}"

# Diff faces
set-face global DiffAdded      "%opt{green},%opt{diff_add}"
set-face global DiffRemoved    "%opt{red},%opt{diff_delete}"
set-face global DiffChanged    "%opt{blue},%opt{diff_change}"
set-face global DiffModified   "%opt{fg},%opt{diff_text}"

# Search highlighting
set-face global Search       "%opt{bg1},%opt{orange}"
set-face global IncSearch    "%opt{bg1},%opt{blue}"

# Insert-mode white cursor
remove-hooks global gruvdark-cursor
hook -group gruvdark-cursor global ModeChange 'push:.*:insert' %{
  set-face global PrimaryCursor   "%opt{bg1},rgb:ffffff"
  set-face global SecondaryCursor "%opt{bg1},rgb:ffffff"
}
hook -group gruvdark-cursor global ModeChange 'pop:insert:.*' %{
  set-face global PrimaryCursor   "%opt{bg1},%opt{blue}"
  set-face global SecondaryCursor "%opt{bg1},%opt{aqua}"
}
