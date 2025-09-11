
function startTradeCommand(params)
{
    local focusId = getFocusedPlayer();
    if(focusId == -1)
    {
        Chat.print(255, 5, 5, _L("You dont look at anybody, who is ready to trade."));
        return;
    }

    if(Player.gui != -1)
        return;

    local args = sscanf("ddd", params);
    if (!args)
    {
        Chat.print(255, 0, 0, _L("Type /h <slot id> <amount> <gold for item>"));
        return;
    }

    local itemSlot = args[0];
    local amount = args[1];
    local goldAmount = args[2];

    if(goldAmount < 1)
        goldAmount = 1;

    local item = getItemBySlot(itemSlot);
    if(item == null)
    {
        Chat.print(255, 0, 0, _L("You dont have anything on this slot."));;
        return;
    }

    if(item.amount < amount)
    {
        Chat.print(255,0,0, _L("You dont have %s in amount %d", item.name, amount));
        return;
    }

    Player.packetTrade(focusId, item.instance, item.name, amount, goldAmount);
}
