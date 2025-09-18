-- Minimal plugin bootstrap; ignores errors if the plugin is missing.
local ok, git = pcall(require, "git")
if ok then
  git:setup()
end
