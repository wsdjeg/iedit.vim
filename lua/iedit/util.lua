local M = {}

function M.getchar(...)
  local status, ret = pcall(vim.fn.getchar, ...)
  if not status then
    ret = 3
  end
  if type(ret) == 'number' then
    return vim.fn.nr2char(ret)
  else
    return ret
  end
end

function M.t(str)
  if vim.api ~= nil and vim.api.nvim_replace_termcodes ~= nil then
    -- https://github.com/neovim/neovim/issues/17369
    local ret = vim.api.nvim_replace_termcodes(str, false, true, true):gsub('\128\254X', '\128')
    return ret
  else
    -- local ret = vim.fn.execute('echon "\\' .. str .. '"')
    -- ret = ret:gsub('<80>', '\128')
    -- return ret
    return vim.eval(string.format('"\\%s"', str))
  end
end
function M.toggle_case(str)
    local chars = {}
    for _, char in pairs(M.string2chars(str)) do
        local cn = string.byte(char)
        if cn >= 97 and cn <= 122 then
            table.insert(chars, string.char(cn - 32))
        elseif cn >= 65 and cn <= 90 then
            table.insert(chars, string.char(cn + 32))
        else
            table.insert(chars, char)
        end
    end
    return table.concat(chars, '')
end
function M.string2chars(str)
    local t = {}
    for k in string.gmatch(str, '.') do table.insert(t, k) end
    return t
end

function M.matchstrpos(str, need, ...)
  local matchedstr = vim.fn.matchstr(str, need, ...)
  local matchbegin = vim.fn.match(str, need, ...)
  local matchend = vim.fn.matchend(str, need, ...)
  return {matchedstr, matchbegin, matchend}
  -- return vim.fn.matchstrpos(str, need, ...)
end

function M.strAllIndex(str, need, use_expr)
  local rst = {}
  if use_expr then
    local idx = M.matchstrpos(str, need)
    while idx[2] ~= -1 do
      table.insert(rst, {idx[2], idx[3]})
      idx = M.matchstrpos(str, need, idx[3])
    end
  else
    local pattern = [[\<\V]] .. need .. [[\ze\W\|\<\V]] .. need .. [[\ze\$]]
    local idx = vim.fn.match(str, pattern)
    while idx ~= -1 do
      table.insert(rst, {idx, idx + vim.fn.len(need)})
      idx = vim.fn.match(str, pattern, idx + 1 + vim.fn.len(need))
    end
  end
  return rst
end
M.hi = function(info)
  if vim.fn.empty(info) == 1 or vim.fn.get(info, 'name', '') == '' then
    return
  end
  vim.cmd('silent! hi clear ' .. info.name)
  local cmd = 'silent hi! ' .. info.name
  if vim.fn.empty(info.ctermbg) == 0 then
    cmd = cmd .. ' ctermbg=' .. info.ctermbg
  end
  if vim.fn.empty(info.ctermfg) == 0 then
    cmd = cmd .. ' ctermfg=' .. info.ctermfg
  end
  if vim.fn.empty(info.guibg) == 0 then
    cmd = cmd .. ' guibg=' .. info.guibg
  end
  if vim.fn.empty(info.guifg) == 0 then
    cmd = cmd .. ' guifg=' .. info.guifg
  end
  local style = {}

  for _, sty in ipairs({ 'bold', 'italic', 'underline', 'reverse' }) do
    if info[sty] == 1 then
      table.insert(style, sty)
    end
  end

  if vim.fn.empty(style) == 0 then
    cmd = cmd .. ' gui=' .. vim.fn.join(style, ',') .. ' cterm=' .. vim.fn.join(style, ',')
  end
  if info.blend then
    cmd = cmd .. ' blend=' .. info.blend
  end
  pcall(vim.cmd, cmd)
end
M.group2dict = function(name)
  local id = vim.fn.hlID(name)
  if id == 0 then
    return {
      name = '',
      ctermbg = '',
      ctermfg = '',
      bold = '',
      italic = '',
      reverse = '',
      underline = '',
      guibg = '',
      guifg = '',
    }
  end
  local rst = {
    name = vim.fn.synIDattr(id, 'name'),
    ctermbg = vim.fn.synIDattr(id, 'bg', 'cterm'),
    ctermfg = vim.fn.synIDattr(id, 'fg', 'cterm'),
    bold = vim.fn.synIDattr(id, 'bold'),
    italic = vim.fn.synIDattr(id, 'italic'),
    reverse = vim.fn.synIDattr(id, 'reverse'),
    underline = vim.fn.synIDattr(id, 'underline'),
    guibg = vim.fn.tolower(vim.fn.synIDattr(id, 'bg#', 'gui')),
    guifg = vim.fn.tolower(vim.fn.synIDattr(id, 'fg#', 'gui')),
  }
  return rst
end

M.hide_in_normal = function(name)
  local group = M.group2dict(name)
  if vim.fn.empty(group) == 1 then
    return
  end
  local normal = M.group2dict('Normal')
  local guibg = normal.guibg or ''
  local ctermbg = normal.ctermbg or ''
  group.guifg = guibg
  group.guibg = guibg
  group.ctermfg = ctermbg
  group.ctermbg = ctermbg
  group.blend = 100
  M.hi(group)
end
return M
