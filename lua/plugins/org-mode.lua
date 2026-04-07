return {
  'nvim-orgmode/orgmode',
  ft = { 'org' },
  config = function()
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
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
          vim.schedule(function()
            require('orgmode').action('org_mappings.insert_heading_respect_content')
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
            require('orgmode').action('org_mappings.do_demote', true)
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
            require('orgmode').action('org_mappings.do_promote', true)
            vim.fn.cursor(vim.fn.line('.'), math.max(1, col - 1))
            vim.cmd('startinsert')
          end)
          return ''
        end, {
          buffer = true,
          expr = true,
          desc = 'Promote subtree',
        })

        -- Leader-m followed by t/d/c to set TODO states
        vim.keymap.set('n', '<Leader>mt', function()
          local file = require('orgmode.api').current()
          local headline = file:get_closest_headline()
          if headline then
            headline._section:set_todo('TODO')
          end
        end, {
          buffer = true,
          desc = 'Set TODO state',
        })

        vim.keymap.set('n', '<Leader>md', function()
          local file = require('orgmode.api').current()
          local headline = file:get_closest_headline()
          if headline then
            headline._section:set_todo('DONE')
          end
        end, {
          buffer = true,
          desc = 'Set DONE state',
        })

        vim.keymap.set('n', '<Leader>mc', function()
          local file = require('orgmode.api').current()
          local headline = file:get_closest_headline()
          if headline then
            headline._section:set_todo('CLOSED')
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
          local file = require('orgmode.api').current()
          local headline = file:get_closest_headline()
          if not headline then
            vim.notify('No headline found', vim.log.levels.WARN)
            return nil
          end

          local pos = headline.position
          local lines = vim.api.nvim_buf_get_lines(0, pos.start_line - 1, pos.end_line, false)
          vim.api.nvim_buf_set_lines(0, pos.start_line - 1, pos.end_line, false, {})

          return lines, headline.title
        end

        vim.keymap.set('n', '<Leader>osx', function()
          local lines, _ = cut_subtree()
          if lines then
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

          vim.ui.input({ prompt = 'Node title: ', default = default_title }, function(title)
            if not title or title == '' then
              return
            end

            local timestamp = os.date('%Y%m%d%H%M%S')
            local slug = title:lower():gsub('%s+', '-'):gsub('[^%w-]', '')
            local roam_dir = vim.fn.expand(os.getenv('ROAM_DIR') or '~/org-roam')
            local filename = roam_dir .. '/' .. timestamp .. '-' .. slug .. '.org'

            local uuid = vim.fn.system('uuidgen'):gsub('\n', '')

            local file_lines = {
              ':PROPERTIES:',
              ':ID:       ' .. uuid,
              ':END:',
              '#+title: ' .. title,
              '',
            }

            for _, line in ipairs(lines) do
              table.insert(file_lines, line)
            end

            vim.fn.writefile(file_lines, filename)
            vim.notify('Subtree extracted to: ' .. filename, vim.log.levels.INFO)
            vim.cmd('edit ' .. filename)

            vim.schedule(function()
              vim.cmd('RoamUpdate')
            end)
          end)
        end, {
          desc = 'Extract subtree to new org-roam node',
        })
      end,
    })
  end,
}
