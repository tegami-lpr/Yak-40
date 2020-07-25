kln_maputils = {}

require "/KLN90/kln_utils"


local displayBrightness = globalPropertyf("kln90b/KLN90/brightness") -- brightness of display and angle of power knob

------ Map icons

local mapplane =   loadImage("KLNmap.png", 2,  58, 5, 4)
local mapstar =    loadImage("KLNmap.png", 16, 57, 5, 5)
local mapdiamond = loadImage("KLNmap.png", 9,  57, 5, 5)
local mappixel =   loadImage("KLNmap.png", 4,  53, 1, 1)
local mapplus =    loadImage("KLNmap.png", 43, 58, 3, 3)
local mapquad =    loadImage("KLNmap.png", 9,  52, 3, 3)
local mapAPT =     loadImage("KLNmap.png", 23, 57, 5, 5)
local mapNDB =     loadImage("KLNmap.png", 30, 57, 4, 4)
local mapVOR =     loadImage("KLNmap.png", 36, 57, 5, 5)

local Atex = loadImage("KLNmap.png", 1,   21, 5, 7)
local Btex = loadImage("KLNmap.png", 7,   21, 5, 7)
local Ctex = loadImage("KLNmap.png", 13,  21, 5, 7)
local Dtex = loadImage("KLNmap.png", 19,  21, 5, 7)
local Etex = loadImage("KLNmap.png", 25,  21, 5, 7)
local Ftex = loadImage("KLNmap.png", 31,  21, 5, 7)
local Gtex = loadImage("KLNmap.png", 37,  21, 5, 7)
local Htex = loadImage("KLNmap.png", 43,  21, 5, 7)
local Itex = loadImage("KLNmap.png", 49,  21, 5, 7)
local Jtex = loadImage("KLNmap.png", 55,  21, 5, 7)
local Ktex = loadImage("KLNmap.png", 61,  21, 5, 7)
local Ltex = loadImage("KLNmap.png", 67,  21, 5, 7)
local Mtex = loadImage("KLNmap.png", 73,  21, 5, 7)
local Ntex = loadImage("KLNmap.png", 79,  21, 5, 7)
local Otex = loadImage("KLNmap.png", 85,  21, 5, 7)
local Ptex = loadImage("KLNmap.png", 91,  21, 5, 7)
local Qtex = loadImage("KLNmap.png", 97,  21, 5, 7)
local Rtex = loadImage("KLNmap.png", 103, 21, 5, 7)
local Stex = loadImage("KLNmap.png", 109, 21, 5, 7)
local Ttex = loadImage("KLNmap.png", 115, 21, 5, 7)
local Utex = loadImage("KLNmap.png", 121, 21, 5, 7)
local Vtex = loadImage("KLNmap.png", 127, 21, 5, 7)
local Wtex = loadImage("KLNmap.png", 133, 21, 5, 7)
local Xtex = loadImage("KLNmap.png", 139, 21, 5, 7)
local Ytex = loadImage("KLNmap.png", 145, 21, 5, 7)
local Ztex = loadImage("KLNmap.png", 151, 21, 5, 7)
local ötex = loadImage("KLNmap.png", 157, 21, 5, 7)
local ö0tex = loadImage("KLNmap.png", 1,  13, 5, 7)
local ö1tex = loadImage("KLNmap.png", 7,  13, 5, 7)
local ö2tex = loadImage("KLNmap.png", 13, 13, 5, 7)
local ö3tex = loadImage("KLNmap.png", 19, 13, 5, 7)
local ö4tex = loadImage("KLNmap.png", 25, 13, 5, 7)
local ö5tex = loadImage("KLNmap.png", 31, 13, 5, 7)
local ö6tex = loadImage("KLNmap.png", 37, 13, 5, 7)
local ö7tex = loadImage("KLNmap.png", 43, 13, 5, 7)
local ö8tex = loadImage("KLNmap.png", 49, 13, 5, 7)
local ö9tex = loadImage("KLNmap.png", 55, 13, 5, 7)


function kln_maputils.notoccupied(tables, x, y, size)
    for i, v in ipairs(tables) do
        local size2 = v["position"]["value"]
        if size2 == nil then
             return false
        end

        if not (x > size2[1] + size2[3] or x + size < size2[1] or y + 7 < size2[2] or y > size2[2] + size2[4]) then
            return false
        end

    end
    return true
end


function kln_maputils.getImage(idx)
    if idx == "0" then
        return mapVOR
    elseif idx == "1" then
        return mapquad
    elseif idx == "2" then
        return mapplane
    elseif idx == "3" then
        return mapdiamond
    elseif idx == "4" then
        return mapstar
    elseif idx == "5" then
        return mapAPT
    elseif idx == "6" then
        return mapNDB
    else
        return mappixel
    end
end

function kln_maputils.drawline(tables, x1, y1, x2, y2, size)
    -- 1 sup, 2 left, 3 righ, 4apt
    if math.abs(x1 - x2) > math.abs(y1 - y2) then
        local x3 = x1
        local x4 = x2
        local y3 = y1
        local y4 = y2
        if x1 > x2 then
            x3 = x2
            x4 = x1
            y3 = y2
            y4 = y1
        end
        -- if y1 < y2 then
        -- y3 = y2
        -- y4 = y1
        -- end
        local climb = (y2 - y1) / (x2 - x1)

        y3 = y3 + climb
        x3 = x3 + 1
        while x3 < x4 do
            if x3 - 0.5 > size[1] and x3 + 0.5 < size[1] + size[3] and y3 - 0.5 > size[2] and y3 + 0.5 < size[2] + size[4] then
                table.insert(tables, 
                    textureLit {
                        position = { kln_utils.round(x3 - 0.5), kln_utils.round(y3 - 0.5), 1, 1 },
                        image = get(mappixel),
                        brt2 = function()
                            return get(displayBrightness)
                        end,
                        visible = function()
                            return true
                        end
                    }
                )
            end
            y3 = y3 + climb
            x3 = x3 + 1
        end
    else
        local y3 = y1
        local y4 = y2
        local x3 = x1
        local x4 = x2
        if y1 > y2 then
            y3 = y2
            y4 = y1
            x3 = x2
            x4 = x1
        end
        -- if x1 < x2 then
        -- x3 = x2
        -- x4 = x1
        -- end
        local climb = (x2 - x1) / (y2 - y1)

        x3 = x3 + climb
        y3 = y3 + 1
        -- print("bb",climb, x1, y3, x2, y2)
        while y3 < y4 do
            if x3 - 0.5 > size[1] and x3 + 0.5 < size[1] + size[3] and y3 - 0.5 > size[2] and y3 + 0.5 < size[2] + size[4] then
                table.insert(tables, 
                    textureLit {
                        position = { kln_utils.round(x3 - 0.5), kln_utils.round(y3 - 0.5), 1, 1 },
                        image = get(mappixel),
                        brt2 = function()
                            return get(displayBrightness)
                        end,
                        visible = function()
                            return true
                        end
                    }
                )
            end
            x3 = x3 + climb
            y3 = y3 + 1
        end
    end
end

function kln_maputils.string2tex(tables, strings, x, y, size)
	local num1 = 1
	local length = string.find(strings, " ")
	if length == nil then
		length = 4
	else
		length = length - 2
	end
	length = length * 6

	local num2 = 1
	local switchx = {6, 6, 6, - length / 2, -6 - length, -6 - length, -6 - length, - length / 2, 6}
	local switchy = {-7, 0, 7, 7, 7, 0, -7, -7, -7}
	-- print(strings, x, switchx[1], switchx[4], switchx[5], length)
	--we check all eight positions if they are free! (we don't even need to check 9)
	while num2 <= 8 do
		if kln_maputils.notoccupied(tables, kln_utils.round(x - 2.5 + switchx[num2]), kln_utils.round(y - 3.5 + switchy[num2]), length) == true and kln_utils.round(x - 2.5 + switchx[num2]) > size[1] and  kln_utils.round(x + length + 2.5 + switchx[num2]) < size[1]+size[3] and kln_utils.round(y - 3.5 + switchy[num2]) > size[2] and kln_utils.round(y + 3.5 + switchy[num2]) < size[2]+size[4] then break end
		num2 = num2 + 1
	end

	x = x + switchx[num2]
	y = y + switchy[num2]

	while num1 <= 5 do
		local strings = string.sub(strings, num1, num1)
		if kln_utils.round(x-2.5) > size[1] and kln_utils.round(x+2.5) < size[1]+size[3] and kln_utils.round(y-3.5) > size[2] and kln_utils.round(y+3.5) < size[2]+size[4] and strings ~= " " then
			local file = get(Atex)
			if strings == "B" then
				file = get(Btex)
			elseif strings == "C" then
				file = get(Ctex)
			elseif strings == "D" then
				file = get(Dtex)
			elseif strings == "E" then
				file = get(Etex)
			elseif strings == "F" then
				file = get(Ftex)
			elseif strings == "G" then
				file = get(Gtex)
			elseif strings == "H" then
				file = get(Htex)
			elseif strings == "I" then
				file = get(Itex)
			elseif strings == "J" then
				file = get(Jtex)
			elseif strings == "K" then
				file = get(Ktex)
			elseif strings == "L" then
				file = get(Ltex)
			elseif strings == "M" then
				file = get(Mtex)
			elseif strings == "N" then
				file = get(Ntex)
			elseif strings == "O" then
				file = get(Otex)
			elseif strings == "P" then
				file = get(Ptex)
			elseif strings == "Q" then
				file = get(Qtex)
			elseif strings == "R" then
				file = get(Rtex)
			elseif strings == "S" then
				file = get(Stex)
			elseif strings == "T" then
				file = get(Ttex)
			elseif strings == "U" then
				file = get(Utex)
			elseif strings == "V" then
				file = get(Vtex)
			elseif strings == "W" then
				file = get(Wtex)
			elseif strings == "X" then
				file = get(Xtex)
			elseif strings == "Y" then
				file = get(Ytex)
			elseif strings == "Z" then
				file = get(Ztex)
			elseif strings == "0" then
				file = get(ö0tex)
			elseif strings == "1" then
				file = get(ö1tex)
			elseif strings == "2" then
				file = get(ö2tex)
			elseif strings == "3" then
				file = get(ö3tex)
			elseif strings == "4" then
				file = get(ö4tex)
			elseif strings == "5" then
				file = get(ö5tex)
			elseif strings == "6" then
				file = get(ö6tex)
			elseif strings == "7" then
				file = get(ö7tex)
			elseif strings == "8" then
				file = get(ö8tex)
			elseif strings == "9" then
				file = get(ö9tex)
			end

            table.insert(tables, 
            textureLit {
                position = {kln_utils.round(x-2.5), kln_utils.round(y-3.5), 5, 7},
                image = file,
                brt2 = function()
                    return get(displayBrightness)
                end,
                visible = function()
                    return true
                end,
		    })
	    end
	    x = x + 6
	    num1 = num1 + 1
    end
end

function kln_maputils.split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end


