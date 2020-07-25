-- draws texture independed of cockpit lighting system

-- no default texture
defineProperty("image")
defineProperty("brightness", 1)
defineProperty("offset", {0, 0})
defineProperty("tx_size", {-1, -1})

function draw(self) 
    local brightnessValue = get(brightness)
    local w, h = getTextureSize(get(image))
    local tx_size = get(tx_size)
    if (not (get(tx_size)[1] == -1)) and (not (get(tx_size)[2] == -1)) then
        w = get(tx_size)[1]
        h = get(tx_size)[2]

        --print("w:h = "..tostring(w) .. ":" .. tostring(h))
    end
    
    local offsetP = get(offset)
    local x = get(offsetP[1])
    local y = get(offsetP[2])
    
--    print("y:x = " .. tostring(y) .. ":" .. tostring(x))

    drawTexture(get(image), x, y, w, h, {brightnessValue, brightnessValue, brightnessValue, 1}) 
end


