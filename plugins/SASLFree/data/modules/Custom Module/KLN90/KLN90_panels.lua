-- Creating MD41, KLN90 and control popup panels

require "/KLN90/kln_utils"

---------- KLN drefs ---------------

local MD41visible = globalPropertyi("kln90b/MD41/visible"); -- show MD41 popup window
local KLN90visible = globalPropertyi("kln90b/KLN90/visible"); -- show/hide main KLN90B popup panel
local KLN90popupVisible = globalPropertyi("kln90b/KLN90pop/visible"); -- show/hide KLN popup control panel

local popx = globalPropertyi("kln90b/KLN90pop/x", 1);
local popy = globalPropertyi("kln90b/KLN90pop/y", 1);


---------- X-Plane drefs -----------

-- window size issue for panels
local window_height = globalPropertyi("sim/graphics/view/window_height")
local window_width = globalPropertyi("sim/graphics/view/window_width")
local external = globalPropertyi("sim/graphics/view/view_is_external")
local scroll = globalPropertyf("sim/graphics/misc/current_scroll_pos")

---------- KLN Panels Commands ------------

local KLNpopupc_command = createCommand("xap/KLN90/Toggle_Popup_Panel", "Toggle KLN's small button panel visibility")
function KLNpopupc_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        if get(KLN90popupVisible) ~= 0 then
            set(KLN90popupVisible, 0)
        else
            set(KLN90popupVisible, 1)
        end
    end
    return 0
end
registerCommandHandler(KLNpopupc_command, 0, KLNpopupc_handler)

local KLNc_command = createCommand("xap/KLN90/Toggle_KLN_90B_Panel", "Toggle 2D KLN90B Panel visibility")
function KLNc_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        if get(KLN90visible) ~= 0 then
            set(KLN90visible, 0)
        else
            set(KLN90visible, 1)
        end
    end
    return 0
end
registerCommandHandler(KLNc_command, 0, KLNc_handler)

local MD41c_command = createCommand("xap/KLN90/Toggle_MD41_Panel", "Toggle 2D MD41 Panel visibility")
function MD41c_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        if get(MD41visible) ~= 0 then
            set(MD41visible, 0)
        else
            set(MD41visible, 1)
        end
    end
    return 0
end
registerCommandHandler(MD41c_command, 0, MD41c_handler)


------------------------------------------------------------------------------------


local coef = get(window_height) / 1024
if coef > 1 then
    coef = 1
end -- set initial coefficient for float panel's size - make 'em smaller, if screen resolution less then 1024 by height.

-- TODO: switch to SASL internal subpanel position save/restore funcs
local popx2 = get(window_width) - 100
local popy2 = get(window_height) - 100

local filename = getAircraftPath() .. "/KLNconfig.txt"
local file = io.open(filename, "r")
if file then
    while true do
        local line = file:read("*line")
        if line == nil then
            break
        end
        if string.find(line, "#popx") then
            popx2 = tonumber(string.sub(line, 6))
        elseif string.find(line, "#popy") then
            popy2 = tonumber(string.sub(line, 6))
        end
    end
    file:close()
end

MD41_panel = contextWindow {
    name = "MD41 panel",
    visible = get(MD41visible) == 1,
    fbo = true,
    fpsLimit = 4,
    resizeMode = SASL_CW_RESIZE_RIGHT_BOTTOM,
    saveState = true,
    customDecore = true,
    position = { get(window_width) - 512, get(window_height) - 330, 512 * coef, 194 * coef },
    noBackground = true,
    callback = function(id, event)
        if event == SASL_CW_EVENT_VISIBILITY then
            if MD41_panel:isVisible() == false then
                -- Check, if window closed, then set actual property value
                set(MD41visible, 0)
            end
        end
    end,
    components = {
        MD41_panel {
            position = { 0, 0, 512 * coef, 194 * coef }
        }
    }
}

KLN90B_panel = contextWindow {
    name = "KLN90B",
    visible = get(KLN90visible) == 1,
    fbo = true,
    fpsLimit = 4,
    resizeMode = SASL_CW_RESIZE_RIGHT_BOTTOM,
    customDecore = true,
    saveState = true,
    --	savePosition = true;
    -- position = { get(window_width) - 914-50, get(window_height) - 293-50, 914 * coef, 293 * coef };
    position = { get(window_width) - 457 - 50, get(window_height) - 147 - 50, 457 * coef, 147 * coef},
    noBackground = true,
    callback = function(id, event)
        if event == SASL_CW_EVENT_VISIBILITY then
            if KLN90B_panel:isVisible() == false then
                -- Check, if window closed, then set actual property value
                set(KLN90visible, 0)
            end
        end
    end,
    components = {
        KLN90B_panel {
            -- position = { 0, 0, 914 * coef, 293 * coef },
            position = { 0, 0, 457 * coef, 147 * coef
            }
        }
    }
}

local closeImage = loadImage("close.png") -- close cross image

KLNpopup_panel = subpanel {
    visible = (get(KLN90popupVisible) == 1 and get(external) == 0),
    noResize = true,
    position = { popx2, popy2, 64 * coef, 64 * coef },
    noBackground = true,
    components = {
        KLNpopup_panel {
            position = { 0, 0, 64 * coef, 64 * coef }
        },
        textureLit {
            position = { (64 - 13) * coef, (64 - 13) * coef, 16 * coef, 16 * coef },
            visible = function()
                return get(external) == 0
            end,
            image = get(closeImage)
        }
    }
}

function update()
    -- show or hide MD41 popup panel
    local mdVisible = kln_utils.int2bool(get(MD41visible))
    if not (mdVisible == MD41_panel:isVisible()) then
        MD41_panel:setIsVisible(mdVisible)
    end
    -- show or hide KLN popup control panel
    -- control panel shown only inside plane
    local ppVisible = kln_utils.int2bool(get(KLN90popupVisible)) and (not kln_utils.int2bool(get(external)))
    if not (ppVisible == KLNpopup_panel.visible) then
        KLNpopup_panel.visible = (ppVisible)
    end
    -- show or hide KLN90B popup panel
    local klnVisible = kln_utils.int2bool(get(KLN90visible))
    if not (klnVisible == KLN90B_panel:isVisible()) then
        KLN90B_panel:setIsVisible(klnVisible)
    end
end
