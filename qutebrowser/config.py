config.load_autoconfig()

# Remove default tab switching bindings
config.unbind('J')
config.unbind('K')
config.unbind('H')
config.unbind('L')

# Use Shift+H/L for previous/next tab
config.bind('H', 'tab-prev')
config.bind('L', 'tab-next')
