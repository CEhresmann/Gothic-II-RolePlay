Player <- {
    loggIn = false

    fractionId = -1,
    classId = -1,
    gui = -1,

    description = array(getMaxSlots(), "")
}


function getPlayerClass(pid)
{
    if(!Fraction.rawin(Player.fractionId))
        return "Bd";

    if(!Fraction[Player.fractionId].classes.rawin(Player.classId))
        return "Bd";

    return Fraction[Player.fractionId].classes[Player.classId].name;
}

Player.packetLoggIn <- function(name, password){
    local packet = Packet();
    packet.writeUInt8(PacketId.Player);
    packet.writeUInt8(PacketPlayer.LoggIn);
    packet.writeString(name);
    packet.writeString(password);
    packet.send(RELIABLE_ORDERED);
    packet = null;
}

Player.packetTrade <- function(focusId, instance, name, amount, gold){
    local packet = Packet();
    packet.writeUInt8(PacketId.Player);
    packet.writeUInt8(PacketPlayer.Trade);
    packet.writeInt16(focusId);
    packet.writeString(instance);
    packet.writeString(name);
    packet.writeInt16(amount);
    packet.writeInt16(gold);
    packet.send(RELIABLE_ORDERED);
    packet = null;
}

Player.packetRegister <- function(name, password){
    local packet = Packet();
    packet.writeUInt8(PacketId.Player);
    packet.writeUInt8(PacketPlayer.Register);
    packet.writeString(name);
    packet.writeString(password);
    packet.send(RELIABLE_ORDERED);
    packet = null;
}

Player.packetVisual <- function(bodyModel, bodyTxt, headModel, headTxt) {
    local packet = Packet();
    packet.writeUInt8(PacketId.Player);
    packet.writeUInt8(PacketPlayer.Visual);
    packet.writeString(bodyModel);
    packet.writeInt16(bodyTxt);
    packet.writeString(headModel);
    packet.writeInt16(headTxt);
    packet.send(RELIABLE_ORDERED);
    packet = null;
}

Player.packetWalk <- function(walkStyle) {
    local packet = Packet();
    packet.writeUInt8(PacketId.Player);
    
    if (typeof walkStyle == "string") {
        packet.writeUInt8(PacketPlayer.WalkString);
        packet.writeString(walkStyle);
    } else {
        packet.writeUInt8(PacketPlayer.Walk);
        packet.writeInt16(walkStyle);
    }
    
    packet.send(RELIABLE_ORDERED);
    packet = null;
}

Player.onPacket <- function(packet)
{
    local packetType = packet.readUInt8();
    if(packetType != PacketId.Player)
        return;

    packetType = packet.readUInt8();
    switch(packetType)
    {
        case PacketPlayer.Register:
            Interface.Register.hide();
            Interface.baseInterface(false);
			ShowChat(true);
        break;
        case PacketPlayer.LoggIn:
            Interface.LoggIn.hide();
            Interface.baseInterface(false);
			ShowChat(true);
        break;
        case PacketPlayer.SetClass:
            Player.fractionId = packet.readInt16();
            Player.classId = packet.readInt16();
        break;
        case PacketPlayer.Description:
            Player.description[packet.readInt16()] = packet.readString();
        break;
        case PacketPlayer.Animation:
            playAni(packet.readInt16(), packet.readString());
        break;
    }
}

addEventHandler("onPacket", Player.onPacket);

function setPlayerWalkStyle(pid, id)
{
    Player.packetWalk(id);
}


addEventHandler("onPlayerUseItem", function(id, item, from, to)
{
    if (id != heroId)
        return;

    if (from != 0)
        return;

    local packet = Packet();
    packet.writeUInt8(PacketId.Player);
    packet.writeUInt8(PacketPlayer.UseItem);
    packet.writeString(item.instance);
    packet.send(RELIABLE_ORDERED);
    packet = null;
});

addEventHandler("onPlayerSpellCast", function(playerid, item, spell) 
{
    if (playerid != heroId)
        return;

    local instance = item.instance;
    local spellName = spell.getName();

    if(instance.find("ITSC_") != null) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.UseItem);
        packet.writeString(instance);
        packet.send(RELIABLE_ORDERED);
        packet = null;
    }
});


addEventHandler("onShoot", function() 
{
    local wp = getPlayerWeaponMode(heroId);
    if(wp == 5){
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.UseItem);
        packet.writeString("ITRW_ARROW");
        packet.writeInt16(1);
        packet.send(RELIABLE_ORDERED);
        packet = null;
    }else if(wp == 6) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.UseItem);
        packet.writeString("ITRW_BOLT");
        packet.writeInt16(1);
        packet.send(RELIABLE_ORDERED);
        packet = null;
    }
});

