# readme
# ' :: ' is the production operator, its left side must be replaced by its right side
# '_CONTENT_' is recursively replaced by the element's content. In the end, the resolveld text content must be html-escaped for '<','>','"'
# '_EMPTY_' is the empty string
# '_UNKNOWN_' is the unknown tag name, eg. <foobar> is interpreted as <_UNKNOWN_>

# any tag may have any additional set of attributes, but those must be omitted: <br _moz_dirty="true">::<br>
# empty tags may have a self-closing slash <br /> or <br/>, but the production should remove it: <br>
# all attributes and tag names must be set to lowercase, but attribute values (where allowed) must be handled as case-sensitive

# The whitelisting does not say what should happen with non-supoorted tags:
# but without blocklevel elements as a replacement, the document will loose its structure 
# (by interpreting all the rest as inline phrasing content, eg a table would become a string-like gibberish). 
# and the content of inline level elements like <u> cannot be found easily in a longer text. 
# For that reason, all blocklevel flow elements that are not on the whitelist become a div, and inline level elements a span here. 
