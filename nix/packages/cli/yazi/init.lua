-- Plugin bootstrap; ignores errors if plugins are missing.
local plugins = {
	"git",
	"full-border",
	"no-status",
}

for _, plugin_name in ipairs(plugins) do
	local ok, plugin = pcall(require, plugin_name)
	if ok and plugin.setup then
		plugin:setup()
	end
end
