
local focusDraw = Draw(0,0,"Klawisz L aby rozpocz interakcj");
local focusPlayer = -1;

function showPlayerDialog()
{
    focusDraw.text = Player.description[focusPlayer];
    focusDraw.setPosition(4100-focusDraw.width/2, 7800);
    focusDraw.visible = true;
    focusDraw.top();
}

function hidePlayerDialog()
{
    focusDraw.visible = false;
}

addEventHandler("onFocus", function(new, old) {
    if(new == -1 && focusPlayer != -1)
    {
        focusPlayer = -1;
        hidePlayerDialog();
        return;
    }

    if(new == -1)
        return;

    if(new >= getMaxSlots())
        return;

    if(getPlayerWeaponMode(heroId) != 0 || getPlayerWeaponMode(new) != 0)
        return;

    focusPlayer = new;
    showPlayerDialog();
})

function getFocusedPlayer()
{
    return focusPlayer;
}

addEventHandler("onGUIClose", function () {
    focusDraw.visible = false;
})

addEventHandler("onGUIOpen", function() {
    focusDraw.visible = false;
})