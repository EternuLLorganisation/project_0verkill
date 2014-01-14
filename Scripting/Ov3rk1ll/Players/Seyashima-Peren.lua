function _CheckRunes( EntityState )
	if EntityState ~= nil then
		-- Using numeric identifiers because there are multiple entries of this kind of skill,
		-- one for monsters and one for players. We're interested only in what we do, and unfortunately,
		-- this is the second entry.
		if EntityState:GetState( 8307 ) ~= nil then
			return 5;
		elseif EntityState:GetState( 8306 ) ~= nil then
			return 4;
		elseif EntityState:GetState( 8305 ) ~= nil then
			return 3;
		elseif EntityState:GetState( 8304 ) ~= nil then
			return 2;
		elseif EntityState:GetState( 8303 ) ~= nil then
			return 1;
		end
	end
	
	return 0;
end


--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned )


	-- Retrieve the entity state.
	local EntityState = Entity:GetState();
	
	-- Retrieve the rune level on the target.
	local Runes = self:_CheckRunes( EntityState );
	
	-- Stunned is overwritten with Spin, but Assassinate needs the real stun status.
	local ReallyStunned = Stunned;

	-- Check if the enemy is in the spin state, let's assume that's a type of stun!
	if EntityState ~= nil and not EntityState:GetState( "Spin" ) == nil then
		Stunned = true;
		Spinned = true;
	else
		Spinned = false;
	end
	
	-- Chain 1: Remove Shock
	if not Stunned and Helper:CheckAvailable( "Cyclone Slash" ) then
		Helper:CheckExecute( "Cyclone Slash" );
		return false;
	elseif not Stunned and Helper:CheckAvailable( "Bursting Flame Strike" ) then
		Helper:CheckExecute( "Bursting Flame Strike" );
		return false;
	elseif Helper:CheckAvailable( "Remove Shock" ) then
		Helper:CheckExecute( "Remove Shock" );
		return true;
	end

	-- Conditional 2: Evasive Boost, Whirlwind Slash and Counterattack
	if Helper:CheckAvailable( "Evasive Boost" ) then
		Helper:CheckExecute( "Evasive Boost" );
		return false;
	elseif not Stunned and Helper:CheckAvailable( "Whirlwind Slash" ) then
	Helper:CheckExecute( "Whirlwind Slash" );
	return false;
	elseif not Stunned and Helper:CheckAvailable( "Counterattack" ) then
	Helper:CheckExecute( "Counterattack" );
	return false;
	end
	
	--if Helper:CheckAvailable( "Blinding Burst" ) then
	--	Helper:CheckExecute( "Blinding Burst" );
	--	return false;
	--end

	-- Check if the target entity is doing a skill.
	if Entity:GetSkillID() ~= 0 then

	local Skill = SkillList:GetSkill( Entity:GetSkillID());

	-- Check if this is a valid skill and is a magical skill, in which case we can use Aethertwisting.
	if Skill ~= nil and Skill:IsMagical() and Helper:CheckAvailable( "Aethertwisting" ) then
				Helper:CheckExecute( "Aethertwisting" );
				return false;	
				elseif Skill ~= nil and Skill:IsPhysical() and Helper:CheckAvailable( "Focused Evasion" ) then
				Helper:CheckExecute( "Focused Evasion" );
				return false;
				end
	end
	

	
	if Range <= Player:GetAttackRange() + 25 then	
		-- Buff 2: Apply Poison
		if Helper:CheckAvailable( "Apply Poison" ) and Player:GetState():GetState( Helper:CheckName( "Apply Poison I" )) == nil and Helper:CheckAvailableInventory( "Scolopen Poison", 4 ) then
			Helper:CheckExecute( "Apply Poison I" );
			return false;
		end

		-- Buff 3: Apply Deadly Poison
		if Helper:CheckAvailable( "Apply Deadly Poison" ) and Player:GetState():GetState( Helper:CheckName( "Apply Deadly Poison I" )) == nil and Helper:CheckAvailableInventory( "Scolopen Poison", 2 ) then
			Helper:CheckExecute( "Apply Deadly Poison I" );
			return false;
		end
		
		-- Buff 3: Apply Deadly Poison
		if Helper:CheckAvailable( "Apply Lethal Venom" ) and Player:GetState():GetState( Helper:CheckName( "Apply Lethal Venom" )) == nil and Helper:CheckAvailableInventory( "Scolopen Poison", 2 ) then
			Helper:CheckExecute( "Apply Lethal Venom" );
			return false;
		end
	end
	
	-- Use devotion and such when in range.
	if Range <= Player:GetAttackRange() + 14 and not Player:GetState():GetState( Helper:CheckName( "Hide II" )) ~= nil then

		
		if Helper:CheckAvailable( "Flurry" ) then
			Helper:CheckExecute( "Flurry" );
			return false;
		end

		if Helper:CheckAvailable( "Clear Focus" ) then
			Helper:CheckExecute( "Clear Focus" );
			return false;
		end

	end
	
	if Helper:CheckAvailable( "Lightning Slash" ) and Helper:CheckAvailable( "Soul Slash" ) then
		Helper:CheckExecute( "Lightning Slash" );
		return false;
	end
	if Helper:CheckAvailable( "Rune Slash" ) then
		Helper:CheckExecute( "Rune Slash" );
		return false;
	end
	if Helper:CheckAvailable( "Soul Slash" ) then
		Helper:CheckExecute( "Soul Slash" );
		return true;
	end
	
	if Helper:CheckAvailable( "Sigil Strike" ) then
		Helper:CheckExecute( "Sigil Strike" );
		return false;
	end

	if Helper:CheckAvailable( "Beast Swipe") then 
		Helper:CheckExecute( "Beast Swipe");
		return false;
	end

	if Helper:CheckAvailable( "Beast Kick" ) then
		Helper:CheckExecute( "Beast Kick");
		return true;
	end

	-- Attack 1: 
	if Helper:CheckAvailable( "Weakening Blow" ) then
		Helper:CheckExecute( "Weakening Blow" );
	--elseif Helper:CheckAvailable( "Dash Attack" ) then
	--	Helper:CheckExecute( "Dash Attack" );
	--	return false;
	end
		

	-- Attack 4: Surprise Attack (Spin)
	if Spinned or (Helper:CheckAvailable( "Surprise Attack" ) and Range <= 4) then
		local PosE = Entity:GetPosition();
		local dist = 2; 
		local Angle = Entity:GetRotation();
		PosE.X = PosE.X - dist*math.sin(Angle*(math.pi/180));
		PosE.Y = PosE.Y + dist*math.cos(Angle*(math.pi/180));
		Player:SetPosition(PosE);
		Helper:CheckExecute( "Surprise Attack" );
		return false;
	end

	if Spinned or (Helper:CheckAvailable( "Weakening Blow" ) and Range <= 4) then
		local PosE = Entity:GetPosition();
		local dist = 2; 
		local Angle = Entity:GetRotation();
		PosE.X = PosE.X - dist*math.sin(Angle*(math.pi/180));
		PosE.Y = PosE.Y + dist*math.cos(Angle*(math.pi/180));
		Player:SetPosition(PosE);
		Helper:CheckExecute( "Weakening Blow" );
		return false;
	end
		

	-- Buff Up before Rune Blast
		if Helper:CheckAvailable( "Devotion" ) and not Player:GetState():GetState( Helper:CheckName( "Hide II" )) ~= nil then
			Helper:CheckExecute( "Devotion" );
			return false;
		elseif Helper:CheckAvailable( "Dash Attack" ) then
			Helper:CheckExecute( "Dash Attack" );
			
		end
	-- Check if we have enough runes carved on the target.
	if Runes >= 5 then
		
		if not Stunned and Helper:CheckAvailable( "Pain Rune" ) then
			Helper:CheckExecute( "Pain Rune" );
			return false;
		
		elseif Helper:CheckAvailable( "Needle Rune" ) then
			Helper:CheckExecute( "Needle Rune" );
			return false;

		end

		--if not Stunned and Helper:CheckAvailable( "Pain Rune" ) then
		--	Helper:CheckExecute( "Pain Rune" );
		--	return false;

		if Helper:CheckAvailable( "Rune Burst" ) then
			Helper:CheckExecute( "Rune Burst" );
			return false;

		end

		--if Helper:CheckAvailable( "Blood Rune" ) then
			--Helper:CheckExecute( "Blood Rune" );
			--return false;

		--elseif Helper:CheckAvailable( "Darkness Rune" ) then
			--Helper:CheckExecute( "Darkness Rune" );
			--return false;

		--end

	-- Attack 12: Ripclaw Strike (Carves Level 5)
	elseif Runes < 1 and Helper:CheckAvailable( "Ripclaw Strike" ) then
		Helper:CheckExecute( "Ripclaw Strike" );
		return true;
		
	
	elseif Helper:CheckAvailable( "Fang Strike" ) then
		Helper:CheckExecute( "Fang Strike" );
		return true;

	
	-- Start Chain 2: Rune Carve
	elseif Helper:CheckAvailable( "Rune Carve" ) then
		Helper:CheckExecute( "Rune Carve" );
		return true;

	end
	
		-- Conditional 2: Crashing Wind Strike
	if Helper:CheckAvailable( "Crashing Wind Strike" ) then
		Helper:CheckExecute( "Crashing Wind Strike" );
		return false;
	end
	
	if Helper:CheckAvailable( "Swift Edge" ) then
		Helper:CheckExecute( "Swift Edge" );
		return true;
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

	-- Nothing was executed, continue with other functions.
	return true;
	
end