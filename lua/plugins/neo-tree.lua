return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  config = function()
    -- keymaps for neotre
    vim.keymap.set('n', '<Leader>.', ':Neotree reveal left<CR>', { desc = 'open Neotree left' })
    vim.keymap.set('n', '<Leader>tt', ':Neotree toggle<CR>', { desc = 'open Neotree left' })
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
}
