-------------------------------------------------------------------------
-- Base configuration
-------------------------------------------------------------------------

--vim.cmd [[colorscheme vim]]

vim.g.have_nerd_font = true

vim.opt.encoding = "utf8"
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
-- Use mouse in terminal?
vim.opt.mouse = "a"
-- Minimal number of screen lines to keep above and below the cursor
vim.opt.scrolloff = 30
vim.opt.ttyfast = true
vim.opt.wildmode = "longest,list"
-- Use a swapfile for the buffer
vim.opt.swapfile = true
-- Every wrapped line will continue visually indented (same amount of
-- space as the beginning of that line), thus preserving horizontal blocks
-- of text
vim.opt.breakindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Highlight search results in file
vim.opt.hlsearch = true
-- While typing a search command, show where the pattern, as it was typed
vim.opt.incsearch = true
-- Tab length in spaces
vim.opt.tabstop = 4
-- Idk
vim.opt.shiftwidth = 4
-- Tab in spaces equivalent
vim.opt.softtabstop = 4
-- Use spaces instead of real tab
vim.opt.expandtab = false
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.formatoptions = "cro"

vim.opt.list = true
vim.opt.listchars = {
	tab = "»  ",      -- real tabs
	trail = "·",      -- spaces at the end of line
	multispace = "·", -- fake tabs
	nbsp = "␣",       -- non-breakable space
}
-- Highlight line with cursor
vim.opt.cursorline = false
-- Where vertical/horizontal split should go
vim.opt.splitright = false
vim.opt.splitbelow = true

-------------------------------------------------------------------------
-- Custom filetype associations for syntax highlighting
-------------------------------------------------------------------------

-- Support for extra languages could be achieved by plugins for treesitter,
-- like nvim-treesitter
vim.filetype.add {
	pattern = {
		[".*/vifmrc"] = "vim",
		[".*/.*%.vifmrc"] = "vim",
		[".*/waybar/config"] = "jsonc",

		[".*/hypr/.*%.conf"] = "hyprlang",

		["./sway/.*%.conf"]  = "i3config",
		--		["./sway/.*%.sway"]  = "sway",
		--		["./sway/config"]    = "sway",
		--		["./sway/binds"]     = "sway",
	},
}

-------------------------------------------------------------------------
-- Keybindings
-------------------------------------------------------------------------

-- Used for keybindings which needed to press <leader> key before executing them
-- (like type <space> + e in normal mode for go to file explorer (defined in some plugin))
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ctrl+s for file save
vim.keymap.set({ "n", "v" }, "<C-s>", ":w<CR>")
-- Move lines which partially selected in visual mode down/up
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- When you yanking some selection, use "<leader>p" key to replace current new selection
-- without loosing copied content from the main clipboard register
vim.keymap.set("x", "<leader>p", "\"_dP")
-- Copy selection to the desktop environment's clipboard instead of nvim's
-- by "<leader>y" or "<leader>Y"
vim.keymap.set({ "n", "v" }, "<leader>y", "\"+y")
vim.keymap.set({ "n", "v" }, "<leader>Y", "\"+Y")
-- Delete selection without copyind it's content to clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- Easier creation of splitted windows by shrinking key combination to just Alt+something
vim.keymap.set("n", "<A-s>", "<C-w><C-s>")
vim.keymap.set("n", "<A-v>", "<C-w><C-v>")
-- Easier focus movement between splitted windows by Alt + h/j/k/l
vim.keymap.set("n", "<A-h>", "<C-w><C-h>")
vim.keymap.set("n", "<A-j>", "<C-w><C-j>")
vim.keymap.set("n", "<A-k>", "<C-w><C-k>")
vim.keymap.set("n", "<A-l>", "<C-w><C-l>")
-- Easier focused window move by using Shift+Alt+ h/j/k/l
vim.keymap.set("n", "<A-H>", "<C-w>H")
vim.keymap.set("n", "<A-J>", "<C-w>J")
vim.keymap.set("n", "<A-K>", "<C-w>K")
vim.keymap.set("n", "<A-L>", "<C-w>L")
vim.keymap.set("n", "<A-x>", "<C-w>x")
-- Increase/decrease window size
-- TODO: this not work for vertical split
vim.keymap.set("n", "-", "<C-w>5<")
vim.keymap.set("n", "_", "<C-w>5>")
vim.keymap.set("n", "=", "<C-w>=")
-- Make current edited file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-------------------------------------------------------------------------
-- Plugins
-------------------------------------------------------------------------

-- Is lazy installed? No? Install it
-- Copied from https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ "brenoprata10/nvim-highlight-colors",
		config = function()
			vim.opt.termguicolors = true
			require("nvim-highlight-colors").setup({})
		end,
	},
	{ "nmac427/guess-indent.nvim",
		config = function()
			require("guess-indent").setup({})
		end,
	},
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp", },
	{ "neovim/nvim-lspconfig",
		config = function()
			-- Language Server Protocol setup

			-- Reserve a space in the gutter
			-- This will avoid an annoying layout shift in the screen
			vim.opt.signcolumn = "yes"

			-- Add cmp_nvim_lsp capabilities settings to lspconfig
			-- This should be executed before you configure any language server
			local lspconfig_defaults = require("lspconfig").util.default_config
			lspconfig_defaults.capabilities = vim.tbl_deep_extend(
				"force",
				lspconfig_defaults.capabilities,
				require("cmp_nvim_lsp").default_capabilities()
			)

			-- This is where you enable features that only work
			-- if there is a language server active in the file
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = {buffer = event.buf}

					vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
					vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
					vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
					vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
					vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
					vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
					vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
					vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
					vim.keymap.set({"n", "x"}, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
					vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
				end,
			})

			local lspconfig = require("lspconfig")

			-- Enable (broadcasting) snippet capability for completion
			-- Needed by css, html servers
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			-- vscode-css-language-server
			lspconfig.cssls.setup { capabilities = capabilities, }
			-- vscode-eslint-language-server
			lspconfig.eslint.setup({
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			})
			-- vscode-html-language-server
			require'lspconfig'.html.setup({ capabilities = capabilities, })
			-- vscode-json-language-server
			require'lspconfig'.jsonls.setup({ capabilities = capabilities, })
			-- vscode-markdown-language-server
			-- TODO: do it
			lspconfig.bashls.setup({})
			lspconfig.csharp_ls.setup({})
			lspconfig.nixd.setup({})
			lspconfig.pylsp.setup({})
			lspconfig.lua_ls.setup({
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc') then
							return
						end
					end

					client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
						runtime = {
							-- Tell the language server which version of Lua you're using
							-- (most likely LuaJIT in the case of Neovim)
							version = 'LuaJIT'
						},
						-- Make the server aware of Neovim runtime files
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME
								-- Depending on the usage, you might want to add additional paths here.
								-- "${3rd}/luv/library"
								-- "${3rd}/busted/library",
							}
							-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
							-- library = vim.api.nvim_get_runtime_file("", true)
						}
					})
				end,
				settings = {
					Lua = {},
				},
			})
		end,
	},
	{ "echasnovski/mini.nvim",
		version = "*",
	},
	{ "equalsraf/neovim-gui-shim", },
	{ "preservim/nerdtree",
		dependencies = {
			{ "ryanoasis/vim-devicons"},
			{ "PhilRunninger/nerdtree-visual-selection"},
		},
		config = function()
			-- Toggle file explorer by " e"
			vim.keymap.set("n", "<leader>e", vim.cmd.NERDTreeToggle)
		end,
	},
	{ "nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sf", builtin.find_files, {})  -- search files
			vim.keymap.set("n", "<leader>sg", builtin.git_files, {})   -- git watched files
			vim.keymap.set("n", "<gs>", function()                     -- explore file by grep
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end)
		end,
	},
	{ "nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			-- A list of parser names, or "all" (the listed parsers MUST always be installed)
			ensure_installed = {
				"bash",
				"c",
				"c_sharp",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"hyprlang",
				"python",
				"java",
				"javascript",
				"xml",
				"gdscript",
				"powershell",
				"purescript",
				"bibtex",
				"latex",
			},

			auto_install = true,

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			highlight = {
				enable = true,

				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},

			indent = {
				enable = true,
			},
		},
	},
	{ "mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end,
	},
})

require('mini.base16').setup({
	palette = {
		base00 = "#232627",
		base01 = "#2a2e32",
		base02 = "#2d5c76",
		base03 = "#7a7c7d",
		base04 = "#cfcfc2",
		base05 = "#cfcfc2",
		base06 = "#3f8058",
		base07 = "#3f8058",
		base08 = "#27aeae",
		base09 = "#f67400",
		base0A = "#0099ff",
		base0B = "#f44f4f",
		base0C = "#3daee9",
		base0D = "#3daee9",
		base0E = "#27ae60",
		base0F = "#3f8058"
	}
})
