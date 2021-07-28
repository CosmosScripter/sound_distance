--Fun fact: the "Doppler Effect" is physics law about waves, according to it, basically waves change depending on their distance.
--The Doppler Effect is what makes us able to tell if the sound origin is getting closer or further.

local sonic_boom = {
	physical = false,
	timer = 0,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5},
	textures = {"sonic_boom.png"},
	lastpos= {},
	collisionbox = {0, 0, 0, 0, 0, 0},
}
sonic_boom.on_step = function(self, dtime, pos)--Sonic boom expanding
    sound_distance_play(self.object:get_pos(), "tnt_explode", 1, 32)--Sonic boom noise
    self.timer = (self.timer or 0) + dtime
    local size_x = self.object:get_properties().visual_size.x
    local size_y = self.object:get_properties().visual_size.y
    self.object:set_properties({visual_size = {x=size_x + 0.1, y=size_y + 0.1}})
    if self.timer > 1 then--Fun fact: the first time this was tested, the time limit was too long, so it became a Detroit Smash
        self.object:remove()
    end
end

minetest.register_entity("sound_distance:sonic_boom", sonic_boom)

--Note: "a" stands for the target position, while "b" is the origin position
local get_distance = function(a, b) --This function is from mobs redo

	if not a or not b then return 50 end -- nil check

	local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z

	return math.sqrt(x * x + y * y + z * z)
end

local check_movement = function(pos, yaw, player)--For now this kind of works, further testing needed
    if not yaw or not pos or not player then return false end
    local player_pos = player:get_pos()
    local deg = math.deg(yaw)--Try to use get_look_horizontal instead of get_look_yaw, as the deprecated function breaks this one
    if deg < 360 and deg > 270 then--NE
        if deg > 315 then--Closer to North
            if player_pos.z > pos.z then
                return true--True for getting closer, false for going away
            else
                return false
            end
        elseif deg < 315 then--Closer to East
            if player_pos.x > pos.x then
                return true--True for getting closer, false for going away
            else
                return false
            end
        end
    elseif deg < 270 and deg > 180 then--SE
        if deg > 225 then--Closer to East
            if player_pos.x > pos.x then
                return true
            else
                return false
            end
        elseif deg < 225 then--Closer to South
            if player_pos.z < pos.z then
                return true
            else
                return false
            end
        end
    elseif deg < 180 and deg > 90 then--SW
        if deg > 135 then--Closer to South
            if player_pos.z < pos.z then
                return true
            else
                return false
            end
        elseif deg < 135 then--Closer to West
            if player_pos.x < pos.x then
                return true
            else
                return false
            end
        end
    elseif deg < 90 and deg > 0 then--NW
        if deg > 45 then--Closer to West
            if player_pos.x < pos.x then
                return true
            else
                return false
            end
        elseif deg < 45 then--Closer to North
            if player_pos.z > pos.z then
                return true
            else
                return false
            end
        end
    elseif deg == 0 then--N
        if player_pos.z > pos.z then
            return true
        else
            return false
        end
    elseif deg == 270 then--E
        if player_pos.x > pos.x then
            return true
        else
            return false
        end
    elseif deg == 180 then--S
        if player_pos.z < pos.z then
            return true
        else
            return false
        end
    elseif deg == 90 then--W
        if player_pos.x < pos.x then
            return true
        else
            return false
        end
    end
end

function sound_distance_play(pos, sound, sound_gain, distance, moving, yaw, vel, force_sound_speed)
    if not pos or not sound or not distance then return end
    if not sound_gain then sound_gain = 1 end
	for _,player in ipairs(minetest.get_connected_players()) do
        local dist = get_distance(player:get_pos(), pos)
        if not dist then return end
        if dist > distance then return end
        local doppler = distance - dist
        if not doppler then return end
        if not player then return end--Avoid glitching incase player leaves
        if moving == true and not yaw then yaw = 0 end
        if not vel then vel = {x = 10, y = 0, z = 10} end
        local actual_vel = math.ceil(vel.x * vel.x + vel.z * vel.z) ^ 0.5--Converts a vector into an approximate number
        if force_sound_speed == true then actual_vel = 340 end
        if actual_vel >= 340 and actual_vel <= 342 then minetest.add_entity(pos, "sound_distance:sonic_boom") end
        if moving == true and check_movement(pos, yaw, player) == true then--Thanks to Astrobe I've noticed the mod was missing pitch changes
            if actual_vel >= 340 then return end--Object is moving above or at sound speed, so only those behind the object can hear it
            --minetest.chat_send_player(player:get_player_name(), "working pitch change")
            if doppler == 0 then
                minetest.sound_play(sound, {gain = 0.1, pitch = 2, to_player = player:get_player_name()})--Higher pitch incase the object is moving and aproaching
            else
                if sound_gain*(doppler/10) > sound_gain then
                    minetest.sound_play(sound, {gain = sound_gain, pitch = 2, to_player = player:get_player_name()})
                else
                    minetest.sound_play(sound, {gain = sound_gain*(doppler/10), pitch = 2, to_player = player:get_player_name()})
                end
            end
        else
            if actual_vel > 340 then--If above sound speed, the sound will be delayed
                local sound_timing = actual_vel - 340
                if not sound_timing then return end
                minetest.after(sound_timing, function()
                    if doppler == 0 then
                        minetest.sound_play(sound, {gain = 0.1, to_player = player:get_player_name()})
                    else
                        if sound_gain*(doppler/10) > sound_gain then
                            minetest.sound_play(sound, {gain = sound_gain, to_player = player:get_player_name()})
                        else
                            minetest.sound_play(sound, {gain = sound_gain*(doppler/10), to_player = player:get_player_name()})
                        end
                    end
                end)
            else
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
    end
end

--Testing stuff

--Node
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
})

--Moving sound emitter
local test_entity = {
	physical = false,
	timer = 0,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5},
	textures = {"default_steel_block.png"},
	lastpos= {},
	collisionbox = {0, 0, 0, 0, 0, 0},
}
test_entity.on_step = function(self, dtime, pos)--Moving sound source
    sound_distance_play(self.object:get_pos(), "default_place_node", 10, 100, true, self.object:get_yaw(), self.object:get_velocity())--A repeating short sound
    self.timer = (self.timer or 0) + dtime
    if self.timer > 40 then
        self.object:remove()
    end
end

minetest.register_entity("sound_distance:test_entity", test_entity)

--Below sound speed
minetest.register_craftitem("sound_distance:test_item", {
	inventory_image = "default_steel_block.png",
	description = "Moving sound source (TEST)",
    stack_max = 1,
    on_use = function (itemstack, user, pointed_thing)
		local pos = user:getpos()
		local dir = user:get_look_dir()
		local yaw = user:get_look_horizontal()
		if pos and dir and yaw then
			pos.y = pos.y + 1.6
			local obj = minetest.add_entity(pos, "sound_distance:test_entity")
			if obj then
				obj:setvelocity({x=dir.x * 12, y=dir.y * 12, z=dir.z * 12})
				obj:setyaw(yaw)
				local ent = obj:get_luaentity()
				if ent then
					ent.player = ent.player or user
			itemstack = ""
				end
			end
		end
		return itemstack
    end,
})

--Above sound speed (delayed sound)
minetest.register_craftitem("sound_distance:ultrasonic_item", {
	inventory_image = "default_steel_block.png",
	description = "Ultrasonic sound source (TEST)",
    stack_max = 1,
    on_use = function (itemstack, user, pointed_thing)
		local pos = user:getpos()
		local dir = user:get_look_dir()
		local yaw = user:get_look_horizontal()
		if pos and dir and yaw then
			pos.y = pos.y + 1.6
			local obj = minetest.add_entity(pos, "sound_distance:test_entity")
			if obj then
				obj:setvelocity({x=dir.x * 345, y=dir.y * 345, z=dir.z * 345})
				obj:setyaw(yaw)
				local ent = obj:get_luaentity()
				if ent then
					ent.player = ent.player or user
			itemstack = ""
				end
			end
		end
		return itemstack
    end,
})

--At sound speed (sonic boom and only people behind the object can hear it)
minetest.register_craftitem("sound_distance:sound_speed_item", {
	inventory_image = "default_steel_block.png",
	description = "Sound speed sound source (TEST)",
    stack_max = 1,
    on_use = function (itemstack, user, pointed_thing)
		local pos = user:getpos()
		local dir = user:get_look_dir()
		local yaw = user:get_look_horizontal()
		if pos and dir and yaw then
			pos.y = pos.y + 1.6
			local obj = minetest.add_entity(pos, "sound_distance:test_entity")
			if obj then
				obj:setvelocity({x=dir.x * 340, y=dir.y * 340, z=dir.z * 340})
				obj:setyaw(yaw)
				local ent = obj:get_luaentity()
				if ent then
					ent.player = ent.player or user
			itemstack = ""
				end
			end
		end
		return itemstack
    end,
})]]
