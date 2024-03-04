local M = {}

---@param is_auto boolean
function M.format(is_auto)
  local timeout_ms = is_auto and 2000 or 10000
  require('neoconf-ls-selector.formatter').format {
    async = false,
    timeout_ms = timeout_ms,
  }
end

return M
