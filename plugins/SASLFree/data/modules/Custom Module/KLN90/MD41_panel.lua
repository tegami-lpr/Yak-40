size = {761, 288}

local bg = loadImage("MD41.png", 0, 224, 761, 288)
local NAVimg = loadImage("MD41.png", 150, 172, 85, 30)
local ARMimg = loadImage("MD41.png", 275, 172, 85, 30)
local OBSimg = loadImage("MD41.png", 400, 172, 85, 30)
local MSGimg = loadImage("MD41.png", 525, 172, 85, 30)
local GPSimg = loadImage("MD41.png", 150, 119, 85, 30)
local ACTVimg = loadImage("MD41.png", 275, 119, 85, 30)
local LEGimg = loadImage("MD41.png", 400, 119, 85, 30)
local WPTimg = loadImage("MD41.png", 525, 119, 85, 30)


local HSIsource = globalPropertyi("sim/cockpit2/radios/actuators/HSI_source_select_pilot")
--HSI source to display: 0 for Nav1, 1 for Nav2, 2 for GPS.

local test = globalPropertyi("kln90b/MD41/test")
local OBS = globalPropertyi("kln90b/KLN90/OBS")
local OBSreq = globalPropertyi("kln90b/MD41/OBSreq")
local APR = globalPropertyi("kln90b/KLN90/APR")
local MSG = globalPropertyi("kln90b/KLN90/MSG")
local WPT = globalPropertyi("kln90b/KLN90/WPT")
local Flash = globalPropertyi("kln90b/KLN90/Flash")

local Night = globalPropertyf("sim/graphics/scenery/percent_lights_on")
local Panel = globalPropertyf("sim/cockpit/electrical/cockpit_lights")

local Dim = 1
local Testdim = 0

function update()
	if Testdim == 0 then
		--0.75 is the minimum brightness when the panel is fully lit.
		Dim = (-get(Night)*0.75*-get(Panel))/2-get(Night)/2+1
	elseif Testdim == 2 then
		Dim = Dim + 0.05
		if Dim > (-get(Night)*0.75*-get(Panel))/2-get(Night)/2+1 then
			Dim = (-get(Night)*0.75*-get(Panel))/2-get(Night)/2+1
			Testdim = 0
		end
	end
end

local MD41NAVGPSc_command = createCommand("xap/KLN90/MD_41_Toggle_NAV-GPS", "Right Cursor")
function MD41NAVGPSc_handler(phase)  -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
	if 0 == phase then
			if get(HSIsource) == 2  then
				set(HSIsource, 0)
			else
				set(HSIsource, 2)
			end
			end
	return 0
end
registerCommandHandler(MD41NAVGPSc_command, 0, MD41NAVGPSc_handler)

local MD41APRc_command = createCommand("xap/KLN90/MD_41_Toggle_Approach", "Right Cursor")
function MD41APRc_handler(phase)  -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
	if 0 == phase then
			if get(APR) == 0  then
				set(APR, 1)
			else
				set(APR, 0)
			end
			end
	return 0
end
registerCommandHandler(MD41APRc_command, 0, MD41APRc_handler)

local MD41OBSc_command = createCommand("xap/KLN90/MD_41_Toggle_OBS-LEG", "Right Cursor")
function MD41OBSc_handler(phase)  -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
	if 0 == phase then
			if get(OBS) == 1  then
				set(OBSreq, 2)
			else
				set(OBSreq, 1)
			end
			end
	return 0
end
registerCommandHandler(MD41OBSc_command, 0, MD41OBSc_handler)

local MD41testc_command = createCommand("xap/KLN90/MD_41_Test_Lamps", "Right Cursor")
function MD41testc_handler(phase)  -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
	if 0 == phase then
				set(test, 1)
	elseif 2 == phase then
				set(test, 0)
	end
	return 0
end
registerCommandHandler(MD41testc_command, 0, MD41testc_handler)

local buttonCursor = {
	-- finger cursor
  x = -8,
  y = -16,
  width = 20,
  height = 20,
  shape = sasl.gl.loadImage("cursors.png",280,461,20,20),
  hideOSCursor = true
}

components = {

------ background ------
	textureLit {
		position = {0, 0, size[1], size[2]},
		image = bg,
		brightness = function()
			-- if night lights on, then dim background image
			if get(Night) == 0 then
				return 1
			else
				return Dim/2
			end
		end
	},


------ NAV/GPS ------
	textureLit {
		-- NAV lamp
		position = {150, 208, 85, 30},
		image = NAVimg,
		brightness = function()
			return Dim
		end,
		visible = function()
			return get(HSIsource) ~= 2 or get(test) == 1
		end,
	},

	textureLit {
		-- GPS lamp
		position = {150, 155, 85, 30},
		image = GPSimg,
		brightness = function()
			return Dim
		end,
		visible = function()
			return get(HSIsource) == 2 or get(test) == 1
		end,
	},

  interactive {
		--NAV/GPS button
		position = {143, 33, 80, 80 },
		cursor = buttonCursor,
		onMouseDown = function()
			if get(HSIsource) == 2  then
				set(HSIsource, 0)
			else
				set(HSIsource, 2)
			end
			return true
		end
	},


------ ARM/ACTV ------
	textureLit {
		-- ARM lamp
		position = {275, 208, 85, 30},
		image = ARMimg,
		brightnes = function()
			return Dim
		end,
		visible = function()
			return get(APR) == 1 or get(test) == 1
		end,
	},
	textureLit {
		-- ACTV lamp
		position = {275, 155, 85, 30},
		image = ACTVimg,
		brightnes = function()
			return Dim
		end,
		visible = function()
			return get(APR) == 2 or get(test) == 1
		end,
	},
	interactive {
		-- ARM/ACTV button
		position = {272, 33, 80, 80 },
		cursor = buttonCursor,
		onMouseDown = function()
			if get(APR) == 1  then
				set(APR, 0)
			else
				set(APR, 1)
			end
			return true
		end
	},


	------ OBS/LEG ------
	textureLit {
		-- OBS lamp
		position = {400, 208, 85, 30},
		image = OBSimg,
		brightnes = function()
			return Dim
		end,
		visible = function()
			return get(OBS) == 2 or get(test) == 1
		end,
	},
	textureLit {
		-- LEG lamp
		position = {400, 155, 85, 30},
		image = LEGimg,
		brightnes = function()
			return Dim
		end,
		visible = function()
			return get(OBS) == 1 or get(test) == 1
		end,
	},
	interactive {
		position = {409, 33, 80, 80 },
		cursor = buttonCursor,
		onMouseDown = function()
			if get(OBS) == 1  then
				set(OBSreq, 2)
			else
				set(OBSreq, 1)
			end
			return true
		end
	},


------ MSG/WPT ------
	textureLit {
		-- MSG lamp
		position = {525, 208, 85, 30},
		image = get(MSGimg),
		brightnes = function()
			return Dim
		end,
		visible = function()
			return (get(MSG) == 1 and get(Flash) == 1) or get(test) == 1
		end,
	},
	textureLit {
		-- WPT lamp
		position = {525, 155, 85, 30},
		image = get(WPTimg),
		brightnes = function()
			return Dim
		end,
		visible = function()
			return (get(WPT) == 1 and get(Flash) == 1) or get(test) == 1
		end,
	},


------ Brightnes test button ------
	interactive {
		position = {50, 119, 40, 40 },
		cursor = buttonCursor,
		onMouseDown = function()
			Testdim = 1
			return true
		end,
		onMouseHold = function()
			Dim = Dim - 0.05
			if Dim < 0.5 then
				Dim = 0.5
			end
			return true
		end,
		onMouseUp = function()
			Testdim = 2
			return true
		end,
	},


------ Lamps test button ------
	interactive {
		position = {665, 125, 30, 30 },
		cursor = buttonCursor,
		onMouseDown = function()
			set(test, 1)
			return true
		end,
		onMouseUp = function()
			set(test, 0)
			return true
		end,
	},
}
