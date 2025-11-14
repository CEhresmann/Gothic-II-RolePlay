function strip(str) {
    local start = 0;
    local end = str.len() - 1;

    while (start <= end && str[start] == ' ') {
        start++;
    }

    while (end >= start && str[end] == ' ') {
        end--;
    }

    return str.slice(start, end + 1);
}


function implode(array, separator) {
    local result = "";
    foreach (i, item in array) {
        if (i > 0) result += separator;
        result += rawstring(item);
    }
    return result;
}



addChatCommand("kostka", function(pid, params) {
    if (params == "") {
        SendSystemMessage(pid, "U¿ycie: /kostka [min] [max] <liczba_kostek> - np. /kostka 1 6 2", {r=220, g=130, b=0});
        return;
    }

    local tokens = split(params, " ");
    local minValue = 1;
    local maxValue = 6;
    local diceCount = 1;

    if (tokens.len() >= 2) {
        try {
            minValue = tokens[0].tointeger();
            maxValue = tokens[1].tointeger();

            if (minValue >= maxValue) {
                SendSystemMessage(pid, "B³¹d: Wartoœæ minimalna musi byæ mniejsza ni¿ maksymalna", {r=190, g=0, b=0});
                return;
            }

            if (minValue < 1) minValue = 1;
            if (maxValue < 2) maxValue = 2;

        } catch (e) {
            SendSystemMessage(pid, "B³¹d: Nieprawid³owe wartoœci min/max", {r=190, g=0, b=0});
            return;
        }
    } else {
        SendSystemMessage(pid, "U¿ycie: /kostka [min] [max] <liczba_kostek> - np. /kostka 1 6 2", {r=220, g=130, b=0});
        return;
    }

    if (tokens.len() >= 3) {
        try {
            diceCount = tokens[2].tointeger();
            if (diceCount < 1) diceCount = 1;
            if (diceCount > 10) diceCount = 10;
        } catch (e) {
            SendSystemMessage(pid, "B³¹d: Nieprawid³owa liczba kostek", {r=190, g=0, b=0});
            return;
        }
    }

    local results = [];
    local total = 0;

    for (local i = 0; i < diceCount; i++) {
        local roll = random(minValue, maxValue + 1);
        results.push(roll);
        total += roll;
    }

    local resultText = "";
    if (diceCount == 1) {
        resultText = "wyrzuci³ " + results[0] + " (" + minValue + "-" + maxValue + ")";
    } else {
        resultText = "wyrzuci³ " + total + " (" + implode(results, " + ") + ") na " + diceCount + " kostkach (" + minValue + "-" + maxValue + ")";
    }

    local prefix = "# " + getPlayerName(pid) + " ";
    local content = resultText + " #";
    local color = { r = 195, g = 140, b = 55 };
    local distance = 1500;

    sendNearbyMultiColorMessage(pid, "IC", prefix, color, content, color, distance);
});



local lastPM = {};

addChatCommand("pm", function(pid, params) {
    if (params == "") {
        SendSystemMessage(pid, "U¿ycie: /pm [id] [wiadomoœæ]");
        return;
    }

    local tokens = split(params, " ");
    if (tokens.len() < 2) {
        SendSystemMessage(pid, "U¿ycie: /pm [id] [wiadomoœæ]");
        return;
    }

    local targetId = null;
    try {
        targetId = tokens[0].tointeger();
    } catch (e) {
        SendSystemMessage(pid, "B³¹d: Nieprawid³owe ID gracza");
        return;
    }

    if (!isPlayerConnected(targetId)) {
        SendSystemMessage(pid, "B³¹d: Gracz o ID " + targetId + " nie jest online");
        return;
    }

    if (targetId == pid) {
        SendSystemMessage(pid, "Nie mo¿esz wys³aæ wiadomoœci do siebie");
        return;
    }

    local messageStart = tokens[0].len() + 1;
    local message = strip(params.slice(messageStart));

    if (message == "") {
        SendSystemMessage(pid, "B³¹d: Wiadomoœæ nie mo¿e byæ pusta");
        return;
    }

    lastPM[pid] <- targetId;
    lastPM[targetId] <- pid;

    local senderPrefix = "[PM -> " + getPlayerName(targetId) + "]: ";
    local receiverPrefix = "[PM <- " + getPlayerName(pid) + "]: ";

    SendSystemMessage(pid, senderPrefix + message, {r=100, g=200, b=255}, {r=200, g=230, b=255});
    SendSystemMessage(targetId, receiverPrefix + message, {r=255, g=150, b=100}, {r=255, g=200, b=180});
});

addChatCommand("re", function(pid, params) {
    if (params == "") {
        SendSystemMessage(pid, "U¿ycie: /re [wiadomoœæ]");
        return;
    }

    if (!(pid in lastPM)) {
        SendSystemMessage(pid, "B³¹d: Nie masz ostatniej rozmowy");
        return;
    }

    local targetId = lastPM[pid];
    if (!isPlayerConnected(targetId)) {
        SendSystemMessage(pid, "B³¹d: Gracz nie jest ju¿ online");
        delete lastPM[pid];
        return;
    }

    if (targetId == pid) {
        SendSystemMessage(pid, "B³¹d: Nieprawid³owy odbiorca");
        delete lastPM[pid];
        return;
    }

    lastPM[targetId] <- pid;

    local senderPrefix = "[PM -> " + getPlayerName(targetId) + "]: ";
    local receiverPrefix = "[PM <- " + getPlayerName(pid) + "]: ";

    SendSystemMessage(pid, senderPrefix + params, {r=100, g=200, b=255}, {r=200, g=230, b=255});
    SendSystemMessage(targetId, receiverPrefix + params, {r=255, g=150, b=100}, {r=255, g=200, b=180});
});



addChatCommand("event", function(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) {
        return;
    }

    if (params == "") {
        SendSystemMessage(pid, "U¿ycie: /event [dystans] [wiadomoœæ]", {r=220, g=130, b=0});
        return;
    }

    local tokens = split(params, " ");
    local distance = 1500;

    if (tokens.len() >= 2) {
        try {
            distance = tokens[0].tointeger();

            if (distance < 1) distance = 1;
            if (distance > 10000) distance = 10000;

        } catch (e) {
            SendSystemMessage(pid, "B³¹d: Nieprawid³owa wartoœæ dystansu", {r=190, g=0, b=0});
            return;
        }
    } else {
        SendSystemMessage(pid, "U¿ycie: /event [dystans] [wiadomoœæ]", {r=220, g=130, b=0});
        return;
    }

    local message = "";
    for (local i = 1; i < tokens.len(); i++) {
        message += tokens[i];
        if (i < tokens.len() - 1) {
            message += " ";
        }
    }

    if (message == "") {
        SendSystemMessage(pid, "B³¹d: Wiadomoœæ nie mo¿e byæ pusta", {r=190, g=0, b=0});
        return;
    }

    local prefix = "EVENT: ";
    local content = message;
    local color = { r = 156, g = 121, b = 39 };

    sendNearbyMultiColorMessage(pid, "IC", prefix, color, content, color, distance);
});

addChatCommand("gdo", function(pid, params) {
	if (!checkPermission(pid, LEVEL.MOD)) {
        return;
    }
    if (params == "") {
        SendSystemMessage(pid, "U¿ycie: /gdo [wiadomoœæ]", {r=220, g=130, b=0});
        return;
    }
    local content = params;
	local color = { r = 133, g = 100, b = 37 };
	sendGlobalMessage(content, "GLOBAL: ", color, color, "IC")
});