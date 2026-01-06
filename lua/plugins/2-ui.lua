-- User interface
-- Plugins that make the user interface better.

--    Sections:
--       -> tokyonight                  [theme]
--       -> astrotheme                  [theme]
--       -> morta                       [theme]
--       -> eldritch                    [theme]
--       -> alpha-nvim                  [greeter]
--       -> nvim-notify                 [notifications]
--       -> mini.indentscope            [guides]
--       -> heirline-components.nvim    [ui components]
--       -> heirline                    [ui components]
--       -> telescope                   [search]
--       -> telescope-fzf-native.nvim   [search backend]
--       -> dressing.nvim               [better ui elements]
--       -> noice.nvim                  [better cmd/search line]
--       -> nvim-web-devicons           [icons | ui]
--       -> lspkind.nvim                [icons | lsp]
--       -> nvim-scrollbar              [scrollbar]
--       -> mini.animate                [animations]
--       -> highlight-undo              [highlights]
--       -> which-key                   [on-screen keybinding]

local utils = require("base.utils")
local is_windows = vim.fn.has('win32') == 1         -- true if on windows
local is_android = vim.fn.isdirectory('/data') == 1 -- true if on android

return {

  --  vim oxocarbon theme
  --  https://github.com/nyoom-engineering/oxocarbon.nvim
  {
    "nyoom-engineering/oxocarbon.nvim",
    event = "User LoadColorSchemes",
  },
  --  vim enfocado theme
  --  https://github.com/wuelnerdotexe/vim-enfocado
  {
    "wuelnerdotexe/vim-enfocado",
    event = "User LoadColorSchemes",
  },
  --  tokyonight [theme]
  --  https://github.com/folke/tokyonight.nvim
  {
    "folke/tokyonight.nvim",
    event = "User LoadColorSchemes",
    opts = {
      dim_inactive = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    }
  },
  --  astrotheme [theme]
  --  https://github.com/AstroNvim/astrotheme
  {
    "AstroNvim/astrotheme",
    event = "User LoadColorSchemes",
    opts = {
      palette = "astrodark",
      plugins = { ["dashboard-nvim"] = true },
    },
  },

  --  morta [theme]
  --  https://github.com/ssstba/morta.nvim
   {
     "philosofonusus/morta.nvim",
     event = "User LoadColorSchemes",
     opts = {}
   },

  --  eldritch [theme]
  --  https://github.com/eldritch-theme/eldritch.nvim
   {
     "eldritch-theme/eldritch.nvim",
     event = "User LoadColorSchemes",
     opts = {}
   },



  --  mini.indentscope [guides]
  --  https://github.com/nvim-mini/mini.indentscope
  {
    "nvim-mini/mini.indentscope",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      draw = { delay = 0, animation = function() return 0 end },
      options = { border = "top", try_as_border = true },
      symbol = "▏",
    },
    config = function(_, opts)
      require("mini.indentscope").setup(opts)

      -- Disable for certain filetypes
      vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "Disable indentscope for certain filetypes",
        callback = function()
          local ignored_filetypes = {
            "aerial",
            "dashboard",
            "help",
            "lazy",
            "leetcode.nvim",
            "mason",
            "neo-tree",
            "NvimTree",
            "neogitstatus",
            "notify",
            "startify",
            "toggleterm",
            "Trouble",
            "calltree",
            "coverage"
          }
          if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
    end
  },

  -- heirline-components.nvim [ui components]
  -- https://github.com/zeioth/heirline-components.nvim
  -- Collection of components to use on your heirline config.
  {
    "zeioth/heirline-components.nvim",
    opts = function()
      -- return different items depending of the value of `vim.g.fallback_icons_enabled`
      local function get_icons()
        if vim.g.fallback_icons_enabled then
          return require("base.icons.fallback_icons")
        else
          return require("base.icons.icons")
        end
      end

      -- opts
      return {
        icons = get_icons(),
      }
    end
  },

  --  heirline [ui components]
  --  https://github.com/rebelot/heirline.nvim
  --  Use it to customize the components of your user interface,
  --  Including tabline, winbar, statuscolumn, statusline.
  --  Be aware some components are positional. Read heirline documentation.
  {
    "rebelot/heirline.nvim",
    dependencies = { "zeioth/heirline-components.nvim" },
    event = "User BaseDefered",
    opts = function()
      local lib = require("heirline-components.all")
      return {
        opts = {
          disable_winbar_cb = function(args) -- We do this to avoid showing it on the greeter.
            local is_disabled = not require("heirline-components.buffer").is_valid(args.buf) or
                lib.condition.buffer_matches({
                  buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                  filetype = {
                    "NvimTree",
                    "neo%-tree",
                    "dashboard",
                    "Outline",
                    "aerial",
                    "rnvimr"
                  },
                }, args.buf)
            return is_disabled
          end,
        },
        tabline = { -- UI upper bar
          lib.component.tabline_conditional_padding(),
          lib.component.tabline_buffers(),
          lib.component.fill { hl = { bg = "tabline_bg" } },
          lib.component.tabline_tabpages()
        },
        winbar = { -- UI breadcrumbs bar
          init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
          fallthrough = false,
          -- Winbar for terminal, neotree, and aerial.
          {
            condition = function() return not lib.condition.is_active() end,
            {
              lib.component.neotree(),
              lib.component.compiler_play(),
              lib.component.fill(),
              lib.component.compiler_redo(),
              lib.component.aerial(),
            },
          },
          -- Regular winbar
          {
            lib.component.neotree(),
            lib.component.compiler_play(),
            lib.component.fill(),
            lib.component.breadcrumbs(),
            lib.component.fill(),
            lib.component.compiler_redo(),
            lib.component.aerial(),
          }
        },
        statuscolumn = { -- UI left column
          init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
          lib.component.foldcolumn(),
          lib.component.numbercolumn(),
          lib.component.signcolumn(),
        } or nil,
        statusline = { -- UI statusbar
          hl = { fg = "fg", bg = "bg" },
          lib.component.mode(),
          lib.component.git_branch(),
          lib.component.file_info(),
          lib.component.git_diff(),
          lib.component.diagnostics(),
          lib.component.fill(),
          lib.component.cmd_info(),
          lib.component.fill(),
          lib.component.lsp(),
          lib.component.compiler_state(),
          lib.component.virtual_env(),
          lib.component.nav(),
          lib.component.mode { surround = { separator = "right" } },
        },
      }
    end,
    config = function(_, opts)
      local heirline = require("heirline")
      local heirline_components = require "heirline-components.all"

      -- Setup
      heirline_components.init.subscribe_to_events()
      heirline.load_colors(heirline_components.hl.get_colors())
      heirline.setup(opts)
    end,
  },

  --  Telescope [search] + [search backend] dependency
  --  https://github.com/nvim-telescope/telescope.nvim
  --  https://github.com/nvim-telescope/telescope-fzf-native.nvim
  --  https://github.com/debugloop/telescope-undo.nvim
  --  NOTE: Normally, plugins that depend on Telescope are defined separately.
  --  But its Telescope extension is added in the Telescope 'config' section.
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "debugloop/telescope-undo.nvim",
        cmd = "Telescope",
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        enabled = vim.fn.executable("make") == 1,
        build = "make",
      },
    },
    cmd = "Telescope",
    opts = function()
      local get_icon = require("base.utils").get_icon
      local actions = require("telescope.actions")
      local mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<ESC>"] = actions.close,
          ["<C-c>"] = false,
        },
        n = { ["q"] = actions.close },
      }
      return {
        defaults = {
          prompt_prefix = get_icon("PromptPrefix") .. " ",
          selection_caret = get_icon("PromptPrefix") .. " ",
          multi_icon = get_icon("PromptPrefix") .. " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.50,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = mappings,
        },
        extensions = {
          undo = {
            use_delta = true,
            side_by_side = true,
            vim_diff_opts = { ctxlen = 0 },
            entry_format = "󰣜 #$ID, $STAT, $TIME",
            layout_strategy = "horizontal",
            layout_config = {
              preview_width = 0.65,
            },
            mappings = {
              i = {
                ["<cr>"] = require("telescope-undo.actions").yank_additions,
                ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
                ["<C-cr>"] = require("telescope-undo.actions").restore,
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      -- Here we define the Telescope extension for all plugins.
      -- If you delete a plugin, you can also delete its Telescope extension.
      if utils.is_available("telescope-fzf-native.nvim") then telescope.load_extension("fzf") end
      if utils.is_available("telescope-undo.nvim") then telescope.load_extension("undo") end
      if utils.is_available("project.nvim") then telescope.load_extension("projects") end
      if utils.is_available("LuaSnip") then telescope.load_extension("luasnip") end
      if utils.is_available("aerial.nvim") then telescope.load_extension("aerial") end
      if utils.is_available("nvim-neoclip.lua") then
        telescope.load_extension("neoclip")
        telescope.load_extension("macroscope")
      end
    end,
  },

  --  [better ui elements]
  --  https://github.com/stevearc/dressing.nvim
  {
    "stevearc/dressing.nvim",
    event = "User BaseDefered",
    opts = {
      input = { default_prompt = "➤ " },
      select = { backend = { "telescope", "builtin" } },
    }
  },


  --  UI icons [icons - ui]
  --  https://github.com/nvim-tree/nvim-web-devicons
  {
    "nvim-tree/nvim-web-devicons",
    enabled = not vim.g.fallback_icons_enabled,
    event = "User BaseDefered",
    opts = {
      override = {
        default_icon = {
          icon = require("base.utils").get_icon("DefaultFile")
        },
      },
    },
  },

  --  LSP icons [icons | lsp]
  --  https://github.com/onsails/lspkind.nvim
  {
    "onsails/lspkind.nvim",
    enabled = not vim.g.fallback_icons_enabled,
    opts = {
      mode = "symbol",
      symbol_map = {
        Array = "󰅪",
        Boolean = "⊨",
        Class = "󰌗",
        Constructor = "",
        Copilot = "",
        Key = "󰌆",
        Namespace = "󰅪",
        Null = "NULL",
        Number = "#",
        Object = "󰀚",
        Package = "󰏗",
        Property = "",
        Reference = "",
        Snippet = "",
        String = "󰀬",
        TypeParameter = "󰊄",
        Unit = "",
      },
      menu = {},
    },
    config = function(_, opts)
      require("lspkind").init(opts)
    end,
  },

  --  nvim-scrollbar [scrollbar]
  --  https://github.com/petertriho/nvim-scrollbar
  {
    "petertriho/nvim-scrollbar",
    event = "User BaseFile",
    opts = {
      handlers = {
        gitsigns = true, -- gitsigns integration (display hunks)
        ale = true,      -- lsp integration (display errors/warnings)
        search = false,  -- hlslens integration (display search result)
      },
      excluded_filetypes = {
        "cmp_docs",
        "cmp_menu",
        "noice",
        "prompt",
        "TelescopePrompt",
        "alpha"
      },
    },
  },


  --  highlight-undo
  --  https://github.com/tzachar/highlight-undo.nvim
  --  This plugin only flases on undo/redo.
  --  But we also have a autocmd to flash on yank.
  {
    "tzachar/highlight-undo.nvim",
    event = "User BaseDefered",
    opts = {
      duration = 150,
      hlgroup = "IncSearch",
    },
    config = function(_, opts)
      require("highlight-undo").setup(opts)

      -- Also flash on yank.
      vim.api.nvim_create_autocmd("TextYankPost", {
        desc = "Highlight yanked text",
        pattern = "*",
        callback = function()
          (vim.hl or vim.highlight).on_yank()
        end,
      })
    end,
  },

  --  which-key.nvim [on-screen keybindings]
  --  https://github.com/folke/which-key.nvim
  {
    "folke/which-key.nvim",
    event = "User BaseDefered",

    opts_extend = { "disable.ft", "disable.bt" },
    opts = {
      preset = "classic", -- "classic", "modern", or "helix"
      icons = {
        group = (vim.g.fallback_icons_enabled and "+") or "",
        rules = false,
        separator = "-",
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      require("base.utils").which_key_register()
    end,
  },


} -- end of return
