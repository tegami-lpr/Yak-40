size = {426,200}

require "/KLN90/kln_maputils"

-- KLN90 and custom drefs
local displayBrightness = globalPropertyf("kln90b/KLN90/brightness") -- brightness of display and angle of power knob
local kln_power = globalPropertyi("kln90b/kln_power")

local NAV5CompProp = globalPropertys("kln90b/KLN90/graphNAV5Comp"); -- NAV5 map elements
local APT3Prop = globalPropertys("kln90b/KLN90/graphAPT3Comp");

---- KLN90B display lines
local gline_1 = globalPropertys("kln90b/KLN90/gline_1")
local gline_2 = globalPropertys("kln90b/KLN90/gline_2")
local gline_3 = globalPropertys("kln90b/KLN90/gline_3")
local gline_4 = globalPropertys("kln90b/KLN90/gline_4")
local gline_5 = globalPropertys("kln90b/KLN90/gline_5")
local gline_6 = globalPropertys("kln90b/KLN90/gline_6")
local gline_7 = globalPropertys("kln90b/KLN90/gline_7")
local gline_8 = globalPropertys("kln90b/KLN90/gline_8")
local bline_1 = globalPropertys("kln90b/KLN90/bline_1")
local bline_2 = globalPropertys("kln90b/KLN90/bline_2")
local bline_3 = globalPropertys("kln90b/KLN90/bline_3")
local bline_4 = globalPropertys("kln90b/KLN90/bline_4")
local bline_5 = globalPropertys("kln90b/KLN90/bline_5")
local bline_6 = globalPropertys("kln90b/KLN90/bline_6")
local bline_7 = globalPropertys("kln90b/KLN90/bline_7")
local bline_8 = globalPropertys("kln90b/KLN90/bline_8")
local scaleline = globalPropertys("kln90b/KLN90/scale_line")
local cagevisible = globalPropertyi("kln90b/KLN90/cage")

-- X_Plane drefs

local Night = globalPropertyf("sim/graphics/scenery/percent_lights_on")
local Panel = globalPropertyf("sim/cockpit/electrical/cockpit_lights")

-- local resources
---- Images

local glass = loadImage("KLN90.png", 10, 15, 426, 199)
local cage = loadImage("KLN90.png", 9, 9, 415, 2)

---- Fonts
local font = loadBitmapFont('KLN90.fnt')
local fontb = loadBitmapFont('KLN90_2.fnt')
local fontl = loadBitmapFont('KLN90_3.fnt')

---- Local vars

local Nav5Comp = {}
local APT3Comp = {}
local Dim = 1

local in_NAV5Comp
local in_NAV5CompPrev

local in_APT3Comp
local in_APT3CompPrev




---- Components definitions
---
bottomComponents = {
    rectangle2 {
        -- Display backlight
		position = {0, 0, 426, 200},
		color = {0, 0.85, 0.05},
		alpha = function()
			if get(kln_power) == 0 then
				return 0
			else
				return get(displayBrightness) / 10
			end
		end,
    },

    textureLit {
        -- Bottom cage line
        position = {5, 50, 208, 2},
        image = cage,
        brightness = function()
            return get(displayBrightness)
        end,
        visible = function()
            return get(cagevisible) == 1
        end,
    },    
}

topComponents = {
	textureLit {
        -- Glass
		position = {0, 0, 426, 200},
        image = glass,
        brightness = function()
            if get(kln_power) == 0 then
                if get(Night) == 0 then
                    return 1
                else
                    return Dim / 4
                end
            else
                return get(displayBrightness)
            end
        end,        
	},
}


function NAV5Decoder()
    Nav5Comp = {}
    --local in_NAV5Comp = get(NAV5CompProp)
    local draw_elements = kln_maputils.split(in_NAV5Comp,":")
    for ie,ve in ipairs(draw_elements) do
        local elm = kln_maputils.split(ve, ";")
        if elm[1] == "1" then
            table.insert(Nav5Comp, 
                textureLit {
                    position = {tonumber(elm[2]), tonumber(elm[3]), tonumber(elm[4]), tonumber(elm[5])},
                    image = kln_maputils.getImage(elm[6]),
                    brightness = function()
                        return get(displayBrightness)
                    end,
                    visible = function()
                        return true
                    end,
                })
        elseif elm[1] == "2" then
            kln_maputils.drawline(Nav5Comp, tonumber(elm[2]), tonumber(elm[3]), tonumber(elm[4]), tonumber(elm[5]),{tonumber(elm[6]), tonumber(elm[7]), tonumber(elm[8]), tonumber(elm[9])})
        elseif elm[1] == "3" then
            kln_maputils.string2tex(Nav5Comp, elm[2],  tonumber(elm[3]),  tonumber(elm[4]), { tonumber(elm[5]),  tonumber(elm[6]),  tonumber(elm[7]),  tonumber(elm[8])})
        else
        end
    end
end

function APT3Decoder()
    APT3Comp = {}
    --local in_APT3Comp = get(APT3Prop)
    local draw_elements = kln_maputils.split(in_APT3Comp,":")
    for ie,ve in ipairs(draw_elements) do
        local elm = kln_maputils.split(ve, ";")
        if elm[1] == "1" then
            table.insert(APT3Comp, 
                textureLit {
                    position = {tonumber(elm[2]), tonumber(elm[3]), tonumber(elm[4]), tonumber(elm[5])},
                    image = kln_maputils.getImage(elm[6]),
                    brightness = function()
                        return get(displayBrightness)
                    end,
                    visible = function()
                        return true
                    end,
                }  
            )
        elseif elm[1] == "2" then
            kln_maputils.drawline(APT3Comp, tonumber(elm[2]), tonumber(elm[3]), tonumber(elm[4]), tonumber(elm[5]),{tonumber(elm[6]), tonumber(elm[7]), tonumber(elm[8]), tonumber(elm[9])})
        elseif elm[1] == "3" then
            kln_maputils.string2tex(APT3Comp, elm[2],  tonumber(elm[3]),  tonumber(elm[4]), {tonumber(elm[5]), tonumber(elm[6]), tonumber(elm[7]), tonumber(elm[8])})
        else
        end
    end
end

function update()
  in_NAV5Comp = get(NAV5CompProp)
  if not (in_NAV5Comp == in_NAV5CompPrev) then
    NAV5Decoder()
    in_NAV5CompPrev = in_NAV5Comp
  end

  in_APT3Comp = get(APT3Prop)
  if not (in_APT3Comp == in_APT3CompPrev) then
    APT3Decoder()
    in_APT3CompPrev = in_APT3Comp
  end

  Dim = (-get(Night)*0.75*-get(Panel))/2-get(Night)/2+1
end

function draw()
    drawAll(bottomComponents)

    local brt = get(displayBrightness)
    if get(kln_power) == 1 then
        sasl.gl.saveGraphicsContext()

        setScaleTransform(2, 2)

        -- beetween 1 and 2 line (from bottom) interval equal 14 px (2 px for cage line)
        -- beetween 2 and 3 and etc interval is 11 px

        -- normal lines
        drawBitmapText(font,  3, 67,  get(gline_1), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(font,  3, 56,  get(gline_2), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(font,  3, 45,  get(gline_3), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(font,  3, 34,  get(gline_4), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(font,  3, 23,  get(gline_5), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(font,  3, 12,  get(gline_6), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(font,  3, -2,  get(gline_7), TEXT_ALIGN_LEFT, {brt, brt, brt})

        -- bold lines
        drawBitmapText(fontb, 3, 67, get(bline_1), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(fontb, 3, 56, get(bline_2), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(fontb, 3, 45, get(bline_3), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(fontb, 3, 34, get(bline_4), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(fontb, 3, 23, get(bline_5), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(fontb, 3, 12, get(bline_6), TEXT_ALIGN_LEFT, {brt, brt, brt})
        drawBitmapText(fontb, 3, -2, get(bline_7), TEXT_ALIGN_LEFT, {brt, brt, brt})
        
        -- Super NAV1 scale line
        drawBitmapText(fontl, 7.5, 56, get(scaleline), TEXT_ALIGN_LEFT, {brt, brt, brt})

        drawAll(Nav5Comp)
        drawAll(APT3Comp)
        sasl.gl.restoreGraphicsContext()
    end

    drawAll(topComponents)
end