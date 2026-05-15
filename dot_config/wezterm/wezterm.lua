-- Pull in the wezterm API
local wezterm = require "wezterm"
local act = wezterm.action
local mux = wezterm.mux

wezterm.on("update-right-status", function(window, pane)
  local name = window:active_key_table()
  if name then name = "TABLE: " .. name end
  window:set_right_status(name or "")
end)

function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    return "Catppuccin Mocha"
  else
    return "Catppuccin Latte"
  end
end

-- This table will hold the configuration.
local config = {
  default_cursor_style = "BlinkingBlock",
  cursor_blink_rate = 500,
  window_close_confirmation = "NeverPrompt",
  default_prog = { "/run/current-system/sw/bin/zellij", "-l", "welcome" },
  launch_menu = {
    {
      label = "top",
      args = { "/run/current-system/sw/bin/btop" },
    },
  },
  use_ime = true,
  window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
  enable_tab_bar = true,
  tab_bar_at_bottom = false,
  hide_tab_bar_if_only_one_tab = true,
  disable_default_key_bindings = true,
  font = wezterm.font_with_fallback {
    { family = "FantasqueSansM Nerd Font Mono", weight = "Bold" },
    { family = "LXGW WenKai Mono", weight = "Bold" },
    -- "FantasqueSansM Nerd Font Propo",
    -- "LXGW WenKai Mono",
  },
  scrollback_lines = 10000,
  font_size = 14,
  front_end = "OpenGL",
  -- freetype_load_target = "Light",
  freetype_load_flags = "NO_HINTING",
  -- freetype_render_target = "HorizontalLcd",
  line_height = 1.4,
  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  leader = { key = "z", mods = "CTRL", timeout_milliseconds = 2000 },

  window_decorations = "RESIZE",
  allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace",
  inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
  },
  window_background_opacity = 0.85,
  macos_window_background_blur = 15,

  keys = {
    { key = "q", mods = "SUPER", action = act.QuitApplication },
    -- {
    --   key = "r",
    --   mods = "LEADER",
    --   action = act.ActivateKeyTable {
    --     name = "resize_pane",
    --     one_shot = false,
    --   },
    -- },
    -- {
    --   key = "a",
    --   mods = "LEADER",
    --   action = act.ActivateKeyTable {
    --     name = "activate_pane",
    --     timeout_milliseconds = 1000,
    --   },
    -- },
    { key = "n", mods = "CTRL", action = act.RotatePanes "Clockwise" },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },
    {
      key = "c",
      mods = "SUPER",
      action = act.CopyTo "Clipboard",
    },
    {
      key = "v",
      mods = "SUPER",
      action = act.PasteFrom "Clipboard",
    },
    {
      key = "w",
      mods = "SUPER",
      action = act.CloseCurrentPane { confirm = false },
    },
    {
      key = "m",
      mods = "SUPER",
      action = act.Hide,
    },
    {
      key = "s",
      mods = "LEADER",
      action = act.ShowLauncherArgs { flags = "WORKSPACES" },
    },
    {
      key = "S",
      mods = "CTRL|SHIFT",
      action = act.QuickSelect,
    },
    {
      key = "w",
      mods = "LEADER",
      action = act.ShowTabNavigator,
    },
    {
      key = "[",
      mods = "LEADER",
      action = wezterm.action.ActivateCopyMode,
    },
    {
      key = "f",
      mods = "SUPER",
      action = act { Search = { CaseSensitiveString = "" } },
    },
    -- {
    --   key = "\\",
    --   mods = "CTRL|SHIFT",
    --   action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
    -- },
    -- {
    --   key = "-",
    --   mods = "CTRL|SHIFT",
    --   action = act.SplitVertical { domain = "CurrentPaneDomain" },
    -- },
    -- {
    --   key = "Z",
    --   mods = "CTRL|SHIFT",
    --   action = act.TogglePaneZoomState,
    -- },
  },
  key_tables = {
    -- Defines the keys that are active in our resize-pane mode.
    -- Since we're likely to want to make multiple adjustments,
    -- we made the activation one_shot=false. We therefore need
    -- to define a key assignment for getting out of this mode.
    -- 'resize_pane' here corresponds to the name="resize_pane" in
    -- the key assignments above.
    -- resize_pane = {
    --   { key = "h", action = act.AdjustPaneSize { "Left", 1 } },
    --   { key = "l", action = act.AdjustPaneSize { "Right", 1 } },
    --   { key = "k", action = act.AdjustPaneSize { "Up", 1 } },
    --   { key = "j", action = act.AdjustPaneSize { "Down", 1 } },
    --   -- Cancel the mode by pressing escape
    --   { key = "Escape", action = "PopKeyTable" },
    -- },
    -- activate_pane = {
    --   { key = "h", action = act.ActivatePaneDirection "Left" },
    --   { key = "l", action = act.ActivatePaneDirection "Right" },
    --   { key = "k", action = act.ActivatePaneDirection "Up" },
    --   { key = "j", action = act.ActivatePaneDirection "Down" },
    -- },
    search_mode = {
      { key = "Enter", mods = "NONE", action = act.CopyMode "PriorMatch" },
      { key = "Escape", mods = "NONE", action = act.CopyMode "Close" },
      { key = "n", mods = "CTRL", action = act.CopyMode "NextMatch" },
      { key = "p", mods = "CTRL", action = act.CopyMode "PriorMatch" },
      { key = "r", mods = "CTRL", action = act.CopyMode "CycleMatchType" },
      { key = "u", mods = "CTRL", action = act.CopyMode "ClearPattern" },
      {
        key = "PageUp",
        mods = "NONE",
        action = act.CopyMode "PriorMatchPage",
      },
      {
        key = "PageDown",
        mods = "NONE",
        action = act.CopyMode "NextMatchPage",
      },
      { key = "UpArrow", mods = "NONE", action = act.CopyMode "PriorMatch" },
      { key = "DownArrow", mods = "NONE", action = act.CopyMode "NextMatch" },
    },
  },
  hyperlink_rules = {
    -- Matches: a URL in parens: (URL)
    {
      regex = "\\((\\w+://\\S+)\\)",
      format = "$1",
      highlight = 1,
    },
    -- Matches: a URL in brackets: [URL]
    {
      regex = "\\[(\\w+://\\S+)\\]",
      format = "$1",
      highlight = 1,
    },
    -- Matches: a URL in curly braces: {URL}
    {
      regex = "\\{(\\w+://\\S+)\\}",
      format = "$1",
      highlight = 1,
    },
    -- Matches: a URL in angle brackets: <URL>
    {
      regex = "<(\\w+://\\S+)>",
      format = "$1",
      highlight = 1,
    },
    -- Then handle URLs not wrapped in brackets
    {
      regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",
      format = "$0",
    },
    -- implicit mailto link
    {
      regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
      format = "mailto:$0",
    },
    -- github
    -- {
    --   regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
    --   format = "https://www.github.com/$1/$3",
    --   highlight = 1,
    -- },
    {
      regex = "^/[^/\r\n]+(?:/[^/\r\n]+)*:\\d+:\\d+",
      format = "$EDITOR:$0",
    },
    {
      regex = "[^\\s]+\\.rs:\\d+:\\d+",
      format = "$EDITOR:$0",
    },
  },
}

-- for i = 1, 8 do
--   -- CTRL+ALT + number to activate that tab
--   table.insert(config.keys, {
--     key = tostring(i),
--     mods = "SUPER",
--     action = act.ActivateTab(i - 1),
--   })
--   -- F1 through F8 to activate that tab
--   table.insert(config.keys, {
--     key = "F" .. tostring(i),
--     action = act.ActivateTab(i - 1),
--   })
-- end

return config
