/**
 * @command /pm [target_id] [message]
 * @description Sends a private message to another player.
 */
function command_pm(pid, params) {
    local args = split(params, " ", 2); // Split into 2 parts: id and the rest of the message
    if (args.len() < 2) {
        sendSystemMessage(pid, "USAGE: /pm [player_id] [message]");
        return;
    }

    local targetId;
    try {
        targetId = args[0].tointeger();
    } catch (e) {
        sendSystemMessage(pid, "Error: Invalid player ID.");
        return;
    }

    if (targetId == pid) {
        sendSystemMessage(pid, "You cannot send a message to yourself.");
        return;
    }
    
    local message = args[1].strip();
    if (message == "") {
        sendSystemMessage(pid, "Error: The message cannot be empty.");
        return;
    }

    ChatService.sendPrivateMessage(pid, targetId, message);
}

addChatCommand("pm", command_pm);
