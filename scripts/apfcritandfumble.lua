--
-- Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

-- Determine weapon name
local function getWeaponName(s)
	local sWeaponName = s:gsub('%[ATTACK %(%u%)%]', '');
	sWeaponName = sWeaponName:gsub('%[ATTACK #%d+ %(%u%)%]', '');
	sWeaponName = sWeaponName:gsub('%[%u+%]', '');
	if sWeaponName:match('%[USING ') then sWeaponName = sWeaponName:match('%[USING (.-)%]'); end
	sWeaponName = sWeaponName:gsub('%[.+%]', '');
	sWeaponName = sWeaponName:gsub(' %(vs%. .+%)', '');
	sWeaponName = StringManager.trim(sWeaponName);

	return sWeaponName or ''
end

-- Check for Extended Automation and whether the attack is tagged as a spell or spell-like ability
local function kelSpell(rRoll)
	return rRoll.tags and (rRoll.tags:match('spell') or rRoll.tags:match('spelllike'))
end

-- Check if Advanced Effects is loaded and whether the attack has a Weapon attached
local function advEffectsSpell(rSource)
	return AdvancedEffects and not (rSource.nodeItem or rSource.nodeWeapon)
end

-- Determine attack type
local function attackType(rSource, rRoll)
	for kDmgType, _ in pairs(DataCommon.naturaldmgtypes) do
		if string.find(getWeaponName(rRoll.sDesc):lower(), kDmgType) then
			return "Natural";
		end
	end
	if kelSpell(rRoll) or advEffectsSpell(rSource) then
		return "Magic";
	elseif string.match(rRoll.sDesc, "%[ATTACK.*%((%w+)%)%]") == "R" then
		return "Ranged";
	else
		return "Melee";
	end
end

-- Determine damage type
local function damageType(rSource, rRoll)
	local sWeapon = getWeaponName(rRoll.sDesc);
	local aDmgTypes = { DataCommon.naturaldmgtypes, DataCommon.weapondmgtypes };
	for _, tDmgTypes in pairs(aDmgTypes) do
		for kDmgType, vDmgType in pairs(tDmgTypes) do
			if string.find(sWeapon:lower(), kDmgType) then
				if type(vDmgType) == 'string' then
					return vDmgType:gsub(',.*', '');
				else
					return vDmgType['*'];
				end
			end
		end
	end
	if kelSpell(rRoll) or advEffectsSpell(rSource, rRoll) then
		return "Magic";
	else
		return 'bludgeoning'
	end
end

local function onPostAttackResolve_new(rSource, _, rRoll)
	if not (rRoll and rSource) then return; end -- need rRoll to continue

	-- HANDLE FUMBLE/CRIT HOUSE RULES
	local sOptionHRFC = OptionsManager.getOption("HRFC");
	if rRoll.sResult == "fumble" and ((sOptionHRFC == "both") or (sOptionHRFC == "fumble")) then
		AutoPFCritFumbleOOB.notifyApplyHRFC('Fumble - ' .. attackType(rSource, rRoll));
	end
	if rRoll.sResult == "crit" and ((sOptionHRFC == "both") or (sOptionHRFC == "criticalhit")) then
		AutoPFCritFumbleOOB.notifyApplyHRFC('Critical - ' .. StringManager.titleCase(damageType(rSource, rRoll)));
	end
end

-- Function Overrides
function onInit()
	ActionAttack.onPostAttackResolve = onPostAttackResolve_new;
end
