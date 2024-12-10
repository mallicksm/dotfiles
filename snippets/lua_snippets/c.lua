local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local c = ls.choice_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
        s("main", fmt([[
        int main({}) {{
            {}
            return 0;
        }}
    ]], {
                c(1, {
                        t("void"),                  -- Option for void
                        t("int argc, char *argv[]") -- Option for argc, argv
                }),
                i(0)                                -- Placeholder for the body of the function
        })),
        s("if", fmt([[
        if ({}) {{
            {}
        }}
    ]], {
                i(1, "true"), -- Placeholder for the condition with default value "true"
                i(0)          -- Placeholder for the block content
        })),
        s("el", fmt("<%={} %>{}", { i(1), i(0) })),
        s("ei", fmt("<%= if {} do %>{}<% end %>{}", { i(1),i(2), i(0) })),
}
