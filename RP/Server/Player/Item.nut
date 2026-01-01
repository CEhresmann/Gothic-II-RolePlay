_giveItem <- giveItem;
_removeItem <- removeItem;

function playerUseItemClient(pid, instance)
{
    instance = instance.toupper();
    Player[pid].items[instance] = Player[pid].items[instance] - 1;
}

function removeItem(pid, instance, amount)
{
    instance = instance.toupper();
    _removeItem(pid, instance, amount);
	Player[pid].items[instance] = Player[pid].items[instance] - amount;
}

function giveItem(pid, instance, amount)
{
	instance = instance.toupper();
	
	if (!isNpc(pid) && pid in Player) {		
		if(Player[pid].items.rawin(instance))
			Player[pid].items[instance] = Player[pid].items[instance] + amount;
		else
			Player[pid].items[instance] <- amount;
	}
	
	_giveItem(pid, instance, amount);
}

function hasPlayerItem(pid, instance)
{
    instance = instance.toupper();
    
    if(Player[pid].items.rawin(instance))
        return Player[pid].items[instance];

    return 0;
}