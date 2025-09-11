
class BotIntegration
{
    Bots = [];
    Streaming = [];

    function add(bot)
    {
        bot.id = Bots.len();
        Bots.append(bot);
        return bot;
    }

    function update()
    {
        local args = [];

        foreach(_bot in BotIntegration.Bots)
            _bot.onUpdate();

        foreach(_bot in BotIntegration.Streaming)
        {
            local pos = getPlayerPosition(_bot.element)
            if(getDistance3d(pos.x, pos.y, pos.z, _bot.position.x, _bot.position.y, _bot.position.z) < 100)
                continue;

            args.append({id = _bot.id, x = pos.x, y = pos.y, z = pos.z});

            _bot.position.x = pos.x;
            _bot.position.y = pos.y;
            _bot.position.z = pos.z;
        }

        if(args.len() == 0)
            return;

        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.SynchronizePosition);
        packet.writeInt16(args.len());

        foreach(arg in args)
        {
            packet.writeUInt16(arg.id);
            packet.writeFloat(arg.x);
            packet.writeFloat(arg.y);
            packet.writeFloat(arg.z);
        }

        packet.send(RELIABLE);
        packet = null;
    }

    function packetPosition(bot)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.SynchronizePosition);
        packet.writeUInt16(bot.id);
        packet.writeFloat(bot.position.x);
        packet.writeFloat(bot.position.y);
        packet.writeFloat(bot.position.z);
        packet.send(RELIABLE_ORDERED);
    }

    function packetAttack(bot, target, _type, dmg = null)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Bot);
        packet.writeUInt8(PacketBot.AttackPlayer);
        packet.writeUInt16(bot.id);
        packet.writeUInt16(target);
        packet.writeInt8(_type);
        if(dmg != null)
            packet.writeInt16(dmg);

        packet.send(RELIABLE_ORDERED);
    }

    function onPacket(packet)
    {
        local id = packet.readUInt8();
        if(id != PacketId.Bot)
            return;

        id = packet.readUInt8();
        switch(id)
        {
            case PacketBot.Init:
                local bot = getBot(packet.readUInt16());
                bot.setPosition(packet.readFloat(), packet.readFloat(), packet.readFloat())
                bot.setAngle(packet.readInt16())
                bot.setHealth(packet.readUInt16())
                bot.playAnimation(packet.readString())
                bot.setWeaponMode(packet.readInt16());
            break;
            case PacketBot.Spawn:
                local bot = getBot(packet.readUInt16());
                bot.isStreamer = packet.readBool();
                bot.spawn();

                if(bot.isStreamer)
                    BotIntegration.Streaming.append(bot);
            break;
            case PacketBot.Respawn:
                local bot = getBot(packet.readUInt16());
                bot.respawn(packet.readFloat(), packet.readFloat(), packet.readFloat());
            break;
            case PacketBot.Unspawn:
                local bot = getBot(packet.readUInt16());
                if(bot.isStreamer)
                    BotIntegration.Streaming.remove(BotIntegration.Streaming.find(bot));

                bot.isStreamer = false;
                bot.unspawn();
            break;
            case PacketBot.SynchronizePosition:
                local bot = getBot(packet.readUInt16());
                if(bot.isStreamer)
                    return;
                bot.synchronizePositionFromPlayer(packet.readFloat(), packet.readFloat(), packet.readFloat())
            break;
            case PacketBot.SynchronizeAngle:
                local bot = getBot(packet.readUInt16());
                bot.setAngle(packet.readInt16())
            break;
            case PacketBot.SynchronizeWeaponMode:
                local bot = getBot(packet.readUInt16());
                bot.setWeaponMode(packet.readInt16())
            break;
            case PacketBot.PlayAnimation:
                local bot = getBot(packet.readUInt16());
                bot.playAnimation(packet.readString());
            break;
            case PacketBot.SynchronizeHealth:
                local bot = getBot(packet.readUInt16());
                bot.setHealth(packet.readUInt16());
            break;
            case PacketBot.AttackPlayer:
                local bot = getBot(packet.readUInt16());
                bot.attack(packet.readUInt16(), packet.readInt16());
            break;
        }
    }

    function onPlayerHit(kid, pid, dmg)
    {
        if(!(pid >= getMaxSlots() || kid >= getMaxSlots())) {
            return;
        }
        eventValue(0);

        if(pid == heroId)
        {
            local bot = getBot(kid - getMaxSlots());
            BotIntegration.packetAttack(bot, pid, 1);
        }
        if (kid == heroId)
        {
            local bot = getBot(pid - getMaxSlots());
            BotIntegration.packetAttack(bot, kid, 2, dmg);
        }
    }
}

setTimer(function()
{
    BotIntegration.update()
}, 200, 0)

function getNpcByName(name)
{
    foreach(_bot in BotIntegration.Bots)
    {
        if(_bot.name == name)
        {
            return _bot;
        }
    }
    return null;
}

function getNpcByRealId(name)
{
    foreach(_bot in BotIntegration.Bots)
    {
        if(_bot.element == name)
        {
            return _bot;
        }
    }
    return null;
}

function getBot(id)
{
    if(id in BotIntegration.Bots)
        return BotIntegration.Bots[id];

    return null;
}

addEventHandler("onPacket", BotIntegration.onPacket)
addEventHandler("onPlayerHit", BotIntegration.onPlayerHit)