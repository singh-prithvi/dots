# ==========================================
# Aliases & Functions
# ==========================================

# ---------- Battery Cap ----------
function bat
    if test (count $argv) -ne 1
        echo "Usage: bat <40-100>"
        return 1
    end

    set -l limit $argv[1]

    if test $limit -lt 40 -o $limit -gt 100
        echo "❌ Battery limit must be between 40 and 100."
        return 1
    end

    sudo asusctl battery limit $limit

    if test $status -eq 0
        set -l profile (powerprofilesctl get)
        set -l time (date "+%H:%M:%S")

        echo
        echo "╭──────────────────────────────────────────╮"
        printf "│ %-40s │\n" "󰂄 ASUS Battery"
        echo "├──────────────────────────────────────────┤"
        printf "│ %-40s │\n" "✓ Charging limit updated"
        printf "│ %-40s │\n" ""
        printf "│ %-40s │\n" "Limit      : $limit%"
        printf "│ %-40s │\n" "Profile    : $profile"
        printf "│ %-40s │\n" "Time       : $time"
        echo "╰──────────────────────────────────────────╯"
        echo
    end
end

# Create bat40 ... bat100
for i in (seq 40 100)
    alias bat$i="bat $i"
end

alias batcheck="asusctl battery info"

# ---------- Power Profiles ----------
function pstatus
    set -l level (cat /sys/class/power_supply/BAT0/capacity)
    set -l profile (powerprofilesctl get)

    echo "🔋 Battery : $level%"
    echo "⚡ Profile : $profile"
end

alias psave="powerprofilesctl set power-saver"
alias pbal="powerprofilesctl set balanced"
alias pperf="powerprofilesctl set performance"

# ---------- Misc ----------
alias c="clear"

# ==========================================
# Fish
# ==========================================

fish_vi_key_bindings
