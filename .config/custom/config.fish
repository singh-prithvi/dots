# Aliases
## Battery aliases
alias bat60 "sudo asusctl battery limit 60"
alias bat80 "sudo asusctl battery limit 80"
alias bat100 "sudo asusctl battery limit 100"
alias batcheck "asusctl battery info"

## Battery power profile
function pstatus
    set -l level (cat /sys/class/power_supply/BAT0/capacity)
    set -l profile (powerprofilesctl get)

    echo "    🔋 Battery : $level%"
    echo "    ⚡ Profile : $profile"
end
alias psave='powerprofilesctl set power-saver'
alias pbal='powerprofilesctl set balanced'
alias pperf='powerprofilesctl set performance'

# Enable vim bindings
fish_vi_key_bindings

# c to clear
alias c="clear"
