/*
    ChangeLog:
    Added command create draw ~ Blaszunia



*/
local AllDraws3D = [];

class Draw3D
{
    constructor(drawname, x, y, z, expiration)
    {
        position = {x = x, y = y, z = z};

        left = expiration;
        name = drawname;

        id = AllDraws3D.len();

        local packet = Packet();
        packet.writeUInt8(PacketId.Other);
        packet.writeUInt8(PacketOther.Draw3D);
        packet.writeInt16(AllDraws3D.len());
        packet.writeString(drawname);
        packet.writeFloat(x);
        packet.writeFloat(y);
        packet.writeFloat(z);
        packet.sendToAll(RELIABLE_ORDERED);
        packet = null;

        AllDraws3D.append(this);
    }
	//Zapis
    //Wczyt
	function commandDraw(pid,params){

        local args = sscanf("ds", params)
        if(args){
            //TODO: Dodac sprawdzenie czy gracz jest adminem
            local pos = getPlayerPosition(pid)
            Draw3D(args[1],pos.x,pos.y,pos.z,args[0]);
                    //TODO: Zapis
           }
           else  sendMessageToPlayer(pid,250,0,0,"Wrong parameters! Use: /createdraw <name> <second>");
	}

    id = -1;
    name = "";

    left = null;
    position = null;
}
addCommand("createdraw", Draw3D.commandDraw)
//addEventHandler("onPlayerCommand",Draw3D.commandDraw);
function remove3DDraw(object)
{
    foreach(id, _draw in AllDraws3D)
    {
        if(object == _draw)
        {
            local packet = Packet();
            packet.writeUInt8(PacketId.Other);
            packet.writeUInt8(PacketOther.Draw3DRemove);
            packet.writeInt16(id);
            packet.sendToAll(RELIABLE_ORDERED);
            packet = null;
            AllDraws3D.remove(id);
            return;
        }
    }
}

addEventHandler("onSecond", function() {
    foreach(_indeks, _draw in AllDraws3D)
    {
        if(_draw.left == -1)
            continue;

        _draw.left = _draw.left - 1;
        if(_draw.left <= 0)
            remove3DDraw(_draw)
    }
})

addEventHandler("onPlayerJoin", function(pid) {
    foreach(_indeks, _draw in AllDraws3D)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Other);
        packet.writeUInt8(PacketOther.Draw3D);
        packet.writeInt16(_draw.id);
        packet.writeString(_draw.name);
        packet.writeFloat(_draw.position.x);
        packet.writeFloat(_draw.position.y);
        packet.writeFloat(_draw.position.z);
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }
})