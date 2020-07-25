-- draws texture independed of cockpit lighting system

-- no default texture
defineProperty("image")
defineProperty("brightness", 1)

function draw(self) 
    local brightnessValue = get(brightness)
    local w, h = getTextureSize(get(image))

    drawTexture(get(image), 0, 0, w, h, {brightnessValue, brightnessValue, brightnessValue}) 
end


