-- configuration
PVP = {}

-- server metadata
local players = {}
local dead_players = {}
local teams = {
    blue = {"TenPlusTwo", "realyg", "Darkf4antom", "KitoCat", "AnthonyDe", "SoulSeeker", "JediKnight"},
    yellow = {"-lipop-", "minetest", "j45", "RUBIUSOMG11", "cephalotus", "Amine35", "realyg"},
    green = {"Elvis26", "DiamondPlane", "gameit", "end", "Skyisblue", "-CrocMoney-", "N4xQ", "LuaFrank"}
}

local team_colours = {
    blue = "#0000FF",
    yellow = "#FFFF00",
    green = "#64f20b"
}

for team, p_table in pairs(teams) do
    for index, member in pairs(p_table) do
        table.insert(players, member)
    end
end

-- Chat coloring
minetest.format_chat_message = function(name, message)
	return minetest.colorize(team_colours[PVP.get_team(name)], "<" ..name .. "> ") .. message
end

--Private Server
minetest.register_on_prejoinplayer(function(name)
    if table.indexof(players, name) >= 1 then
        minetest.log("Welcome ".. name.."!")
    else
        return "Sorry, this is a private server!"
    end
 end)

 --Helper functions
function PVP.get_team(p_name)
    for team, p_table in pairs(teams) do
        if table.indexof(p_table, p_name) > 0 then
            return tostring(team)
        end
    end
end


--minetest. Registering
minetest.register_on_respawnplayer(function(player)
	dead_players[player:get_player_name()] = nil
end)

--PvP logistics
minetest.register_on_punchplayer(function (victim,attacker,time_from_last_punch,tool_capabilities,dir, damage)
    if victim and attacker and table.indexof(dead_players, victim) < 1 then
        local a_name = attacker:get_player_name()
        local v_name = victim:get_player_name()

        if dead_players[v_name] then
            return true
        end

        if PVP.get_team(a_name) ~= PVP.get_team(v_name) then
            local victim_hp = victim:get_hp()
            if victim_hp == 0 then
                return false
            end

            if victim_hp - damage <= 0 then
                dead_players[v_name] = true

                -- Kill History
                minetest.chat_send_all(
                    minetest.colorize(team_colours[PVP.get_team(a_name)], a_name)..
                    minetest.colorize("#FF0000", " has killed ")..
                    minetest.colorize(team_colours[PVP.get_team(v_name)], v_name)
                )
                return false
            end
            victim:set_hp(victim_hp - damage)
        end
        return true
    end
end)
