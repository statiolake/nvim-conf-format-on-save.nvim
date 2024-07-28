local M = {}

---@generic T
---@param key string
---@param default T|nil
---@return T
function M.get(key, default)
  return require('nvim-conf').get().format_on_save[key] or default
end

return M
