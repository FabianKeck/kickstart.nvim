-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `config` key, the configuration only runs
-- after the plugin has been loaded:
--  config = function() ... end

return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
  opts = {
    spec = {
      { '<leader>c', group = '[C]ode' },
      { '<leader>c_', hidden = true },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>d_', hidden = true },
      { '<leader>h', group = 'Git [H]unk' },
      { '<leader>h_', hidden = true },
      { '<leader>o', group = '[O]rg mode' },
      { '<leader>o_', hidden = true },
      { '<leader>n', group = 'Org Roam [N]ode' },
      { '<leader>n_', hidden = true },
      { '<leader>na', group = 'Org Roam [A]lias' },
      { '<leader>na_', hidden = true },
      { '<leader>nd', group = 'Org Roam [D]aily' },
      { '<leader>nd_', hidden = true },
      { '<leader>r', group = '[R]ename' },
      { '<leader>r_', hidden = true },
      { '<leader>s', group = '[S]earch' },
      { '<leader>s_', hidden = true },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>t_', hidden = true },
      { '<leader>w', group = '[W]indow' },
      { '<leader>w_', hidden = true },
      { '<leader>b', group = '[B]uffer' },
      { '<leader>b_', hidden = true },
      { '<leader>l', group = 'current [L]ine' },
      { '<leader>l_', hidden = true },
      { '<leader>m', group = '[M]ark TODO state' },
      { '<leader>m_', hidden = true },
      { '<leader>os', group = 'org [S]ubtree' },
      { '<leader>os_', hidden = true },
      -- visual mode
      { '<leader>h', desc = 'Git [H]unk', mode = 'v' },
    },
  },
}
