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
local function advEffectsSpell(rRoll)
	return AdvancedEffects and not rRoll.nodeWeapon
end

-- Determine attack type
local function attackType(rRoll)
	if DataCommon.naturaldmgtypes[getWeaponName(rRoll.sDesc):lower()] then
		return "Natural";
	elseif kelSpell(rRoll) or advEffectsSpell(rRoll) then
		return "Magic";
	elseif string.match(rRoll.sDesc, "%[ATTACK.*%((%w+)%)%]") == "R" then
		return "Ranged";
	else
		return "Melee";
	end
end

-- Determine damage type
local function damageType(rRoll)
	local sWeapon = getWeaponName(rRoll.sDesc);
	if DataCommon.naturaldmgtypes[sWeapon:lower()] then
		return DataCommon.naturaldmgtypes[sWeapon:lower()]:gsub(',.*', '');
	elseif DataCommon.weapondmgtypes[sWeapon:lower()] then
		return DataCommon.weapondmgtypes[sWeapon:lower()]:gsub(',.*', '');
	elseif kelSpell(rRoll) or advEffectsSpell(rRoll) then
		return "Magic";
	else
		return 'bludgeoning'
	end
end

local function onPostAttackResolve_new(_, _, rRoll)
	-- HANDLE FUMBLE/CRIT HOUSE RULES
	local sOptionHRFC = OptionsManager.getOption("HRFC");
	if rRoll.sResult == "fumble" and ((sOptionHRFC == "both") or (sOptionHRFC == "fumble")) then
		AutoPFCritFumbleOOB.notifyApplyHRFC('Fumble - ' .. attackType(rRoll));
	end
	if rRoll.sResult == "crit" and ((sOptionHRFC == "both") or (sOptionHRFC == "criticalhit")) then
		AutoPFCritFumbleOOB.notifyApplyHRFC('Critical - ' .. StringManager.titleCase(damageType(rRoll)));
	end
end

-- Function Overrides
function onInit()
	ActionAttack.onPostAttackResolve = onPostAttackResolve_new;
end
