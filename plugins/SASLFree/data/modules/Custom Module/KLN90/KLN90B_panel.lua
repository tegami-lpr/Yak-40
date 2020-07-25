size = {914, 293}

-- Popup panel for KLN90B

-- KLN90 and custom drefs

local displayBrightness = globalPropertyf("kln90b/KLN90/brightness") -- brightness of display and angle of power knob
local L_Angle_3D = globalPropertyi("kln90b/KLN90/3D_L_Angle")
local R_Angle_3D = globalPropertyi("kln90b/KLN90/3D_R_Angle")
local SCAN = globalPropertyi("kln90b/KLN90/SCAN") -- flag, if right knob in SCAN mode

-- X-Plane drefs

local Night = globalPropertyf("sim/graphics/scenery/percent_lights_on")
local Panel = globalPropertyf("sim/cockpit/electrical/cockpit_lights")

--commands

local KLNLCRSRc_command = findCommand("xap/KLN90/Toggle_Left_Cursor")
local KLNRCRSRc_command = findCommand("xap/KLN90/Toggle_Right_Cursor")
local KLNpowerc_command = findCommand("xap/KLN90/Toggle_Power_Switch")
local KLNincbrtc_command = findCommand("xap/KLN90/Increase_Brightness")
local KLNdecbrtc_command = findCommand("xap/KLN90/Decrease_Brightness")

local KLNSCANc_command = findCommand("xap/KLN90/Toggle_Scan_Mode")

local KLNlknoblccc_command = findCommand("xap/KLN90/Turn_Left_Large_Knob_Counterclockwise")
local KLNlknobsccc_command = findCommand("xap/KLN90/Turn_Left_Small_Knob_Counterclockwise")
local KLNlknobscc_command = findCommand("xap/KLN90/Turn_Left_Small_Knob_Clockwise")
local KLNlknoblcc_command = findCommand("xap/KLN90/Turn_Left_Large_Knob_Clockwise")
local KLNrknoblccc_command = findCommand("xap/KLN90/Turn_Right_Large_Knob_Counterclockwise")
local KLNrknobsccc_command = findCommand("xap/KLN90/Turn_Right_Small_Knob_Counterclockwise")
local KLNrknobscc_command = findCommand("xap/KLN90/Turn_Right_Small_Knob_Clockwise")
local KLNrknoblcc_command = findCommand("xap/KLN90/Turn_Right_Large_Knob_Clockwise")


local KLNMSGc_command = findCommand("xap/KLN90/Toggle_Message_Page")
local KLNALTc_command = findCommand("xap/KLN90/Toggle_Altitude_Page")
local KLNDTOc_command = findCommand("xap/KLN90/Toggle_Direct_To_Page")
local KLNCLRc_command = findCommand("xap/KLN90/Press_CLR")
local KLNENTc_command = findCommand("xap/KLN90/Press_ENT")


-- local resources

---- Images
local bg = loadImage("KLN90.png", 0, 219, 914, 293)
local powerknob = loadImage("KLN90.png", 455, 139, 52, 52)
local powerext = loadImage("KLN90.png", 445, 62, 65, 50)
local rknobstex = loadImage("KLN90.png", 528, 129, 71, 71)
local lknobstex = loadImage("KLN90.png", 528, 49, 71, 71)


----Cursors

local buttonCursor = {
    -- finger cursor
    x = -8,
    y = -16,
    width = 20,
    height = 20,
    shape = sasl.gl.loadImage("cursors.png", 280, 461, 20, 20),
    hideOSCursor = true
}

local rotateRightLargeCursor = {
    -- rotate right large cursor
    x = -24,
    y = -24,
    width = 64,
    height = 64,
    shape = sasl.gl.loadImage("cursors.png", 0, 257, 64, 64),
    hideOSCursor = true
}

local rotateLeftLargeCursor = {
    -- rotate left large cursor
    x = -24,
    y = -24,
    width = 64,
    height = 64,
    shape = sasl.gl.loadImage("cursors.png", 320, 257, 64, 64),
    hideOSCursor = true
}

local rotateRightSmallCursor = {
    -- rotate right large cursor
    x = -24,
    y = -24,
    width = 64,
    height = 64,
    shape = sasl.gl.loadImage("cursors.png", 128, 257, 64, 64),
    hideOSCursor = true
}

local rotateLeftSmallCursor = {
    -- rotate left large cursor
    x = -24,
    y = -24,
    width = 64,
    height = 64,
    shape = sasl.gl.loadImage("cursors.png", 190, 257, 64, 64),
    hideOSCursor = true
}

-- local vars

local Dim = 1

-- functions
function calc_panel_brightness()
    -- if night lights on, then dim background image
    if get(Night) == 0 then
        return 1
    else
        return Dim / 2
    end
end


components = {
    ------ background ------
	textureLit {
        position = {0, 0, size[1], size[2]},
		image = bg,
		brightness = calc_panel_brightness,
    },
    
    needle {
        -- Powerknob
        position = {779, 210, 52, 52},
        image = powerknob,
        brightness = calc_panel_brightness,
        angle = function()
            return get(displayBrightness) * 335
        end,
    },

    needle {
        -- left knob
        position = {39.5*2, 16*2, 35.5, 35.5},
        image = lknobstex,
        brightness = calc_panel_brightness,
        angle = function()
            return get(L_Angle_3D) * 10
        end,
    },

    needle {
        -- right knob
        position = {385*2, 16*2, 35.5, 35.5},
        image = rknobstex,
        brightness = calc_panel_brightness,
        angle = function()
            return get(R_Angle_3D) * 10
        end,
    },    
    
    needle {
        -- right knob with SCAN
        position = {386*2, 30, 35.5, 35.5},
        image = rknobstex,
        brightness = calc_panel_brightness,
        angle = function()
            return get(R_Angle_3D) * 10
        end,
        visible = function()
            return get(SCAN) == 1
        end,
    },

    interactive {
        -- Power button
        position = {398*2, 114*2, 20, 20},
        cursor = buttonCursor,
        onMouseDown = function()
            commandOnce(KLNpowerc_command)
            return true
        end
    },

    interactive {
        -- Left cursor button
        position = {43.5*2, 75.5*2, 51, 30 },
        cursor = buttonCursor,
        onMouseDown = function()
            commandOnce(KLNLCRSRc_command)
            return true
        end
    },
 
    interactive {
        --Right cursor button
        position = {388*2, 75.5*2, 51, 30 },
        cursor = buttonCursor,
        onMouseDown = function()
            commandOnce(KLNRCRSRc_command)
            return true
        end
    },

    interactive {
        -- Decrease display brightness
        position = {378*2, 107.5*2, 20, 40 },
        cursor = rotateLeftSmallCursor,
        onMouseDown = function()
            commandOnce(KLNdecbrtc_command)
            return true
        end
    },

    interactive {
        -- Increase display brightness
        position = {418*2, 107.5*2, 20, 40 },
        cursor = rotateRightSmallCursor,
        onMouseDown = function()
            commandOnce(KLNincbrtc_command)
            return true
        end
    },

    interactive {
        -- MSG button
        position = {116*2, 18, 53, 31 },
        cursor = buttonCursor,
        onMouseDown = function()
            commandOnce(KLNMSGc_command)
            return true
        end
    },

    interactive {
        -- ALT button
	    position = {165.5*2, 18, 53, 31 },
	    cursor = buttonCursor,
        onMouseDown = function()
            commandOnce(KLNALTc_command)
            return true
        end
	},

    interactive {
        -- DCT button
	    position = {215*2, 18, 53, 31 },
	    cursor = buttonCursor,
        onMouseDown = function()
            commandOnce(KLNDTOc_command)
	        return true
        end
	},

    interactive {
        -- CLR button
        position = {264.5*2, 18, 53, 31 },
        cursor = buttonCursor,
        onMouseDown = function()
            commandOnce(KLNCLRc_command)
            return true
        end
    },

    interactive {
        -- ENT button
	    position = {314*2, 18, 53, 31 },
	    cursor = buttonCursor,
        onMouseDown = function()
	        commandOnce(KLNENTc_command)
	        return true
        end
	},

    interactive {
        -- Left Small knob rotate CCW
	    position = {60, 20, 45, 95 },
	    cursor = rotateLeftSmallCursor,
        onMouseDown = function()
            commandOnce(KLNlknobsccc_command)
	        return true
        end
	},    

    interactive {
        -- Left Small knob rotate CW
        position = {120, 20, 45, 95 },
        cursor = rotateRightSmallCursor,
        onMouseDown = function()
            commandOnce(KLNlknobscc_command)
            return true
        end
    },

    interactive {
        -- Left Large knob rotate CCW
        position = {10, 20, 45, 95 },
        cursor = rotateLeftLargeCursor,
        onMouseDown = function()
            commandOnce(KLNlknoblccc_command)
            return true
        end
	},        

    interactive {
        -- Left Large knob rotate CW
	    position = {170, 20, 45, 95 },
	    cursor = rotateRightLargeCursor,
        onMouseDown = function()
	        commandOnce(KLNlknoblcc_command)
	        return true
        end
	},
    
    interactive {
        -- Right Small knob rotate CCW
        position = {750, 20, 45, 95 },
        cursor = rotateLeftSmallCursor,
        onMouseDown = function()
            commandOnce(KLNrknobsccc_command)
            return true
        end
	},

    interactive {
        -- Right Small knob rotate CW
	    position = {810, 20, 45, 95 },
        cursor = rotateRightSmallCursor,
        onMouseDown = function()
            commandOnce(KLNrknobscc_command)
	        return true
        end
    },
    
    interactive {
        -- Right Large knob rotate CCW
        position = {700, 20, 45, 95 },
        cursor = rotateLeftLargeCursor,
        onMouseDown = function()
            commandOnce(KLNrknoblccc_command)
            return true
        end
    },

    interactive {
        -- Right Large knob rotate CW
	    position = {860, 20, 45, 95 },
	    cursor = rotateRightLargeCursor,
        onMouseDown = function()
	        commandOnce(KLNrknoblcc_command)
	        return true
        end
    },
    
    interactive {
        -- SCAN button
        position = {776, 60, 51, 35 },
        cursor = buttonCursor,
        onMouseDown = function()
            commandOnce(KLNSCANc_command)
            return true
        end
    },

    KLN90B_display {
        position = {244, 66, 426, 200},
    },
}

function update()
    -- 0.75 is the minimum brightness when the panel is fully lit.
    Dim = (-get(Night) * 0.75 * -get(Panel)) / 2 - get(Night) / 2 + 1
    updateAll(components)
end
