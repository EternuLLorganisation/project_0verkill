--[[

	--------------------------------------------------
	Copyright (C) 2011 Blastradius

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

--- (Private Function) Check required healing for the entity.
--
-- @param	Entity		Entity to check.
-- @param	IsPriority	Indicates only priority healing to be executed.
-- @return	bool

function _Heal( Entity, IsPriority )
	
	-- Retrieve the rechargeable health.
	local HealthRecharge = Entity:GetHealthMaximum() - Entity:GetHealthMaximum();
	
	-- Retrieve the state.
	local EntityState = Entity:GetState();
	
	-- Heal 1: Recovery Spell
	if Helper:CheckAvailable( "Recovery Spell" ) and (( IsPriority and HealthRecharge >= 2526 ) or ( not IsPriority and Entity:GetHealth() < 60 )) then
		Helper:CheckExecute( "Recovery Spell", Entity );
		return false;
	end

	-- Heal 2: Stamina Recovery
	if Entity:GetID() == Player:GetID() and Helper:CheckAvailable( "Stamina Restoration" ) and (( IsPriority and Entity:GetHealth() < 40 ) or ( not IsPriority and Entity:GetHealth() < 50 )) then
		Helper:CheckExecute( "Stamina Restoration" );
		return false;
	end

	-- Heal 3: Healing Burst
	if Helper:CheckAvailable( "Healing Burst" ) and (( IsPriority and Entity:GetHealth() < 40 ) or ( not IsPriority and Entity:GetHealth() < 50 )) then
		Helper:CheckExecute( "Healing Burst", Entity );
		return false;
	end
	
	-- Heal 4: Healing Light
	if EntityState:GetState( Helper:CheckName( "Recovery Spell" )) == nil and Helper:CheckAvailable( "Healing Light" ) and (( IsPriority and Entity:GetHealth() < 50 ) or ( not IsPriority and Entity:GetHealth() < 60 )) then
		Helper:CheckExecute( "Healing Light", Entity );
		return false;
	end
	
end

--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned )
		
	-- Prepare the attack timer when the target is stunned to determine when to use Soul Crush.
	if Stunned and self.AttackTimer == nil then
		self.AttackTimer = Time() + 750;
	elseif not Stunned then
		self.AttackTimer = nil;
	end
	
	--
	-- Binding Word (Physical Charged Attack)
	--
	
	--------------------------------------------------
	--                H E A L I N G                 --
	--------------------------------------------------
	
	self:_Heal( Player, true );
	
	--------------------------------------------------
	--         C H A I N   A T T A C K (S)          --
	--------------------------------------------------

	-- Chain Attack 1: Remove Shock
	if not Stunned and Helper:CheckAvailable( "Backshock" ) and ( not Helper:CheckAvailable( "Retribution" ) or Range <= 10 ) then
		Helper:CheckExecute( "Backshock" );
		return false;
	elseif not Stunned and Helper:CheckAvailable( "Retribution" ) then
		Helper:CheckExecute( "Retribution" );
		return false;
	elseif Helper:CheckAvailable( "Remove Shock" ) then
		Helper:CheckExecute( "Remove Shock" );
		return false;
	end
	
	-- Chain Attack 2: Meteor Strike
	if Helper:CheckAvailable( "Pentacle Shock" ) then
		Helper:CheckExecute( "Pentacle Shock" );
		return false;
	elseif Helper:CheckAvailable( "Incandescent Blow" ) then
		Helper:CheckExecute( "Incandescent Blow" );
		return false;
	end
	
	-- Chain Attack 4 Part I: Hallowed Strike
	if Helper:CheckAvailable( "Booming Smash" ) then
		Helper:CheckExecute( "Booming Smash" );
		return false;
	elseif Helper:CheckAvailable( "Booming Assault" ) then
		Helper:CheckExecute( "Booming Assault" );
		return false;
	end
	
	-- Chain Attack 3: Infernal Blaze (Parrying Strike, if available, is preferred).
	if not Stunned and Helper:CheckAvailable( "Parrying Strike" ) and Helper:CheckAvailable( "Infernal Blaze" ) then
		Helper:CheckExecute( "Parrying Strike" );
		return false;
	elseif not Stunned and Helper:CheckAvailable( "Infernal Blaze" ) then
		Helper:CheckExecute( "Infernal Blaze" );
		return false;
	end
	
	-- Chain Attack 4 Part II: Hallowed Strike
	if Helper:CheckAvailable( "Booming Strike" ) then
		Helper:CheckExecute( "Booming Strike" );
		return false;
	end
	
	--------------------------------------------------
	--   C O N D I T I O N A L   A T T A C K (S)    --
	--------------------------------------------------
		
	-- Conditional Attack 1: Seismic Crash
	if Helper:CheckAvailable( "Seismic Crash" ) then
		Helper:CheckExecute( "Seismic Crash" );
		return false;
	end
	
	-- Conditional Attack 2: Resonance Haze
	if Helper:CheckAvailable( "Resonance Haze" ) then
		Helper:CheckExecute( "Resonance Haze" );
		return false;
	end
	
	-- Conditional Attack 3: Soul Lock
	if Helper:CheckAvailable( "Soul Lock" ) then
		Helper:CheckExecute( "Soul Lock" );
		return false;
	end	
	
	-- Conditional Attack 4: Parrying Strike
	if not Stunned and Helper:CheckAvailable( "Parrying Strike" ) then
		Helper:CheckExecute( "Parrying Strike" );
		return false;
	end
	
	-- Conditional Attack 5: Soul Crush
	if self.AttackTimer ~= nil and self.AttackTimer < Time() and Helper:CheckAvailable( "Soul Crush" ) then
		Helper:CheckExecute( "Soul Crush" );
		return false;
	end
	
	--------------------------------------------------
	--     P R E P A R I N G   A T T A C K (S)      --
	--------------------------------------------------
	
	-- When the entity is a player ...
	if Entity:IsPlayer() then
	
		-- Preparing Attack 1: Confident Defense
		if Helper:CheckAvailable( "Confident Defense" ) then
			Helper:CheckExecute( "Confident Defense" );
			return false;
		end	
	
		-- Preparing Attack 2: Protective Ward
		if Helper:CheckAvailable( "Protective Ward" ) then
			Helper:CheckExecute( "Protective Ward" );
			return false;
		end
		
		-- Preparing Attack 3: Marchutan's Protection/Yustiel's Protection
		if Player:GetDP() >= 2000 then
			if Helper:CheckAvailable( "Marchutan's Protection" ) then
				Helper:CheckExecute( "Marchutan's Protection" );
				return false;
			elseif Helper:CheckAvailable( "Yustiel's Protection" ) then
				Helper:CheckExecute( "Yustiel's Protection" );
				return false;
			end
		end
		
	-- Otherwise when the entity is not a player ...
	else
	
		-- Preparing Attack 4: Focused Parry
		if Helper:CheckAvailable( "Focused Parry" ) then
			Helper:CheckExecute( "Focused Parry" );
			return false;
		end	
		
		-- Preparing Attack 4: Word of Revival (Also in Pause)
		if Player:GetHealthCurrent() < Player:GetHealthMaximum() and Player:GetState():GetState( Helper:CheckName( "Word of Revival" )) == nil and Helper:CheckAvailable( "Word of Revival" ) then
			Helper:CheckExecute( "Word of Revival", Player );
			return false;
		end
		
	end
	
	--------------------------------------------------
	--                H E A L I N G                 --
	--------------------------------------------------
	
	self:_Heal( Player, false );
	
	--------------------------------------------------
	--        R A N G E D   A T T A C K (S)         --
	--------------------------------------------------
	
	-- Ranged Attack 1: Inescapable Judgement/Soul Strike and Retribution (Chain Skill)
	if not Stunned and Helper:CheckAvailable( "Inescapable Judgement" ) then
		Helper:CheckExecute( "Inescapable Judgement" );
		return false;
	elseif not Stunned and Helper:CheckAvailable( "Soul Strike" ) then
		Helper:CheckExecute( "Soul Strike" );
		return false;
	end
	
	--------------------------------------------------
	--        N O R M A L   A T T A C K (S)         --
	--------------------------------------------------
	
	-- Normal Attack 1: Mountain Crash
	if Helper:CheckAvailable( "Mountain Crash" ) then
		Helper:CheckExecute( "Mountain Crash" );
		return false;
	end
	
	-- Normal Attack 2: Disorienting Blow
	if not Stunned and Helper:CheckAvailable( "Disorienting Blow" ) then
		Helper:CheckExecute( "Disorienting Blow" );
		return false;
	end
	
	-- Normal Attack 3: Numbing Blow 
	if not Stunned and Helper:CheckAvailable( "Numbing Blow" ) then
		Helper:CheckExecute( "Numbing Blow" );
		return false;
	end

	--------------------------------------------------
	--       I N I T I A L   A T T A C K (S)        --
	--------------------------------------------------
	
	-- Initial Attack 1: Automatic Attack
	if self.AttackStarted ~= Entity:GetID() then
		self.AttackStarted = Entity:GetID();
		Helper:CheckExecute( "Attack/Chat" );
		return false;
	end
	
	-- Initial Attack 2: Meteor Strike
	if Helper:CheckAvailable( "Meteor Strike" ) then
		Helper:CheckExecute( "Meteor Strike" );
		return false;
	end

	-- Initial Attack 3: Hallowed Strike
	if Helper:CheckAvailable( "Hallowed Strike" ) then
		Helper:CheckExecute( "Hallowed Strike" );
		return false;
	end
		
	-- Nothing was executed, continue with other functions.
	return true;

end

--- Perform healing checks both in and our of combat.
--
-- @param	bool	Indicates whether or not the function is running before force checks.
-- @return	bool

function Heal( BeforeForce )
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end

--- Perform the safety checks before moving to the next target.
--
-- @return	bool

function Pause()
		
	--------------------------------------------------
	--                H E A L I N G                 --
	--------------------------------------------------
		
	-- Heal 5: Word of Revival (Also in Attack)
	if Player:GetHealthCurrent() < Player:GetHealthMaximum() and Player:GetState():GetState( Helper:CheckName( "Word of Revival" )) == nil and Helper:CheckAvailable( "Word of Revival" ) then
		Helper:CheckExecute( "Word of Revival", Player );
		return false;
	end
	
	-- Heal 6: Magic Recovery
	if Helper:CheckAvailable( "Magic Recovery" ) and Player:GetManaCurrent() < Player:GetManaMaximum() - 2500 then
		Helper:CheckExecute( "Magic Recovery", Player );
		return false;
	end
	
	-- Heal 0: Non-Priority Healing
	self:_Heal( Player, false );
	
	--------------------------------------------------
	--                B U F F I N G                 --
	--------------------------------------------------

	-- Check if the state checking timer has expired.
	if ( self.StateBuffTime == nil or self.StateBuffTime < Time()) then

		-- Retrieve the state.
		local EntityState = Player:GetState();
	
		-- Buff 1: Blessing of Health
		if Helper:CheckAvailable( "Blessing of Health" ) and EntityState:GetState( "Blessing of Health I" ) == nil and EntityState:GetState( "Blessing of Health II" ) == nil then
			Helper:CheckExecute( "Blessing of Health", Player );
			return false;
		end
		
		-- Buff 2: Blessing of Rock/Blessing of Stone
		if EntityState:GetState( "Blessing of Rock I" ) == nil and EntityState:GetState( "Blessing of Stone I" ) == nil then
		
			-- Buff 2: Blessing of Rock
			if Helper:CheckAvailable( "Blessing of Stone I" ) then
				Helper:CheckExecute( "Blessing of Stone", Player );
				return false;
			-- Buff 2: Blessing of Stone
			elseif Helper:CheckAvailable( "Blessing of Rock I" )  then
				Helper:CheckExecute( "Blessing of Rock", Player );
				return false;
			end

		end

		-- Buff 3: Promise of Wind
		if Helper:CheckAvailable( "Promise of Wind" ) and EntityState:GetState( Helper:CheckName( "Promise of Wind" )) == nil  then
			Helper:CheckExecute( "Promise of Wind", Player );
			return false;
		end

		-- Buff 3: Blessing of Wind
		if Helper:CheckAvailable( "Blessing of Wind" ) and EntityState:GetState( Helper:CheckName( "Blessing of Wind" )) == nil then
			Helper:CheckExecute( "Blessing of Wind", Player );
			return false;
		end

		-- Buff 4: Rage Spell
		if Helper:CheckAvailable( "Rage Spell I" ) and EntityState:GetState( "Rage Spell I" ) == nil then
			Helper:CheckExecute( "Rage Spell", Player );
			return false;
		end
		
		-- Update the state checking timer.
		self.StateBuffTime = Time() + 1000;
		
	end
		
	-- Nothing was executed, continue with other functions.
	return true;
	
end