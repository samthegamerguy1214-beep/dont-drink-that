--[[
Purpose: Shared registry of Don't Drink That reaction unlocks.
Where it goes in Studio: ReplicatedStorage/ReactionRegistry.lua (ModuleScript)
Dependencies: None
]]

local ReactionRegistry = {}

ReactionRegistry.Reactions = {
	{ id = "spin_fling", displayName = "Spin-Fling", unlockTier = 0, description = "Head spins, disgust face, then launches upward." },
	{ id = "puddle", displayName = "Puddle", unlockTier = 0, description = "Melts into a neon puddle." },
	{ id = "balloon", displayName = "Balloon", unlockTier = 0, description = "Inflates, floats, and pops." },
	{ id = "ragdoll_flop", displayName = "Ragdoll Flop", unlockTier = 0, description = "Full limp backward flop." },
	{ id = "sour_face", displayName = "Sour Face", unlockTier = 5, description = "Scrunched face, big head, steam ears." },
	{ id = "fire_mouth", displayName = "Fire Mouth", unlockTier = 5, description = "Fire breath and panicked sprint." },
	{ id = "time_warp", displayName = "Time Warp", unlockTier = 5, description = "Slo-mo drop, speed-up impact." },
	{ id = "windmill", displayName = "Windmill", unlockTier = 5, description = "Arms spin wildly in place." },
	{ id = "head_rocket", displayName = "Head Rocket", unlockTier = 15, description = "Head rockets into the sky." },
	{ id = "skeleton_reveal", displayName = "Skeleton Reveal", unlockTier = 15, description = "Disintegrates into a dancing skeleton." },
	{ id = "rainbow_vomit", displayName = "Rainbow Vomit", unlockTier = 15, description = "Rainbow beam launches player backward." },
	{ id = "shrink", displayName = "Shrink", unlockTier = 15, description = "Shrinks tiny and squeaks away." },
	{ id = "dimension_rip", displayName = "Dimension Rip", unlockTier = 40, description = "Portal opens and eats the player." },
	{ id = "freeze_shatter", displayName = "Freeze-Shatter", unlockTier = 40, description = "Freezes, then shatters into cubes." },
	{ id = "bomb_head", displayName = "Bomb Head", unlockTier = 40, description = "Head becomes a fuse bomb." },
	{ id = "ghost_float", displayName = "Ghost Float", unlockTier = 40, description = "Soul floats up and waves." },
	{ id = "alien_abduction", displayName = "Alien Abduction", unlockTier = 40, description = "UFO beams player away." },
	{ id = "clone_split", displayName = "Clone Split", unlockTier = 40, description = "Splits into four clones that all fall over." },
	{ id = "black_hole", displayName = "Black Hole", unlockTier = 40, description = "Gets swallowed by a tiny mouth black hole." },
	{ id = "winners_curse", displayName = "The Winner's Curse", unlockTier = 40, description = "Top-player flex: flips the diner illusion." },
}

local byId = {}
for _, reaction in ipairs(ReactionRegistry.Reactions) do
	byId[reaction.id] = reaction
end

function ReactionRegistry.Get(reactionId)
	return byId[reactionId]
end

function ReactionRegistry.GetUnlockedForWins(wins)
	local unlocked = {}
	for _, reaction in ipairs(ReactionRegistry.Reactions) do
		if wins >= reaction.unlockTier then
			table.insert(unlocked, reaction.id)
		end
	end
	return unlocked
end

function ReactionRegistry.IsUnlocked(reactionId, wins)
	local reaction = byId[reactionId]
	return reaction ~= nil and wins >= reaction.unlockTier
end

return ReactionRegistry
