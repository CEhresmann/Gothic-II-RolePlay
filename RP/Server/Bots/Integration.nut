class BotIntegration
{
    Bots = [];

    function add(bot)
    {
        local pos = bot.position;
        local chunk = Grid.find(pos.x, pos.z);

        bot.id = Bots.len();
        chunk.addBot(bot.id);
        bot.grid = chunk;

        Bots.append(bot);

        return bot;
    }

    function playerUpdate(pid, x,y,z)
    {
        local oldChunk = BotPlayer[pid].grid;
        local chunk = Grid.find(x, z);
        if(chunk == oldChunk)
            return;

        local oldChunks = Grid.nearest(oldChunk, 2);
        local newChunks = Grid.nearest(chunk, 2);

        foreach(_chunk in oldChunks)
        {
            if (newChunks.find(_chunk) == null)
                _chunk.removePlayer(pid)
        }

        foreach(_chunk in newChunks)
        {
            if(oldChunks.find(_chunk))
                continue;

            _chunk.addPlayer(pid);
        }

        BotPlayer[pid].grid = chunk;
    }

    function playerLoggIn(pid)
    {
        local pos = getPlayerPosition(pid);
        local chunk = Grid.find(pos.x, pos.z);
        local newChunks = Grid.nearest(chunk, 2);

        foreach(_chunk in newChunks)
            _chunk.addPlayer(pid);

        BotPlayer[pid].grid = chunk;
    }

    function playerJoin(pid)
    {
        foreach(_Bot in BotIntegration.Bots)
            BotIntegration.packetInit(_Bot, pid);
    }

    function update()
    {
        foreach(_Bot in BotIntegration.Bots)
            _Bot.update();
    }

    function packetUnSpawn(botId, playerId)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.Unspawn);
        packet.writeUInt16(botId);
        packet.send(playerId, RELIABLE_ORDERED);
    }

    function packetSpawn(botId, playerId, isStreamer)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.Spawn);
        packet.writeUInt16(botId);
        packet.writeBool(isStreamer);
        packet.send(playerId, RELIABLE_ORDERED);
    }

    function packetRespawn(bot, playerId)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.Respawn);
        packet.writeUInt16(bot.id);
        packet.writeFloat(bot.position.x);
        packet.writeFloat(bot.position.y);
        packet.writeFloat(bot.position.z);
        packet.send(playerId, RELIABLE_ORDERED);
    }

    function packetInit(bot, playerId)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.Init);
        packet.writeUInt16(bot.id);
        packet.writeFloat(bot.position.x);
        packet.writeFloat(bot.position.y);
        packet.writeFloat(bot.position.z);
        packet.writeInt16(bot.angle);
        packet.writeUInt16(bot.hp);
        packet.writeString(bot.animation);
        packet.writeInt16(bot.weaponMode);
        packet.send(playerId, RELIABLE_ORDERED);
    }

    function packetStreamer(bot, playerId)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.SynchronizeStreamer);
        packet.writeUInt16(bot.id);
        packet.writeUInt16(bot.streamer);
        packet.send(playerId, RELIABLE_ORDERED);
    }

    function packetAngle(bot, playerId)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.SynchronizeAngle);
        packet.writeUInt16(bot.id);
        packet.writeInt16(bot.angle);
        packet.send(playerId,RELIABLE_ORDERED);
    }

    function packetWeaponMode(bot, playerId)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.SynchronizeWeaponMode);
        packet.writeUInt16(bot.id);
        packet.writeInt16(bot.weaponMode);
        packet.send(playerId,RELIABLE_ORDERED);
    }

    function packetPosition(bot, playerId)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.SynchronizePosition);
        packet.writeUInt16(bot.id);
        packet.writeFloat(bot.position.x);
        packet.writeFloat(bot.position.y);
        packet.writeFloat(bot.position.z);
        packet.send(playerId,RELIABLE_ORDERED);
    }

    function packetAnimation(bot, playerId)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.PlayAnimation);
        packet.writeUInt16(bot.id);
        packet.writeString(bot.animation);
        packet.send(playerId,RELIABLE_ORDERED);
    }

    function packetHealth(bot, playerId)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.SynchronizeHealth);
        packet.writeUInt16(bot.id);
        packet.writeUInt16(bot.hp);
        packet.send(playerId,RELIABLE_ORDERED);
    }

    function packetAttack(bot, target, playerId, mode)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.AttackPlayer);
        packet.writeUInt16(bot.id);
        packet.writeUInt16(target);
        packet.writeInt16(mode);
        packet.send(playerId,RELIABLE_ORDERED);
    }

    function onBotPosition(botId, x,y,z)
    {
        local bot = getBot(botId);
        if(!bot)
            return;

        bot.position = {x = x, y = y, z = z};

        local chunk = Grid.find(bot.position.x, bot.position.z);
        if(bot.grid == chunk)
            return;

        bot.grid.removeBot(botId);
        chunk.addBot(botId);

        bot.grid = chunk;
        bot.onPositionSynchronize();
    }

    function onPacket(pid, packet)
    {
        local id = packet.readUInt8();
        if(id != PacketId.Bot)
            return;

        id = packet.readUInt8();
        switch(id)
        {
            case PacketBot.SynchronizePosition:
                local synchBots = packet.readInt16();
                for(local i = 0; i < synchBots; i ++)
                {
                    local botId = packet.readUInt16();
                    local x = packet.readFloat();
                    local y = packet.readFloat();
                    local z = packet.readFloat();

                    BotIntegration.onBotPosition(botId, x, y, z);

                    local packet = Packet();
                    packet.writeUInt8(PacketId.Bot);
                    packet.writeUInt8(PacketBot.SynchronizePosition);
                    packet.writeUInt16(botId);
                    packet.writeFloat(x);
                    packet.writeFloat(y);
                    packet.writeFloat(z);
                    packet.sendToAll(RELIABLE);
                    packet = null;
                }
            break;
            case PacketBot.AttackPlayer:
                local bot = getBot(packet.readUInt16());
                local targetId = packet.readUInt16();
                local typeD = packet.readInt8();

                switch(typeD)
                {
                    case 1:
                        bot.hitPlayer(targetId);
                    break;
                    case 2:
                        bot.hitByPlayer(targetId, packet.readInt16());
                    break;
                }
            break;
        }
    }

    function onGameTimeEvent(tag)
    {
        if(tag.find("botSchedule") == null)
            return;

        tag = tag.slice(12, tag.len());
        tag = split(tag, "_");

        BotIntegration.Bots[tag[0].tointeger()].onGetScheduleEvent(tag[1].tointeger());
    }
}

function getBot(id)
{
    if(id in BotIntegration.Bots)
        return BotIntegration.Bots[id];

    return null;
}

setTimer(function()
{
	BotIntegration.update();
}, 300, 0)

addEventHandler("onPlayerJoin", BotIntegration.playerJoin)
addEventHandler("onPlayerLoggIn", BotIntegration.playerLoggIn)
addEventHandler("onPlayerPositionChange", BotIntegration.playerUpdate)
addEventHandler("onGameTimeEvent", BotIntegration.onGameTimeEvent)
addEventHandler("onPacket", BotIntegration.onPacket)