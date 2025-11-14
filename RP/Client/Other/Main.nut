local isInterfaceVisible = false;
local isPlayerLogged = false;
isBWActive <- false;

addEventHandler("onPlayerLoggin", function(heroId) {
    isPlayerLogged = true;
});

addEventHandler("onKeyDown", function(key) {
    if (key == KEY_F3 && isPlayerLogged) {
        toggleInterface();
    }
});

function toggleInterface() {
    if (isBWActive) {
        return;
    }
    
    isInterfaceVisible = !isInterfaceVisible;
    
    if (isInterfaceVisible) {
        Interface.baseInterface(true, PLAYER_GUI.NONE);
        setCursorVisible(false);
        Camera.movementEnabled = true;
        setFreeze(false);
        disableHumanAI(false);
    } else {
        Interface.baseInterface(false);
    }
}
