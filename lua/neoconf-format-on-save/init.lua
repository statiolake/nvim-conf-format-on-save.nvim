local neoconf = require 'neoconf'

local format = require 'neoconf-format-on-save.format'
local view = require 'neoconf-format-on-save.view'

local function break_undo()
  local keyseq =
    vim.api.nvim_replace_termcodes('i <Esc>"_dl', true, true, true)
  vim.cmd('normal! ' .. keyseq)
end

local disable_temporary = false

local function check_should_run()
  local bufnr = 0
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })

  if disable_temporary then
    return false
  end

  -- ファイルタイプごとの設定があればそれを使う
  local l_enabled =
    neoconf.get(string.format('format-on-save.%s.enable', filetype))
  if l_enabled ~= nil then
    return l_enabled
  end

  -- 型アノテーション的にはテーブルを期待するようだが、今回欲しいのはbooleanな
  -- ので無視する
  ---@diagnostic disable-next-line: param-type-mismatch
  return neoconf.get('format-on-save._.enable', true)
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
  format.format(is_auto)
  view.allwinrestview(saved)
end

local M = {}

---@param save_cmd string
function M.save_without_format(save_cmd)
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
