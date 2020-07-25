---------------- Custom drefs ----------------
local payloadWindowVisible = createGlobalPropertyi("yak40/panels/payload/visible", 1)

---------- Payload Window Commands ------------
local PWpopup_command = createCommand("yak40/Toggle_Payload_Panel", "Toggle Yak40 Payload panel visibility")
function PWpopup_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        if get(payloadWindowVisible) ~= 0 then
            set(payloadWindowVisible, 0)
        else
            set(payloadWindowVisible, 1)
        end
    end
    return 0
end
registerCommandHandler(PWpopup_command, 0, PWpopup_handler)

PayloadPanel = contextWindow {
    name = "Yak40 Payload panel",
    visible = get(payloadWindowVisible),
    fbo = true,
    fpsLimit = 4,
    resizeMode = SASL_CW_RESIZE_RIGHT_BOTTOM,
    saveState = true,
    customDecore = true,
    position = { 0, 0, 710, 990},
    noBackground = true,
    callback = function(id, event)
        if event == SASL_CW_EVENT_VISIBILITY then
            if PayloadPanel:isVisible() == false then
                -- Check, if window closed, then set actual property value
                set(payloadWindowVisible, 0)
            end
        end
    end,
    components = {
        payload_panel {
            position = { 0, 0, 710, 990 }
        }
    }    
}

function update()
    -- show or hide Payload popup panel
    local mdVisible = get(payloadWindowVisible) == 1
    if not (mdVisible == PayloadPanel:isVisible()) then
        PayloadPanel:setIsVisible(mdVisible)
    end
end