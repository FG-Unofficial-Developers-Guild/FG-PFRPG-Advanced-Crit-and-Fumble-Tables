--
-- Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals notifyApplyHRFC

OOB_MSGTYPE_APPLYHRFC = 'applyhrfc'

function notifyApplyHRFC(sTable)
	local msgOOB = {}
	msgOOB.type = OOB_MSGTYPE_APPLYHRFC

	msgOOB.sTable = sTable

	Comm.deliverOOBMessage(msgOOB, '')
end

local function handleApplyHRFC(msgOOB) TableManager.processTableRoll('', msgOOB.sTable) end

function onInit() OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYHRFC, handleApplyHRFC) end
