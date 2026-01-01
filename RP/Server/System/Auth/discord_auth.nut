class DiscordAuthSession extends ORM.Model </ table="discord_auth_sessions" /> {
    </ primary_key = true, auto_increment = true />
    id = -1

    </ type = "INTEGER", not_null = true />
    player_id = -1

    </ type = "VARCHAR(8)", not_null = true />
    auth_code = ""

    </ type = "INTEGER", not_null = true />
    expires_at = 0
}

DiscordAuth <- {
    AuthSessions = {}
}

function DiscordAuth::GenerateAuthCode(player) {
    local pid = player.pid;
    
    if (pid in DiscordAuth.AuthSessions) {
        local oldSession = DiscordAuthSession.findOne(@(q) q.where("player_id", "=", player.id).where("auth_code", "=", DiscordAuth.AuthSessions[pid].auth_code));
        if (oldSession) {
            oldSession.delete();
        }
    }

    local code = "";
    for (local i = 0; i < 8; i++) {
        code += format("%c", rand() % 26 + 65); // A-Z
    }

    local expiration = getTickCount() + (5 * 60 * 1000); // 5 minutes

    local session = DiscordAuthSession();
    session.player_id = player.id;
    session.auth_code = code;
    session.expires_at = expiration;
    session.insert();

    DiscordAuth.AuthSessions[pid] <- {
        auth_code = code,
        expires_at = expiration
    };

    return code;
}

function DiscordAuth::IsAuthenticated(player) {
    return player.discord_id != null;
}

function DiscordAuth::CheckAuthConfirmation(player) {
    if (player.discord_id) {
        return true;
    }

    local account = PlayerAccount.findOne(@(q) q.where("id", "=", player.id));
    if (account && account.discord_id) {
        player.discord_id = account.discord_id;
        return true;
    }

    return false;
}

function DiscordAuth::LinkDiscordAccount(discordId, authCode) {
    local session = DiscordAuthSession.findOne(@(q) q.where("auth_code", "=", authCode));
    if (!session) {
        return { success = false, error = "INVALID_CODE" };
    }

    local currentTime = getTickCount();
    if (session.expires_at < currentTime) {
        session.delete();
        return { success = false, error = "CODE_EXPIRED" };
    }

    local existingAccount = PlayerAccount.findOne(@(q) q.where("discord_id", "=", discordId));
    if (existingAccount && existingAccount.id != session.player_id) {
        return { success = false, error = "DISCORD_ALREADY_LINKED" };
    }

    local account = PlayerAccount.findOne(@(q) q.where("id", "=", session.player_id));
    if (!account) {
        return { success = false, error = "PLAYER_NOT_FOUND" };
    }

    account.discord_id = discordId;
    account.save();

    foreach (pid, player in Player) {
        if (player.id == session.player_id) {
            player.discord_id = discordId;
            
            local successPacket = Packet();
            successPacket.writeUInt8(PacketId.DiscordAuth);
            successPacket.writeUInt8(DiscordAuthPacket.AuthSuccess);
            successPacket.send(pid, RELIABLE_ORDERED);
            
            if (pid in DiscordAuth.AuthSessions) {
                DiscordAuth.AuthSessions.rawdelete(pid);
            }
            break;
        }
    }

    session.delete();

    return { success = true, player_id = session.player_id };
}

function DiscordAuth::VerifyCode(authCode) {
    local session = DiscordAuthSession.findOne(@(q) q.where("auth_code", "=", authCode));
    if (!session) {
        return { valid = false, error = "INVALID_CODE" };
    }

    local currentTime = getTickCount();
    if (session.expires_at < currentTime) {
        session.delete();
        return { valid = false, error = "CODE_EXPIRED" };
    }

    return { 
        valid = true, 
        player_id = session.player_id,
        expires_at = session.expires_at
    };
}

addEventHandler("onPlayerDisconnect", function(playerId, reason) {
    if (playerId in DiscordAuth.AuthSessions) {
        local player = Player[playerId];
        if (player && player.id > 0) {
            local session = DiscordAuthSession.findOne(@(q) q.where("player_id", "=", player.id));
            if (session) {
                session.delete();
            }
        }
        DiscordAuth.AuthSessions.rawdelete(playerId);
    }
});

addEventHandler("onPlayerLoggIn", function(playerId) {
    setTimer(function() {
        if (!isPlayerConnected(playerId)) return;
        
        local player = Player[playerId];
        if (!player || !player.loggIn) return;
        
        if (DiscordAuth.CheckAuthConfirmation(player)) {
            return;
        }

        local packet = Packet();
        packet.writeUInt8(PacketId.DiscordAuth);
        packet.writeUInt8(DiscordAuthPacket.ShowAuthScreen);
        packet.send(playerId, RELIABLE_ORDERED);

        local authCode = DiscordAuth.GenerateAuthCode(player);
        local packet2 = Packet();
        packet2.writeUInt8(PacketId.DiscordAuth);
        packet2.writeUInt8(DiscordAuthPacket.SetAuthCode);
        packet2.writeString(authCode);
        packet2.send(playerId, RELIABLE_ORDERED);
    }, 500, 1);
});

addEventHandler("onPacket", function(playerId, packet) {
    local packetId = packet.readUInt8();
    if (packetId != PacketId.DiscordAuth) return;

    local subPacketId = packet.readUInt8();
    local player = Player[playerId];

    switch (subPacketId) {
        case DiscordAuthPacket.RequestCode:
            local authCode = DiscordAuth.GenerateAuthCode(player);
            local packet = Packet();
            packet.writeUInt8(PacketId.DiscordAuth);
            packet.writeUInt8(DiscordAuthPacket.SetAuthCode);
            packet.writeString(authCode);
            packet.send(playerId, RELIABLE_ORDERED);
            break;
        case DiscordAuthPacket.ConfirmCode:
           
            local errorPacket = Packet();
            errorPacket.writeUInt8(PacketId.DiscordAuth);
            errorPacket.writeUInt8(DiscordAuthPacket.AuthError);
            errorPacket.writeString("Use /auth in Discord bot");
            errorPacket.send(playerId, RELIABLE_ORDERED);
            break;
    }
});