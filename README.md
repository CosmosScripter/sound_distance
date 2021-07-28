Sound distance mod [v1.0] by Cosmos
==========================
This mod only adds a function, which plays a sound with a different gain depending on the distance to the sound origin.
It can be used so players can know if they're either closer or further to the sound origin.

Incase the sound source is moving, it has a pitch change if moving towards the player.

How to use:

sound_distance_play(pos, sound, sound_gain, distance, moving, yaw, vel, force_sound_speed)

Example:

sound_distance_play(self.object:get_pos(), "example_sound", 1, 16, true, self.object:get_yaw(), self.object:get_velocity(), false)
---------------------------------------------
See: license.txt for license.

Special thanks to Astrobe, as their feedback improved this mod.
Special thanks to TenPlus1, as the "get_distance" function is from mobs redo.
---------------------------------------------
Depends on: default, tnt.
---------------------------------------------

==HOW TO INSTALL THE MOD==
1.Download the mod, it may be a ZIP file.
2. Extract the folder inside to somewhere on the computer (if its a ZIP file).
3.Make sure that when you open the folder, you can directly find "README.md" in the listing. If you just see another folder, move that folder up one level and delete the old one.
4.Rename the folder to "sound_distance" incase it has another name.
5.Move the mod to "minetest/mods/" or "~/.minetest/mods/".
6.Here we go!
============================
