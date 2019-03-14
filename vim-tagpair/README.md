# vim-tagpair
Lightweight auto-completion plugin for html tags.

Typing a `>` will automatically close the tag:

    <div|  ->  <div>|</div>

Void elements (those without a closing tag) will not be completed.

    <input|  ->  <input>|

Pressing enter between two tags expands them like:

    <a href="#">|</a>  ->  <a href="#">
                             |
                           </a>
