return {
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  ft = { 'org' },
  config = function()
    -- Setup orgmode
    require('orgmode').setup {
      org_agenda_files = { os.getenv 'ROAM_DIR' .. '/*', os.getenv 'ROAM_DIR' .. '/daily/*' },
      org_default_notes_file = '~/orgfiles/refile.org',
    }
    
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'org',
      callback = function()
        vim.keymap.set('i', '<M-CR>', function()
          -- Use insert_heading_respect_content which works from anywhere
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
          vim.schedule(function()
            require('orgmode').instance().org_mappings:insert_heading_respect_content()
          end)
          return ''
        end, {
          buffer = true,
          expr = true,
          desc = 'Insert new heading',
        })
      end,
    })

    -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
    -- add ~org~ to ignore_install
    -- require('nvim-treesitter.configs').setup({
    --   ensure_installed = 'all',
    --   ignore_install = { 'org' },
    -- })
  end,
}
