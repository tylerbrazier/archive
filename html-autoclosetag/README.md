HTML-AutoCloseTag
=================

**Archived since I creating vim-tagpair**

Fork of http://www.vim.org/scripts/script.php?script_id=2591
with updates for HTML 5 and several bug fixes.

Automatically closes HTML tag once you finish typing it with `>`.
It is also smart enough to not autoclose tags when in a comment or when they
are self-closing.

So, `<body id="foo">`, upon typing `>`, will become `<body id="foo">|</body>`,
where `|` is the cursor.
But, if you type `<img src="bar.png">`, the script knows to keep it the same.
