
local STATUS_TARGETED = 1;
local STATUS_TRADER = 2;
local PlayerTrade = {};

for(local i = 0; i <= getMaxSlots(); i ++) {
    PlayerTrade[i] <- {};
    PlayerTrade[i].active <- false;
    PlayerTrade[i].target <- -1;
    PlayerTrade[i].item <- null;
    PlayerTrade[i].amount <- -1;
    PlayerTrade[i].gold <- -1;
    PlayerTrade[i].counter <- -1;
}

function startPlayerTrade(pid, focusId, item, name, amount, gold)
{
    if(focusId > getMaxSlots())
        return;

    if(!(isPlayerConnected(focusId) && isPlayerSpawned(focusId)))
        return;

    if(PlayerTrade[focusId].active != false)
    {
        sendMessageToPlayer(pid, 255,0,0, _L(pid, "%s alredy trading with someone.", getPlayerName(focusId)));
        return;
    }

    if(PlayerTrade[pid].active != false)
    {
        sendMessageToPlayer(pid, 255,0,0, _L(pid, "You alredy on trade."));
        return;
    }

    sendMessageToPlayer(pid, 255, 255, 255, _L(pid,"Trade: %s %s in amount %d for %d gold.", getPlayerName(focusId), name, amount, gold));
    sendMessageToPlayer(focusId, 255, 255, 255, _L(focusId,"Trade: %s %s in amount %d for %d gold.", getPlayerName(pid), name, amount, gold));
    sendMessageToPlayer(focusId, 255, 255, 255, _L(focusId,"Trade accept - ha, Trade reject - hr"));

    PlayerTrade[pid].active = STATUS_TRADER;
    PlayerTrade[pid].target = focusId;
    PlayerTrade[pid].counter = 15;
    PlayerTrade[pid].item = item;
    PlayerTrade[pid].amount = amount;
    PlayerTrade[pid].gold = gold;

    PlayerTrade[focusId].active = STATUS_TARGETED;
    PlayerTrade[focusId].target = pid;
    PlayerTrade[focusId].counter = 15;
    PlayerTrade[focusId].item = item;
    PlayerTrade[focusId].amount = amount;
    PlayerTrade[focusId].gold = gold;
}

function resetPlayerTrade(pid)
{
    PlayerTrade[pid].active = false;
    PlayerTrade[pid].target = -1;
    PlayerTrade[pid].counter = 0;
    PlayerTrade[pid].item = null;
    PlayerTrade[pid].amount = -1;
    PlayerTrade[pid].gold = -1;
}

function acceptPlayerTrade(pid, params)
{
    if(PlayerTrade[pid].active != STATUS_TARGETED)
    {
        sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "Noone gave you an offer."));
        return;
    }

    if(!(isPlayerConnected(pid) && isPlayerSpawned(pid)))
        return;

    local instance = PlayerTrade[pid].item;
    local amount = PlayerTrade[pid].amount;
    local gold = PlayerTrade[pid].gold;

    if(hasPlayerItem(pid,CFG.Currency) < gold)
    {
        sendMessageToPlayer(pid, 255, 0, 0, _L(pid, "You don't have this amount of gold."));
        return;
    }

    local targetId = PlayerTrade[pid].target;

    if(!(isPlayerConnected(targetId) && isPlayerSpawned(targetId)))
        return;

    if(hasPlayerItem(targetId, instance) < amount)
    {
        sendMessageToPlayer(pid, 255, 0, 0, _L(pid, "Player try to trick you. Don't have enaught of given item."));
        return;
    }

    removeItem(targetId, instance, amount);
    giveItem(targetId, "ITMI_GOLD", gold);
    giveItem(pid, instance, amount);
    removeItem(pid, "ITMI_GOLD", gold);

    sendMessageToPlayer(pid, 0, 255, 0, _L(pid, "Successfull trade."));
    sendMessageToPlayer(targetId, 0, 255, 0, _L(targetId, "Successfull trade."));

    resetPlayerTrade(pid);
    resetPlayerTrade(targetId);
}

addCommand("ha", acceptPlayerTrade);

function rejectPlayerTrade(pid, params)
{
    if(PlayerTrade[pid].active != STATUS_TARGETED)
    {
        sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "Noone gave you an offer."));
        return;
    }

    if(!(isPlayerConnected(pid) && isPlayerSpawned(pid)))
        return;

    local targetId = PlayerTrade[pid].target;

    if(!(isPlayerConnected(targetId) && isPlayerSpawned(targetId)))
        return;

    sendMessageToPlayer(pid, 0, 255, 0, _L(pid, "Rejected trade."));
    sendMessageToPlayer(targetId, 0, 255, 0, _L(targetId, "Rejected trade."));

    resetPlayerTrade(pid);
    resetPlayerTrade(targetId);
}

addCommand("hr", rejectPlayerTrade);

addEventHandler("onSecond", function() {
    for(local i = 0; i <= getMaxSlots(); i ++) {
        if(PlayerTrade[i].active == false)
            continue;

        PlayerTrade[i].counter = PlayerTrade[i].counter - 1;
        if(PlayerTrade[i].counter <= 0)
        {
            sendMessageToPlayer(i, 255, 0, 0, _L(i, "Trade rejected... acceptation time 15 seconds."));
            resetPlayerTrade(i);
        }
    }
})

addEventHandler("onPlayerDisconnect", function(pid, res) {
    if(PlayerTrade[pid].active == false)
        return;

    local target = PlayerTrade[pid].target;
    resetPlayerTrade(pid);
    resetPlayerTrade(target);
})