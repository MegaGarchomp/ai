math.randomseed( require("os").time() )

function OnStartOfDuel()	
	AI.Chat("This is a tutorial AI file")
end

function OnSelectOption(options)
	return math.random(#options)
end

function OnSelectEffectYesNo(id, triggeringCard)--任意効果
	return 1
end

function OnSelectYesNo(description_id)--ダイレクトアタック時に他の場所からモンスターが出てきた場合に戦闘を続けるかどうか
	if description_id == 10000 then -- continue attacking
		return -1
	else
		return 1
	end
end

function OnSelectPosition(id, available)
	local result = 0
	local band = bit32.band
  result = POS_FACEUP_ATTACK
	if band(result,available) == 0 then
		if band(POS_FACEUP_ATTACK,available) > 0 then
			result = POS_FACEUP_ATTACK
		elseif band(POS_FACEUP_DEFENCE,available) > 0 then
			result = POS_FACEUP_DEFENCE
		elseif band(POS_FACEDOWN_DEFENCE,available) > 0 then
			result = POS_FACEDOWN_DEFENCE
		else
			result = POS_FACEDOWN_ATTACK
		end
	end
	return result
end

function OnSelectTribute(cards,minTributes, maxTributes)
	local result = {}
	local tributes = {}
	for i=1,#cards do
		tributes[i] = {attack=cards[i].attack, index=i}
	end
	table.sort(tributes, function(a,b) return a.attack<b.attack end)
	for i=1,minTributes do
		result[i]=tributes[i].index
	end
	return result
end

function OnDeclareMonsterType(count, choices)
	local result = 0
	local returnCount = 0
	while returnCount < count do
		result = result + choices[returnCount+1]
		returnCount = returnCount + 1
	end
	return result
end

function OnDeclareAttribute(count, choices)
	local result = 0
	local returnCount = 0
	while returnCount < count do
		result = result + choices[returnCount+1]
		returnCount = returnCount + 1
	end
	return result
end

function OnDeclareCard()	
	return 85138716 -- Rescue Rabbit
end

function OnSelectNumber(choices)
	return math.random(#choices)
end

function OnSelectChain(cards, only_chains_by_player, forced)
	return 1,1
end

function OnSelectSum(cards, sum, triggeringCard)
	local result = {}
	local num_levels = 0
	for i=1,#cards do
		num_levels = num_levels + cards[i].level
		result[i]=i
		if(num_levels >= sum) then
			break
		end
	end
	return result
end

function OnSelectCard(cards, minTargets, maxTargets, triggeringID, triggeringCard)
  local result = {}
  for i=1,minTargets do
    result[i]=i
  end
  return result
end


function OnSelectBattleCommand(cards, activatable_cards)
	local CMD_ATTACK = 1
	local CMD_ACTIVATE = 2
	local CMD_STOP = 0
	local command = 1
	local index = 1
	local function getWeakestAttackerIndex()
		local lowestIndex = 1
		local lowestAttack = cards[1].attack
		for i=2,#cards do
			if cards[i].attack < lowestAttack then
				lowestIndex = i
				lowestAttack = cards[i].attack
			end
		end
		return lowestIndex
	end
	if #cards > 0 then
		command = CMD_ATTACK
		index = getWeakestAttackerIndex()
	elseif #activatable_cards > 0 then
		command = CMD_ACTIVATE
		index = 1
	else
		command = CMD_STOP
		index = 0
	end
	return command,index
end

COMMAND_LET_AI_DECIDE		= -1
COMMAND_SUMMON 				= 0
COMMAND_SPECIAL_SUMMON 		= 1
COMMAND_CHANGE_POS 			= 2
COMMAND_SET_MONSTER 		= 3
COMMAND_SET_ST 				= 4
COMMAND_ACTIVATE 			= 5
COMMAND_TO_NEXT_PHASE 		= 6
COMMAND_TO_END_PHASE 		= 7
function OnSelectInitCommand(cards, to_bp_allowed, to_ep_allowed)	
	if #cards.activatable_cards > 0 then
		return COMMAND_ACTIVATE,1
	end
	if #cards.spsummonable_cards > 0 then
		return COMMAND_SPECIAL_SUMMON,1
	end	
	if #cards.summonable_cards > 0 then
		return COMMAND_SUMMON,1
	end
	if #cards.monster_setable_cards > 0 then
		return COMMAND_SET_MONSTER,1
	end
	if #cards.st_setable_cards > 0 and AI.GetCurrentPhase() == PHASE_MAIN2 then
		local setCards = cards.st_setable_cards
		for i=1,#setCards do
			if bit32.band(setCards[i].type,TYPE_TRAP) > 0 then
				return COMMAND_SET_ST,i
			end
		end
	end
	if AI.GetCurrentPhase() == PHASE_MAIN1 and to_bp_allowed then
		return COMMAND_TO_NEXT_PHASE,1
	else
		return COMMAND_TO_END_PHASE,1
	end
end
