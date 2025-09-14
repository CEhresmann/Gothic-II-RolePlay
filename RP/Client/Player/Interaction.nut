local focusDraw = Draw(0, 0, "Klawisz L aby rozpocząć interakcję");
local focusPlayer = -1;

function showPlayerDialog()
{
    if (focusPlayer == -1) return;
    
    //local playerDesc = getPlayerDescription(focusPlayer);
    //focusDraw.text = playerDesc;
    focusDraw.setPosition(4100 - focusDraw.width / 2, 7800);
    //focusDraw.visible = true;
    focusDraw.top();
}

function hidePlayerDialog()
{
    focusDraw.visible = false;
}

addEventHandler("onTakeFocus", function(type, id, name) 
{

    if (type != VOB_NPC) return;
    if (id >= getMaxSlots()) return;
    
    local heroWeaponMode = getPlayerWeaponMode(heroId);
    local targetWeaponMode = getPlayerWeaponMode(id);
    
    if (heroWeaponMode != WEAPONMODE_NONE || targetWeaponMode != WEAPONMODE_NONE)
        return;

    focusPlayer = id;
    showPlayerDialog();
});

addEventHandler("onLostFocus", function(type, id, name) 
{

    if (type != VOB_NPC) return;
    
    if (focusPlayer != -1 && id == focusPlayer)
    {
        focusPlayer = -1;
        hidePlayerDialog();
    }
});

addEventHandler("onPlayerChangeWeaponMode", function(playerid, oldWeaponMode, newWeaponMode) 
{
    if (playerid == heroId || playerid == focusPlayer)
    {
        if (newWeaponMode != WEAPONMODE_NONE)
        {
            hidePlayerDialog();
        }
        else if (focusPlayer != -1 && getPlayerWeaponMode(focusPlayer) == WEAPONMODE_NONE)
        {
            showPlayerDialog();
        }
    }
});

addEventHandler("onOpenInventory", function() {
    hidePlayerDialog();
});

addEventHandler("onCloseInventory", function() {
    if (focusPlayer != -1)
        showPlayerDialog();
});
