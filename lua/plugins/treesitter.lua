return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  event = { 'BufReadPost', 'BufNewFile' },
  build = ':TSUpdate',
  config = function()
    local ts = require 'nvim-treesitter'

    ts.install { 'bash', 'c', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then
          return
        end

        local function start()
          if not pcall(vim.treesitter.start, ev.buf, lang) then
            return
          end
          -- Ruby relies on vim's regex highlighting for some constructs
          if lang == 'ruby' then
            vim.bo[ev.buf].syntax = 'on'
          else
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        if vim.treesitter.language.add(lang) then
          start()
        else
          -- Auto-install missing parsers, then enable highlighting
          ts.install(lang):await(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
              start()
            end
          end)
        end
      end,
    })
  end,
}
