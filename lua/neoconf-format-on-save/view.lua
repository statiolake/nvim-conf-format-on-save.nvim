local M = {}

function M.allwinsaveview()
  local orig_winid = vim.api.nvim_get_current_win()
  local curr_tabpage = vim.api.nvim_get_current_tabpage()

  local view = {}
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if
      vim.fn.win_gettype(winid) == ''
      and vim.api.nvim_win_get_tabpage(winid) == curr_tabpage
    then
      -- 現在のタブにある、通常タイプのウィンドウに限る
      vim.api.nvim_set_current_win(winid)
      view[winid] = vim.fn.winsaveview()
    end
  end

  vim.api.nvim_set_current_win(orig_winid)
  return view
end

---@param view table
function M.allwinrestview(view)
  local orig_winid = vim.api.nvim_get_current_win()
  for winid, state in pairs(view) do
    vim.api.nvim_set_current_win(winid)
    vim.fn.winrestview(state)
  end
  vim.api.nvim_set_current_win(orig_winid)
end

return M
