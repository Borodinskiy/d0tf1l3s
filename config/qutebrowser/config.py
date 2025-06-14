config.load_autoconfig(False)

c.tabs.show = "multiple"

c.url.default_page = "about:blank"
c.url.start_pages  = "about:blank"
c.url.searchengines = {
    # Search
    "DEFAULT": "https://duckduckgo.com/?q={}",
    # Archlinux wiki
    "arw": "https://wiki.archlinux.org/?search={}",
    # Youtube
    "yt": "https://www.youtube.com/results?search_query={}"
}

# So dauns won't say that your browser "outdated"
#c.content.headers.user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:134.0) Gecko/20100101 Firefox/134.0"
c.content.headers.user_agent = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.3.8956.66 Safari/537.36"

# Axioma
#config.bind("J", "tab-prev", mode="normal")
#config.bind("K", "tab-next", mode="normal")

#c.content.proxy = "socks5://127.0.0.1:9051"

c.fonts.default_size = "11pt"

base_bg = "#232627"
base_fg = "#cfcfc2"
base_basebg = "#2a2e32"

sel_bg = "#2d5c76"
sel_fg = "#cfcfc2"
sel_selfg = "#3f8058"

c.colors.hints.bg       = base_bg
c.colors.hints.fg       = base_fg
c.colors.hints.match.fg = base_bg
c.hints.border          = "2px solid " + sel_bg

c.colors.statusbar.normal.bg = base_bg
c.colors.statusbar.normal.fg = base_fg

c.colors.statusbar.command.bg = base_bg
c.colors.statusbar.command.fg = base_fg

c.colors.completion.scrollbar.bg = base_bg
c.colors.completion.scrollbar.fg = base_fg

c.colors.completion.fg = base_fg

c.colors.completion.category.border.top    = base_basebg
c.colors.completion.category.border.bottom = base_basebg
c.colors.completion.category.bg = base_basebg
c.colors.completion.category.fg = base_fg

c.colors.completion.even.bg = base_bg
c.colors.completion.odd.bg = base_bg

c.colors.completion.item.selected.border.top    = sel_bg
c.colors.completion.item.selected.border.bottom = sel_bg
c.colors.completion.item.selected.bg = sel_bg
c.colors.completion.item.selected.fg = sel_fg

c.colors.completion.match.fg = sel_selfg
c.colors.completion.item.selected.match.fg = base_basebg

c.colors.prompts.bg     = base_bg
c.colors.prompts.fg     = base_fg
c.colors.prompts.border = "2px solid" + sel_bg

c.colors.prompts.selected.bg = sel_bg
c.colors.prompts.selected.fg = sel_fg

c.colors.tabs.bar.bg = base_bg

c.colors.tabs.even.bg = base_bg
c.colors.tabs.even.fg = base_fg
c.colors.tabs.odd.bg  = base_bg
c.colors.tabs.odd.fg  = base_fg

c.colors.tabs.selected.even.bg = sel_bg
c.colors.tabs.selected.even.fg = sel_fg
c.colors.tabs.selected.odd.bg  = sel_bg
c.colors.tabs.selected.odd.fg  = sel_fg

# Allows to use cyrillic symbols that share the same keyboard key as english symbol
c.bindings.key_mappings = {
    'й' : 'q',
    'ц' : 'w',
    'у' : 'e',
    'к' : 'r',
    'е' : 't',
    'н' : 'y',
    'г' : 'u',
    'ш' : 'i',
    'щ' : 'o',
    'з' : 'p',
    'х' : '[',
    'ъ' : ']',
    'ф' : 'a',
    'ы' : 's',
    'в' : 'd',
    'а' : 'f',
    'п' : 'g',
    'р' : 'h',
    'о' : 'j',
    'л' : 'k',
    'д' : 'l',
    'ж' : ';',
    'э' : '\'',
    'я' : 'z',
    'ч' : 'x',
    'с' : 'c',
    'м' : 'v',
    'и' : 'b',
    'т' : 'n',
    'ь' : 'm',
    'б' : ',',
    'ю' : '.',
    'ё' : '`',
    'Й' : 'Q',
    'Ц' : 'W',
    'У' : 'E',
    'К' : 'R',
    'Е' : 'T',
    'Н' : 'Y',
    'Г' : 'U',
    'Ш' : 'I',
    'Щ' : 'O',
    'Х' : '{',
    'Ъ' : '}',
    'Ф' : 'A',
    'Ы' : 'S',
    'В' : 'D',
    'А' : 'F',
    'П' : 'G',
    'Р' : 'H',
    'О' : 'J',
    'Л' : 'K',
    'Д' : 'L',
    'Ж' : ':',
    'Э' : '\"',
    'Я' : 'Z',
    'Ч' : 'X',
    'С' : 'C',
    'М' : 'V',
    'И' : 'B',
    'Т' : 'N',
    'Ь' : 'M',
    'Б' : '<',
    'Ю' : '>',
    'Ё' : '~',
    '<Ctrl-С>' : '<Ctrl-C>',
    '<Ctrl-М>' : '<Ctrl-V>'
}

