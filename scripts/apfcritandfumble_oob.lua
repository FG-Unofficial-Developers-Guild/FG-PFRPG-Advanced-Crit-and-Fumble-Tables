--
-- Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

OOB_MSGTYPE_APPLYHRFC = "applyhrfc";

-- luacheck: globals handleApplyHRFC notifyApplyHRFC
function handleApplyHRFC(msgOOB)
	TableManager.processTableRoll("", msgOOB.sTable);
end

function notifyApplyHRFC(sTable)
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYHRFC;

	msgOOB.sTable = sTable;

	Comm.deliverOOBMessage(msgOOB, "");
end

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYHRFC, handleApplyHRFC);
end