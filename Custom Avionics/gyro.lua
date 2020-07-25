-- this is the simple logic of relative gyroscope, used for compases

-- define property table
-- source
defineProperty("turn", globalPropertyf("sim/flightmodel/misc/turnrate_roll")) -- turn rate deg/sec. must be used with some coef.
defineProperty("lat", globalPropertyf("sim/flightmodel/position/latitude")) -- real latitude position
defineProperty("frame_time", globalPropertyf("sim/custom/xap/time/frame_time")) -- time for frames
defineProperty("flight_time", globalPropertyf("sim/time/total_running_time_sec")) -- sim time
defineProperty("true_psi", globalPropertyf("sim/flightmodel/position/true_psi")) -- real course
defineProperty("latitude", globalPropertyf("sim/flightmodel/position/latitude")) -- real latitude position
defineProperty("longitude", globalPropertyd("sim/flightmodel/position/longitude")) -- The longitude of the aircraft
defineProperty("roll", globalPropertyf("sim/flightmodel/position/phi")) --
defineProperty("pitch", globalPropertyf("sim/flightmodel/position/true_theta")) --

-- power
defineProperty("DC_27_volt", globalPropertyf("sim/custom/xap/power/DC_27_volt")) -- 27 volt
defineProperty("AC_36_volt", globalPropertyf("sim/custom/xap/power/AC_36_volt")) -- 36 volt
defineProperty("AC_115_volt", globalPropertyf("sim/custom/xap/power/AC_115_volt")) -- 115 volt
defineProperty("AZS", globalPropertyi("sim/custom/xap/azs/AZS_GMK_sw")) -- AZS switcher
defineProperty("gyro_cc", globalPropertyf("sim/custom/xap/gauges/GMK_cc"))  -- current consumtion


-- fail
defineProperty("fail", globalPropertyf("sim/operation/failures/rel_ss_dgy"))

-- result
defineProperty("gyro_curse", globalPropertyf("sim/custom/xap/gauges/gyro_curse"))

local curse = 0 --math.random(-180, 180)  -- start value of curse

local passed = 0

local counter = 0
local cur_last = get(true_psi)
local rotation = 0
local lat_last = get(latitude)
local lon_last = get(longitude)

local geo_corr = 0

-- We need to compute the longitudinal difference,
-- preserving the sign depending on whether we move east or west, which gets painful
-- near the international date line
local function sign_preserving_lon_diff(lon_current, lon_previous)
  --    dlon(170.0, 171.0)) -- moving east -1
  --    dlon(171.0, 170.0)) -- moving west 1
  --    dlon(-171.0, -170.0)) -- moving east -1
  --    dlon(-170.0, -171.0)) -- moving west 1
  --    dlon(-0.5, 0.5)) -- moving east -1
  --    dlon(0.5, -0.5)) -- moving west 1
  --    dlon(179.5, -179.5)) -- moving east -1
  --    dlon(-179.5, 179.5)) -- moving west 1
  -- Effectively it is a problem of finding the smallest angle, but preserving the sign.
  -- http://stackoverflow.com/a/7869457
  local dlon = (lon_current - lon_previous)
  if dlon > 180 then
    dlon = dlon - 360
  end
  if dlon < -180 then
    dlon = dlon + 360
  end
  return dlon
end



-- postframe calculations
function update()
	-- time calculations
	passed = get(frame_time)
-- pre bug check
if passed > 0 then
	-- calculate power
	if get(DC_27_volt) > 21 and get(AC_36_volt) > 30 and get(AZS) > 0 and get(fail) < 6 then
			local curs = get(true_psi)
		
		
		
		local delta_cur = curs - cur_last
		cur_last = curs
		if delta_cur > 180 then delta_cur = delta_cur - 360
		elseif delta_cur < -180 then delta_cur = delta_cur + 360 end
		
		local pitch_now = get(pitch)
		if math.abs(pitch_now) > 80 then delta_cur = 0 end
		
		--print(delta_cur)
		
		if counter > 10 then
			local lat_now = get(latitude)
			local lon_now = get(longitude)
			
			geo_corr = sign_preserving_lon_diff(lon_now, lon_last) * math.sin(math.rad((lat_last + lat_now)/2))
			-- print(lon_now, lon_last, geo_corr)
			lat_last = lat_now
			lon_last = lon_now
			
			if geo_corr == geo_corr then
				curse = curse - geo_corr -- test for NaN and/or Inf?
			end
			
			counter = 0
		end
		counter = counter + passed
	
	
		-- earth rotation
		local earth_rot = 360 * math.sin(math.rad(get(latitude))) * passed / 86164 -- one astronomic day eq 86164 seconds
		-- calculate new curse
		curse = curse + delta_cur - earth_rot
		-- limit curse
		if curse > 180 then curse = curse - 360
		elseif curse < -180 then curse = curse + 360 end
	
	--print("gyro", earth_rot, curse)
		-- set result
		set(gyro_curse, curse)

		
		
		
		
		
		
		
		
	else
		--set(gyro_cc, 0)
	end
	


end

end



