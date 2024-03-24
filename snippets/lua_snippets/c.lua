local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node

return {
	s("ctrig", t("also loaded!!"))
}, {
	s("autotrig", t("autotriggered, if enabled"))
}
