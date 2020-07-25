
-- default angle
defineProperty("angle", 0)

-- no image
defineProperty("image")

defineProperty("brightness", 1)

function draw(self)
    local brightnessValue = get(brightness)
    local w, h = getTextureSize(get(image))
    
    local max = w
    if h > max then
        max = h
    end

--    local rw = (w / max) * 100
--    local rh = (h / max) * 100
    local rw = (w / max) * 100
    local rh = (h / max) * 100
--    drawRotatedTexture(get(image), get(angle), (w - rw) / 2, (h - rh) / 2, rw, rh)
    drawRotatedTextureCenter(get(image), get(angle), w/2, h/2, 0, 0, w, h, {brightnessValue, brightnessValue, brightnessValue}) 
end
