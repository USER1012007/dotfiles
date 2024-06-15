require "core"

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

dofile(vim.g.base46_cache .. "defaults")
vim.opt.rtp:prepend(lazypath)
require "plugins"

vim.api.nvim_exec(
  [[
  augroup templates
    autocmd!
    autocmd BufReadPost *.html if line('$') == 1 && getline(1) ==# '' | execute 'silent! 0r ~/.config/nvim/templates/html.tpl' | endif
  augroup END
]],
  false
)

function Replace_placeholder()
  local current_file = vim.fn.expand "%:t:r"
  local template_path = vim.fn.expand "~/.config/nvim/templates/java.tpl"

  local template_content = vim.fn.readfile(template_path)

  for i, line in ipairs(template_content) do
    template_content[i] = string.gsub(line, "%%FILENAME%%", current_file)
  end

  vim.fn.setline(1, template_content)
end

vim.api.nvim_exec(
  [[
  augroup JavaTemplate
    autocmd!
    autocmd BufReadPost *.java if line('$') == 1 && getline(1) ==# '' | call v:lua.Replace_placeholder() | endif
  augroup END
]],
  false
)

vim.api.nvim_exec(
  [[
    augroup exe_code
      autocmd!

      autocmd FileType rust nnoremap <F1>
              \ :sp<CR> :term rustc % && %:r<CR> :startinsert<CR>
      
      autocmd FileType python nnoremap <F1>
              \ :sp<CR> :term python %<CR> :startinsert<CR>

      autocmd FileType bash,sh nnoremap <F1>
              \ :sp<CR> :term bash %<CR> :startinsert<CR>
    augroup END
]],
  false
)
require'nvim-treesitter.configs'.setup {
  autotag = {
    enable = true,
  }
}

