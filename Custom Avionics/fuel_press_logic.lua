defineProperty("engrpm0", globalPropertyf("sim/flightmodel/engine/ENGN_N1_[0]"))
defineProperty("engrpm1", globalPropertyf("sim/flightmodel/engine/ENGN_N1_[1]"))
defineProperty("engrpm2", globalPropertyf("sim/flightmodel/engine/ENGN_N1_[2]"))
defineProperty("fuelp0", globalPropertyf("sim/custom/updateyak/fuel/fuel_press_0"))
defineProperty("fuelp1", globalPropertyf("sim/custom/updateyak/fuel/fuel_press_1"))
defineProperty("fuelp2", globalPropertyf("sim/custom/updateyak/fuel/fuel_press_2"))


local fp_table = {{ 0.0,  0.0},
					   { 34.0,   75.0 }, -- min (rpm)
					   { 60.0,  160.0 },
					   { 99.0,  580.0}}   -- max

function update()
local fp0 = interpolate(fp_table, get(engrpm0))
local fp1 = interpolate(fp_table, get(engrpm1))
local fp2 = interpolate(fp_table, get(engrpm2))
set(fuelp0, fp0)
set(fuelp1, fp1)
set(fuelp2, fp2)
end
