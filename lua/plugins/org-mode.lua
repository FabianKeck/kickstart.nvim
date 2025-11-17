return {
  'nvim-orgmode/orgmode',
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
        
        -- Open agenda view
        vim.keymap.set('n', '<Leader>oa', function()
          require('orgmode').action('agenda.prompt')
        end, {
          desc = 'Open agenda view',
        })
        
        -- Cut subtree to clipboard
        local function cut_subtree()
          local headline = require('orgmode').instance().files:get_closest_headline()
          if not headline then
            vim.notify('No headline found', vim.log.levels.WARN)
            return nil
          end
          
          -- Get subtree content
          local range = headline:get_range()
          local lines = vim.api.nvim_buf_get_lines(0, range.start_line - 1, range.end_line, false)
          
          -- Delete from current buffer
          vim.api.nvim_buf_set_lines(0, range.start_line - 1, range.end_line, false, {})
          
          return lines, headline:get_title()
        end
        
        vim.keymap.set('n', '<Leader>osx', function()
          local lines, _ = cut_subtree()
          if lines then
            -- Copy to clipboard (+ register for system clipboard)
            vim.fn.setreg('+', table.concat(lines, '\n'))
            vim.notify('Subtree cut to clipboard', vim.log.levels.INFO)
          end
        end, {
          desc = 'Cut subtree to clipboard',
        })
        
        -- Extract subtree to new org-roam node
        vim.keymap.set('n', '<Leader>osf', function()
          local lines, default_title = cut_subtree()
          if not lines then
            return
          end
          
          -- Prompt for node title
          vim.ui.input({ prompt = 'Node title: ', default = default_title }, function(title)
            if not title or title == '' then
              return
            end
            
            -- Generate org-roam style filename: timestamp-slug.org
            local timestamp = os.date('%Y%m%d%H%M%S')
            local slug = title:lower():gsub('%s+', '-'):gsub('[^%w-]', '')
            local roam_dir = vim.fn.expand(os.getenv('ROAM_DIR') or '~/org-roam')
            local filename = roam_dir .. '/' .. timestamp .. '-' .. slug .. '.org'
            
            -- Generate UUID for org-roam node
            local uuid = vim.fn.system('uuidgen'):gsub('\n', '')
            
            -- Prepare file content with org-roam properties
            local file_lines = {
              ':PROPERTIES:',
              ':ID:       ' .. uuid,
              ':END:',
              '#+title: ' .. title,
              '',
            }
            
            -- Add the subtree content
            for _, line in ipairs(lines) do
              table.insert(file_lines, line)
            end
            
            -- Write to new file
            vim.fn.writefile(file_lines, filename)
            
            vim.notify('Subtree extracted to: ' .. filename, vim.log.levels.INFO)
            
            -- Open the new file
            vim.cmd('edit ' .. filename)
            
            -- Update org-roam database
            vim.schedule(function()
              vim.cmd('RoamUpdate')
            end)
          end)
        end, {
          desc = 'Extract subtree to new org-roam node',
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
