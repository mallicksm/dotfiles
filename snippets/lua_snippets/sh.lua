local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
return {
	s("btrig", t("also loaded!!")),
	s("autotrig", t("autotriggered, if enabled"))
}
