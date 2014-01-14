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

--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @param	mixed	Indicates whether or not to ignore Lumiel's Effect for the fusion chain.
-- @return	bool

function Attack( Entity, Range, Stunned, Ignore )
	
	-- Check if Flame Cage has been applied on the target.
	local FlameCageEffect = Entity:GetState():GetState( Helper:CheckName( "Flame Cage" ));
	
	-- Check if Lumiel's Wisdom has been applied on the player.
	local LumielsWisdomEffect = Player:GetState():GetState( Helper:CheckName( "Lumiel's Wisdom" ));
	
	-- Check if the player has Lumiel's Wisdom and assume we always have its effect when we do not!
	if not Settings.Sorcerer.AllowMpConservation or AbilityList:GetAbility( Helper:CheckName( "Lumiel's Wisdom" )) == nil then
		LumielsWisdomEffect = true;
		self._LumielsWisdom = Time() + 15000;
	end
	
	-- Solo/Support Rotation
	if not Settings.Sorcerer.AllowGroupRotation then
	
		-- Ice Chain -> Frozen Shock
		if Helper:CheckAvailable( "Frozen Shock" ) then
			if self._DelayedBlast == nil then
				Helper:CheckExecute( "Frozen Shock", Entity );
				return false;
			else
				self._DelayedBlast = nil;
			end
		end
		
		-- Flame Bolt -> Blaze
		if Helper:CheckAvailable( "Blaze" ) then
			Helper:CheckExecute( "Blaze", Entity );
			return false;
		end
	
	end
	
	-- Absorb Energy (Assuming highest level of Absorb Energy)
	if Helper:CheckAvailable( "Absorb Energy" ) and Player:GetManaCurrent() < Player:GetManaMaximum() - 643 then
		Helper:CheckExecute( "Absorb Energy" );
		return false;
	end
	
	-- Flame Fusion -> Flame Cage -> Wind Cut Down -> Flame Harpoon -> Flame Bolt
	if Entity:GetState():GetState( Helper:CheckName( "Flame Fusion" )) ~= nil or Ignore ~= nil then
	
		-- Solo/Support Rotation
		if not Settings.Sorcerer.AllowGroupRotation then
		
			-- Flame Cage [Might need removing in Solo/Support Rotation)
			if Helper:CheckAvailable( "Flame Cage" ) and FlameCageEffect == nil then
				Helper:CheckExecute( "Flame Cage", Entity );
				return false;
			end
			
			-- Wind Cut Down
			if Helper:CheckAvailable( "Wind Cut Down" ) then
				Helper:CheckExecute( "Wind Cut Down", Entity );
				return false;
			end
		
		end
				
		-- Flame Harpoon
		if Helper:CheckAvailable( "Flame Harpoon" ) then
			Helper:CheckExecute( "Flame Harpoon", Entity );
			return false;
		end
		
		-- Flame Bolt
		if Helper:CheckAvailable( "Flame Bolt" ) then
			Helper:CheckExecute( "Flame Bolt", Entity );
			return false;
		end
	
	end
	
	-- Group Rotation
	if Settings.Sorcerer.AllowGroupRotation then

		-- Flame Cage
		if Helper:CheckAvailable( "Flame Cage" ) and FlameCageEffect == nil then
			Helper:CheckExecute( "Flame Cage", Entity );
			return false;
		end
	
		-- Wind Cut Down
		if Helper:CheckAvailable( "Wind Cut Down" ) then
			Helper:CheckExecute( "Wind Cut Down", Entity );
			return false;
		end
		
		-- Lumiel's Wisdom Enabled
		if LumielsWisdomEffect ~= nil then
			
			-- Inferno: When Lumiel's Wisdom is enabled and has enough remaining time.
			if self._LumielsWisdom > Time() + 4000 and Helper:CheckAvailable( "Inferno" ) then
				Helper:CheckExecute( "Inferno", Entity );
				return false;
			end
		
			-- Soul Freeze: When Lumiel's Wisdom is enabled and has enough remaining time.
			if self._LumielsWisdom > Time() + 1000 and Helper:CheckAvailable( "Soul Freeze" ) then
				Helper:CheckExecute( "Soul Freeze", Entity );
				return false;
			end
		
			-- Frostbite
			if Helper:CheckAvailable( "Frostbite" ) then
				Helper:CheckExecute( "Frostbite", Entity );
				return false;
			end
		
		end
		
	end
	
	-- Lumiel's Wisdom Enabled
	if LumielsWisdomEffect ~= nil then
	
		-- Solo/Support Rotation: Initial Attack.
		if not Settings.Sorcerer.AllowGroupRotation and Entity:GetHealth() == 100 then
		
			-- Delayed Blast
			if Helper:CheckAvailable( "Delayed Blast" ) then
				Helper:CheckExecute( "Delayed Blast", Entity );
				self._DelayedBlast = true;
				return false;
			end
			
			-- Ice Chain
			if Helper:CheckAvailable( "Ice Chain" ) then
				Helper:CheckExecute( "Ice Chain", Entity );
				return false;
			end
			
		end

		-- Flame Fusion (This starts other attacks, such as Wind Cut Down and Flame Harpoon).
		if Helper:CheckAvailable( "Flame Fusion" ) then
			Helper:CheckExecute( "Flame Fusion", Entity );
			return false;
		end
		
	end
	
	-- Group Rotation: Checking Mana.
	if Settings.Sorcerer.AllowGroupRotation and not self:Pause() then
		return false;
	end
	
	-- Lumiel's Wisdom
	if Helper:CheckAvailable( "Lumiel's Wisdom" ) then
		Helper:CheckExecute( "Lumiel's Wisdom" );
		self._LumielsWisdom = Time() + 15000;
		return false;
	end
	
	-- Solo/Support Rotation: Ignore Lumiel's Wisdom
	if not Settings.Sorcerer.AllowGroupRotation then
		
		-- Perform another attack routine without paying attention to MP, when in attack-mode already!
		if Entity:GetHealth() ~= 100 then
			return self:Attack( Entity, Range, Stunned, true );
		end
		
	else
	
		-- Refracting Shard
		if Helper:CheckAvailable( "Refracting Shard" ) then
			Helper:CheckExecute( "Refracting Shard" );
			return false;
		end
		
	end
	
	-- Nothing was executed, continue with other functions.
	return false;
	
end

--- Perform the safety checks before moving to the next target.
--
-- @return	bool

function Pause()

	local EntityState = Player:GetState();
	
	-- Buff: Absorb Energy
	if Helper:CheckAvailable( "Absorb Energy" ) and Player:GetManaMaximum() - Player:GetManaCurrent() > 226 then
		Helper:CheckExecute( "Absorb Energy" );
		return false;
	end
	
	-- Buff: Stone Skin
	if Helper:CheckAvailable( "Stone Skin" ) and EntityState:GetState( Helper:CheckName( "Stone Skin" )) == nil then
		Helper:CheckExecute( "Stone Skin" );
		return false;
	end
	
	-- Buff: Robe of Flame
	if Helper:CheckAvailable( "Robe of Flame" ) and EntityState:GetState( Helper:CheckName( "Robe of Flame" )) == nil then
		Helper:CheckExecute( "Robe of Flame" );
		return false;
	end
	
	-- Gain Mana (Assuming highest level of Absorb Energy)
	if Helper:CheckAvailable( "Gain Mana" ) and Player:GetManaCurrent() < Player:GetManaMaximum() - 1590 then
		Helper:CheckExecute( "Gain Mana" );
		return false;
	end

	-- Nothing was executed, continue with other functions.
	return true;
	
end