size = {64, 64}

local bg = loadImage("KLNpopup.png", 0, 0, 64, 64)

local KLN90popupvisible = globalPropertyi("kln90b/KLN90pop/visible")
local MD41visible = globalPropertyi("kln90b/MD41/visible")
local KLN90visible = globalPropertyi("kln90b/KLN90/visible")

local buttonCursor = {
	-- finger cursor
  x = -8,
  y = -9,
  width = 20,
  height = 20,
  shape = sasl.gl.loadImage ("cursors.png",280,461,20,20),
  hideOSCursor = true
}

components = {
	textureLit {
		position = {0, 0, size[1], size[2]},
		image = bg,
	},


	interactive {
		-- KLN90B panel show/hide
		position = {0, 28, 64, 26 },
		cursor = buttonCursor,
		onMouseDown = function()
			if get(KLN90visible) == 1 then
				set(KLN90visible, 0)
			else
				set(KLN90visible, 1)
			end
			return true
		end,
		},

	interactive {
		-- MD41 panel show/hide
		position = {0, 0, 64, 26 },
		cursor = buttonCursor,
		onMouseDown = function()
			if get(MD41visible) == 1 then
				set(MD41visible, 0)
			else
				set(MD41visible, 1)
			end
			return true
		end,
		},

	-- 	-- clickable area for closing main menu
	-- 	clickable {
	-- 	position = { size[1]-10, size[2]-10, 10, 10 },
	--
	-- 	cursor = {
	-- 	x = 16,
	-- 	y = 32,
	-- 	width = 16,
	-- 	height = 16,
	-- 	shape = loadImage("clickable.png")
	-- },
	--
	-- onMouseClick = function()
	-- 	set(KLN90popupvisible, 0 )
	-- 	return true
	-- end
	-- 	},
}
