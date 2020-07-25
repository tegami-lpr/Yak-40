
---------- GPS Panel Commands ------------
local GPSpopup_command = createCommand("yak40/Toggle_GPS_Panel", "Toggle Yak40 GPS popup panel visibility")
function PWpopup_handler(phase) -- for all commands phase equals: 0 on press; 1 while holding; 2 on release
    if 0 == phase then
        local navoption = globalPropertyf("PNV/navoption") -- Что выбрано в качестве GPS (0-KLN90B, 1-GNS430)
        if get(navoption) == 0 or get(navoption) == nil then
            commandOnce(findCommand("xap/KLN90/Toggle_KLN_90B_Panel"))
        else
            commandOnce(findCommand("sim/FMS/CDU_popup"))
        end
    end
    return 0
end
registerCommandHandler(GPSpopup_command, 0, PWpopup_handler)

