
defineProperty("color", { 0.15, 0.15, 0.15})
defineProperty("alpha")

function draw(self)
    local c = get(color)
    drawRectangle(0, 0, size[1], size[2], {c[1], c[2], c[3], get(alpha)})
end

