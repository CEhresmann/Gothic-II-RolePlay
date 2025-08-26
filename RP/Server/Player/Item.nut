_giveItem <- giveItem;
_removeItem <- removeItem;

function playerUseItemClient(pid, instance)
{
    instance = instance.toupper();
    // USUŃ: local id = Items.id(instance); - NIE POTRZEBNE
    // Możesz od razu użyć instance
}

function removeItem(pid, instance, amount)
{
    instance = instance.toupper();
    // USUŃ: local id = Items.id(instance); - NIE POTRZEBNE
    // Użyj bezpośrednio instance
    
    // Tutaj twoja logika zarządzania ekwipunkiem...
    _removeItem(pid, instance, amount); // ← Przekazuj nazwę instancji
}

function giveItem(pid, instance, amount)
{
    instance = instance.toupper();
    // USUŃ: local id = Items.id(instance); - NIE POTRZEBNE
    
    // Twoja logika zarządzania ekwipunkiem...
    if(Player[pid].items.rawin(instance)) // ← Używaj nazwy instancji jako klucza
        Player[pid].items[instance] = Player[pid].items[instance] + amount;
    else
        Player[pid].items[instance] <- amount;

    _giveItem(pid, instance, amount); // ← Przekazuj nazwę instancji
}

function hasPlayerItem(pid, instance)
{
    instance = instance.toupper();
    // USUŃ: local id = Items.id(instance); - NIE POTRZEBNE
    
    if(Player[pid].items.rawin(instance)) // ← Używaj nazwy instancji
        return Player[pid].items[instance];

    return 0;
}