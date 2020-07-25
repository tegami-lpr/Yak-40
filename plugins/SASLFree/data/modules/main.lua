size = { 2048, 2048 }

-- Нужно указывать эти значения для корректной работы курсора мыши
panelWidth3d = 2048
panelHeight3d = 2048


addSearchPath(moduleDirectory.."/Custom Module/KLN90/")
addSearchPath(moduleDirectory.."/Custom Module/images/")

set(globalPropertys("sim/aircraft/view/acf_tailnum"), "RA87968")

-- компоненты
components = {
	KLN90 {},
--	KLN90_panel {
--			position = { 269, 555, 588, 188 }
--	},
	KLN90B_display {
		position = { 423, 592, 282, 134 }
	},
	menu {},
}
