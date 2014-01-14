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

--- Returns whether or not the provided entity should be taunted.
--
-- @return	bool

function _Taunt( Entity )

	-- Check whether or not smart taunting should be used.
	if Entity == nil or not Settings.Templar.AllowSmartTaunting then 
		return true;
	end
	
	-- Check whether or not the current target is the same target as before.
	if self.TauntID == nil or self.TauntID ~= Entity:GetID() then
		return true;
	end
	
	-- Check whether or not I am still the target of my own target.
	if Entity:GetTargetID() ~= Player:GetID() then
		return true;
	end
	
	-- No taunting is required.
	return false;
	
end

function HasGreatswordEquipped()
	for Inventory in ListIterator( InventoryList:GetList()) do
		if Inventory:GetType():ToString() == "Weapon2H" and Inventory:GetSlot():ToString() == "3" then -- Main Hand (1) + Off Hand (2) == :)
			return true;
		end
	end
	return false;
end

function IsPvp( Entity )
	if Entity ~= nil and Entity:IsPlayer() and Entity:IsHostile() then
		return true;
	else
		return false;
	end
end

function SkillIsMagical( Entity )

	local Skill = SkillList:GetSkill(Entity:GetSkillID());
	
	if Skill ~= nil and Skill:IsMagical() then
		-- Write ( "Skill is Magical." );
		return true;
	else
		-- Write ( "Skill is NOT Magical." );
		return false;
	end
	
end

function GetBuff()

	-- Loop through the state of the target entity 
	for i = 0, Player:GetState():GetStateSize() - 1, 1 do
	
		-- Retrieve the state from the EntityState.
		local StateIndex = Player:GetState():GetStateIndex( i );

		-- Check if the state is correct and check if it is a debuff.
		if StateIndex ~= nil and StateIndex:IsDebuff() then		
			return true;			
		end
		
	end
	
end

function CountMobs()
	local i = 0;
	
	-- Iterate through all entities
	for ID, Entity in DictionaryIterator( EntityList:GetList()) do
		
		local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());	
		
		-- Add Mob
		if Entity:IsMonster() and Entity:GetHealth() > 0 and Entity:IsHostile() and Range <= 10 then
			i = i + 1;
		end
	
	end
	
	return i;	
end

--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned )
	
	-- Check timer used for Steel Wall Defense and Shield Defense
	if self._iSkillDelay == nil or self._iSkillDelay < Time() then

		--[[ BEGIN STATUS/REACTIVE SKILLS ]]--

		-- Status/Reactive: Remove Shock
		if not Stunned and Helper:CheckAvailable( "Refresh Spirit" ) then
			Helper:CheckExecute( "Refresh Spirit" );
			return false;
		elseif Helper:CheckAvailable( "Ensnaring Blow" ) then
			Helper:CheckExecute( "Ensnaring Blow" );
			return false;
		elseif Helper:CheckAvailable( "Remove Shock" ) then
			Helper:CheckExecute( "Remove Shock" );
			return false;
		end	
		
		-- Status/Reactive: Break Power
		if Helper:CheckAvailable( "Break Power" ) then
			Helper:CheckExecute( "Break Power" );
			return false;
		end
		
		
		-- Status/Reactive: Pitiless Blow
		if Helper:CheckAvailable( "Pitiless Blow" ) then
			Helper:CheckExecute( "Pitiless Blow" );
			return false;
		end
		
		-- Status/Reactive: Face Smash
		if Helper:CheckAvailable( "Face Smash" ) then
			Helper:CheckExecute( "Face Smash" );
			return false;
		end
		
		--[[ END STATUS/REACTIVE SKILLS ]]--

		--[[ BEGIN CHAIN ATTACKS ]]--

		-- Chain: Weakening Severe Blow->Divine Blow->Judgement
		if Helper:CheckAvailable( "Judgment" ) then
			Helper:CheckExecute( "Judgment" );
			return false;
		elseif Helper:CheckAvailable( "Divine Blow" ) then
			Helper:CheckExecute( "Divine Blow" );
			return false;
		end
		--end Chain
		
		-- Chain: Ferocious Strike->Robust Blow->Magic Smash/Wrath Strike
		if Helper:CheckAvailable( "Magic Smash" ) then
			Helper:CheckExecute( "Magic Smash" );
			return false;
		elseif Helper:CheckAvailable( "Wrath Strike" ) then
			Helper:CheckExecute( "Wrath Strike" );
			return false;
		elseif Helper:CheckAvailable( "Robust Blow" ) then
			Helper:CheckExecute( "Robust Blow" );
			return false;
		end
		-- End chain
		
		-- Chain: Ferocious Strike->Rage->Slash Artery
		if Helper:CheckAvailable( "Slash Artery" ) then
			Helper:CheckExecute( "Slash Artery" );
			return false;
		elseif Helper:CheckAvailable( "Rage" ) then
			Helper:CheckExecute( "Rage" );
			return false;
		end
		-- End Chain
		
		
		--[[ END CHAIN ATTACKS ]]--

		--[[ BEGIN BUFFS ]]--

		if Entity ~= nil and not Entity:IsFriendly() then

			-- Divine Fury
			if Range <= 7 and Helper:CheckAvailable( "Divine Fury" ) then
				Helper:CheckExecute( "Divine Fury" );
				return false;
			end
			
			-- Unwavering Devotion
			if self:IsPvp(Entity) and Helper:CheckAvailable( "Unwavering Devotion" ) then
				Helper:CheckExecute( "Unwavering Devotion" );
				return false;
			end
			
			-- Holy Shield
			if Helper:CheckAvailable( "Holy Shield" ) and Range <= 6 then
				Helper:CheckExecute( "Holy Shield" );
				return false;
			end
			
			-- Empyrean Fury I
			if Helper:CheckAvailable( "Empyrean Fury I" ) and Range <= 6 then
				Helper:CheckExecute( "Empyrean Fury I" );
				return false;
			end
			
		end
		
		--[[ END BUFFS ]]--

		--[[ BEGIN LEAD-OFF ATTACKS ]]--

		-- Lead-off 1: Divine Justice
		if not Stunned and Range <= 25 and Helper:CheckAvailable( "Divine Justice" ) then
			Helper:CheckExecute( "Divine Justice" );
			return false;
		end
		
		-- Lead-off 2: Doom Lure
		if Settings.Templar.AllowDoomLure and Range >= 5 and Range <= 17 and Helper:CheckAvailable( "Doom Lure" ) then
			Helper:CheckExecute( "Doom Lure" );
			return false;
		end
		
		-- Lead-off 3: DP Skill Chastisement of Darkness
		if Settings.Templar.AllowDpSkills and not Entity:IsPlayer() and Player:GetDP() >= 2000 then
			if Helper:CheckAvailable( "Chastisement of Darkness" ) then
				Helper:CheckExecute( "Chastisement of Darkness" );
				return false;
			elseif Helper:CheckAvailable( "Divine Chastisement" ) then
				Helper:CheckExecute( "Divine Chastisement" );
				return false; 
			end
		end
		
		--[[ END LEAD-OFF ATTACKS ]]--

		--[[ BEGIN IF ENTITY CASTING SKILLS ]]--

		-- Entity Casting: Aether Armor.
		if self:IsPvp( Entity ) and Entity:IsBusy() and self:SkillIsMagical( Entity ) and Helper:CheckAvailable( "Aether Armor" ) then
			Helper:CheckExecute( "Aether Armor" );
			return false;
		end
		
		-- Check if we are wielding a shield, which allows different skills.
		if not self:HasGreatswordEquipped() and Entity:IsBusy() and Entity:GetSkillTime() > 1 then
		
			-- Attack 12: Shield Bash
			if Helper:CheckAvailable( "Shield Bash" ) then
				Helper:CheckExecute( "Shield Bash" );
				return false;
			-- Shield Defense
			elseif not self:SkillIsMagical( Entity ) then
				if Helper:CheckAvailable( "Steel Wall Defense" ) then
					Helper:CheckExecute( "Steel Wall Defense" );
					self._bDefenseEnabled = true;
					self._iSkillDelay = Time() + Entity:GetSkillTime() + 1000;
					return false;
				elseif Helper:CheckAvailable( "Shield Defense" ) then
					Helper:CheckExecute( "Steel Wall Defense" );
					self._bDefenseEnabled = true;
					self._iSkillDelay = Time() + Entity:GetSkillTime() + 1000;
					return false;
				else
					self._bDefenseEnabled = false;
				end
			end
		
		end
		
		--[[ END ENTITY CASTING SKILLS ]]--

		--[[ BEGIN SHIELD SKILLS AFTER BLOCK ]]--

		-- Check if we are wielding a shield, which allows different skills.
		if not self:HasGreatswordEquipped() then
		
			-- Reactive Block: Shield Retribution
			if Helper:CheckAvailable( "Shield Retribution" ) then
				Helper:CheckExecute( "Shield Retribution" );
				return false;
			end
			
			-- Reactive Block: Avenging Blow
			if Helper:CheckAvailable( "Avenging Blow" ) then
				Helper:CheckExecute( "Avenging Blow" );
				return false;
			end
			
			-- Reactive Block: Provoking Shield Counter
			if Helper:CheckAvailable( "Provoking Shield Counter" ) then
				Helper:CheckExecute( "Provoking Shield Counter" );
				return false;
			end
			
			-- Reactive Block: Provoking Shield Counter (Pre-level 51 skill).
			if Helper:CheckAvailable( "Provoking Shield Counter IV" ) then
				Helper:CheckExecute( "Provoking Shield Counter IV" );
				return false;
			elseif Helper:CheckAvailable( "Provoking Shield Counter III" ) then
				Helper:CheckExecute( "Provoking Shield Counter III" );
				return false;
			elseif Helper:CheckAvailable( "Provoking Shield Counter II" ) then
				Helper:CheckExecute( "Provoking Shield Counter II" );
				return false;
			elseif Helper:CheckAvailable( "Provoking Shield Counter I" ) then
				Helper:CheckExecute( "Provoking Shield Counter I" );
				return false;
			end
			
			-- Reactive Block: Shield Counter
			if not Stunned and Helper:CheckAvailable( "Shield Counter" ) then
				Helper:CheckExecute( "Shield Counter" );
				return false;
			end
			
		end
			
		--[[ END SHIELD SKILLS AFTER BLOCK ]]--

		--[[ BEGIN TAUNTING SKILLS ]]--		
		
		if Settings.Templar.AllowTaunting then
			if self:_Taunt( Entity ) then
				if Helper:CheckAvailable( "Taunt" ) and Helper:CheckExecute( "Taunt" ) then
					self.TauntID = Entity:GetID();
					return false;
				end
				-- Incite Rage
				if Helper:CheckAvailable( "Incite Rage" ) and Helper:CheckExecute( "Incite Rage" ) then
					self.TauntID = Entity:GetID();
					return false;
				end				
			end	
			
			-- Taunting - AOE Taunt
			if Helper:CheckAvailable( "Cry of Ridicule" ) and self:CountMobs() > 1 then
				Helper:CheckExecute( "Cry of Ridicule" );
				return false;
			end
		end
		
		--[[ END TAUNTING SKILLS ]]--	

		-- Initial Attack 1: Automatic Attack
		if self.AttackStarted ~= Entity:GetID() then
			self.AttackStarted = Entity:GetID();
			Helper:CheckExecute( "Attack/Chat" );
			return false;
		end
	
		--[[ BEGIN ATTACK SKILLS ]]--
						
		-- Chain 1 Attack: Weakening Severe Blow
		if Helper:CheckAvailable( "Weakening Severe Blow" ) then
			self.FerociousTrigger = true;
			Helper:CheckExecute( "Weakening Severe Blow" );
			return false;
		end
		
		-- Attack 4: Punishment (Doing each level check due to a similarly named NPC skill)
		if self:HasGreatswordEquipped() then
			if Helper:CheckAvailable( "Punishment V" ) then
				Helper:CheckExecute( "Punishment V" );
				return false;
			elseif Helper:CheckAvailable( "Punishment IV" ) then
				Helper:CheckExecute( "Punishment IV" );
				return false;
			elseif Helper:CheckAvailable( "Punishment III" ) then
				Helper:CheckExecute( "Punishment III" );
				return false;
			elseif Helper:CheckAvailable( "Punishment II" ) then
				Helper:CheckExecute( "Punishment II" );
				return false;
			elseif Helper:CheckAvailable( "Punishment I" ) then
				Helper:CheckExecute( "Punishment I" );
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
		
		-- Attack 11: Righteous Punishment
		if Helper:CheckAvailable( "Righteous Punishment" ) then
			Helper:CheckExecute( "Righteous Punishment" );
			return false;
		elseif Helper:CheckAvailable( "Holy Punishment" ) then
		    Helper:CheckExecute( "Holy Punishment" );
			return false;
		end
				
		-- Attack 10: Shining Slash
		if Helper:CheckAvailable( "Shining Slash" ) then
			Helper:CheckExecute( "Shining Slash" );
			return false;
		end
		
		-- Attack 9: Provoking Severe Blow
		if Helper:CheckAvailable( "Provoking Severe Blow" ) then
			Helper:CheckExecute( "Provoking Severe Blow" );
			return false;
		end
		
		-- Attack 14: Siegebreaker
		if Helper:CheckAvailable( "Siegebreaker" ) then
			Helper:CheckExecute( "Siegebreaker" );
			return false;
		end
		
		--[[ END ATTACK SKILLS ]]--

	end
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end


function Force()
	if self._bDefenseEnabled ~= nil then
		if Helper:CheckAvailable( "Steel Wall Defense" ) then
			Helper:CheckExecute( "Steel Wall Defense" );
			return false;
		elseif Helper:CheckAvailable( "Shield Defense" ) then
			Helper:CheckExecute( "Shield Defense" );
			return false;
		else
			self._bDefenseEnabled = nil;
		end
	end
	return true;
end

--- Perform healing checks both in and our of combat.
--
-- @param	bool	Indicates whether or not the function is running before force checks.
-- @return	bool

function Heal( BeforeForce )

	-- Defense 1: Empyrean Armor
	if Helper:CheckAvailable( "Empyrean Armor" )  and Player:GetHealth() <= 75 then
		Helper:CheckExecute( "Empyrean Armor" );
		return false;
	end
	
	-- Defense 2: Iron Skin
	if Helper:CheckAvailable( "Iron Skin" )  and Player:GetHealth() <= 50 then
		Helper:CheckExecute( "Iron Skin" );
		return false;
	end
	
	-- Health Recover: Prayer of Resilience
	if Player:GetHealth() <= 55 and Helper:CheckAvailable( "Prayer of Resilience" ) then
		Helper:CheckExecute( "Prayer of Resilience" );
		return false;
	end
	
	-- Health Recover: Hand of Healing
	local Entity = EntityList:GetEntity( Player:GetTargetID());
	if Entity ~= nil and Helper:CheckAvailable( "Hand of Healing" ) then
		if Entity:IsPlayer() and Entity:IsHostile() and Player:GetDP() >= 3000 and Player:GetHealth() <= 25 then
			Helper:CheckExecute( "Hand of Healing" );
			return false;
		elseif Entity:IsPlayer() and Entity:IsHostile() and Player:GetDP() >= 1000 and Player:GetHealth() <= 50 and Helper:CheckAvailableInventory( "Zeller Aether Jelly" ) then
			PlayerInput:Inventory( "Zeller Aether Jelly" );
			return false;
		elseif Entity:IsPlayer() and Entity:IsHostile() and Player:GetHealth() <= 50 and Helper:CheckAvailableInventory( "Cippo Aether Jelly" ) then
			PlayerInput:Inventory( "Cippo Aether Jelly" );
			return false;
		end
	end
	
--[[ Check Buff State
	if self:GetBuff() then
		if Helper:CheckAvailableInventory( "Greater Healing Potion" ) then
			PlayerInput:Inventory( "Greater Healing Potion" );
			return false;
		end
	end ]]--
	
	-- List of known Items
	-- 10044 = Major Rally Serum
	-- 10051 = Major Focus Agent
	-- 10224 = Wild Ginseng Pickle
	-- 10225 = Tasty Wild Ginseng Pickle
	-- 10094 = Tasty Leopis Cocktail
	-- 10062 = Leopis Cocktail
	
	-- Use Liquid Item
	
	if Entity ~= nil and Entity:IsHostile() and Helper:CheckAvailableInventory( "Leopis Cocktail" ) and Player:GetState():GetState(10062) == nil then
		PlayerInput:Inventory( "Leopis Cocktail" );
		return false;
	end
	
	-- Use Food Item
	
	if Entity ~= nil and Entity:IsHostile() and Helper:CheckAvailableInventory( "Wild Ginseng Pickle" ) and Player:GetState():GetState(10224) == nil then
		PlayerInput:Inventory( "Wild Ginseng Pickle" );
		return false;
	end
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end

--- Perform the special routine when the target entity is currently reflecting attacks.
--
-- @param	Entity	Contains the entity that is reflecting our attacks (may not be targetted).
-- @return bool

function Reflect( Entity )

	-- Taunting - Taunt and Incite Rage
	if Settings.Templar.AllowTaunting and self:_Taunt( Entity ) then
		if Helper:CheckAvailable( "Taunt" ) and Helper:CheckExecute( "Taunt" ) then
			self.TauntID = Entity:GetID();
			return false;
		end
		
		if Helper:CheckAvailable( "Incite Rage" ) and Helper:CheckExecute( "Incite Rage" ) then
			self.TauntID = Entity:GetID();
			return false;
		end
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