local function has_words_before()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if col == 0 then
    return false
  end
  local line = vim.api.nvim_get_current_line()
  return line:sub(col, col):match("%s") == nil
end

return {
  {"mfussenegger/nvim-jdtls"},
  {"neovim/nvim-lspconfig"},
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
  'saghen/blink.cmp',
  lazy = false,
  -- optional: provides snippets for the snippet source
  dependencies = {
    'rafamadriz/friendly-snippets' ,
    'nvim-tree/nvim-web-devicons'
  },

  -- use a release tag to download pre-built binaries
  version = '1.6.0',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    --
    keymap = {
      preset = 'default' ,

      ['<Up>'] = false,
      ['<Down>'] = false,
      -- ['<tab>'] = { 'select_next', 'fallback' },
      ['<tab>'] = {
        function(cmp)
          if cmp.is_menu_visible() then
            return cmp.select_next()
          elseif has_words_before() then
            return cmp.show()
          end
        end,
        'fallback' 
      },
      ['<s-tab>'] = { 'select_prev', 'fallback' },
    },

    cmdline = {
      keymap = { preset = 'inherit' },
      completion = {
        menu = { auto_show = true } ,
        list = { selection = { preselect = false } },
      },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      -- nerd_font_variant = 'mono'
      kind_icons = require('icons').kinds
    },

    completion = {
      documentation = { auto_show = true } ,
      list = { selection = { preselect = false, } },
      menu = {
        -- border = 'rounded' ,
        draw = {
          treesitter = {'lsp'},
          columns = {
            { 'kind_icon', 'kind', gap = 1 },
            { 'label', 'label_description', gap = 1 },
            {'source_name'} 
          },
        }
      },
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      }
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },

  opts_extend = { "sources.default" }
  }
}
