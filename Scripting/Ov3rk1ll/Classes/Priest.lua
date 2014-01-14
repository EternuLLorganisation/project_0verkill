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

	if Helper:CheckAvailable( "Hallowed Strike" ) then
		Helper:CheckExecute( "Hallowed Strike" );
		return false;
	elseif Helper:CheckAvailable( "Infernal Blaze" ) then
		Helper:CheckExecute( "Infernal Blaze" );
		return false;
	end
	
	if Helper:CheckAvailable( "Smite" ) then
		Helper:CheckExecute( "Smite" );
		return false;
	end
	
	Helper:CheckExecute( "Attack/Chat" );
	
	-- Nothing was executed, continue with other functions.
	return true;

end

--- Perform healing checks both in and our of combat.
--
-- @param	bool	Indicates whether or not the function is running before force checks.
-- @return	bool

function Heal( BeforeForce )

	if BeforeForce then
	
		if Helper:CheckAvailable( "Healing Light" ) and Player:GetHealthCurrent() < Player:GetHealthMaximum() / 2  then
			Helper:CheckExecute( "Healing Light", Player );
			return false;
		end

		if Helper:CheckAvailable( "Light of Renewal" ) and Player:GetState():GetState( Helper:CheckName( "Light of Renewal" )) == nil and Player:GetHealthCurrent() < Player:GetHealthMaximum() / 1.1 then
			Helper:CheckExecute( "Light of Renewal" );
			return false;
		end
			
		if Player:GetState():GetState( Helper:CheckName( "Blessing of Health" )) == nil and Helper:CheckAvailable( "Blessing of Health" ) then
			Helper:CheckExecute( "Blessing of Health" );
			return false;
		end

		if Player:GetState():GetState( Helper:CheckName( "Blessing of Rock" )) == nil and Helper:CheckAvailable( "Blessing of Rock" ) then
			Helper:CheckExecute( "Blessing of Rock" );
			return false;
		end

		if Player:GetState():GetState( Helper:CheckName( "Promise of Wind" )) == nil and Helper:CheckAvailable( "Promise of Wind" ) then
			Helper:CheckExecute( "Promise of Wind" );
			return false;
		end	
		
	end
	
	-- Nothing was executed, continue with other functions.
	return true;
	
end