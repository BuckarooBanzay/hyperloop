--[[

	Hyperloop Mod
	=============

	Copyright (C) 2017 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	History:
	see init.lua

]]--


function hyperloop.update_all_booking_machines()
	for _, dataset in pairs(hyperloop.tAllStations) do
		if dataset.booking_pos ~= nil then
			local pos = minetest.string_to_pos(dataset.booking_pos)
			minetest.registered_nodes["hyperloop:booking"].update(pos)
		end
	end
end


-- return sorted list of all network stations
local function get_station_list(station_name)	
	local stations = hyperloop.get_network_stations(station_name)
	if stations == nil then
		return nil
	end
	table.sort(stations)
	return stations
end

-- Form spec for the station list
-- param station_name: local station name
local function formspec(station_name)
	local tRes = {"size[10,9]label[2,0; Wähle dein Ziel :: Select your destination]"}
	tRes[2] = "label[1,1;Destination]label[3,1;Distance]label[4.5,1;Position]label[6,1;Local Info]"
	local local_pos = hyperloop.tAllStations[station_name]["pos"]
	for idx,dest_name in ipairs(get_station_list(station_name)) do
		local ypos = 1 + idx*0.8
		local ypos2 = ypos - 0.2
		local dest_info = hyperloop.tAllStations[dest_name]["booking_info"] or ""
		local dest_pos = hyperloop.tAllStations[dest_name]["pos"]
		local distance = hyperloop.distance(local_pos, dest_pos)
		tRes[#tRes+1] = "button_exit[0,"..ypos2..";1,1;button;"..idx.."]"
		tRes[#tRes+1] = "label[1,"..ypos..";"..dest_name.."]"
		tRes[#tRes+1] = "label[3,"..ypos..";"..distance.." m]"
		tRes[#tRes+1] = "label[4.2,"..ypos..";"..dest_pos.."]"
		tRes[#tRes+1] = "label[6,"..ypos..";"..dest_info.."]"
	end
	return table.concat(tRes)
end

minetest.register_node("hyperloop:booking", {
		description = "Hyperloop Booking Machine",
		tiles = {
			-- up, down, right, left, back, front
			"hyperloop_booking.png",
			"hyperloop_booking.png",
			"hyperloop_booking.png",
			"hyperloop_booking.png",
			"hyperloop_booking.png",
			"hyperloop_booking_front.png",
		},

		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local meta = minetest.get_meta(pos)
			local formspec = "size[6,4]"..
			"label[0,0;Please insert station name to which this booking machine belongs]" ..
			"field[0.5,1.5;5,1;name;Station name;MyTown]" ..
			"field[0.5,2.7;5,1;info;Additional station information;]" ..
			"button_exit[2,3.6;2,1;exit;Save]"
			meta:set_string("formspec", formspec)
		end,

		on_receive_fields = function(pos, formname, fields, player)
			local meta = minetest.get_meta(pos)
			-- station name entered?
			if fields.name ~= nil then
				local station_name = string.trim(fields.name)
				if station_name == "" then
					return
				end
				-- valid name entered?
				if hyperloop.tAllStations[station_name] ~= nil then
					if hyperloop.tAllStations[station_name]["booking_pos"] ~= nil then
						minetest.chat_send_player(player:get_player_name(), 
							"Error: Station already has a booking machine!")
						return
					end
					-- check distance to the named station
					local station_pos = minetest.string_to_pos(hyperloop.tAllStations[station_name].pos)
					if hyperloop.distance(pos, station_pos) > 30 then
						minetest.chat_send_player(player:get_player_name(), "Error: station too far away!")
						return
					end
					-- store meta and generate station formspec
					hyperloop.tAllStations[station_name]["booking_pos"] = minetest.pos_to_string(pos)
					hyperloop.tAllStations[station_name]["booking_info"] = string.trim(fields.info)
					meta:set_string("station_name", station_name)
					meta:set_string("infotext", "Station: "..station_name)
					meta:set_string("formspec", formspec(station_name))
					hyperloop.update_all_booking_machines()
				else
					minetest.chat_send_player(player:get_player_name(), "Error: Invalid station name!")
				end
			-- destination selected?
			elseif fields.button ~= nil then
				local station_name = meta:get_string("station_name")
				-- place booking
				local idx = tonumber(fields.button)
				local destination = get_station_list(station_name)[idx]
				hyperloop.booking[station_name] = destination
				-- open the pod door
				hyperloop.open_pod_door(station_name)
			end
		end,

		on_destruct = function(pos)
			local meta = minetest.get_meta(pos)
			local station_name = meta:get_string("station_name")
			if hyperloop.tAllStations[station_name] ~= nil 
			and hyperloop.tAllStations[station_name]["booking_pos"] ~= nil then
				hyperloop.tAllStations[station_name]["booking_pos"] = nil
			end
		end,
		
		update = function(pos)
			if hyperloop.debugging then
				print("Booking machine update")
			end
			local meta = minetest.get_meta(pos)
			local station_name = meta:get_string("station_name")
			local stations = get_station_list(station_name)
			meta:set_string("formspec", formspec(station_name, stations))
		end,
		
		light_source = 2,
		paramtype2 = "facedir",
		groups = {cracky=2},
		is_ground_content = false,
	})



