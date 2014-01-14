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
-- @param	mixed	Indicates whether or not to ignore Lumiel's Effect for the fusion chain.
-- @return	bool

function Attack( Entity )

 	if Helper:CheckAvailable( "Blaze" ) then
		Helper:CheckExecute( "Blaze" );
		return false;
	end

	if Helper:CheckAvailable( "Frozen Shock" ) then
		Helper:CheckExecute( "Frozen Shock" );
		return false;
	end

	if Helper:CheckAvailable( "Ice Chain" ) then
		Helper:CheckExecute( "Ice Chain" );
		return false;
	end

	if Helper:CheckAvailable( "Absorb Energy" ) and Player:GetManaCurrent() < Player:GetManaMaximum() - 178 then
		Helper:CheckExecute( "Absorb Energy" );
		return false;
	end

	if Helper:CheckAvailable( "Flame Bolt" ) then
		Helper:CheckExecute( "Flame Bolt" );
		return false;
	end
	
	if Helper:CheckAvailable( "Erosion" ) then
		Helper:CheckExecute( "Erosion" );
		return false;
	end

	-- Nothing was executed, continue with other functions.
	return false;
	
end

function Heal( BeforeForce )

	if BeforeForce then
		if Player:GetState():GetState( Helper:CheckName( "Stone Skin" )) == nil and Helper:CheckAvailable( "Stone Skin" ) then
			Helper:CheckExecute( "Stone Skin" );
			return false;
		end

	end

	return true;
	
end