--[[

	--------------------------------------------------
	Copyright (C) 2011 apatia777

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

	if Stunned and Helper:CheckAvailable( "Surprise Attack" ) then
		local PosE = Entity:GetPosition();
		local dist = 1; 
		local Angle = Entity:GetRotation();
		PosE.X = PosE.X - dist * math.sin( Angle * ( math.pi / 180 ));
		PosE.Y = PosE.Y + dist * math.cos( Angle * ( math.pi / 180 ));
		if not Player:SetMove( PosE ) then
			Helper:CheckExecute( "Surprise Attack" );
		end
		return false;
	end

	if Helper:CheckAvailable( "Soul Slash" ) then
		Helper:CheckExecute( "Devotion" );
		Helper:CheckExecute( "Soul Slash" );
		return false;
	elseif Helper:CheckAvailable( "Swift Edge" ) then
		Helper:CheckExecute( "Devotion" );
		Helper:CheckExecute( "Swift Edge" );
		return false;
	end
	
	if Helper:CheckAvailable( "Counterattack" ) then
		Helper:CheckExecute( "Counterattack" );
		return false;
	end

	if Helper:CheckAvailable( "Focused Evasion" ) and Player:GetHealthCurrent() < Player:GetHealthMaximum() / 2 then
		Helper:CheckExecute( "Focused Evasion" );
		return false;	
	end

	-- Nothing was executed, continue with other functions.
	return true;
	
end

function Heal( BeforeForce )

	if Helper:CheckAvailable( "Focused Evasion" ) and Player:GetHealthCurrent() < Player:GetHealthMaximum() / 2  then
			Helper:CheckExecute( "Focused Evasion" );
			return false;	
	end
	-- Nothing was executed, continue with other functions.
	return true;
	
end