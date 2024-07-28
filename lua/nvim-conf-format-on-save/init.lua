local config = require 'nvim-conf-format-on-save.config'

local fix = require 'nvim-conf-format-on-save.fix'
local format = require 'nvim-conf-format-on-save.format'
local view = require 'nvim-conf-format-on-save.view'

local function break_undo()
  local keyseq =
    vim.api.nvim_replace_termcodes('i <Esc>"_dl', true, true, true)
  vim.cmd('normal! ' .. keyseq)
end

local disable_temporary = false

local function check_should_run()
  if disable_temporary then
    return false
  end
  return config.get('enable', true)
end

---@param is_auto boolean
local function checking_run(is_auto)
  -- autocmd から実行されているときは、設定でグローバルに無効化しているときは
  -- 実行しない。
  if is_auto and not check_should_run() then
    return
  end

  -- すべての処理を一つの undo ブロックへまとめ、フォーマットだけ undo するこ
  -- とができるようにする。
  local saved = view.allwinsaveview()

  break_undo()
  vim.cmd 'undojoin'

  fix.fix(is_auto)
  format.format(is_auto)

  view.allwinrestview(saved)
end

local M = {}

---@param save_cmd string
function M.save_without_format(save_cmd, file_name)
  if #file_name > 0 then
    save_cmd = string.format('%s %s', save_cmd, file_name[1])
  end

  disable_temporary = true
  vim.cmd(save_cmd)
  disable_temporary = false
end

-- フォーマッタを登録する
function M.setup()
  vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function()
      checking_run(true)
    end,
  })

  vim.api.nvim_create_user_command('Format', function()
    checking_run(false)
  end, { nargs = 0 })

  vim.api.nvim_create_user_command('W', function(ctx)
    M.save_without_format('write' .. (ctx.bang and '!' or ''), ctx.args)
  end, { nargs = '?', bang = true })

  vim.api.nvim_create_user_command('WA', function(ctx)
    M.save_without_format('wall' .. (ctx.bang and '!' or ''), ctx.args)
  end, { nargs = '?', bang = true })
end

return M
