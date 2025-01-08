return {
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  ft = { 'org' },
  config = function()
    -- Setup orgmode
    require('orgmode').setup {
      org_agenda_files = { os.getenv 'ROAM_DIR' .. '/*', os.getenv 'ROAM_DIR' .. '/daily/*' },
      org_default_notes_file = '~/orgfiles/refile.org',
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'org',
        callback = function()
          vim.keymap.set('i', '<M-CR>', function()
            require('orgmode').action 'org_insert_heading_respect_content'
          end, {
            -- silent = true,
            buffer = true,
            desc = 'org_insert_heading_respect_content',
          })
        end,
      }),
    }

    -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
    -- add ~org~ to ignore_install
    -- require('nvim-treesitter.configs').setup({
    --   ensure_installed = 'all',
    --   ignore_install = { 'org' },
    -- })
  end,
}
