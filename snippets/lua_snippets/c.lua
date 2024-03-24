local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("cheader", {
		t({ "also", "loaded!!" }),
		i(1),
		t("also loaded!!")
	}),
	s("autotrig", {
		t("autotriggered, if enabled")
	})
}
