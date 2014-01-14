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

--- Find the spirit that belongs to the provided player.
--
-- @param	Integer Contains the player identifier.
-- @return	Entity

function FindSpirit( ID )

	-- Check the provided identifier to look for, otherwise use my own identifier.
	if ID == nil then
		ID = Player:GetID();
	end
	
	-- Loop through the available entities to find the spirit.
	for EntityID, Entity in DictionaryIterator( EntityList:GetList()) do
		-- Check if this monster is a spirit and belongs to me!
		if Entity:GetOwnerID() == ID and string.find( Entity:GetName(), "Spirit" ) ~= nil then
			return Entity;	
		end
	end

	-- Return nothing, the spirit has not been found.
	return nil;
	
end

--- Perform the attack routine on the selected target.
--
-- @param Entity Contains the target entity.
-- @param Range Contains the range to the target entity. 
-- @param IsStunned Indicates whether the target entity is stunned.
-- @param IsAttackOnly Indicates whether the script is running as attack-only.
-- @return Indicates whether other functions can continue running.

function Attack( Entity, Range, IsStunned, IsAttackOnly )

	-- Curse of Water
	-- Dispel Magic (Enemy has states!)
	-- Fear
	-- Sandblaster (AOE, Long Duration)
	-- Spirit Wrath Position (Shield)
		
	-- Retrieve the entity state of the target.
	local EntityState = Entity:GetState();
	
	-- Retrieve the entity of the summoned spirit.
	local SpiritEntity = self:FindSpirit();
	
	-- Check if the player spirit is valid.
	if SpiritEntity == nil and not IsAttackOnly then
		
		-- Buff 01: Summoning Alacrity
		if Helper:CheckAvailable( "Summoning Alacrity" ) then
			Helper:CheckExecute( "Summoning Alacrity" );
			return false;
		end
	
		-- Summon 1: Summon Earth Spirit
		if Helper:CheckAvailable( "Summon Earth Spirit" ) then
			Helper:CheckExecute( "Summon Earth Spirit" );
			return false;
		-- Summon 2: Summon Fire Spirit (For Level 10-13).
		elseif Helper:CheckAvailable( "Summon Fire Spirit" ) then
			Helper:CheckExecute( "Summon Fire Spirit" );
			return false;
		end
		
		-- Unable to continue until a spirit has been summoned.
		return false;
		
	end
	
	-- Check if the entity state is valid.
	if EntityState == nil then
		return;
	end
	
	-- Check if the spirit entity is valid.
	if SpiritEntity ~= nil then
		
		-- Summon 2: Replenish Element
		if SpiritEntity:GetHealth() < 65 and Player:GetHealth() > 50 and Helper:CheckAvailable( "Replenish Element" ) then
			Helper:CheckExecute( "Replenish Element" );
			return;
		end
		
		-- Summon 3: Spirit Recovery
		if SpiritEntity:GetHealth() < 10 and Helper:CheckAvailable( "Spirit Recovery" ) then
			Helper:CheckExecute( "Spirit Recovery" );
			return;
		end
		
		-- Summon 4: Healing Spirit
		if SpiritEntity:GetHealth() < 20 and Helper:CheckAvailable( "Healing Spirit" ) then
			Helper:CheckExecute( "Healing Spirit" );
			return;
		end
		
		-- Spirit Buff 01: Armor Spirit
		if Helper:CheckAvailable( "Armor Spirit I" ) then
			Helper:CheckExecute( "Armor Spirit" );
			return false;
		end
		
		-- Check if this a new target and move the spirit when it is.
		if AbilityList:GetAbility( "Spirit Threat" ) ~= nil and Settings.SpiritMaster.AllowInitialThreat and ( self._LastEntity == nil or self._LastEntity ~= Entity:GetID()) then
			-- Check if Spirit Threat is available, do not continue until it is.
			if not Helper:CheckAvailable( "Spirit Threat" ) then
				if self._bPrepareThreat then
					self._LastEntity = Entity:GetID();
					self._bPrepareThreat = nil;
				end
				return false;
			-- Check if the entity has selected a target.
			elseif Entity:GetTargetID() ~= 0 then
				Helper:CheckExecute( "Spirit Threat" );
				self._bPrepareThreat = true;
				return false;
			-- Otherwise send the spirit to attack.
			elseif self._iClickTime == nil or self._iClickTime < Time() then
				-- Retrieve the pet_command_dialog.
				local PetDialog = DialogList:GetDialog( "pet_command_dialog" );
				-- If this dialog does not exist, you are not using a non-native EU client.
				if PetDialog == nil then
					-- Retrieve the pet_dialog.
					PetDialog = DialogList:GetDialog( "pet_dialog" );
					-- If this dialog does not exist, there is a huge issue! >_<
					if PetDialog == nil then
						Write( "ERROR: The pet command dialog could not be found!" );
						return false;
					end
				end
				-- Click!
				PetDialog:GetDialog( "pet_cmd1" ):Click();
				-- And make sure we are not spamming this clicking action.
				self._iClickTime = Time() + 1000;
				self._bPrepareThreat = true;
				return false;
			-- For now, do nothing.
			else
				return false;
			end
		end
	end
	
	-- Chain 1: Remove Shock
	if Player:GetHealth() < 70 and Player:GetMana() < 85 and Helper:CheckAvailable( "Vengeful Backdraft" ) then
		Helper:CheckExecute( "Vengeful Backdraft" );
		return false;
	elseif Helper:CheckAvailable( "Flames of Anguish" ) then
		Helper:CheckExecute( "Flames of Anguish" );
		return false;
	elseif Helper:CheckAvailable( "Remove Shock" ) then
		Helper:CheckExecute( "Remove Shock" );
		return false;
	end
	
	-- Chain 2: Stone Shock
	if not IsStunned and Helper:CheckAvailable( "Stone Shock" ) then
		Helper:CheckExecute( "Stone Shock" );
		return false;
	end
	
	-- When this is an attack-only script, recover MP.
	if IsAttackOnly then
		self:Pause();
	end
	
	-- Check if the spirit entity is valid.
	if SpiritEntity ~= nil then

		-- Attack 03: Spirit Disturbance
		if Helper:CheckAvailable( "Spirit Disturbance" ) then
			Helper:CheckExecute( "Spirit Disturbance" );
			return false;
		end
		
		-- Attack 01: Spirit Thunderbolt Claw
		if Helper:CheckAvailable( "Spirit Thunderbolt Claw" ) then
			Helper:CheckExecute( "Spirit Thunderbolt Claw" );
			return false;
		end
		
		-- Attack 05: Spirit Detonation Claw
		if Helper:CheckAvailable( "Spirit Detonation Claw" ) then
			Helper:CheckExecute( "Spirit Detonation Claw" );
			return false;
		end
		
		-- Spirit Buff 02: Spirit Wrath Position
		if Helper:CheckAvailable( "Spirit Wrath Position" ) then 
			Helper:CheckExecute( "Spirit Wrath Position" );
			return false;
		end
	
	end
	
	-- Buff 01: Summoning Alacrity
	if Helper:CheckAvailable( "Summoning Alacrity" ) then
		Helper:CheckExecute( "Summoning Alacrity" );
		return false;
	end
		
	-- Attack 02: Summon Wind Servant
	if Helper:CheckAvailable( "Summon Wind Servant" ) then
		Helper:CheckExecute( "Summon Wind Servant" );
		return false;
	end
	
	-- Stigma 01: Summon Cyclone Servant
	if Helper:CheckAvailable( "Summon Cyclone Servant" ) then
		Helper:CheckExecute( "Summon Cyclone Servant" );
		return false;
	end
	
	-- Attack 04: Backdraft
	if Helper:CheckAvailable( "Backdraft" ) and Player:GetHealth() < 80 and Player:GetMana() < 90 then
		Helper:CheckExecute( "Backdraft" );
		return false;
	end
	
	-- Stigma 05: Absorb Vitality
	if Helper:CheckAvailable( "Absorb Vitality" ) and Player:GetHealth() < 75 then
		Helper:CheckExecute( "Absorb Vitality" );
		return false;
	end
	
	-- Check if the spirit entity is valid.
	if SpiritEntity ~= nil then
	
		-- Buff 02: Spirit Preserve
		if Helper:CheckAvailable( "Spirit Preserve" ) and Player:GetHealth() < 25 then
			Helper:CheckExecute( "Spirit Preserve" );
			return false;
		end
		
		-- Buff 03: Spirit Substitution
		if Helper:CheckAvailable( "Spirit Substitution" ) and Player:GetHealth() < 15 then
			Helper:CheckExecute( "Spirit Substitution" );
			return false;
		end
		
	end
	
	-- Indicates whether or not to preserve mana. Damage-over-time skills are not applied after 50%.
	if not Settings.SpiritMaster.AllowPreserveMana or Entity:GetHealth() >= 50 then
			
		-- Stigma 02: Cyclone of Wrath
		if Helper:CheckAvailable( "Cyclone of Wrath" ) and EntityState:GetState( Helper:CheckName( "Cyclone of Wrath" )) == nil then
			Helper:CheckExecute( "Cyclone of Wrath" );
			return false;
		end
		
		-- Stigma 03: Infernal Pain
		if Helper:CheckAvailable( "Infernal Pain" ) then 
			Helper:CheckExecute( "Infernal Pain" );
			return false;
		end
	
	end
			
	-- Attack 06: Erosion
	if Helper:CheckAvailable( "Erosion" ) and EntityState:GetState( Helper:CheckName( "Erosion" )) == nil then
		Helper:CheckExecute( "Erosion" );
		return false;
	end
		
	-- Attack 07: Chain of Earth
	if Entity:GetHealthCurrent() > 1000 and Helper:CheckAvailable( "Chain of Earth" ) and EntityState:GetState( Helper:CheckName( "Chain of Earth" )) == nil then
		Helper:CheckExecute( "Chain of Earth" );
		return false;
	end
		
	-- Attack 08: Vacuum Choke
	if Helper:CheckAvailable( "Vacuum Choke" ) then
		Helper:CheckExecute( "Vacuum Choke" );
		return false;
	end
	
	-- Stigma 04: Weaken Spirit
	if Helper:CheckAvailable( "Weaken Spirit" ) then
		Helper:CheckExecute( "Weaken Spirit" );
		return false;
	end
	
	-- Attack 09: Curse of Fire/Curse of Water
	--if Helper:CheckAvailable( "Curse of Water" ) and Player:GetHealth() < 33 then
	--	Helper:CheckExecute( "Curse of Water" );
	--	return false;
	--end
				
	-- Attack 10: Flame Bolt (Lowbies)
	if Player:GetLevel() <= 19 and Helper:CheckAvailable( "Flame Bolt" ) then
		Helper:CheckExecute( "Flame Bolt" );
		return false;
	end
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end

--- Perform the safety checks before moving to the next target.
--
-- @return	bool

function Pause()

	-- Retrieve the entity state of the player.
	local EntityState = Player:GetState();
	
	-- Buff 04: Absorb Energy
	if Helper:CheckAvailable( "Absorb Energy" ) and Player:GetManaMaximum() - Player:GetManaCurrent() > 226 then
		Helper:CheckExecute( "Absorb Energy" );
		return false;
	end
	
	-- Buff 05: Stone Skin
	if Helper:CheckAvailable( "Stone Skin" ) and EntityState:GetState( Helper:CheckName( "Stone Skin" )) == nil then
		Helper:CheckExecute( "Stone Skin" );
		return false;
	end
	
	-- Buff 06: Spirit Absorption
	if Helper:CheckAvailable( "Spirit Absorption" ) and Player:GetMana() < 70 and self:FindSpirit() ~= nil then
		Helper:CheckExecute( "Spirit Absorption" );
		return false;
	end
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end