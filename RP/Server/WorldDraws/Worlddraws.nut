
local AllDraws3D = [];

class Draw3DModel extends ORM.Model </ table="world_draws" /> {
    </ primary_key = true, auto_increment = true />
    id = -1

    </ type = "VARCHAR(255)", not_null = true />
    text = ""

    </ type = "FLOAT", not_null = true />
    x = 0.0

    </ type = "FLOAT", not_null = true />
    y = 0.0

    </ type = "FLOAT", not_null = true />
    z = 0.0

    </ type = "INTEGER", not_null = true />
    distance = 800

    </ type = "INTEGER", not_null = true />
    color_r = 255

    </ type = "INTEGER", not_null = true />
    color_g = 255

    </ type = "INTEGER", not_null = true />
    color_b = 255

    </ type = "INTEGER", not_null = true />
    color_a = 255

    </ type = "VARCHAR(50)" />
    creator_name = null
}

class Draw3D
{
    constructor(text, x, y, z, distance = 800, color = {r=255, g=255, b=255, a=255}, creatorName = null)
    {
        position = {x = x, y = y, z = z};
        this.text = text;
        this.distance = distance;
        this.color = color;
        creator = creatorName;
        
        local dbRecord = Draw3DModel();
        dbRecord.text = text;
        dbRecord.x = x;
        dbRecord.y = y;
        dbRecord.z = z;
        dbRecord.distance = distance;
        dbRecord.color_r = color.r;
        dbRecord.color_g = color.g;
        dbRecord.color_b = color.b;
        dbRecord.color_a = color.a;
        dbRecord.creator_name = creatorName;
        
        
        if (dbRecord.insert()) {
            id = dbRecord.id;

            local packet = Packet();
            packet.writeUInt8(PacketId.Other);
            packet.writeUInt8(PacketOther.Draw3D);
            packet.writeInt16(id);
            packet.writeString(text +" ("+id+")");
            packet.writeFloat(x);
            packet.writeFloat(y);
            packet.writeFloat(z);
            packet.writeInt32(distance);
            packet.writeUInt8(color.r);
            packet.writeUInt8(color.g);
            packet.writeUInt8(color.b);
            packet.writeUInt8(color.a);
            packet.sendToAll(RELIABLE_ORDERED);
            
            AllDraws3D.append(this);
            SendSystemMessage(pid, "Draw3D '" + text + "' created with ID: " + id);
        } else {
            print("Failed to save Draw3D to database. Error details:");
            print("Text: " + text);
            print("Position: " + x + ", " + y + ", " + z);
            print("Distance: " + distance);
            print("Color: " + color.r + ", " + color.g + ", " + color.b + ", " + color.a);
            print("Creator: " + creatorName);
            
            throw "Failed to save Draw3D to database";
        }
    }

    id = -1;
    text = "";
    distance = 800;
    color = {r=255, g=255, b=255, a=255};
    position = null;
    creator = null;

    static function commandDraw(pid, params)
    {
        if (!checkPermission(pid, LEVEL.MOD)) {
            SendSystemMessage(pid, "You don't have permission to use this command!", {r=250, g=0, b=0});
            return;
        }

        if (params == "") {
            SendSystemMessage(pid, "Usage: /createdraw <text> [distance] [r,g,b,a]", {r=250, g=0, b=0});
            SendSystemMessage(pid, "Example: /createdraw \"Hello World\" 1000 255,0,0,255", {r=200, g=200, b=200});
            return;
        }

        local distance = 800;
        local color = {r=255, g=255, b=255, a=255};
        
        local distancePos = -1;
        local colorPos = -1;
        
        local tokens = split(params, " ");
        for (local i = 0; i < tokens.len(); i++) {
            local token = tokens[i];
            local isNumber = true;
            foreach (ch in token) {
                if (ch < '0' || ch > '9') {
                    isNumber = false;
                    break;
                }
            }
            if (isNumber && token.len() > 0 && distancePos == -1) {
                distancePos = i;
                distance = token.tointeger();
                if (distance < 1) distance = 800;
            }
        }

        for (local i = 0; i < tokens.len(); i++) {
            if (tokens[i].find(",") != null && colorPos == -1) {
                colorPos = i;
                try {
                    local colorParts = split(tokens[i], ",");
                    if (colorParts.len() == 4) {
                        color = {
                            r = colorParts[0].tointeger(),
                            g = colorParts[1].tointeger(),
                            b = colorParts[2].tointeger(),
                            a = colorParts[3].tointeger()
                        };
                        
                        if (color.r < 0) color.r = 0;
                        if (color.r > 255) color.r = 255;
                        if (color.g < 0) color.g = 0;
                        if (color.g > 255) color.g = 255;
                        if (color.b < 0) color.b = 0;
                        if (color.b > 255) color.b = 255;
                        if (color.a < 0) color.a = 0;
                        if (color.a > 255) color.a = 255;
                    }
                } catch (e) {
                    print("Color conversion error: " + e);
                }
            }
        }
        
        local textParts = [];
        for (local i = 0; i < tokens.len(); i++) {
            if (i != distancePos && i != colorPos) {
                textParts.append(tokens[i]);
            }
        }
        local text = implode(textParts, " ");
        
        local playerName = getPlayerName(pid);
        local pos = getPlayerPosition(pid);
        try {
            Draw3D(text, pos.x, pos.y, pos.z, distance, color, playerName);
        } catch (e) {
            SendSystemMessage(pid, "Error creating Draw3D: " + e, {r=250, g=0, b=0});
            print("Error in Draw3D constructor: " + e);
        }
    }

    static function commandRemoveDraw(pid, params)
    {
        if (!checkPermission(pid, LEVEL.MOD)) {
            SendSystemMessage(pid, "You don't have permission to use this command!", {r=250, g=0, b=0});
            return;
        }

        if (params == "") {
            SendSystemMessage(pid, "Usage: /removedraw <id>", {r=250, g=0, b=0});
            return;
        }

        local cleanParams = strip(params);
        if (cleanParams.len() == 0) {
            SendSystemMessage(pid, "Usage: /removedraw <id>", {r=250, g=0, b=0});
            return;
        }

        local isNumber = true;
        foreach (ch in cleanParams) {
            if (ch < '0' || ch > '9') {
                isNumber = false;
                break;
            }
        }

        if (!isNumber) {
            SendSystemMessage(pid, "Error: ID must be a number", {r=250, g=0, b=0});
            return;
        }

        local drawId = cleanParams.tointeger();
        foreach(index, draw in AllDraws3D) {
            if(draw.id == drawId) {
                remove3DDrawByIndex(index);
                SendSystemMessage(pid, "Draw3D with ID " + drawId + " removed!");
                return;
            }
        }
        SendSystemMessage(pid, "Draw3D with ID " + drawId + " not found!", {r=250, g=0, b=0});
    }

    static function commandListDraws(pid, params)
    {
        if (!checkPermission(pid, LEVEL.MOD)) {
            SendSystemMessage(pid, "You don't have permission to use this command!", {r=250, g=0, b=0});
            return;
        }

        if (AllDraws3D.len() == 0) {
            SendSystemMessage(pid, "No Draw3D objects found.");
            return;
        }

        SendSystemMessage(pid, "=== Draw3D Objects ===", {r=0, g=200, b=200});
        foreach(draw in AllDraws3D) {
            local creatorInfo = draw.creator ? " | Creator: " + draw.creator : "";
            local message = "ID: " + draw.id + " | Text: " + draw.text + " | Distance: " + draw.distance + creatorInfo;
            SendSystemMessage(pid, message);
        }
    }
}

addChatCommand("createdraw", Draw3D.commandDraw);
addChatCommand("removedraw", Draw3D.commandRemoveDraw);
addChatCommand("listdraws", Draw3D.commandListDraws);

function remove3DDrawByIndex(index)
{
    if (index < 0 || index >= AllDraws3D.len()) {
        return;
    }

    local draw = AllDraws3D[index];
    
    local dbRecord = Draw3DModel.findOne(@(query) query.where("id", "=", draw.id));
    if (dbRecord) {
        if (dbRecord.remove()) {
            print("Draw3D removed from database: " + draw.id);
        } else {
            print("Failed to remove Draw3D from database: " + draw.id);
        }
    } else {
        print("Draw3D not found in database: " + draw.id);
    }

    local packet = Packet();
    packet.writeUInt8(PacketId.Other);
    packet.writeUInt8(PacketOther.Draw3DRemove);
    packet.writeInt16(draw.id);
    packet.sendToAll(RELIABLE_ORDERED);
    
    AllDraws3D.remove(index);
}

function loadDrawsFromDatabase()
{
    try {
        local dbRecords = Draw3DModel.findAll();
        foreach(record in dbRecords) {
            try {
                local draw = {
                    id = record.id,
                    text = record.text,
                    position = {x = record.x, y = record.y, z = record.z},
                    distance = record.distance,
                    color = {r=record.color_r, g=record.color_g, b=record.color_b, a=record.color_a},
                    creator = record.creator_name
                };
                
                AllDraws3D.append(draw);
                
                local packet = Packet();
                packet.writeUInt8(PacketId.Other);
                packet.writeUInt8(PacketOther.Draw3D);
                packet.writeInt16(draw.id);
                packet.writeString(draw.text+" ("+draw.id+")");
                packet.writeFloat(draw.position.x);
                packet.writeFloat(draw.position.y);
                packet.writeFloat(draw.position.z);
                packet.writeInt32(draw.distance);
                packet.writeUInt8(draw.color.r);
                packet.writeUInt8(draw.color.g);
                packet.writeUInt8(draw.color.b);
                packet.writeUInt8(draw.color.a);
                packet.sendToAll(RELIABLE_ORDERED); 
            } catch (e) {
                print("Error loading Draw3D record: " + e);
            }
        }
    } catch (e) {
        print("Error in loadDrawsFromDatabase: " + e);
        print("This might be normal if the table doesn't exist yet - it will be created on first save");
    }
}

addEventHandler("onPlayerJoin", function(pid) {
    foreach(draw in AllDraws3D)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Other);
        packet.writeUInt8(PacketOther.Draw3D);
        packet.writeInt16(draw.id);
        packet.writeString(draw.text+" ("+draw.id+")");
        packet.writeFloat(draw.position.x);
        packet.writeFloat(draw.position.y);
        packet.writeFloat(draw.position.z);
        packet.writeInt32(draw.distance);
        packet.writeUInt8(draw.color.r);
        packet.writeUInt8(draw.color.g);
        packet.writeUInt8(draw.color.b);
        packet.writeUInt8(draw.color.a);
        packet.send(pid, RELIABLE_ORDERED);
    }
});

addEventHandler("onInit", function() {
    loadDrawsFromDatabase();
});