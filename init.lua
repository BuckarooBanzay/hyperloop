--[[

	Hyperloop Mod
	=============

	v0.01 by JoSt

	Copyright (C) 2017 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	History:
	2017-06-18  v0.01  First version

]]--


hyperloop = {
    tAllStations = {},
	tWifi = {},
	booking = {},
}

hyperloop.debugging = true

dofile(minetest.get_modpath("hyperloop") .. "/utils.lua")
dofile(minetest.get_modpath("hyperloop") .. "/tube.lua")
dofile(minetest.get_modpath("hyperloop") .. "/booking.lua")
dofile(minetest.get_modpath("hyperloop") .. "/junction.lua")
dofile(minetest.get_modpath("hyperloop") .. "/map.lua")
dofile(minetest.get_modpath("hyperloop") .. "/door.lua")
dofile(minetest.get_modpath("hyperloop") .. "/seat.lua")
dofile(minetest.get_modpath("hyperloop") .. "/pod.lua")
dofile(minetest.get_modpath("hyperloop") .. "/lcd.lua")
dofile(minetest.get_modpath("hyperloop") .. "/wifi.lua")
--dofile(minetest.get_modpath("hyperloop") .. "/robot.lua")

print ("[MOD] Hyperloop loaded")
