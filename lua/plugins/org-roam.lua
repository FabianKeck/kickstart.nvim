return {
  'chipsenkbeil/org-roam.nvim',
  tag = '0.1.1',
  dependencies = {
    {
      'nvim-orgmode/orgmode',
      tag = '0.3.7',
    },
  },
  config = function()
    require('org-roam').setup {
      directory = '~/org_roam_files',
      -- optional
      org_files = {
        '~/another_org_dir',
        '~/some/folder/*.org',
        '~/a/single/org_file.org',
      },
      -- extensions.dailies.Templates
      extensions = {
        dailies = {
          templates = {
            d = {
              description = 'daily',
              template = '* absences\n** planned\n- \n** actual\n- \n* daily topics\n** %?',
              target = '%<%Y-%m-%d>.org',
            },
          },
          bindings = {
            ---Capture today's note.
            capture_today = '<prefix>dT',

            ---Capture tomorrow's note.
            capture_tomorrow = '<prefix>dM',

            ---Navigate to today's note.
            goto_today = '<prefix>dt',

            ---Navigate to tomorrow's note.
            goto_tomorrow = '<prefix>dm',
          },
        },
      },
    }
  end,
}
