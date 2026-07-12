-- Default variables
-- Copy these to ~/.config/hypr/custom/variables.lua to make changes in a dotfiles-update-friendly manner

-- Battery preferences
local function onBattery()
	local f = io.open("/sys/class/power_supply/BAT0/status", "r")
	if not f then
		return false
	end

	local status = f:read("*l")
	f:close()

	return status == "Discharging"
end

local battery = onBattery()

local primaryTerminal = battery and "foot" or "kitty"
local secondaryTerminal = battery and "kitty" or "foot"

local primaryBrowser = battery and "helium-browser" or "vivaldi"
local secondaryBrowser = battery and "vivaldi" or "helium-browser"

-- The folder within ~/.config/quickshell containing the config
hl.env("qsConfig", "ii")

-- Apps
-- PULL REQUESTS ADDING MORE WILL NOT BE ACCEPTED, CONFIG FOR YOURSELF

terminal = "~/.config/hypr/hyprland/scripts/launch_first_available.sh '"
	.. primaryTerminal
	.. "' '"
	.. secondaryTerminal
	.. "' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm'"

fileManager =
	"~/.config/hypr/hyprland/scripts/launch_first_available.sh 'dolphin' 'nautilus' 'nemo' 'thunar' 'kitty -1 fish -c yazi'"

browser = "~/.config/hypr/hyprland/scripts/launch_first_available.sh '"
	.. primaryBrowser
	.. "' '"
	.. secondaryBrowser
	.. "' 'google-chrome-stable' 'zen-browser' 'firefox' 'brave' 'chromium' 'microsoft-edge-stable' 'opera' 'librewolf'"

codeEditor =
	"~/.config/hypr/hyprland/scripts/launch_first_available.sh 'command -v nvim && kitty -1 nvim' 'windsurf' 'antigravity' 'code' 'codium' 'cursor' 'zed' 'zedit' 'zeditor' 'kate' 'gnome-text-editor' 'emacs' 'command -v micro && kitty -1 micro'"

officeSoftware =
	"~/.config/hypr/hyprland/scripts/launch_first_available.sh 'wps' 'onlyoffice-desktopeditors' 'libreoffice'"

textEditor = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'kate' 'gnome-text-editor' 'emacs'"

volumeMixer = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'pavucontrol-qt' 'pavucontrol'"

settingsApp =
	"XDG_CURRENT_DESKTOP=gnome ~/.config/hypr/hyprland/scripts/launch_first_available.sh 'qs -p ~/.config/quickshell/$qsConfig/settings.qml' 'systemsettings' 'gnome-control-center' 'better-control'"

taskManager =
	"~/.config/hypr/hyprland/scripts/launch_first_available.sh 'gnome-system-monitor' 'plasma-systemmonitor --page-name Processes' 'command -v btop && kitty -1 fish -c btop'"

workspaceGroupSize = 10
