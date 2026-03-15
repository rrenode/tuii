# [red]Some text[/red]
# \e[1;91m

# [#fc0000]Some text[/#fc0000]
# [#fc0000]Some text[/]
# [bg:#fc0000]Some text[/]


# [blue][bg:#fc0000]Some [/]text[/]

import chroma

let c = "ff0000"
let g = parseHex(c)
echo g.toHtmlRgb()