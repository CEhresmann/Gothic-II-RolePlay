/**
 * @file Manages the client-side Discord authentication process using CEF.
 */

local cef = null;

/**
 * Requests a new authentication code from the server.
 * This is triggered by the user from the CEF interface.
 */
local onRequestNewAuthCode = function() {
    local packet = ::Packet();
    packet.writeUInt8(::PacketId.DiscordAuth);
    packet.writeUInt8(::DiscordAuthPacket.RequestCode);
    packet.send(::RELIABLE_ORDERED);
};

/**
 * Displays the authentication screen (CEF window).
 * If the screen is already visible, it does nothing.
 */
local showAuthScreen = function() {
    if (cef != null) return;

    cef = ::Cef();
    cef.setPage("http://game/RP/Client/Web/index.html");
    cef.setSize(600, 500);
    cef.center();
    cef.show();
    cef.enableCursor(true);
    ::setPlayerControlEnabled(false);

    ::addEventHandler("requestNewAuthCode", onRequestNewAuthCode);
};

/**
 * Hides and destroys the authentication screen (CEF window).
 */
local hideAuthScreen = function() {
    if (cef == null) return;

    ::removeEventHandler("requestNewAuthCode", onRequestNewAuthCode);

    cef.destroy();
    cef = null;
    ::setPlayerControlEnabled(true);
};

/**
 * Escapes a string to be safely passed into a JavaScript eval.
 * @param {string} str The string to escape.
 * @returns {string} The escaped string.
 */
local escapeStringForJs = function(str) {
    local escapedStr = str;
    while (escapedStr.find("\"") != null) {
        escapedStr = escapedStr.replace("\"", "\\\"");
    }
    while (escapedStr.find("'") != null) {
        escapedStr = escapedStr.replace("'", "\\'");
    }
    while (escapedStr.find("\n") != null) {
        escapedStr = escapedStr.replace("\n", "\\n");
    }
    return escapedStr;
}

/**
 * Handles incoming packets from the server related to Discord authentication.
 * @param {Packet} packet The packet received from the server.
 */
local onPacketHandler = function(packet) {
    local packetId = packet.readUInt8();
    if (packetId != ::PacketId.DiscordAuth) return;

    local subPacketId = packet.readUInt8();
    switch(subPacketId) {
        case ::DiscordAuthPacket.ShowAuthScreen:
            showAuthScreen();
            break;
        case ::DiscordAuthPacket.SetAuthCode:
            if (cef != null) {
                local code = packet.readString();
                local escapedCode = escapeStringForJs(code);
                cef.eval("setAuthCode(\"" + escapedCode + "\")");
            }
            break;
        case ::DiscordAuthPacket.AuthSuccess:
            hideAuthScreen();
            break;
        case ::DiscordAuthPacket.AuthError:
            if (cef != null) {
                local errorMessage = packet.readString();
                local escapedMessage = escapeStringForJs(errorMessage);
                cef.eval("showError(\"" + escapedMessage + "\")");
            }
            break;
    }
};

::addEventHandler("onPacket", onPacketHandler);
