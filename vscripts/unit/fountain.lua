function tp(keys)
    local caster = keys.caster
	local ability = keys.ability
    local mogicfier = keys.mogicfier
	local castOrg = caster:GetAbsOrigin()
	local enemyin = false
    local range = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() -1))
    local gt = GameRules:GetDOTATime( false, false ) 
    local St = ability:GetLevelSpecialValueFor("st", (ability:GetLevel() -1)) * 60
    --print("St",St)
    --DeepPrintTable(units)
    if gt >= St then
    --print("gt",gt)
    local units = FindUnitsInRadius(caster:GetTeam() , castOrg, nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, 0, 0, false)
	for _,unit in pairs(units) do
				local dist = (unit:GetAbsOrigin()-castOrg):Length2D()
                --print("dist",dist)
					if not unit:HasModifier(mogicfier) and dist < range then
					ability:ApplyDataDrivenModifier( caster, unit, mogicfier, {} )				
					end
			end
    end	
end

function Teleport( event )
	local caster = event.caster
    local target = event.target
    local caster_team = caster:GetTeamNumber()
	local badstatue = Entities:FindByName(nil,"badponit")
    local goodstatue = Entities:FindByName(nil,"goodponit")
    local point1 = badstatue:GetAbsOrigin()
    local point2 = goodstatue:GetAbsOrigin()
	if caster_team == DOTA_TEAM_BADGUYS then
    FindClearSpaceForUnit(target, point1, true)
    target:Stop()  
    else
    FindClearSpaceForUnit(target, point2, true)
    target:Stop()  
    end
    
end