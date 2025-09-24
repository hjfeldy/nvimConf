return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  -- lazy = false,
  config = function() 
    -- print('Loading file-browser extension')
    -- require('telescope').load_extension('file_browser')
  end
}
