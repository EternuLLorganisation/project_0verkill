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

	if Helper:CheckAvailable( "Shield Counter" ) then
		Helper:CheckExecute( "Shield Counter" );
		return false;
	end
	
	if Helper:CheckAvailable( "Robust Blow" ) then
		Helper:CheckExecute( "Robust Blow" );
		return false;
	elseif Helper:CheckAvailable( "Rage" ) then
		Helper:CheckExecute( "Rage" );
		return false;
	end
	
	if Helper:CheckAvailable( "Weakening Severe Blow" ) then
		Helper:CheckExecute( "Weakening Severe Blow" );
		return false;
	end
	
	if Helper:CheckAvailable( "Ferocious Strike" ) then
		Helper:CheckExecute( "Ferocious Strike" );
		return false;
	end
		
end