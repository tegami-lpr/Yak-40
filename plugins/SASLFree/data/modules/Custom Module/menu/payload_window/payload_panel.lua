size = {710, 990}

--defineProperty("payload_subpanel", globalPropertyi("sim/custom/xap/panels/payload"))

-- sim load
defineProperty("payload", globalPropertyf("sim/flightmodel/weight/m_fixed"))  -- payload weight, kg
defineProperty("CG_load", globalPropertyf("sim/flightmodel/misc/cgz_ref_to_default")) -- Center of Gravity reference to default, m
defineProperty("fuel_q_1", globalPropertyfae("sim/flightmodel/weight/m_fuel", 1)) -- fuel quantity for tank 1
defineProperty("fuel_q_2", globalPropertyfae("sim/flightmodel/weight/m_fuel", 2)) -- fuel quantity for tank 2

----------------------- Variables ----------------------------

local flight_distance = 900 -- расстояние до АП,km
local reserv_distance = 200 -- расстояние до зап. АП,km

local mpax_mass = 80 -- вес одного человека


local empty_plane_weight = 10025 -- вес пустого самолета, kg
local MTOW = 17200 -- Maximum Takeoff Weigth (максимальный взлетный вес), kg

local prepared_plane_weight = empty_plane_weight + 185 -- вес снаряженного самолета без загрузки и экипажа

local crew_count = 2 --количество членов экипажа (+стюардесса)
local crew_weight = crew_count * mpax_mass -- вес экипажа, kg

-- количество заполненных мест в рядах
local row_1_pax_count = 0
local row_2_pax_count = 0
local row_3_pax_count = 0
local row_4_pax_count = 0
local row_5_pax_count = 0
local row_6_pax_count = 0
local row_7_pax_count = 0
local row_8_pax_count = 0
local row_9_pax_count = 0
local row_10_pax_count = 0

-- вес пассажиров по рядам
local row_1_pax_mass = 0
local row_2_pax_mass = 0
local row_3_pax_mass = 0
local row_4_pax_mass = 0
local row_5_pax_mass = 0
local row_6_pax_mass = 0
local row_7_pax_mass = 0
local row_8_pax_mass = 0
local row_9_pax_mass = 0
local row_10_pax_mass = 0

local all_pax_mass = 0 -- общий вес пассажиров

local cargo_weight = 0 -- коммерческая загрузка
local ctr_cargo_weight = 0 -- центровочный вес

local extra_fuel = 1100 -- вес запаса топлива, kg
local fuel_nonused = 64 -- неиспользуемый остаток топлива, kg

local used_fuel = 1100
local fuel_weight = extra_fuel + used_fuel + fuel_nonused -- вес загруженного топлива, kg
    
local ZFW = crew_weight + prepared_plane_weight + all_pax_mass -- Zero-Fuel Weight (вес полностью загруженного самолета без учета топлива)

local loaded_plane_weight = prepared_plane_weight + crew_weight + fuel_weight -- эксплуатационный вес 

local TOW = fuel_weight + ZFW --  TakeOff Weight (взлетный вес)

local max_allowable_payload = MTOW - TOW -- допустимая коммерческая загрузка
local landing_weight = TOW - used_fuel


local to_CG = 15 -- смещение центровки самолета на взлете 
local lan_CG = 15 -- смещение центровки самолета на посадке
local empty_fuel_CG = 15 -- смещение центровки самолета без топлива

-- %САХ
local to_SAH = 0 -- центровка %САХ при взлете
local lan_SAH = 0 -- при посадке
local empty_fuel_SAH = 0 -- без топлива


-- Переменные для отрисовки линий

-- подсветка поля с неправильными ошибками
local to_weight_flag = false 
local fuel_flag = false
local to_cg_flag = false
local lan_cg_flag = false
local empty_cg_flag = false

---- Позиции линий на листе загрузки
--- 326 -- initial position in pixels
local pos1 = 326 -- Строка веса экипажа
local pos2 = pos1 -- Первый пассажирский ряд
local pos3 = pos2 
local pos4 = pos3
local pos5 = pos4
local pos6 = pos5
local pos7 = pos6
local pos8 = pos7
local pos9 = pos8
local pos10 = pos9
local pos11 = pos10
local empty_fuel_pos = pos10
local empty_fuel_cargo2 = pos11
local show_all_pax = false
local fuel_show_row = 1

local pos10_show = pos10
local pos11_show = pos11

local takeoff_weight_plank = 245
local landing_weight_plank = 245

----------------------- Resources ----------------------------

local buttonCursor = {
    -- finger cursor
    x = -8,
    y = -16,
    width = 20,
    height = 20,
    shape = loadImage("cursors.png", 280, 461, 20, 20),
    hideOSCursor = true
}

local leftCursor = {
    x = -16, 
    y = -32,  
    width = 16, 
    height = 16, 
    shape = loadImage("rotateleft.png")
}

local rightCursor = {
    x = 16,
    y = -32,
    width = 16,
    height = 16,
    shape = loadImage("rotateright.png")
}

local clGreen = {0.008, 0.545, 0.035}
local clRed   = {0.4,   0.165, 0.004}

-- images
defineProperty("background", loadImage("payload_panel.png", 5, 31, 710, 990))
defineProperty("red_flag", loadImage("payload_panel.png", 734, 977, 70, 25))

-- digits images
-- загружаются все символы, кроме последнего
defineProperty("digitsImage", loadImage("black_digit_strip.png", 1, 60, 14, 196))

---------------------- Functions -----------------------------


local function fuel_diff(weight, load)
    local move = 0
    local row = 1
    if load then
        if weight <= 2100 then
            move = 0.0168 * weight
            row = 1
        else
            move = 0.0104 * weight
            row = 3
        end
    else
        if weight <= 500 then
            move = 0.0086 * weight
            row = 2
        else
            move = 0.0168 * weight
            row = 1
        end
    end
    return move, row
end

--------------------------------------------------------------
local function range2fuel(flight_distance)
    -- Формула выведена методом Constrained Linear Regression по табличным данным 
    -- для высоты полета 6000 м без учета ветра. Средняя ошибка +50кг
    if flight_distance < 100 then
        flight_distance = 200
    end
    return 2.082568807 * flight_distance + 392.6605505
end

local function calc_reserve(flight_distance)
    if flight_distance == 0 then
        return 0
    end
    -- Формула выведена методом Polynomial Regression по табличным данным рассчета АНЗ
    -- для высоты полета 6000, массой на ВПР равной 13000 и ожиданием в зоне резервного АП - 30 минут без учета ветра.
    local anz = -3.333333333 * 10 ^ -5 * reserv_distance ^ 3 + 0.04 * reserv_distance ^ 2 - 10.66666667 *
                    reserv_distance + 2000
    anz = anz +
              (used_fuel * 0.03) -- по правилам к резерву прибавляеться 3% от расходного топлива
        -- по правилам к резерву прибавляеться 3% от расходного топлива
    return anz
end


--------------------------------------------------------------

local function recalculate_planks()
    -- calculate CG position
    pos1 = 390 - crew_weight * 0.275
    pos2 = pos1 - row_1_pax_mass * 0.2146667
    pos3 = pos2 - row_2_pax_mass * 0.1866667
    pos4 = pos3 - row_3_pax_mass * 0.1573333
    pos5 = pos4 - row_4_pax_mass * 0.1293333
    pos6 = pos5 - row_5_pax_mass * 0.1
    pos7 = pos6 - row_6_pax_mass * 0.072
    pos8 = pos7 - row_7_pax_mass * 0.0433333
    -- pos9 = pos8 + cargo_1 * 0.0355

    -- calculate horisontal planks
    takeoff_weight_plank = 284 + (TOW - 9000) * 0.024
    if takeoff_weight_plank > 476 then
        takeoff_weight_plank = 476
    end

    landing_weight_plank = 284 + (landing_weight - 9000) * 0.024
    if landing_weight_plank > 476 then
        landing_weight_plank = 476
    end

    local fuel_load_pos = 0 -- calculate fuel plank moving and row, where we'll show digits
    fuel_load_pos, fuel_show_row = fuel_diff(fuel_weight, true)
    pos10 = pos9 - fuel_load_pos
    pos11 = pos10 - ctr_cargo_weight * 0.202

    local eat_fuel, foo = fuel_diff(used_fuel, false)
    empty_fuel_pos = pos10 + eat_fuel
    empty_fuel_cargo2 = empty_fuel_pos - ctr_cargo_weight * 0.202

    -- red flags logic
    to_weight_flag = TOW > MTOW
    to_cg_flag = (to_SAH < 13) or (to_SAH > 32)
    lan_cg_flag = (lan_SAH < 13) or (lan_SAH > 32)
    empty_cg_flag = (empty_fuel_SAH < 13) or (empty_fuel_SAH > 32)
end

--------------------------------------------------------------

local function recalculate_cg()

    used_fuel = range2fuel(flight_distance)
    fuel_weight = used_fuel + fuel_nonused + extra_fuel

    if fuel_weight > 4400 then
         fuel_weight = 4400
         fuel_flag = true
    else
         fuel_flag = false
    end

    crew_weight = crew_count * mpax_mass
    row_1_pax_mass =  row_1_pax_count * mpax_mass
    row_2_pax_mass =  row_2_pax_count * mpax_mass
    row_3_pax_mass =  row_3_pax_count * mpax_mass
    row_4_pax_mass =  row_4_pax_count * mpax_mass
    row_5_pax_mass =  row_5_pax_count * mpax_mass
    row_6_pax_mass =  row_6_pax_count * mpax_mass
    row_7_pax_mass =  row_7_pax_count * mpax_mass
    row_8_pax_mass =  row_8_pax_count * mpax_mass
    row_9_pax_mass =  row_9_pax_count * mpax_mass
    row_10_pax_mass = row_10_pax_count * mpax_mass

    all_pax_mass = row_1_pax_mass + row_2_pax_mass + row_3_pax_mass + row_4_pax_mass
            + row_5_pax_mass + row_6_pax_mass + row_7_pax_mass + row_8_pax_mass
            + row_9_pax_mass + row_10_pax_mass

    loaded_plane_weight = prepared_plane_weight + crew_weight + fuel_weight
    ZFW = prepared_plane_weight + crew_weight + all_pax_mass + cargo_weight + ctr_cargo_weight
    TOW = ZFW + fuel_weight
    max_allowable_payload = MTOW - TOW
    landing_weight = TOW - used_fuel

    
    local crew_mX = crew_weight * -7.685
    local row_1_mX =  row_1_pax_mass  * -5.615
    local row_2_mX =  row_2_pax_mass  * -4.865
    local row_3_mX =  row_3_pax_mass  * -4.11
    local row_4_mX =  row_4_pax_mass  * -3.355
    local row_5_mX =  row_5_pax_mass  * -2.6
    local row_6_mX =  row_6_pax_mass  * -1.845
    local row_7_mX =  row_7_pax_mass  * -1.09
    local row_8_mX =  row_8_pax_mass  * -0.335
    local row_9_mX =  row_9_pax_mass  * 0.42
    local row_10_mX = row_10_pax_mass * 1.175
    local cargo_mX =  cargo_weight * 1.05
    local ctr_cargo_mX = ctr_cargo_weight * -5.615
    -- dry_mX - mX неизменяемого веса
    -- 102 - mX снаряженного самолета
    local dry_mX = 178 + 102 + crew_mX 
                    + row_1_mX + row_2_mX + row_3_mX + row_4_mX + row_5_mX 
                    + row_6_mX + row_7_mX + row_8_mX + row_9_mX + row_10_mX
                    + cargo_mX + ctr_cargo_mX
    local fuel_mX = fuel_weight * -0.25
    local full_mX = dry_mX + fuel_mX

    to_CG = full_mX / TOW * 100

    empty_fuel_CG = dry_mX / (TOW - used_fuel) * 100

    local land_mX = dry_mX +  ((fuel_weight - used_fuel)*-0.25)
    lan_CG = land_mX / (TOW - used_fuel) * 100

    to_SAH = (full_mX/TOW + 1.04) / 0.0297
    lan_SAH = (land_mX / (TOW - used_fuel) + 1.04) / 0.0297
    empty_fuel_SAH = (dry_mX / (TOW - used_fuel) + 1.04) / 0.0297


    recalculate_planks()

    --print("full_mX = " .. tostring(full_mX))
    --print("fuel saved: "..tostring(fuel_weight - used_fuel))
end

--Рассчитываем значения при загрузке файла
recalculate_cg()

-----------------------------------------------------------------				  

local function decreaseValue(value, step)
    local tmpValue
    if step then
        tmpValue = value - step
    else
        tmpValue = value - 1
    end    

    if tmpValue < 0 then 
        tmpValue = 0
    end
    return tmpValue
end

local function increaseValue(value, maxValue, step)
    local tmpValue
    if step then
        tmpValue = value + step
    else
        tmpValue = value + 1
    end

    if tmpValue > maxValue then 
        tmpValue = maxValue
    end
    return tmpValue
end

-- components of panel
components = {


	-- background
	textureLit {
		image = background,
		position = {0, 0, size[1], size[2]},

	},

	-----------------
	-- red flags --
	----------------
	-- acf weight flag
	textureLit {
		image = red_flag,
		position = {228, 68, 78, 15},
		visible = function()
            return to_weight_flag
		end
	},

	-- fuel weight flag
	textureLit {
		image = red_flag,
		position = {600, 810, 80, 20},
		visible = function()
			return fuel_flag
		end
	},

	-- TO CG flag
	textureLit {
		image = red_flag,
		position = {585, 63, 65, 24},
		visible = function()
			return to_cg_flag
		end
	},

	-- Lan CG flag
	textureLit {
		image = red_flag,
		position = {585, 38, 65, 23},
		visible = function()
			return lan_cg_flag
		end
	},

	-- Empty fuel CG flag
	textureLit {
		image = red_flag,
		position = {585, 89, 65, 24},
		visible = function()
			return empty_cg_flag
		end
	},

	-------------------------
	-- begining digits --
	-------------------------
	
    -- empty plane weight
   digitstape {
        position = { 340, 904, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return prepared_plane_weight
        end;
    }; 

	-- вес экипажа
   digitstape {
        position = { 340, 888, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return 2 * mpax_mass
        end;
    }; 

	-- вес стюардессы
   digitstape {
        position = { 340, 873, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            if crew_count == 3 then
                return mpax_mass
            else
                return 0
            end
        end;
    }; 

	-- вес заправленного топлива
   digitstape {
        position = { 340, 857, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return fuel_weight
        end;
    }; 

	-- maximum TOW
   digitstape {
        position = { 340, 841, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return MTOW
        end;
    }; 

	-- prepared plane weight
   digitstape {
        position = { 340, 826, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return loaded_plane_weight
        end;
    }; 

	-- max payload weight
   digitstape {
        position = { 340, 810, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return max_allowable_payload
        end;
    }; 

	--------------------
	-- distance to destination AP
   digitstape {
        position = { 600, 900, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return flight_distance
        end;
    };

	-- distance to reserve AP
   digitstape {
        position = { 600, 878, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return reserv_distance
        end;
    };	
	
	-- extra fuel
   digitstape {
        position = { 600, 857, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return extra_fuel
        end;
    };	

	-- fuel nonused
   digitstape {
        position = { 600, 835, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            --return fuel_nonused
            return fuel_weight - used_fuel
        end;
    };	

	-- fuel loaded
   digitstape {
        position = { 600, 813, 72, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return fuel_weight
        end;
    };	

	-----------------------
	-- mass digits --
	-----------------------
	
	-- crew weight
   digitstape {
        position = { 620, 737, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return crew_weight
        end;
    }; 	

	-- all pax weight
   digitstape {
        position = { 620, 723, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return all_pax_mass
        end;
		visible = function()
			return show_all_pax
		end
    }; 

	-- row_1_mass weight
   digitstape {
        position = { 620, 709, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return row_1_pax_mass
        end;
		visible = function()
			return not show_all_pax
		end
    }; 

	-- row_2_mass weight
   digitstape {
        position = { 620, 695, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return row_2_pax_mass
        end;
		visible = function()
			return not show_all_pax
		end
    }; 

	-- row_3_mass weight
   digitstape {
        position = { 620, 681, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return row_3_pax_mass
        end;
		visible = function()
			return not show_all_pax
		end
    };

	-- row_4_mass weight
   digitstape {
        position = { 620, 667, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return row_4_pax_mass
        end;
		visible = function()
			return not show_all_pax
		end
    };

	-- row_5_mass weight
   digitstape {
        position = { 620, 653, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return row_5_pax_mass
        end;
		visible = function()
			return not show_all_pax
		end
    };

	-- row_6_mass weight
   digitstape {
        position = { 620, 640, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return row_6_pax_mass
        end;
		visible = function()
			return not show_all_pax
		end
    };

	-- row_7_mass weight
   digitstape {
        position = { 620, 626, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return row_7_pax_mass
        end;
		visible = function()
			return not show_all_pax
		end
    };

	-- ряды 8 и 9
   digitstape {
        position = { 620, 612, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return row_8_pax_mass + row_9_pax_mass
        end;
		visible = function()
			return not show_all_pax
		end
    };	
	
	-- багажная загрузка, правая строка
   digitstape {
        position = { 620, 584, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return cargo_weight
        end;
    };	
	
	-- fuel 1 weight
   digitstape {
        position = { 620, 570, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return fuel_weight
        end;
		visible = function()
			return fuel_show_row == 1
		end
    };		
	
	-- fuel 2 weight
   digitstape {
        position = { 620, 543, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return fuel_weight
        end;
		visible = function()
			return fuel_show_row == 3
		end
    };	
	
	-- центровочный груз, правая строка
   digitstape {
        position = { 620, 529, 60, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return ctr_cargo_weight
        end;
    };	
	
	-----------------------
	-- rows digits --
	-----------------------
	
	-- crew weight
   digitstape {
        position = { 107, 737, 15, 15};
        image = digitsImage;
        digits = 1;
        allowNonRound = true;
        value = function() 
            return crew_count
        end;
    }; 	

	-- all pax count
   digitstape {
        position = { 103, 723, 27, 15};
        image = digitsImage;
        digits = 2;
        allowNonRound = true;
        value = function() 
            return all_pax_mass / mpax_mass
        end;
    }; 

	-- row_1_mass count
   digitstape {
        position = { 107, 709, 15, 15};
        image = digitsImage;
        digits = 1;
        allowNonRound = true;
        value = function() 
            return row_1_pax_mass / mpax_mass
        end;
    }; 

	-- row_2_mass count
   digitstape {
        position = { 107, 695, 15, 15};
        image = digitsImage;
        digits = 1;
        allowNonRound = true;
        value = function() 
            return row_2_pax_mass / mpax_mass
        end;
    }; 

	-- row_3_mass count
   digitstape {
        position = {107, 681, 15, 15};
        image = digitsImage;
        digits = 1;
        allowNonRound = true;
        value = function() 
            return row_3_pax_mass / mpax_mass
        end;
    };

	-- row_4_mass count
   digitstape {
        position = { 107, 667, 15, 15};
        image = digitsImage;
        digits = 1;
        allowNonRound = true;
        value = function() 
            return row_4_pax_mass / mpax_mass
        end;
    };

	-- row_5_mass count
   digitstape {
        position = { 107, 653, 15, 15};
        image = digitsImage;
        digits = 1;
        allowNonRound = true;
        value = function() 
            return row_5_pax_mass / mpax_mass
        end;
    };

	-- row_6_mass count
   digitstape {
        position = { 107, 640, 15, 15};
        image = digitsImage;
        digits = 1;
        allowNonRound = true;
        value = function() 
            return row_6_pax_mass / mpax_mass
        end;
    };

	-- row_7_mass count
   digitstape {
        position = { 107, 626, 15, 15};
        image = digitsImage;
        digits = 1;
        allowNonRound = true;
        value = function() 
            return row_7_pax_mass / mpax_mass
        end;
    };

	-- ряды 8 и 9
   digitstape {
        position = { 107, 612, 15, 15};
        image = digitsImage;
        digits = 1;
        allowNonRound = true;
        value = function() 
            return (row_8_pax_mass + row_9_pax_mass) / mpax_mass
        end;
    };	
	
	-- багажный вес, левая графа
   digitstape {
        position = { 100, 584, 35, 15};
        image = digitsImage;
        digits = 3;
        allowNonRound = true;
        value = function() 
            return cargo_weight
        end;
    };	
	
	-- центровочный вес, левая графа
   digitstape {
        position = { 100, 529, 35, 15};
        image = digitsImage;
        digits = 3;
        allowNonRound = true;
        value = function() 
            return ctr_cargo_weight
        end;
    };	

	-------------------------
	-- result digits --
	-------------------------
	
	-- эксплуатационный вес
   digitstape {
        position = { 228, 99, 78, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return loaded_plane_weight
        end;
    };

	-- вес полезной загрузки
   digitstape {
        position = { 228, 84, 78, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return cargo_weight + all_pax_mass
        end;
    };

	-- взлетный вес (TOW)
   digitstape {
        position = { 228, 68, 78, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return TOW
        end;
    };

	-- вес заправленного топлива
   digitstape {
        position = { 228, 53, 78, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return used_fuel
        end;
    };	

	-- landing weight
   digitstape {
        position = { 228, 38, 78, 15};
        image = digitsImage;
        digits = 5;
        allowNonRound = true;
        value = function() 
            return landing_weight
        end;
    };

	----------------------
	-- result CG digits --
	----------------------
	
	-- takeoff CG
   digitstape {
        position = { 590, 63, 55, 25};
        image = digitsImage;
        digits = 3;
		fractional = 1;
        allowNonRound = true;
        value = function() 
            --return to_CG
            return to_SAH
        end;
    };	

	-- landing CG
   digitstape {
        position = { 590, 38, 55, 25};
        image = digitsImage;
        digits = 3;
		fractional = 1;
        allowNonRound = true;
        value = function() 
            --return lan_CG
            return lan_SAH
        end;
    };	
	
	-- empty fuel CG
   digitstape {
        position = { 590, 89, 55, 25};
        image = digitsImage;
        digits = 3;
		fractional = 1;
        allowNonRound = true;
        value = function() 
            --return empty_fuel_CG
            return empty_fuel_SAH
        end;
    };	

	-----------------
	-- interactives --
	-----------------
	
   -- interactive area for decrement crew_weight
    interactive {
       position = { 95, 738, 20, 14 },
        
       cursor = leftCursor,  
        
        onMouseDown = function()
            crew_count = decreaseValue(crew_count)
			recalculate_cg()
			return true
        end
    },

   -- interactive area for increment crew_weight
    interactive {
       position = { 117, 738, 20, 14 },
        
       cursor = rightCursor,  
        
        onMouseDown = function()
            crew_count = increaseValue(crew_count, 3)
			recalculate_cg()
			return true
        end
    },
	-------------------------
   -- interactive area for decrement all pax mass
    interactive {
       position = { 95, 723, 20, 14 },
        
       cursor = leftCursor,  
        
        onMouseDown = function()
			row_1_pax_count = 0
			row_2_pax_count = 0
			row_3_pax_count = 0
			row_4_pax_count = 0
			row_5_pax_count = 0
			row_6_pax_count = 0
			row_7_pax_count = 0
            row_8_pax_count = 0
            row_9_pax_count = 0
            row_10_pax_count = 0
			show_all_pax = false
			recalculate_cg()
			return true
        end
    },

   -- interactive area for increment all pax mass
    interactive {
       position = { 117, 723, 20, 14 },
        
       cursor = rightCursor,  
        
        onMouseDown = function()
            row_1_pax_count = 4
            row_2_pax_count = 4
            row_3_pax_count = 4
            row_4_pax_count = 4
            row_5_pax_count = 4
            row_6_pax_count = 4
            row_7_pax_count = 4
            row_8_pax_count = 4
            row_9_pax_count = 2
            row_10_pax_count = 2
			show_all_pax = true
			recalculate_cg()
			return true
        end
    },
	-------------------------
    -- interactive area for decrement row_1_mass
    interactive {
       position = { 95, 709, 20, 14 },
       cursor = leftCursor,  
        onMouseDown = function()
            row_1_pax_count = decreaseValue(row_1_pax_count)
			show_all_pax = false
			recalculate_cg()
        return true
        end
    },	
	
   -- interactive area for increment row_1_mass
    interactive {
       position = { 117, 709, 20, 14 },
        
       cursor = rightCursor,  
        
        onMouseDown = function()
            row_1_pax_count = increaseValue(row_1_pax_count, 4)
			show_all_pax = false
			recalculate_cg()
        return true
        end
    },	
	----------------------
   -- interactive area for decrement row_2_mass
    interactive {
       position = { 95, 695, 20, 14 },
       cursor = leftCursor,  
        onMouseDown = function()
			row_2_pax_count = decreaseValue(row_2_pax_count)
			show_all_pax = false
			recalculate_cg()
        return true
        end
    },	
	
   -- interactive area for increment row_2_mass
    interactive {
       position = { 117, 695, 20, 14 },
       cursor = rightCursor,  
        onMouseDown = function()
            row_2_pax_count = increaseValue(row_2_pax_count, 4)
			show_all_pax = false
			recalculate_cg()
        return true
        end
    },	
	----------------------
   -- interactive area for decrement row_3_mass
    interactive {
       position = { 95, 681, 20, 14 },
       cursor = leftCursor,  
        onMouseDown = function()
			row_3_pax_count = decreaseValue(row_3_pax_count)
			show_all_pax = false
			recalculate_cg()
        return true
        end
    },	
	
   -- interactive area for increment row_3_mass
    interactive {
       position = { 117, 681, 20, 14 },
       cursor = rightCursor,  
       onMouseDown = function()
			row_3_pax_count = increaseValue(row_3_pax_count, 4)
			show_all_pax = false
			recalculate_cg()
        return true
       end
    },	
	----------------------
   -- interactive area for decrement row_4_mass
    interactive {
       position = { 95, 667, 20, 14 },
       cursor = leftCursor,  
       onMouseDown = function()
			row_4_pax_count = decreaseValue(row_4_pax_count)
			show_all_pax = false
			recalculate_cg()
        return true
       end
    },	
	
   -- interactive area for increment row_4_mass
    interactive {
       position = { 117, 667, 20, 14 },
       cursor = rightCursor,  
       onMouseDown = function()
			row_4_pax_count = increaseValue(row_4_pax_count, 4)
			show_all_pax = false
			recalculate_cg()
        return true
       end
    },	
	----------------------
   -- interactive area for decrement row_5_mass
    interactive {
       position = { 95, 653, 20, 14 },
       cursor = leftCursor,  
       onMouseDown = function()
			row_5_pax_count = decreaseValue(row_5_pax_count)
			show_all_pax = false
			recalculate_cg()
        return true
       end
    },	
	
   -- interactive area for increment row_5_mass
    interactive {
       position = { 117, 653, 20, 14 },
       cursor = rightCursor,  
        onMouseDown = function()
			row_5_pax_count = increaseValue(row_5_pax_count, 4)
			show_all_pax = false
			recalculate_cg()
        return true
        end
    },	
	----------------------
   -- interactive area for decrement row_6_mass
    interactive {
       position = { 95, 640, 20, 14 },
       cursor = leftCursor,  
       onMouseDown = function()
			row_6_pax_count = decreaseValue(row_6_pax_count)
			show_all_pax = false
			recalculate_cg()
        return true
       end
    },	
	
   -- interactive area for increment row_6_mass
    interactive {
       position = { 117, 640, 20, 14 },
       cursor = rightCursor,  
       onMouseDown = function()
			row_6_pax_count = increaseValue(row_6_pax_count, 4)
			show_all_pax = false
			recalculate_cg()
        return true
       end
    },	
	----------------------
   -- interactive area for decrement row_7_mass
    interactive {
        position = { 95, 626, 20, 14 },
        cursor = leftCursor,  
        onMouseDown = function()
			row_7_pax_count = decreaseValue(row_7_pax_count)
			show_all_pax = false
			recalculate_cg()
            return true
        end
    },	
	
   -- interactive area for increment row_7_mass
    interactive {
        position = { 117, 626, 20, 14 },
        cursor = rightCursor,  
        onMouseDown = function()
			row_7_pax_count = increaseValue(row_7_pax_count, 4)
			show_all_pax = false
			recalculate_cg()
            return true
       end
    },	
	----------------------
   -- interactive area for decrement row_8_mass
    interactive {
        position = { 95, 612, 20, 14 },
        cursor = leftCursor,  
        onMouseDown = function()
            if row_9_pax_count == 0 then
                row_8_pax_count = decreaseValue(row_8_pax_count)
            else
                row_9_pax_count = row_9_pax_count - 1
            end
			show_all_pax = false
			recalculate_cg()
            return true
        end
    },	
	
   -- interactive area for increment row_8_mass
    interactive {
        position = { 117, 612, 20, 14 },
        cursor = rightCursor,  
        onMouseDown = function()
            if row_8_pax_count < 4 then
                row_8_pax_count = row_8_pax_count + 1
            else
                row_9_pax_count = increaseValue(row_9_pax_count, 2)
            end

			show_all_pax = false
			recalculate_cg()
            return true
        end
    },	
	----------------------
   -- interactive area for decrement cargo_weight
    interactive {
        position = { 95, 584, 20, 14 },
        cursor = leftCursor,  
        onMouseDown = function()
			cargo_weight = decreaseValue(cargo_weight, 20)
			recalculate_cg()
            return true
        end
    },	
	
   -- interactive area for increment cargo_weight
    interactive {
        position = { 117, 584, 20, 14 },
        cursor = rightCursor,  
        onMouseDown = function()
			cargo_weight = increaseValue(cargo_weight, 720, 20)
			recalculate_cg()
            return true
        end
    },	
	----------------------
   -- interactive area for decrement cargo_2
    interactive {
        position = { 95, 529, 20, 14 },
        cursor = leftCursor,  
        onMouseDown = function()
			ctr_cargo_weight = decreaseValue(ctr_cargo_weight, 20)
			recalculate_cg()
            return true
        end
    },	
	
   -- interactive area for increment cargo_2
    interactive {
        position = { 117, 529, 20, 14 },
        cursor = rightCursor,  
        onMouseDown = function()
			--if pos11 > 1 then cargo_2 = cargo_2 + 25 end
            --if cargo_2 > 900 then cargo_2 = 900 end
            ctr_cargo_weight = increaseValue(ctr_cargo_weight, 900, 20)
			recalculate_cg()
            return true
        end
    },	
	----------------------

	--------------------------
	-- fuel calculator --
	--------------------------

	
   -- interactive area for decrement destination distance
    interactive {
        position = { 600, 898, 30, 20},
        cursor = leftCursor,  
        onMouseDown = function()
			flight_distance = decreaseValue(flight_distance, 50)
			recalculate_cg()
            return true
        end
    },	
	
   -- interactive area for increment destination distance
    interactive {
        position = { 650, 898, 30, 20 },
        cursor = rightCursor,  
        onMouseDown = function()
            flight_distance = increaseValue(flight_distance, 1800, 50)
			recalculate_cg()
            return true
        end
    },	
	----------------------	
   -- interactive area for decrement reserve distance
    interactive {
        position = { 600, 877, 30, 20},
        cursor = leftCursor,  
        onMouseDown = function()
            reserv_distance = decreaseValue(reserv_distance, 50)
            extra_fuel = calc_reserve(reserv_distance)
			recalculate_cg()
            return true
        end
    },	
	
   -- interactive area for increment reserve distance
    interactive {
        position = { 650, 877, 30, 20 },
        cursor = rightCursor,  
        onMouseDown = function()
            reserv_distance = increaseValue(reserv_distance, 2500, 50)
            extra_fuel = calc_reserve(reserv_distance)
			recalculate_cg()
            return true
        end
    },	
	----------------------		
   -- interactive area for decrement fuel stock
    interactive {
        position = { 600, 855, 30, 20},
        cursor = leftCursor,  
        onMouseDown = function()
            extra_fuel = decreaseValue(extra_fuel, 50)
			recalculate_cg()
            return true
        end
    },	
	
   -- interactive area for increment fuel stock
    interactive {
       position = { 650, 855, 30, 20 },
       cursor = rightCursor,  
        onMouseDown = function()
			extra_fuel = increaseValue(extra_fuel, 2500, 50)
			recalculate_cg()
            return true
        end
    },	
	----------------------	
	
   -- interactive area for store results into sim
    interactive {
       position = { 460, 125, 200, 50 },
       cursor = buttonCursor,  
        onMouseDown = function()
            print("set load")

            set(fuel_q_1, fuel_weight / 2)
            set(fuel_q_2, fuel_weight / 2)
            local acf_CG_meters = to_CG / 100
            set(CG_load, acf_CG_meters)
            set(payload, ZFW - prepared_plane_weight)


            return true
        end,
    },	
}

function drawColorLine(x1, y1, xo, yo, thickness, color)
    drawWideLine(x1, y1, x1+xo, y1+yo, thickness, color)
end

function draw()
    drawAll(components)

    ------------------------
    ---- diagramm planks ---
    ------------------------
    -- crew_weight plank
    drawColorLine(180 + pos1, 730, 0, 22, 3, clGreen)
    if not show_all_pax then
        -- row_1_mass plank
        drawColorLine(180 + pos2, 705, 0, 26, 3, clGreen)
        -- row_2_mass plank
        drawColorLine(180 + pos3, 690, 0, 16, 3, clGreen)
        -- row_3_mass plank
        drawColorLine(180 + pos4, 676, 0, 14, 3, clGreen)
        -- row_4_mass plank
        drawColorLine(180 + pos5, 662, 0, 14, 3, clGreen)
        -- row_5_mass plank
        drawColorLine(180 + pos6, 648, 0, 14, 3, clGreen)
        -- row_6_mass plank
        drawColorLine(180 + pos7, 634, 0, 14, 3, clGreen)
        -- row_7_mass plank
        drawColorLine(180 + pos8, 594, 0, 40, 3, clGreen)

        --TODO: 8, 9, and 10 row
    end

    -- cargo_1 plank
    drawColorLine(180 + pos9, 580, 0, 14, 3, clGreen)
    -- empty_fuel_pos plank
    drawColorLine(180 + empty_fuel_pos, 539, 0, 41, 3, clRed)
    -- empty_fuel_cargo2 plank
    drawColorLine(180 + empty_fuel_cargo2, 283, 0, 257, 3, clRed)
    -- fuel_load_pos plank
    drawColorLine(180 + pos10_show, 539, 0, 41, 3, clGreen)
    -- cargo_2 plank
    drawColorLine(180 + pos11_show, 283, 0, 257, 3, clGreen)

    -------------------
    -- weight planks --
    -------------------
    -- aircraft weight at landing
    drawColorLine(150, landing_weight_plank, 470, 0, 3, clRed)
    -- aircraft weight
    drawColorLine(150, takeoff_weight_plank, 470, 0, 3, clGreen)
end

