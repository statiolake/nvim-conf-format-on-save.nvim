local M = {}

local function fix_trailing_whitespace()
  if
    vim.opt.filetype:get() ~= 'markdown'
    and vim.fn.exists ':FixWhitespace' ~= 0
  then
    vim.cmd 'FixWhitespace'
  end
end

---@param is_auto boolean
local function ls_selector_format(is_auto)
  local timeout_ms = is_auto and 2000 or 10000
  require('neoconf-ls-selector.formatter').format {
    async = false,
    timeout_ms = timeout_ms,
  }
end

---@param is_auto boolean
function M.format(is_auto)
  fix_trailing_whitespace()
  ls_selector_format(is_auto)
end

return M
