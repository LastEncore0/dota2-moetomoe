--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when Refresher Orb is cast.  Takes the player's abilities and items off cooldown.
================================================================================================================= ]]
function item_lightyu(keys)

    keys.caster:Heal(keys.HealthRestore, keys.caster)
	keys.caster:GiveMana(keys.ManaRestore)
	--Refresh all abilities on the caster.
	for i=0, 15, 1 do  --The maximum number of abilities a unit can have is currently 16.
		local current_ability = keys.caster:GetAbilityByIndex(i)
		if current_ability ~= nil then
			current_ability:EndCooldown()
		end
	end
	
	--Refresh all items the caster has.
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() ~= "item_refresher_datadriven" then  --Refresher Orb does not refresh itself.
				current_item:EndCooldown()
			end
		end
	end

	keys.caster:RemoveItem(keys.ability)
end

function Droplightyu( keys )
    local caster = keys.caster
    local pos = caster: GetOrigin() + RandomVector(100)
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_lightyu" then  --Refresher Orb does not refresh itself.
				caster: DropItemAtPositionImmediate(current_item,pos)
			end
		end
	end
end