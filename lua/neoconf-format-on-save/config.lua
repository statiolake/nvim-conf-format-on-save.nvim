local neoconf = require 'neoconf'

local M = {}

---@generic T
---@param key string
---@param default T|nil
---@return T
function M.get(key, default)
  local bufnr = 0
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })

  -- ファイルタイプごとの設定を取得する
  local local_value =
    neoconf.get(string.format('format-on-save.%s.%s', filetype, key))

  -- デフォルトの設定値を取得する
  local global_value =
    neoconf.get(string.format('format-on-save._.%s', key), default)

  if type(local_value) == 'table' and type(global_value) == 'table' then
    local_value = vim.tbl_extend('keep', local_value, global_value)
  end

  if local_value ~= nil then
    return local_value
  end

  return global_value or default
end

return M
