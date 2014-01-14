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

---- Perform the attack routine on the selected target.
---
--- @param	Entity	Contains the entity we have targeted.
--- @param	double	Contains the distance to the target
--- @param	bool	Indicates whether or not the target is stunned.
--- @return	bool

function Attack( Entity, Range, Stunned )

	-- Perform the original function and return the results.
	return Class:Attack( Entity, Range, Stunned );
	
end

---- Perform healing checks both in and our of combat.
---
--- @param	bool	Indicates whether or not we are in combat.
--- @return	bool

function Heal( CombatEnabled )

	-- Perform the original function and return the results.
	return Class:Heal( CombatEnabled );
	
end

---- Perform the safety checks before moving to the next target.
---
--- @return	bool

function Pause()
	
	-- Perform the original function and return the results.
	return Class:Pause();
	
end