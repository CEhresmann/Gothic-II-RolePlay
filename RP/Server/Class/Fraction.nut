class PlayerFraction
{
    id = -1;
    name = -1;

    classes = null;

    constructor(id, name)
    {
        this.id = id;
        
        this.name = name;
        classes = {};
    }

    function giveClass(pid, classId)
    {
        Player[pid].fractionId = id;
        
        classes[classId].giveClass(pid);
    }
}

Fraction <- {};

function addFraction(id, name)
{
    Fraction[id] <- PlayerFraction(id, name);
    return Fraction[id];
}

function setClassPlayer(pid, fractionId, classId)
{
    Fraction[fractionId].giveClass(pid, classId);

    local packet = Packet()
    packet.writeUInt8(PacketId.Player);
    packet.writeUInt8(PacketPlayer.SetClass);
    packet.writeInt16(fractionId);
    packet.writeInt16(classId);
    packet.send(pid, RELIABLE_ORDERED);
    packet = null;       
}

function command_awans(pid, params)
{
    local args = sscanf("dd", params);
    if (!args) {
        sendMessageToPlayer(pid, 255, 0, 0, "Wpisz /awans <id class> <id player>");
        return;
    }

    local id = args[1];
    if (!isPlayerSpawned(id)) {
        sendMessageToPlayer(pid, 255, 0, 0, "Nie jest aktywny gracz o id "+id+"!");
        return;
    }

    if(!Fraction.rawin(Player[pid].fractionId))
    {
        sendMessageToPlayer(pid, 255, 0, 0, "Nie nale¿ysz do ¿adnej frakcji!");
        return;       
    }

    local fraction = Fraction[Player[pid].fractionId];
    local class_id = args[0];

    if(!fraction.classes.rawin(class_id))
    {
        sendMessageToPlayer(pid, 255, 0, 0, "Niema klasy o podanym id.");
        foreach(_key, _class in fraction.classes)
            sendMessageToPlayer(pid, 255, 0, 0, ""+_key+" - "+_class.name);

        return;
    }

    if(!fraction.classes[Player[pid].classId].isLeader) {
        sendMessageToPlayer(pid, 255, 0, 0, "Nie jesteœ liderem w swojej frakcji.");
        return;       
    }

    setClassPlayer(id, Player[pid].fractionId, class_id);

    sendMessageToPlayer(pid, 0, 255, 0, format("Dosta³eœ klasê %s dla %s", fraction.classes[class_id].name, getPlayerName(id)));
    sendMessageToPlayer(id, 0, 255, 0, format("Dosta³eœ klasê %s od %s", fraction.classes[class_id].name, getPlayerName(pid)));
}

addCommand("awans", command_awans)