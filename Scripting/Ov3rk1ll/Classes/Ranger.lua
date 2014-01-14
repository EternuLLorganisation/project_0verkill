--[[

	--------------------------------------------------
	Copyright (C) 2011 Blastradius, macrokor, rellis

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

--[[
KNOWN STATE ID'S 
- State Name = Stunning Shot II - State ID = 679
- State Name = Stunned - State ID = 8217
- State Name = Entangling Shot III - State ID = 676
- State Name = No Name (Godstone: Deltras's Loyalty) State ID = 8540
- State Name = Shackle Arrow I - State ID = 672
- State Name = Sleep Arrow I - State ID = 695
]]--

function CountMobs( EntityTarget, Distance )

	local i = 0;
	
	-- Iterate through all entities
	for ID, Entity in DictionaryIterator( EntityList:GetList()) do
		-- Check if the entiy is valid.
		if Entity ~= nil then
			-- Retrieve the entity state.
			local EntityState = Entity:GetState();
			-- Check if the entity state is valid.
			if EntityState ~= nil then
				-- Check if this is a living monster that is in range.
				if Entity:IsMonster() and not Entity:IsDead() and Entity:IsHostile() and EntityTarget:GetPosition():DistanceToPosition( Entity:GetPosition()) <= Distance then
					-- Check if this entity is sleeping
					if EntityState:GetState( Helper:CheckName( "Sleep Arrow" )) ~= nil then
						return 0;
					-- Increment the number.
					else
						i = i + 1;
					end
				end
			end
		end
	end
	
	return i;
	
end

function SleepMultipleAttacker( EntityTarget, AttackRange )
	-- Check if we have stored a target.
	if self._SleepTarget ~= nil then
		-- Check if the current target is the stored target.
		if self._SleepTarget:GetID() == Player:GetTargetID() then
			-- Check if Sleep Arrow is available.
			if Helper:CheckAvailable( "Sleep Arrow" ) then
				-- Shoot the Sleep Arrow.
				Helper:CheckExecute( "Sleep Arrow" );
				-- Indicate we cannot continue attacking.
				return false;
			else
				-- Set the target.
				Player:SetTarget( self._SleepTargetRestore );
				-- Indicate we cannot continue attacking.
				return false;
			end
		-- Check if the current target is the original target.
		elseif not Helper:CheckAvailable( "Sleep Arrow" ) and self._SleepTargetRestore:GetID() == EntityTarget:GetID() then
			-- Clear the sleep target.
			self._SleepTarget = nil;
			-- Indicate we cannot continue attacking.
			return true;
		else
			-- Set the target.
			Player:SetTarget( self._SleepTarget );
			-- Indicate we cannot continue attacking.
			return false;
		end
	end
	-- Check if Sleep Arrow is available.
	if Helper:CheckAvailable( "Sleep Arrow" ) then
		-- Loop through the entities.
		for ID, Entity in DictionaryIterator( EntityList:GetList()) do
			-- Check if this entity is a monster, is not friendly and decided to attack me (and obviously is not my current target).
			if not Entity:IsDead() and Entity:IsMonster() and not Entity:IsFriendly() and Entity:GetTargetID() == Player:GetID() and Entity:GetID() ~= EntityTarget:GetID() then
				-- Check if the entity that is attacking us is within range.
				if Entity:GetPosition():DistanceToPosition( Player:GetPosition()) <= AttackRange then
					-- Store the sleep target.
					self._SleepTarget = Entity;
					-- Store the restore target.
					self._SleepTargetRestore = EntityTarget;
					-- Set the target.
					Player:SetTarget( Entity );
					-- Indicate we cannot continue attacking.
					return false;
				end
			end
		end
	end
	-- Indicate we can continue attacking.
	return true;
end

--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned, SkipFocusedEvasion )

	local TripeedFruit = InventoryList["Tripeed Fruit"];
	local TripeedSeed = InventoryList["Tripeed Seed"];
	local AttackRange = Player:GetAttackRange();
	
	-- Correct the attack range when using Bestial Fury.
	if Player:GetState():GetState( Helper:CheckName( "Bestial Fury" )) then
		AttackRange = AttackRange - 15;
	end

	-- Check if we are allowed to sleep attackers.
	if Settings.Ranger.AllowSleep and not self:SleepMultipleAttacker( Entity, AttackRange ) then
		return false;
	end

	--------------------------------------------------
	--         C H A I N   A T T A C K (S)          --
	--------------------------------------------------
	
	-- Chain 1: Remove Shock
	if Helper:CheckAvailable( "Seizure Arrow" ) then
		Helper:CheckExecute( "Seizure Arrow" );
		return false;
	elseif Helper:CheckAvailable( "Fighting Withdrawal" ) then 
		Helper:CheckExecute( "Fighting Withdrawal" );
		return false;
	elseif Helper:CheckAvailable( "Remove Shock" ) then
		Helper:CheckExecute( "Remove Shock" );
		return false;
	end
	
	-- Chain 2: Stunning Shot
	if Helper:CheckAvailable( "Rupture Arrow" ) then
		Helper:CheckExecute( "Rupture Arrow" );
		return false;
	end
	
	-- Chain 3: Swift Shot
	if Helper:CheckAvailable( "Arrow Strike" ) then
		Helper:CheckExecute( "Arrow Strike" );
		return false;
	elseif Helper:CheckAvailable( "Spiral Arrow" ) then
		Helper:CheckExecute( "Spiral Arrow" );
		return false;
	end

	--------------------------------------------------
	--       R E A C T I V E   A T T A C K (S)      --
	--------------------------------------------------
	
	-- Reactive Attack 1: Silence Arrow
	if Helper:CheckAvailable( "Silence Arrow" ) and Entity:GetSkillID() ~= 0 and SkillList[Entity:GetSkillID()]:IsMagical() and Entity:GetSkillTime() >= 500 then
		Helper:CheckExecute( "Silence Arrow" );
		return false;
	end
	
	-- Reactive Attack 2: Focused Evasion
	if SkipFocusedEvasion == nil and Helper:CheckAvailable( "Focused Evasion" ) and Entity:GetSkillID() ~= 0 and SkillList[Entity:GetSkillID()]:IsAttack() and Entity:GetSkillTime() >= 500 then
		Helper:CheckExecute( "Focused Evasion" );
		return false;
	end
	
	--------------------------------------------------
	--   C O N D I T I O N A L   A T T A C K (S)    --
	--------------------------------------------------
	
	-- Conditional Attack 1: Aerial Wild Shot
	if Helper:CheckAvailable( "Aerial Wild Shot" ) then
		Helper:CheckExecute( "Aerial Wild Shot" );
		return false;
	end
	
	--------------------------------------------------
	--      T R A P P I N G   A T T A C K (S)       --
	--------------------------------------------------
		
	if SkipFocusedEvasion == nil and Settings.Ranger.AllowTraps and Range <= 25 and Entity:GetTargetID() ~= Player:GetID() then
		
		-- Trapping Preparation: Face Target
		if self.FaceStarted ~= Entity:GetID() then
			self.FaceStarted = Entity:GetID();
			Player:SetAction( "FaceTarget" );
			return false;
		end
	
		-- Trapping Attack 1: Sandstorm Trap
		if Helper:CheckAvailable( "Sandstorm Trap" ) and TripeedFruit ~= nil and TripeedFruit:GetAmount() >= 3 and Range <= 18 then
			Helper:CheckExecute( "Sandstorm Trap" );
			return false;
		end

		-- Trapping Attack 2: Snare Trap
		if Helper:CheckAvailable( "Snare Trap" ) and TripeedSeed ~= nil and TripeedSeed:GetAmount() >= 5 then
			Helper:CheckExecute( "Snare Trap" );
			return false;
		end
		
	end
	
	--------------------------------------------------
	--     P R E P A R I N G   A T T A C K (S)      --
	--------------------------------------------------
	
	-- Preparing Attack 1: Mau Form
	if ( Settings.Ranger.AllowMauWhenGrinding or Entity:IsPlayer()) and not Entity:IsDead() and Player:GetDP() >= 2000 and Helper:CheckAvailable( "Mau Form" ) and Player:GetState():GetState( Helper:CheckName( "Mau Form" )) == nil then
		Helper:CheckExecute( "Mau Form" );
		return false;
	end
	
	-- Preparing Attack 1: Aiming/Bestial Fury
	if Player:GetState():GetState( Helper:CheckName( "Aiming" )) == nil and Player:GetState():GetState( Helper:CheckName( "Bestial Fury" )) == nil then
		if Helper:CheckAvailable( "Aiming" ) and AbilityList:GetAbility( Helper:CheckName( "Bestial Fury" )) == nil then
			Helper:CheckExecute( "Aiming" );
			return false;
		elseif Range <= 15 and Helper:CheckAvailable( "Bestial Fury" ) then
			Helper:CheckExecute( "Bestial Fury" );
			return false;
		end
	end
	
	-- Preparing Attack 2: Focused Shots/Strong Shots
	if Player:GetState():GetState( Helper:CheckName( "Focused Shots" )) == nil and Player:GetState():GetState( Helper:CheckName( "Strong Shots" )) == nil then
		if Helper:CheckAvailable( "Focused Shots" ) and Helper:CheckAvailable( "Stunning Shot" ) then
			Helper:CheckExecute( "Focused Shots" );
			return false;
		elseif Helper:CheckAvailable( "Strong Shots" ) and AbilityList:GetAbility( Helper:CheckName( "Focused Shots" )) == nil then
			Helper:CheckExecute( "Strong Shots" );
			return false;
		end
	end
	
	-- Preparing Attack 3: Bow of Blessing
	if Helper:CheckAvailable( "Bow of Blessing" ) then
		Helper:CheckExecute( "Bow of Blessing" );
		return false;
	end
	
	-- Preparing Attack 4: Speed of the Wind/Hunter's Might
	if Helper:CheckAvailable( "Speed of the Wind" ) then
		Helper:CheckExecute( "Speed of the Wind" );
		return false;
	elseif Helper:CheckAvailable( "Hunter's Might" ) then
		Helper:CheckExecute( "Hunter's Might" );
		return false;
	end

	-- Preparing Attack 5: Devotion
	if Helper:CheckAvailable( "Devotion" ) and Helper:CheckAvailable( "Stunning Shot" ) and Helper:CheckAvailable( "Rupture Arrow", true ) then
		Helper:CheckExecute( "Devotion" );
		return false;
	end
	
	-- Preparing Attack 6: Keen Cleverness
	if SkipFocusedEvasion == nil and Helper:CheckAvailable( "Keen Cleverness" ) then
		Helper:CheckExecute( "Keen Cleverness" );
		return false;
	end
	
	--------------------------------------------------
	--     I N I T I A L   A T T A C K (S) (I)      --
	--------------------------------------------------
	
	-- Initial Attack 1: Automatic Attack
	if self.AttackStarted ~= Entity:GetID() then
		self.AttackStarted = Entity:GetID();
		Helper:CheckExecute( "Attack/Chat" );
		return false;
	end
	
	-- Initial Attack 2: Stunning Shot
	if Range <= 22 and Helper:CheckAvailable( "Stunning Shot" ) and ( not Helper:CheckAvailable( "Rupture Arrow", true ) or Player:GetState():GetState( Helper:CheckName( "Devotion" )) ~= nil ) then		
		Helper:CheckExecute( "Stunning Shot" );
		return false;
	end
	
	--------------------------------------------------
	--         G R O U P   A T T A C K (S)          --
	--------------------------------------------------
	
	if Settings.Ranger.AllowAoe then
	
		-- Group Attack 1: Arrow Storm
		if self:CountMobs( Entity, 10 ) > 1 and Helper:CheckAvailable( "Arrow Storm" ) then
			Helper:CheckExecute( "Arrow Storm" );
			return false;
		end
		
		-- Group Attack 1: Arrow Deluge
		if self:CountMobs( Entity, 5 ) > 1 and Helper:CheckAvailable( "Arrow Deluge" ) then
			Helper:CheckExecute( "Arrow Deluge" );
			return false;
		end
		
	end
	
	--------------------------------------------------
	--        N O R M A L   A T T A C K (S)         --
	--------------------------------------------------
	
	-- Normal Attack 1: Entangling Shot
	if Helper:CheckAvailable( "Entangling Shot" ) and Entity:GetState():GetState( Helper:CheckName( "Shackle Arrow" )) == nil and Entity:GetState():GetState( Helper:CheckName( "Shock Arrow" )) == nil and Entity:GetState():GetState( Helper:CheckName( "Entangling Shot" )) == nil then		
		Helper:CheckExecute( "Entangling Shot" );
		return false;
	end
	
	-- Normal Attack 2: Lightning Arrow/Agonizing Arrow
	if Helper:CheckAvailable( "Lightning Arrow" ) and Range <= 15 then
		Helper:CheckExecute( "Lightning Arrow" );
		return false;
	elseif Helper:CheckAvailable( "Agonizing Arrow" ) and Range <= 15 then
		Helper:CheckExecute( "Agonizing Arrow" );
		return false;
	end	
	
	-- Normal Attack 3: Heart Shot/Lethal Arrow
	if Helper:CheckAvailable( "Heart Shot" ) then
		Helper:CheckExecute( "Heart Shot" );
		return false;
	elseif Helper:CheckAvailable( "Lethal Arrow" ) then
		Helper:CheckExecute( "Lethal Arrow" );
		return false;
	end	
	
	-- Normal Attack 4: Gale Arrow/Explosive Arrow
	if Helper:CheckAvailable( "Gale Arrow" ) then
		Helper:CheckExecute( "Gale Arrow" );
		return false;
	elseif Helper:CheckAvailable( "Explosive Arrow" ) then
		Helper:CheckExecute( "Explosive Arrow" );
		return false;
	end	
	
	-- Normal Attack 5: Shackle Arrow
	if Helper:CheckAvailable( "Shackle Arrow" ) and Entity:GetState():GetState( Helper:CheckName( "Shackle Arrow" )) == nil then
		Helper:CheckExecute( "Shackle Arrow" );
		return false;
	elseif Helper:CheckAvailable( "Shock Arrow" ) and Entity:GetState():GetState( Helper:CheckName( "Shock Arrow" )) == nil then
		Helper:CheckExecute( "Shock Arrow" );
		return false;
	end
	
	-- Normal Attack 6: Unerring Arrow
	if Helper:CheckAvailable( "Unerring Arrow" ) then		
		Helper:CheckExecute( "Unerring Arrow" );
		return false;
	end
	
	-- Normal Attack 7: Brightwing Arrow/Darkwing Arrow
	if Helper:CheckAvailable( "Brightwing Arrow" ) then
		Helper:CheckExecute( "Brightwing Arrow" );
		return false;
	elseif Helper:CheckAvailable( "Darkwing Arrow" ) then
		Helper:CheckExecute( "Darkwing Arrow" );
		return false;
	end
	
	--------------------------------------------------
	--     I N I T I A L   A T T A C K (S) (II)     --
	--------------------------------------------------
	
	-- Initial Attack 3: Swift Shot
	if Helper:CheckAvailable( "Swift Shot" ) then
		Helper:CheckExecute( "Swift Shot" );
		return false;
	end
	
	-- Initial Attack 4: Deadshot
	if Helper:CheckAvailable( "Deadshot" ) then
		Helper:CheckExecute( "Deadshot" );
		return false;
	end	

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

	-- Preparing Attack 6: Breath of Nature
	if Helper:CheckAvailable( "Breath of Nature" ) then
		Helper:CheckExecute( "Breath of Nature", Player );
		return false;
	end
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end