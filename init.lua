--Fun fact: the "Doppler Effect" is physics law about waves, according to it, basically waves change depending on their distance.
--The Doppler Effect is what makes us able to tell if the sound origin is getting closer or further.

--Note: "a" stands for the target position, while "b" is the origin position
local get_distance = function(a, b) --This function is from mobs redo

	if not a or not b then return 50 end -- nil check

	local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z

	return math.sqrt(x * x + y * y + z * z)
end

function sound_distance_play(pos, sound, sound_gain, distance)
    if not pos or not sound or not distance then return end
    if not sound_gain then sound_gain = 1 end
	for _,player in ipairs(minetest.get_connected_players()) do
        local dist = get_distance(player:get_pos(), pos)
        if not dist then return end
        if dist > distance then return end
        local doppler = distance - dist
        if not doppler then return end
        if not player then return end--Avoid glitching incase player leaves
        if doppler == 0 then
            minetest.sound_play(sound, {gain = 0.1, to_player = player:get_player_name()})
        else
            if sound_gain*(doppler/10) > sound_gain then--This avoids a possible ear exploder incase the sound has a huge hear distance for example
                minetest.sound_play(sound, {gain = sound_gain, to_player = player:get_player_name()})--The sound is played only for that specific player
            else
                minetest.sound_play(sound, {gain = sound_gain*(doppler/10), to_player = player:get_player_name()})
            end
        end
    end
end

--[[minetest.register_node("sound_distance:test_node", {
	description = "Sound distance test",
	tiles = {"default_steel_block.png"},
	groups = {oddly_breakable_by_hand=1, snappy=1, cracky=1},
	sounds = default_stone_sounds,
	paramtype = "light",
    is_ground_content = false,
	on_rightclick = function(pos, node, clicker)
        sound_distance_play(pos, "tnt_explode", 1, 16)
        minetest.after(2, function()
            sound_distance_play(pos, "tnt_explode", 1, 16)
        end)
        minetest.after(5, function()
            sound_distance_play(pos, "tnt_explode", 1, 16)
        end)
	end,
})]]
