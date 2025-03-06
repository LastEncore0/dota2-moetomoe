function Manacheck( event )
	local caster = event.caster
	local ability = event.ability
	local mananeed = ability:GetManaCost(-1)

	if mananeed >= caster:GetMana() or caster:IsSilenced()  then
		ability:ToggleAbility()
	end
end
