-------------------------------------------------------------------------
-- Base configuration
-------------------------------------------------------------------------

--vim.cmd [[colorscheme vim]]

vim.g.have_nerd_font = true

vim.opt.encoding = "utf8"
vim.opt.number = true -- line numbers
vim.opt.relativenumber = true
vim.opt.mouse = "a" -- use mouse in terminal?
vim.opt.cursorline = false -- highlight line with cursor
vim.opt.scrolloff = 30 -- minimal number of screen lines to keep above and below the cursor
vim.opt.ttyfast = true
vim.opt.wildmode = "longest,list"
vim.opt.swapfile = true -- use a swapfile for the buffer
vim.opt.breakindent = true -- every wrapped line will continue visually indented
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true -- highlight search results in file
vim.opt.incsearch = true -- while typing a search command, show where the pattern, as it was typed
vim.opt.tabstop = 4 -- tab length in spaces
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4 -- tab in spaces equivalent
vim.opt.expandtab = false -- use spaces instead of real tab
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

local base16_palette = {
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
}

local plugins_desc = {
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
	{ "echasnovski/mini.nvim",
		version = "*",
	},
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
	{ "mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end,
	},
}

local is_root = vim.fn.system('id -u'):gsub('%s+', '') == '0'

-- Is lazy installed? No? Install it
-- Copied from https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not is_root and not (vim.uv or vim.loop).fs_stat(lazypath) then
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

if not is_root then
	vim.opt.rtp:prepend(lazypath)
	require("lazy").setup(plugins_desc)
	require('mini.base16').setup(base16_palette)
end
