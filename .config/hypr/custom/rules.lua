-- Floating terminal (foot-terminal)
hl.window_rule({ match = { class = "^(foot-float)$" }, float = true })
hl.window_rule({ match = { class = "^(foot-float)$" }, center = true })
hl.window_rule({ match = { class = "^(foot-float)$" }, size = { "(monitor_w*0.60)", "(monitor_h*0.60)" } })

-- Floating task manager (btop)
hl.window_rule({ match = { title = "^btop$" }, float = true })
hl.window_rule({ match = { title = "^btop$" }, center = true })
hl.window_rule({ match = { title = "^btop$" }, size = { "(monitor_w*0.60)", "(monitor_h*0.60)" } })

-- Floating image viewer (gwenview)
hl.window_rule({ match = { class = "^(org.kde.gwenview)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.gwenview)$" }, center = true })
hl.window_rule({ match = { class = "^(org.kde.gwenview)$" }, size = { "(monitor_w*0.60)", "(monitor_h*0.60)" } })

-- Transparent Dolphin
hl.window_rule({
	match = { class = "^(org.kde.dolphin)$" },
	opacity = "0.95 0.95",
})
