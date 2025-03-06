--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	A helper method that switches the keys.ability item to one with the inputted name.
================================================================================================================= ]]
function swap_to_item(keys, ItemName)
	for i = 0, 5, 1 do --Fill all empty slots in the player's inventory with "dummy" items.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item == nil then
			keys.caster:AddItem(CreateItem("item_dummy", keys.caster, keys.caster))
		end
	end

	keys.caster:RemoveItem(keys.ability)
	keys.caster:AddItem(CreateItem(ItemName, keys.caster, keys.caster)) --This should be put into the same slot that the removed item was in.

	for i = 0, 5, 1 do                                               --Remove all dummy items from the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_dummy_datadriven" then
				keys.caster:RemoveItem(current_item)
			end
		end
	end
end

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called when Armlet (active) is cast.  Toggles the item to an inactive state.
================================================================================================================= ]]
function item_armlet_active_datadriven_on_spell_start(keys)
	keys.caster:EmitSound("DOTA_Item.Armlet.DeActivate")
	swap_to_item(keys, "item_armlet_datadriven")
end

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called when Armlet (inactive) is cast.  Toggles the item to an active state.  Currently, only one Armlet may be
	toggled on at a time.
================================================================================================================= ]]
function item_armlet_datadriven_on_spell_start(keys)
	while keys.caster:HasAnyAvailableInventorySpace() do --Fill all empty slots in the player's inventory with "dummy" items.
		keys.caster:AddItem(CreateItem("item_dummy", keys.caster, keys.caster))
	end

	--Replace all "on" armlets with "off" ones.
	for i = 0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_armlet_active_datadriven" then
				keys.caster:RemoveItem(current_item)
				keys.caster:AddItem(CreateItem("item_armlet_datadriven", keys.caster, keys.caster)) --This should be put into the same slot that the "on" Armlet was in.
			end
		end
	end

	for i = 0, 5, 1 do --Remove all dummy items from the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_dummy" then
				keys.caster:RemoveItem(current_item)
			end
		end
	end

	keys.caster:EmitSound("DOTA_Item.Armlet.Activate")
	swap_to_item(keys, "item_armlet_active_datadriven") --Turn the newly toggled armlet on.
end

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called regularly while Armlet is toggled on.  Damages the caster.
	Additional parameters: keys.UnholyHealthDrainPerSecond and keys.UnholyHealthDrainInterval
================================================================================================================= ]]
function modifier_item_armlet_active_datadriven_on_interval_think_damage(keys)
	local new_hp = keys.caster:GetHealth() - (keys.UnholyHealthDrainPerSecond * keys.UnholyHealthDrainInterval)

	if new_hp < 1 then --Armlet cannot kill the caster from its HP drain.
		new_hp = 1
	end

	keys.caster:SetHealth(new_hp)
end

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called regularly while Armlet is toggled on.  Gives the caster another tick's worth of Strength if they have not
	yet reached the maximum amount of Strength granted, and increases their current HP by the amount their maximum
	HP was increased by.
	Additional parameters: keys.UnholyTicksToFullEffect and keys.UnholyBonusStrength
================================================================================================================= ]]
function magic_out(keys)
	local caster = keys.caster
	local ability = keys.ability
	local basemana_cost = ability:GetLevelSpecialValueFor("manacost", ability:GetLevel() - 1)
	if caster:HasTalent("saber_talent_1") then
		basemana_cost = ability:GetLevelSpecialValueFor("talentcost", ability:GetLevel() - 1)
	end
	local premana = ability:GetLevelSpecialValueFor("premaxmana", ability:GetLevel() - 1) / 100
	local mana_cost = basemana_cost + premana * caster:GetMaxMana()
	local modifier_flamewing = keys.modifier_flamewing
	local mana = caster:GetMana()
	if sabernewmana == nil then
		sabernewmana = mana - mana_cost
	elseif sabernewmana - mana_cost < mana - mana_cost then
		sabernewmana = sabernewmana - mana_cost
	else
		sabernewmana = mana - mana_cost
	end
	if sabernewmana >= mana_cost then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_magic_out_2", { duration = -1 })

		--Update the stored amount of active Armlet ticks.
		if keys.ability.ArmletTicksActive == nil then
			keys.ability.ArmletTicksActive = 1
		else
			keys.ability.ArmletTicksActive = keys.ability.ArmletTicksActive + 1
		end

		--Increase the caster's current health by the same amount that their maximum health was increased by.
		caster:SetMana(sabernewmana)
	else
		if keys.ability.ArmletTicksActive ~= nil then
			for i = 1, keys.ability.ArmletTicksActive, 1 do
				keys.caster:RemoveModifierByName("modifier_magic_out_2")
			end
		end
		caster:SetMana(sabernewmana)
		keys.ability.ArmletTicksActive = nil
		sabernewmana = nil
		ability:ToggleAbility()
	end
end

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called when an active Armlet is unequipped (e.g. when it is sold or dropped).  Removes any bonus Strength
	modifiers from the caster, and reduces their current HP by the amount their maximum HP was decreased by.
	Additional parameters: keys.UnholyTicksToFullEffect and keys.UnholyBonusStrength
================================================================================================================= ]]
function magic_out_end(keys)
	if keys.ability.ArmletTicksActive ~= nil then
		for i = 1, keys.ability.ArmletTicksActive, 1 do
			keys.caster:RemoveModifierByName("modifier_magic_out_2")
		end
		keys.ability.ArmletTicksActive = nil
	end
	if sabernewmana ~= nil then
		sabernewmana = nil
	end
end

function avalon(keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("avalon")
	if caster:HasItemInInventory("item_heart") then
		ability:SetActivated(true)
		
	else
		ability:SetActivated(false)
	end
end

function Excalibur(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasTalent("saber_talent_2") then
		ability:EndCooldown()
	end
end
