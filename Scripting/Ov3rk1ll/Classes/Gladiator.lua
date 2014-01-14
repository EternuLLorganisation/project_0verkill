--[[

	--------------------------------------------------
	Copyright (C) 2011 kintarooe & rellis

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
	--------------------------------------------------
	
]]--

--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned )

	-- Target Casting use Lockdown
	if Entity:GetSkillID() > 0 and Entity:GetSkillTime() > 1 and Helper:CheckAvailable( "Lockdown" ) then
		--Write ( "Target using skill ID " .. Entity:GetSkillID() .. " with cast time of " .. Entity:GetSkillTime() .. " using Lockdown." );
		Helper:CheckExecute( "Lockdown" );
		return false;
	end
	
	if Settings.Gladiator.AllowTalocHollow then
		-- Taloc's Hollow
		if Helper:CheckAvailableInventory( "Taloc's Tears" ) and Range <= 6 then
			PlayerInput:Inventory( "Taloc's Tears" );
			return false;
		end	
--[[
		if Helper:CheckAvailableInventory( "Neith's Sleepstone" ) then
			PlayerInput:Inventory( "Neith's Sleepstone" );
			return false;
		end	
]]--			
		if Helper:CheckAvailableInventory( "Gellmar's Wardstone" ) then
			PlayerInput:Inventory( "Gellmar's Wardstone" );
			return false;
		end
	end

	-- Chain 1: Remove Shock (Care on WE aoe attack)
	if not Stunned and Helper:CheckAvailable( "Ferocity" ) then
		Helper:CheckExecute( "Ferocity" );
		return false;
	elseif Helper:CheckAvailable( "Wrathful Explosion" ) then 
		Helper:CheckExecute( "Wrathful Explosion" );
		return false;
	elseif Helper:CheckAvailable( "Remove Shock" ) then
		Helper:CheckExecute( "Remove Shock" );
		return false;
	end

	-- Buffs
	if Entity:GetHealth() >= 50 and Helper:CheckAvailable( "Berserking" ) then
		Helper:CheckExecute( "Berserking" );
		return false;
	end
	
	if Entity:GetHealth() >= 50 and Helper:CheckAvailable( "Unwavering Devotion" ) then
		Helper:CheckExecute( "Unwavering Devotion" );
		return false;
	end
	
	if Entity:GetHealth() >= 50 and Player:GetHealth() <= 75 and Helper:CheckAvailable( "Wall of Steel" ) then
		Helper:CheckExecute( "Wall of Steel" );
		return false;
	end
	
-- BEGIN DP SKILLS
--[[ DOESN'T WORK PROPERLY
	if Entity:GetHealth() >= 50 and Player:GetHealth() <= 75 and Helper:CheckAvailable( "Draining Blow" ) and Helper:CheckAvailable( "Explosion of Rage" ) then
		Helper:CheckExecute( "Explosion of Rage" );
		return false;
	elseif 	Entity:GetHealth() >= 75 and Helper:CheckAvailable( "Zikel's Threat" ) then 
		Helper:CheckExecute( "Zikel's Threat" );
		return false;
	elseif 	Entity:GetHealth() >= 75 and Helper:CheckAvailable( "Daevic Fury" ) then 
		Helper:CheckExecute( "Daevic Fury" );
		return false;
	end
]]--

-- END DP SKILLS
	
-- BEGIN STATE ACTIVATED SKILLS
	
	-- Successful Parry
	if Helper:CheckAvailable( "Vengeful Strike" ) then
		Helper:CheckExecute( "Vengeful Strike" );
		return false;
	end
	
	-- Mob Stumbled Skills
	-- Check if Health status warrants using Draining Blow
	if Helper:CheckAvailable( "Draining Blow" ) and Player:GetHealthCurrent() < Player:GetHealthMaximum() - 750 and Range <= 6 then
		Helper:CheckExecute( "Draining Blow" );
		return false;
	elseif Helper:CheckAvailable( "Crippling Cut" ) and Range <= 6  then
		Helper:CheckExecute( "Crippling Cut" );
		return false;
	elseif Helper:CheckAvailable( "Springing Slice" ) then
		Helper:CheckExecute( "Springing Slice" );
		return false;
	elseif Helper:CheckAvailable( "Final Strike" ) and Range <= 6  then
		Helper:CheckExecute( "Final Strike" );
		return false;
	end
	
	-- Mob Aether's Hold
	if Helper:CheckAvailable( "Final Strike" ) then
		Helper:CheckExecute( "Final Strike" );
		return false;
	elseif Helper:CheckAvailable( "Crashing Blow" ) then
		Helper:CheckExecute( "Crashing Blow" );
		return false;
	end
	
-- END STATE ACTIVATED SKILLS

-- BEGIN CHAIN ACTIVATED SKILLS	
	
	-- Chain 2: Rupture
	if Helper:CheckAvailable( "Reckless Strike" ) then
		Helper:CheckExecute( "Reckless Strike" );
		return false;
	end

	-- Chain 6: AoE Chain - Shock Wave
	if Helper:CheckAvailable( "Seismic Billow" ) and Range <= 6 then
		Helper:CheckExecute( "Seismic Billow" );
		return false;
	end
	
	-- Chain 6: AoE Chain - Seismic Wave/Absorbing Fury
	if Helper:CheckAvailable( "Pressure Wave" ) and Range <= 6 then
		Helper:CheckExecute( "Pressure Wave" );
		return false;
	elseif Helper:CheckAvailable( "Shock Wave" ) and Range <= 6 then
		Helper:CheckExecute( "Shock Wave" );
		return false;
	end
	
	-- Chain 2: Ferocious Strike
	if Helper:CheckAvailable( "Robust Blow" ) then
		Helper:CheckExecute( "Robust Blow" );
		return false;
	elseif Helper:CheckAvailable( "Rage" ) then
		Helper:CheckExecute( "Rage" );
		return false;
	end

	-- Chain 2: Robust Blow
	if Helper:CheckAvailable( "Wrathful Strike" ) then
		Helper:CheckExecute( "Wrathful Strike" );
		return false;
	elseif Helper:CheckAvailable( "Rupture" ) then
		Helper:CheckExecute( "Rupture" );
		return false;
	end

-- END CHAIN ACTIVATED SKILLS

-- BEGIN RANGED SKILLS

	-- Ranged skills
	if Range <= 20 then
	
		-- Ranged Stumbled 1: Springing Slice
		if Helper:CheckAvailable( "Springing Slice" ) then
			Helper:CheckExecute( "Springing Slice" );
			return false;
		end
	
		-- Ranged Chain 2: Great Cleave
		if Helper:CheckAvailable( "Righteous Cleave" ) then
			Helper:CheckExecute( "Righteous Cleave" );
			return false;
		end
		
		-- Ranged Chain 1: Cleave
		if Helper:CheckAvailable( "Great Cleave" ) then
			Helper:CheckExecute( "Great Cleave" );
			return false;
		elseif Helper:CheckAvailable( "Force Cleave" ) then
			Helper:CheckExecute( "Force Cleave" );
			return false;
		end
		
		-- Ranged Attack 1: Cleave
		if Helper:CheckAvailable( "Cleave" ) then
			Helper:CheckExecute( "Cleave" );
			return false;
		end
		
	end
	
-- BEGIN PRIMARY ATTACK SKILLS

	
	-- Severe Weakening Blow
	if Helper:CheckAvailable( "Severe Weakening Blow" ) then
		Helper:CheckExecute( "Severe Weakening Blow" );
		return false;
	end
	
	-- Attack 3: Ferocious Strike
	if Helper:CheckAvailable( "Ferocious Strike" ) then
		Helper:CheckExecute( "Ferocious Strike" );
		return false;
	end
	
	-- Attack 4: Aerial Lockdown
	if Helper:CheckAvailable( "Aerial Lockdown" ) then
		Helper:CheckExecute( "Aerial Lockdown" );
		return false;
	end
	
	-- Attack 5: AoE Skills
	if Settings.Gladiator.AllowAoe and Range <= 6 then
		if Helper:CheckAvailable( "Absorbing Fury" ) and Player:GetHealthCurrent() < Player:GetHealthMaximum() - 500 then
			Helper:CheckExecute( "Absorbing Fury" );
			return false;
		elseif Helper:CheckAvailable( "Seismic Wave" ) then
			Helper:CheckExecute( "Seismic Wave" );
			return false;
		end
		
		if Helper:CheckAvailable( "Piercing Rupture" ) then
			Helper:CheckExecute( "Piercing Rupture" );
			return false;
		elseif Helper:CheckAvailable( "Piercing Wave" ) then
			Helper:CheckExecute( "Piercing Wave" );
			return false;
		end
	end
	
	-- Chain 2 Attack: Ferocious Strike
	if self.FerociousTrigger ~= nil and Helper:CheckAvailable( "Ferocious Strike" ) then
		if Helper:CheckExecute( "Ferocious Strike" ) then
			self.FerociousTrigger = nil;
			return false;
		end
	end

-- END PRIMARY ATTACK SKILLS
	
end

--- Perform healing checks both in and our of combat.
--
-- @param	bool	Indicates whether or not the function is running before force checks.
-- @return	bool

function Heal( BeforeForce )
		
	-- Check if we should recharge our health using recovery spell.
	if Helper:CheckAvailable( "Improved Stamina" ) and Player:GetHealthCurrent() < Player:GetHealthMaximum() - 900 then
		Helper:CheckExecute( "Improved Stamina", Player );
		return false;
	end
	
	-- Check if we should recharge our health using recovery spell.
	if Helper:CheckAvailable( "Stamina Recovery" ) and Player:GetHealthCurrent() < Player:GetHealthMaximum() - 1500 then
		Helper:CheckExecute( "Stamina Recovery", Player );
		return false;
	end

	-- Nothing was executed, continue with other functions.
	return true;
	
end

--- Perform the safety checks before moving to the next target.
--
-- @return	bool

function Pause()

	-- Nothing was executed, continue with other functions.
	return true;
	
end