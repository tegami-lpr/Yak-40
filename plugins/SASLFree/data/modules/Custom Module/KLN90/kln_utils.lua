kln_utils = {}

function kln_utils.int2bool(value)
 if value == nil then 
   return false
 end
 if (value==0) then 
   return false
 else
   return true	
 end
end

function kln_utils.round(num, idp)
    -- workaround for the SASL bug
    local mult = string.format("%f", 10 ^ (idp or 0))
    -- local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end
