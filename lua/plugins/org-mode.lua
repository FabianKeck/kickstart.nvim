return {
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  ft = { 'org' },
  config = function()
    -- Setup orgmode
    require('orgmode').setup {
      org_agenda_files = { os.getenv 'ROAM_DIR' .. '/*', os.getenv 'ROAM_DIR' .. '/daily/*' },
      org_default_notes_file = '~/orgfiles/refile.org',
      org_startup_folded = 'showeverything',
      org_adapt_indentation = false,
      org_startup_indented = true,
      org_todo_keywords = { 'TODO', '|', 'DONE', 'CLOSED' },
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
        
        -- TAB to demote subtree in insert mode
        vim.keymap.set('i', '<Tab>', function()
          local col = vim.fn.col('.')
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
          vim.schedule(function()
            require('orgmode').instance().org_mappings:do_demote(true)
            -- Adjust cursor position to account for added star
            vim.fn.cursor(vim.fn.line('.'), col + 1)
            vim.cmd('startinsert')
          end)
          return ''
        end, {
          buffer = true,
          expr = true,
          desc = 'Demote subtree',
        })
        
        -- Shift-TAB to promote subtree in insert mode
        vim.keymap.set('i', '<S-Tab>', function()
          local col = vim.fn.col('.')
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
          vim.schedule(function()
            require('orgmode').instance().org_mappings:do_promote(true)
            -- Adjust cursor position to account for removed star
            vim.fn.cursor(vim.fn.line('.'), math.max(1, col - 1))
            vim.cmd('startinsert')
          end)
          return ''
        end, {
          buffer = true,
          expr = true,
          desc = 'Promote subtree',
        })
        
        -- Leader-m followed by t/d to set TODO states
        vim.keymap.set('n', '<Leader>mt', function()
          local headline = require('orgmode').instance().files:get_closest_headline()
          if headline then
            headline:set_todo('TODO')
          end
        end, {
          buffer = true,
          desc = 'Set TODO state',
        })
        
        vim.keymap.set('n', '<Leader>md', function()
          local headline = require('orgmode').instance().files:get_closest_headline()
          if headline then
            headline:set_todo('DONE')
          end
        end, {
          buffer = true,
          desc = 'Set DONE state',
        })
        
        vim.keymap.set('n', '<Leader>mc', function()
          local headline = require('orgmode').instance().files:get_closest_headline()
          if headline then
            headline:set_todo('CLOSED')
          end
        end, {
          buffer = true,
          desc = 'Set CLOSED state',
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
