return {
  'chipsenkbeil/org-roam.nvim',
  event = 'VeryLazy',
  tag = '0.2.0',
  dependencies = {
    {
      'nvim-orgmode/orgmode',
    },
  },
  config = function()
    require('org-roam').setup {
      directory = os.getenv 'ROAM_DIR',
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
            capture_today = '<prefix>dT',
            capture_tomorrow = '<prefix>dM',
            goto_today = '<prefix>dt',
            goto_tomorrow = '<prefix>dm',
          },
        },
      },
    }
  end,
}
