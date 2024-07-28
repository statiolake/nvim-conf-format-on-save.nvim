local config = require 'nvim-conf-format-on-save.config'

local M = {}

function M.fix(is_auto)
  _ = is_auto

  local fixes_config = config.get('fixes', {})
  for _, fix in ipairs(fixes_config) do
    fix()
  end
end

return M
