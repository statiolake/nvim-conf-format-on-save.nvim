local M = {}

-- Taken from
-- <https://github.com/neovim/neovim/blob/3df1211ebc4c7ec4562d0ad0fa51a24569b81e15/runtime/lua/vim/lsp/diagnostic.lua#L154-L179>
local function severity_vim_to_lsp(severity)
  if type(severity) == 'string' then
    severity = vim.diagnostic.severity[severity]
  end
  return severity
end

local function tags_vim_to_lsp(diagnostic)
  local protocol = vim.lsp.protocol

  if not diagnostic._tags then
    return
  end

  local tags = {} --- @type lsp.DiagnosticTag[]
  if diagnostic._tags.unnecessary then
    tags[#tags + 1] = protocol.DiagnosticTag.Unnecessary
  end
  if diagnostic._tags.deprecated then
    tags[#tags + 1] = protocol.DiagnosticTag.Deprecated
  end
  return tags
end

local function diagnostic_vim_to_lsp(diagnostics)
  return vim.tbl_map(function(diagnostic)
    return vim.tbl_extend('keep', {
      -- "keep" the below fields over any duplicate fields in diagnostic.user_data.lsp
      range = {
        start = {
          line = diagnostic.lnum,
          character = diagnostic.col,
        },
        ['end'] = {
          line = diagnostic.end_lnum,
          character = diagnostic.end_col,
        },
      },
      severity = severity_vim_to_lsp(diagnostic.severity),
      message = diagnostic.message,
      source = diagnostic.source,
      code = diagnostic.code,
      tags = tags_vim_to_lsp(diagnostics),
    }, diagnostic.user_data and (diagnostic.user_data.lsp or {}) or {})
  end, diagnostics)
end

function M.run_code_actions(kinds)
  local end_line = vim.fn.line '$'
  local end_col = vim.fn.col { end_line, '$' }
  local entire_range = { start = { 1, 0 }, ['end'] = { end_line, end_col } }
  local entire_diagnostics = diagnostic_vim_to_lsp(vim.diagnostic.get())

  local kinds_map = {}
  for _, kind in ipairs(kinds) do
    kinds_map[kind] = true
  end

  local executed_map = {}
  vim.lsp.buf.code_action {
    apply = true,
    range = entire_range,
    context = {
      only = kinds_map,
      triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Automatic,
      diagnostics = entire_diagnostics,
    },
    filter = function(action)
      local execute = false
      if kinds_map[action.kind] then
        execute = true
        if executed_map[action.kind] then
          execute = false
        end
        executed_map[action.kind] = true
      end

      return execute
    end,
  }
end

return M
