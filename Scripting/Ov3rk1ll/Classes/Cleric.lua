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
		
--- (Private Function) Checks the healing requirements for the provided entity.
--
-- @param	Entity	Contains the entity to perform healing on.
-- @param	double	Contains the 
-- @return	bool

function _CheckHeal( Entity )

	-- Retrieve the range of the entity compared to my own character position.
	local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());
	
	-- Check if this routine is allowed to be ran under the current circumstances.
	if Entity:IsDead() or ( not Settings.Cleric.AllowApproach and Range > 23 ) then
		return true;
	end

	-- Check if the entity requires healing and perform the correct healing routine.
	if Entity:GetHealth() < 80 and ( Settings.Cleric.AllowApproach or Range <= 23 ) then
	
		-- Retrieve the local target for certain checks.
		local Target = EntityList:GetEntity( Player:GetTargetID());
		
		-- Change the healing routine if I'm healing myself when allowed to attack.
		if Entity:GetID() == Player:GetID() and Settings.Cleric.AllowAttack then -- and Target ~= nil and not Target:IsDead() then
			if Entity:GetHealth() < 25 and Helper:CheckAvailable( "Flash of Recovery" ) then
				Helper:CheckExecute( "Flash of Recovery", Entity );
				return false;
			elseif Entity:GetHealth() < 35 and Helper:CheckAvailable( "Light of Recovery" ) then
				Helper:CheckExecute( "Light of Recovery", Entity );
				return false;
			elseif Entity:GetHealth() < 50 and Helper:CheckAvailable( "Healing Light" ) then
				Helper:CheckExecute( "Healing Light", Entity );
				return false;
			end
		-- Check if we should flash the provided entity.
		elseif Entity:GetHealth() < 50 and Helper:CheckAvailable( "Flash of Recovery" ) then
			Helper:CheckExecute( "Flash of Recovery", Entity );
			return false;
		-- Check if we should heal the provided entity more quickly.
		elseif Entity:GetHealth() < 70 and Helper:CheckAvailable( "Light of Recovery" ) then
			Helper:CheckExecute( "Light of Recovery", Entity );
			return false;
		-- Check if we should heal the provided entity.
		elseif Helper:CheckAvailable( "Healing Light" ) then
			Helper:CheckExecute( "Healing Light", Entity );
			return false;
		end
		
	end
	
	-- Return true to let the caller know this function completed.
	return true;
	
end

--- Checks if the state of the provided entity.
--
-- @param	Entity	Contains the entity to check.
-- @return	bool

function _CheckState( Entity )

	-- Retrieve the range of the entity compared to my own character position.
	local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());
	
	-- Check if this routine is allowed to be ran under the current circumstances.
	if Entity:IsDead() or ( not Settings.Cleric.AllowApproach and Range > 23 ) then
		return true;
	end

	-- Retrieve the state for the current entity to inspect.
	local EntityState = Entity:GetState();
	
	-- Loop through the states only when we are available to dispel them. We still check for removed states!
	if EntityState ~= nil and ( self.StateDispelTime == nil or self.StateDispelTime < Time()) then
		
		-- Create the state array for the global entity storage and undispellable states if it does not exist.
		if self.StateArray == nil or self.StateUndispellable == nil then
			self.StateArray = {};
			self.StateUndispellable = {};
		end
		
		-- Create the state array for the current entity if it does not exist.
		if self.StateArray[Entity:GetID()] == nil then
			self.StateArray[Entity:GetID()] = {};
		end
		
		-- Loop through the states to find which need to be removed.
		for ID, Skill in DictionaryIterator( EntityState:GetList()) do
		
			-- Check if the current skill is valid and has not been marked and undispellable.
			if Skill ~= nil and Skill:IsDebuff() and ( self.StateUndispellable[Skill:GetID()] == nil or self.StateUndispellable[Skill:GetID()] < Time()) then
			
				-- Check if this entity had the current skill effect on him and hasn't been removed by either Cure Mind or Dispel.
				if self.StateArray[Entity:GetID()][Skill:GetID()] ~= nil and self.StateArray[Entity:GetID()][Skill:GetID()] == 2 then
					self.StateUndispellable[Skill:GetID()] = Time() + 30000;
				-- Remove the state from the entity.
				else
			
					-- Retrieve the magical state the current skill.
					local RemoveMagical = Skill:IsMagical();
					
					-- Check if we are required to change the magical state for the current skill.
					if self.StateArray[Entity:GetID()][Skill:GetID()] ~= nil then
						RemoveMagical = not RemoveMagical;
					end
					
					-- Check if the dispel or cure mind can be executed correctly. The function might need to set the target first!
					if ( RemoveMagical and Helper:CheckExecute( "Cure Mind", Entity )) or ( not RemoveMagical and Helper:CheckExecute( "Dispel", Entity )) then
					
						-- Change the state dispel timer to prevent dispel and cure mind from being used too quickly.
						self.StateDispelTime = Time() + 500;
						
						-- Track the current state of the dispel and cure mind to find undispellable states.
						if self.StateArray[Entity:GetID()][Skill:GetID()] == nil then
							self.StateArray[Entity:GetID()][Skill:GetID()] = 1;
							return false;
						else
							self.StateArray[Entity:GetID()][Skill:GetID()] = 2;
							return false;
						end
						
					end

				end
				
			end
			
		end
		
		-- Loop through the existing states to find which have been removed correctly.
		for k,v in pairs( self.StateArray[Entity:GetID()] ) do
			if v ~= nil and EntityState:GetState( k ) == nil then
				self.StateArray[Entity:GetID()][k] = nil;
			end
		end
		
	end
	
	-- Return true to let the caller know this function completed.
	return true;
	
end

--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned )
	
	-- Indicates whether or not attacks are allowed for a Cleric. Extra toggle to allow features such as follow-mode support.
	if Settings.Cleric.AllowAttack then
	
		-- Check if the target is not attacking us and attack only with a servant.
		if Settings.Cleric.AllowAttackDelay and ( self._DelayEntityId == nil or self._DelayEntityId ~= Entity:GetID()) and not Helper:CheckAvailable( "Summon Holy Servant" ) then
			return true;
		end
		
		-- Chain 1: Punishing Earth/Smite
		if Helper:CheckAvailable( "Thunderbolt" ) then
			Helper:CheckExecute( "Thunderbolt" );
			return false;
		elseif Helper:CheckAvailable( "Divine Spark" ) then
			Helper:CheckExecute( "Divine Spark" );
			return false;
		end
		
		-- Chain 2: Punishing Wind/Hallowed Strike
		if Helper:CheckAvailable( "Infernal Blaze" ) then
			Helper:CheckExecute( "Infernal Blaze" );
			return false;
		elseif Helper:CheckAvailable( "Divine Touch" ) then
			Helper:CheckExecute( "Divine Touch" );
			return false;
		end
		
		-- Attack 1: Summon Noble Energy
		if Helper:CheckAvailable( "Summon Noble Energy" ) then
			Helper:CheckExecute( "Summon Noble Energy" );
			return false;
		end
		
		-- Attack 2: Summon Holy Servant
		if Helper:CheckAvailable( "Summon Holy Servant" ) then
			Helper:CheckExecute( "Summon Holy Servant" );
			self._DelayEntityId = Entity:GetID();
			return false;
		end
		
		-- Heal 1: Summon Healing Servant
		if Settings.Cleric.AllowHealing and Helper:CheckAvailable( "Summon Healing Servant" ) then
			Helper:CheckExecute( "Summon Healing Servant" );
			return false;
		end
		
		-- Chain 1: Punishing Earth
		if Helper:CheckAvailable( "Punishing Earth" ) then
			Helper:CheckExecute( "Punishing Earth" );
			return false;
		-- Chain 1: Smite (Thunderbolt related!)
		elseif Helper:CheckAvailable( "Thunderbolt" ) and Helper:CheckAvailable( "Smite" ) then
			Helper:CheckExecute( "Smite" );
			return false;
		end
		
		-- Chain 2: Punishing Wind
		if Helper:CheckAvailable( "Punishing Wind" ) then
			Helper:CheckExecute( "Punishing Wind" );
			return false;
		elseif Helper:CheckAvailable( "Slashing Wind" ) then
			Helper:CheckExecute( "Slashing Wind" );
			return false;
		end
		
		-- Check if high mana consumption skills are allowed.
		if Settings.Cleric.AllowAttackMana then
			-- Attack 5: Call Lightning
			if Helper:CheckAvailable( "Call Lightning" ) then
				Helper:CheckExecute( "Call Lightning" );
				return false;
			end
			
			-- Attack 6: Enfeebling Burst
			if Helper:CheckAvailable( "Enfeebling Burst" ) then
				Helper:CheckExecute( "Enfeebling Burst" );
				return false;
			end
		end
		
		-- Attack 3: Earth's Wrath
		if Helper:CheckAvailable( "Earth's Wrath" ) then
			Helper:CheckExecute( "Earth's Wrath" );
			return false;
		end
		
		-- Attack 4: Chastise
		if Helper:CheckAvailable( "Chastise" ) then
			Helper:CheckExecute( "Chastise" );
			return false;
		end

		-- Attack 5: Storm of Aion
		if Helper:CheckAvailable( "Storm of Aion" ) then
			Helper:CheckExecute( "Storm of Aion" );
			return false;
		end
		
		-- Chain 2: Hallowed Strike (Lower Form)
		if Helper:CheckAvailable( "Hallowed Strike" ) and ( Settings.Cleric.AllowApproach or Range < 4 ) then
			Helper:CheckExecute( "Hallowed Strike" );
			return false;
		end
		
		-- Chain 1: Smite (Lower Form)
		if Helper:CheckAvailable( "Smite" ) then
			Helper:CheckExecute( "Smite" );
			return false;
		end

	end
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end

--- Perform healing checks both in and out of combat.
--
-- @param	bool	Indicates whether or not the function is running before force checks.
-- @return	bool

function Heal( BeforeForce )

	-- Check if my own character has state modifications that need to be removed.
	if BeforeForce and not self:_CheckState( Player ) then
		return false;
	end

	-- Check if we are allowed to execute our healing routines, before checking the Force we check our MP.
	if BeforeForce and Settings.Cleric.AllowHealing then
	
		-- Check if we have a pending Flash of Recovery, which happens directly after Reverse Condition.
		if self.PerformFlash ~= nil and Helper:CheckAvailable( "Flash of Recovery" ) and Helper:CheckExecute( "Flash of Recovery", Player ) then
			self.PerformFlash = nil;
			return false;
		end
		
		-- Check if we have a pending Light of Rejuvenation, which happens directly after Penance.
		if self.PerformRejuvenation ~= nil and Helper:CheckAvailable( "Light of Rejuvenation" ) and Helper:CheckExecute( "Light of Rejuvenation", Player ) then
			self.PerformRejuvenation = nil
			return false;
		end
		
		-- Check if we have enough capacity to contain mana to enable penance.
		if ( Player:GetManaMaximum() - Player:GetManaCurrent()) >= 2150 and Helper:CheckAvailable( "Penance" ) and Helper:CheckAvailable( "Light of Rejuvenation" ) then
			Helper:CheckExecute( "Penance" );
			self.PerformRejuvenation = true;
			return false;
		end
		
		-- Check if we have nearly run out of mana and reverse our condition when this is the case.
		if Player:GetManaCurrent() < 1000 and Helper:CheckAvailable( "Reverse Condition" ) and Helper:CheckAvailable( "Flash of Recovery" ) then
			Helper:CheckExecute( "Reverse Condition" );
			self.PerformFlash = true;
			return false;
		end
						
	end
	
	if BeforeForce and Settings.Cleric.AllowBuff and ( self.StateBuffTime == nil or self.StateBuffTime < Time()) then

		local EntityState = Player:GetState();

		if EntityState ~= nil then
		
			-- Check if this entity has the Blessing of Health state.
			if Helper:CheckAvailable( "Blessing of Health I" ) and EntityState:GetState( "Blessing of Health I" ) == nil and EntityState:GetState( "Blessing of Health II" ) == nil then
				Helper:CheckExecute( "Blessing of Health", Player );
				return false;
			end
			
			-- Check if this entity has the Blessing of Rock state.
			if Helper:CheckAvailable( "Blessing of Rock I" ) and EntityState:GetState( "Blessing of Rock I" ) == nil and EntityState:GetState( "Blessing of Stone I" ) == nil then
				Helper:CheckExecute( "Blessing of Rock", Player );
				return false;
			end
			
			-- Check if this entity has the Promise of Wind state.
			if Helper:CheckAvailable( "Promise of Wind" ) and EntityState:GetState( Helper:CheckName( "Promise of Wind" )) == nil then
				Helper:CheckExecute( "Promise of Wind", Player );
				return false;
			end
			
			-- Check if AllowSummerCircleBuff is set and if entity needs Summer Circle State
			if Settings.Cleric.AllowSummerCircleBuff and Helper:CheckAvailable( "Summer Circle" ) and EntityState:GetState( Helper:CheckName( "Summer Circle" )) == nil then
				Helper:CheckExecute( "Summer Circle", Player );
				return false;
			end
			
			-- Check if AllowWinterCircleBuff is set and if entity needs Winter Circle State
			if not Settings.Cleric.AllowSummerCircleBuff and Settings.Cleric.AllowWinterCircleBuff and Helper:CheckAvailable( "Winter Circle" ) and EntityState:GetState( Helper:CheckName( "Winter Circle" )) == nil then
				Helper:CheckExecute( "Winter Circle", Player );
				return false;
			end
			
			-- Check if AllowRebirth and if this entity has the Rebirth state.
			if Settings.Cleric.AllowRebirth and Helper:CheckAvailable( "Rebirth I" ) and EntityState:GetState( "Rebirth I" ) == nil then
				Helper:CheckExecute( "Rebirth I", Player );
				return false;
			end
			
		end
		
	end
		
	-- Check if we are allowed to execute our healing routines, after checking the force we can check our own HP.
	if not BeforeForce and Settings.Cleric.AllowHealing then
	
		-- Check the required direct healing for my own character.
		if not self:_CheckHeal( Player ) then
			return false;
		end
				
	end
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end

--- Perform the required force checks.
--
-- @return	void

function Force()

	--[[
	Step #1 - Prioritize the force members/spirits based on the target's target.
	Step #2 - Check the states of the prioritized force members/spirits (Dispel/Cure Mind).
	Step #3 - Check the states of the non-prioritized force members (Dispel/Cure Mind).
	Step #4 - (AllowHealing) Check the required healing of the prioritized force members/spirits.
	Step #5 - (AllowHealing) Check if multiple force members are required to be healed.
	Step #6 - (AllowHealing) Check the required healing of the non-prioritized force members.
	Step #7 - (AllowHealing) Check if the prioritized force members/spirits require healing over time.
	Step #8 - (AllowBuff) Check the positive state of the prioritized force members/spirits.
	Step #9 - (AllowBuff) Check the positive state of the non-prioritized force members.
	]]--
	
	-- Contains the amount of force members that would benefit from a group heal.
	local GroupCount = 0;
	
	-- Contains a list of entities that have been targeted by group members.
	local PriorityList = {};
	
	-- Contains a list of entities that should be checked for required healing.
	local PriorityListHeal = {};

	-- Contains the entity belonging to a possible master to assist.
	local MasterEntity = EntityList:GetEntity( Settings.MasterName );
	
	-- Step #1 - Prioritize the force members/spirits based on the target's target.
	for ID, Force in DictionaryIterator( ForceList:GetList()) do
		
		-- Retrieve the entity for the current force member.
		local Entity = EntityList:GetEntity( Force:GetID());
		
		-- Check if the entity is available and is not dead.
		if Entity ~= nil and not Entity:IsDead() then
		
			-- Check if the current force member has selected an entity.
			if Entity:GetTargetID() ~= 0 then
				PriorityList[Entity:GetTargetID()] = true;
			end
			
			-- Check if the current force member would benefit from a group heal.
			if Settings.Cleric.AllowHealing and Player:GetPosition():DistanceToPosition( Entity:GetPosition()) < 25 and ( Entity:GetHealthMaximum() - Entity:GetHealthCurrent()) >= 2300 then
				GroupCount = GroupCount + 1;
			end
			
		end
		
	end

	-- Check the states of the master entity and add it to the priority healing list to enable further checks.
	if MasterEntity ~= nil and not MasterEntity:IsDead() then
		if not self:_CheckState( MasterEntity ) then
			return false;
		else
			PriorityListHeal[MasterEntity:GetID()] = MasterEntity;
		end
	end
	
	-- Step #2 - Check the states of the prioritized force members/spirits (Dispel/Cure Mind).
	for k,v in pairs( PriorityList ) do
	
		-- Retrieve the entity for the current index.
		local Entity = EntityList:GetEntity( k );
		
		-- Check if the entity has been found and is not friendly or dead.
		if Entity ~= nil and not Entity:IsFriendly() and not Entity:IsDead() then
		
			-- Retrieve the entity for the target of the current entity.
			Entity = EntityList:GetEntity( Entity:GetTargetID());
			
			-- Check if the target entity has been found and is either a group member or a summoned entity that belongs to a group member.
			if Entity ~= nil and not Entity:IsDead() and (( Entity:GetOwnerID() ~= 0 and ForceList:GetForce( Entity:GetOwnerID()) ~= nil ) or ForceList:GetForce( Entity:GetID()) ~= nil ) then 
			
				-- Check if the current entity is a summoned entity and if it has state modifications that need to be removed.
				if not self:_CheckState( Entity ) then
					return false;
				end
				
				-- Add the current entity into the healing priority list to handle after checking spirit states.
				if Settings.Cleric.AllowHealing then
					PriorityListHeal[Entity:GetID()] = Entity;
				end
				
			end
			
		end
		
	end

	-- Step #3 - Check the states of the non-prioritized force members (Dispel/Cure Mind).
	for ID, Force in DictionaryIterator( ForceList:GetList()) do
		
		-- Retrieve the entity for the current force member.
		local Entity = EntityList:GetEntity( Force:GetID());
		
		-- Check if the current force members has state modifications that need to be removed.
		if Entity ~= nil and PriorityList[Entity:GetID()] ~= nil and not self:_CheckState( Entity ) then
			return false;
		end
		
	end
		
	-- Check if we are allowed to run the healing-orientated routines.
	if Settings.Cleric.AllowHealing then
	
		-- Retrieve the target entity.
		local TargetEntity = EntityList:GetEntity( Player:GetTargetID());
		
		-- Check if we can summon a healing servant and summon it when we can.
		if ( not Settings.AllowAttack or not Settings.Cleric.AllowAttack or TargetEntity == nil or not TargetEntity:IsHostile()) and Helper:CheckAvailable( "Summon Healing Servant" ) then
			Helper:CheckExecute( "Summon Healing Servant" );
			return false;
		end
		
		-- Step #4 - Check the required healing of the prioritized force members/spirits.
		for k,v in pairs( PriorityListHeal ) do

			-- Check the required direct healing for this force members/spirits.
			if not self:_CheckHeal( v ) then
				return false;
			end
			
		end
		
		-- Step #5 - Check if multiple force members are required to be healed.
		if Helper:CheckAvailable( "Splendor of Recovery" ) and GroupCount >= 2 then
			Helper:CheckExecute( "Splendor of Recovery" );
			return false;
		end
		
		-- Step #6 - Check the required healing of the non-prioritized force members.
		for ID, Force in DictionaryIterator( ForceList:GetList()) do
			
			-- Check if the current force member has already been checked through the priorities.
			if PriorityListHeal[Force:GetID()] == nil then
			
				-- Get the entity from the EntityList.
				local Entity = EntityList:GetEntity( Force:GetID());
				
				-- Check the required direct healing for this force member.
				if Entity ~= nil and not self:_CheckHeal( Entity ) then
					return false;
				end
			
			end
			
		end
				
		-- Step #7 - Check if the prioritized force members/spirits require healing over time.
		if Settings.Cleric.AllowBuff and ( self.StateBuffTime == nil or self.StateBuffTime < Time()) then
			
			-- Loop through the prioritized force members/spirits to check the required healing over time spells.
			for k,v in pairs( PriorityListHeal ) do
				
				-- Retrieve the entity state for this entity.
				local EntityState = v:GetState();
				
				-- Retrieve the range to this entity to check if the entity is in range to use a heal-over-time ability.
				local Range = Player:GetPosition():DistanceToPosition( v:GetPosition());
				
				-- Check the validity of the entity state and the range of the entity.
				if EntityState ~= nil and ( Settings.Cleric.AllowApproach or Range < 25 ) then
				
					-- Check if should give the current entity the Splendor of Rebirth heal-over-time.
					if Helper:CheckAvailable( "Splendor of Rebirth" ) and EntityState:GetState( Helper:CheckName( "Splendor of Rebirth" )) == nil then
						Helper:CheckExecute( "Splendor of Rebirth", v );
						return false;
					end
					
					-- Check if should give the current entity the Light of Rejuvenation heal-over-time.
					if v:GetHealth() < 95 and Helper:CheckAvailable( "Light of Rejuvenation" ) and EntityState:GetState( Helper:CheckName( "Light of Rejuvenation" )) == nil then
						Helper:CheckExecute( "Light of Rejuvenation", v );
						return false;
					end
					
				end
				
			end
			
		end
		
		-- Check if we should recharge some of our mana using Mana Treatment.
		--if not Settings.Cleric.AllowAttack and Helper:CheckAvailable( "Mana Treatment" ) and Player:GetManaMaximum() - Player:GetManaCurrent() >= 700 then
		--	Helper:CheckExecute( "Mana Treatment" );
		--	return false;
		--end
	
	end
	
	-- Check if we are allowed to buff and perform the routine when required.
	if Settings.Cleric.AllowBuff and Settings.Cleric.AllowBuffForce and ( self.StateBuffTime == nil or self.StateBuffTime < Time()) then
	
		-- Step #8 - Check the positive state of the prioritized force members/spirits.
		for k,v in pairs( PriorityListHeal ) do

			-- Retrieve the entity state for this entity.
			local EntityState = v:GetState();

			-- Retrieve the range to this entity to check if the entity is in range to use a heal-over-time ability.
			local Range = Player:GetPosition():DistanceToPosition( v:GetPosition());

			-- Check the validity of the entity state and the range of the entity.
			if EntityState ~= nil and ( Settings.Cleric.AllowApproach or Range < 25 ) then
					
				-- Check if this entity has the Blessing of Health state.
				if Helper:CheckAvailable( "Blessing of Health I" ) and EntityState:GetState( "Blessing of Health I" ) == nil and EntityState:GetState( "Blessing of Health II" ) == nil then
					Helper:CheckExecute( "Blessing of Health", v );
					return false;
				end
				
				-- Check if this entity has the Blessing of Rock state.
				if Helper:CheckAvailable( "Blessing of Rock I" ) and EntityState:GetState( "Blessing of Rock I" ) == nil and EntityState:GetState( "Blessing of Stone I" ) == nil then
					Helper:CheckExecute( "Blessing of Rock", v );
					return false;
				end
		
			end
			
		end
				
		-- Step #9 - (AllowBuff) Check the positive state of the non-prioritized force members.
		for ID, Force in DictionaryIterator( ForceList:GetList()) do
			
			-- Check if the current force member has already been checked through the priorities.
			if PriorityListHeal[Force:GetID()] == nil then
			
				-- Get the entity from the EntityList.
				local Entity = EntityList:GetEntity( Force:GetID());
				
				-- Check the vailidity of the retrieved entity.
				if Entity ~= nil and not Entity:IsDead() then
				
					-- Retrieve the entity state for this entity.
					local EntityState = Entity:GetState();
			
					-- Retrieve the range to this entity to check if the entity is in range to use a heal-over-time ability.
					local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());

					-- Check the validity of the entity state and the range of the entity.
					if EntityState ~= nil and ( Settings.Cleric.AllowApproach or Range < 25 ) then
								
						-- Check if this entity has the Blessing of Health state.
						if Helper:CheckAvailable( "Blessing of Health I" ) and EntityState:GetState( "Blessing of Health I" ) == nil and EntityState:GetState( "Blessing of Health II" ) == nil then
							Helper:CheckExecute( "Blessing of Health", Entity );
							return false;
						end
						
						-- Check if this entity has the Blessing of Rock state.
						if Helper:CheckAvailable( "Blessing of Rock I" ) and EntityState:GetState( "Blessing of Rock I" ) == nil and EntityState:GetState( "Blessing of Stone I" ) == nil then
							Helper:CheckExecute( "Blessing of Rock", Entity );
							return false;
						end
				
					end
					
				end
				
				-- Check the required direct healing for this force member.
				if Entity ~= nil and not self:_CheckHeal( Entity ) then
					return false;
				end
			
			end
			
		end
		
		-- Increment the state timer to postpone additional checks.
		self.StateBuffTime = Time() + 2000;
		
	end
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end

--- Perform the required pause checks.
--
-- @return	bool

function Pause()

	-- Nothing was executed, continue with other functions.
	return true;
	
end