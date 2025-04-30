Config = {}
Config.sitPosition = vector3(1725.79, -7093.39, 124.50) -- player position while seated on catapult
Config.sitPrompt = vector3(1725.83, -7093.06, 124.06) -- the position of the prompt to get in cannon
Config.firePrompt = vector3(1728.4, -7095.04, 124.17) -- the position of the prompt to fire
Config.sitPromptKey = 0x760A9C6F -- your key to get in cannon (Default = G)
Config.firePromptKey = 0xE30CD707 -- your key to fire cannon (Default = R)

Config.useSpawnCommand = true -- use /spawnCatapult command, if false use your own mappings
Config.cannon = { -- catapult model & position (useless if useSpawnCommand is false)
    model = `p_cannon02x`,
    coords = vec3(1726.699951, -7094.180176, 123.291451),
    rotation = vec3(-25.0, 0.000000, -130.374405),
}

Config.velocityMultiplier = 100.0   -- velocity multiplier
Config.forceMultiplier = 4000.0    -- force multiplier
Config.upwardForce = 500.0         -- upward force
Config.duration = 9500             -- force duration applied after launch
Config.animationKey = 0x4AF4D473   -- your key to cancel animation (to avoid player stopping while on catapult)
Config.adminOnly = true            -- whether the commands are admin only or not
Config.AllowPlayerInCannonToFire = true -- allow player in cannon to fire (can avoid player to be stuck in if alone)

Config.prompts = {
    sit = "Sit in the cannon", -- change the value with your own language
    fire = "Fire the cannon", -- change the value with your own language
}
Config.promptGroupName = "Cannonball" -- change the value with your own language
