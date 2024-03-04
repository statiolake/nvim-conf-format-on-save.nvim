local config = require 'neoconf-format-on-save.config'

local M = {}

function M.fix(is_auto)
  _ = is_auto

  local fix_config = config.get('fix', {})
  for key, value in pairs(fix_config) do
    if value == 'command' then
      if vim.fn.exists(':' .. key) ~= 0 then
        vim.cmd(key)
      end
    elseif type(value) == 'function' then
      value()
    elseif value ~= nil and value ~= vim.NIL then
      vim.notify('Invalid fix config: ' .. key, vim.log.levels.ERROR)
    end
  end
end

return M
