
local focusDraw = Label(3134,6904,"LEFT CONTROL to talk");
local focusNpc = -1;

local focusTexture = Sprite(3000,6824,focusDraw.width+268,300, "MENU_INGAME.TGA");
focusTexture.color = Color(55, 5, 5, 255);

function showNpcDialog()
{
    focusTexture.visible = true;
    focusDraw.visible = true;
    focusDraw.top();
}

function hideNpcDialog()
{
    focusTexture.visible = false;
    focusDraw.visible = false;
}

addEventHandler("onKeyDown", function(key) {
    if(key != KEY_LCONTROL)
        return;

    if(focusNpc == -1)
        return;

    if(Player.gui != -1)
        return;

    if(getPlayerWeaponMode(heroId) != 0)
        return;

    if(focusTexture.visible)
        DialogManager.openForNPC(getPlayerName(focusNpc));
})

addEventHandler("onFocus", function(new, old) {
    if(new == -1 && focusNpc != -1)
    {
        focusNpc = -1;
        hideNpcDialog();
        return;
    }

    if(new < getMaxSlots())
        return;

    focusNpc = new;

    if(getPlayerName(new) in DialogManager.Npcs)
        showNpcDialog();
})

function getFocusedNpc()
{
    return focusNpc;
}
