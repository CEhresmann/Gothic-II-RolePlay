class AuthSession extends ORM.Model </ table="auth_sessions" /> {
    </ primary_key = true, auto_increment = true />
    id = -1

    </ type = "INTEGER", not_null = true />
    player_id = -1
	
    </ type = "VARCHAR(20)" />
    discord_id = null

    </ type = "VARCHAR(6)", not_null = true />
    auth_code = ""

    </ type = "INTEGER", not_null = true />
    auth_code_expire = 0
	
	is_authenticated = false
}

Auth <- {
    AuthSessions = {}
}

function Auth::GenerateAuthCode(player) {
    local pid = player.pid;

    local code = "";
    for (local i = 0; i < 6; i++) {
        code += format("%d", rand() % 10);
    }

    local expiration = getTickCount() + (5 * 60 * 1000);

    local session = AuthSession.findOne(@(q) q.where("player_id", "=", player.id));
    if(!session) {
        session = AuthSession();
        session.player_id = player.id;
    }

    session.auth_code = code;
    session.auth_code_expire = expiration;
    session.save();

    AuthSessions[pid] <- {
        auth_code = code,
        auth_code_expire = expiration
    };

    return code;
}

function Auth::IsAuthenticated(player) {
    return player.is_authenticated;
}

addEventHandler("onPlayerDisconnect", function(playerId, reason) {
    if (playerId in Auth.AuthSessions) {
        Auth.AuthSessions.rawdelete(playerId);
    }
});

addEventHandler("onPlayerLoggIn", function(playerId) {
    local player = Player[playerId];
    player.is_authenticated = false;

    local packet = Packet();
    packet.writeUInt8(PacketId.Auth);
    packet.writeUInt8(AuthPacket.ShowAuthScreen);
    packet.send(playerId, RELIABLE_ORDERED);

    local authCode = Auth.GenerateAuthCode(player);
    local packet2 = Packet();
    packet2.writeUInt8(PacketId.Auth);
    packet2.writeUInt8(AuthPacket.SetAuthCode);
    packet2.writeString(authCode);
    packet2.send(playerId, RELIABLE_ORDERED);
});

addEventHandler("onPacket", function(playerId, packet) {
    local packetId = packet.readUInt8();
    if (packetId != PacketId.Auth) return;

    local subPacketId = packet.readUInt8();
    local player = Player[playerId];

    switch (subPacketId) {
        case AuthPacket.RequestNewCode:
            local authCode = Auth.GenerateAuthCode(player);
            local packet = Packet();
            packet.writeUInt8(PacketId.Auth);
            packet.writeUInt8(AuthPacket.SetAuthCode);
            packet.writeString(authCode);
            packet.send(playerId, RELIABLE_ORDERED);
            break;
        case AuthPacket.ConfirmCode:
            local code = packet.readString();
            if (playerId in Auth.AuthSessions && Auth.AuthSessions[playerId].auth_code == code && getTickCount() < Auth.AuthSessions[playerId].auth_code_expire) {
                player.is_authenticated = true;

                local successPacket = Packet();
                successPacket.writeUInt8(PacketId.Auth);
                successPacket.writeUInt8(AuthPacket.AuthSuccess);
                successPacket.send(playerId, RELIABLE_ORDERED);

                Auth.AuthSessions.rawdelete(playerId);
            } else {
                local errorPacket = Packet();
                errorPacket.writeUInt8(PacketId.Auth);
                errorPacket.writeUInt8(AuthPacket.AuthError);
                errorPacket.writeString("Invalid or expired code. Try again.");
                errorPacket.send(playerId, RELIABLE_ORDERED);
            }
            break;
    }
});