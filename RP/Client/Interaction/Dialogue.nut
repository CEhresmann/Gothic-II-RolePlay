local buttons = [];
local workingDialog = -1;
local npcDialog = -1;
local textureMenuDialog = Sprite(8129/2 - anx(320), 5840, anx(640), any(300), "MENU_INGAME.TGA");
textureMenuDialog.color = Color(55, 5, 5, 255);

class DialogManager
{
    All = [];
    Npcs = {};

    function add(dialog)
    {
        dialog.id = DialogManager.All.len();
        DialogManager.All.append(dialog);
        return DialogManager.All[DialogManager.All.len() - 1];
    }

    function addOpener(npcname, dialogId)
    {
        Npcs[npcname] <- dialogId;
    }

    function openForNPC(npcname)
    {
        local npc = getNpcByRealId(getFocusedNpc());
        npcDialog = npc;
        DialogManager.open(Npcs[npcname]);
    }

    function temporaryHideDialog()
    {
        Camera.setFreeze(false);
        npcDialog.playDialogue();
        textureMenuDialog.visible = false;

        foreach(butt in buttons)
            butt.setVisible(false)
    }

    function temporaryShowDialog()
    {
        Camera.setFreeze(true);
        npcDialog.stopDialogue();
        textureMenuDialog.visible = true;

        foreach(butt in buttons)
            butt.setVisible(true)
    }

    function open(dialogId)
    {
        local dialog = getDialog(dialogId);
        if(!dialog)
            return;

        workingDialog = dialog;
        buttons.clear();
        Interface.baseInterface(true, PLAYER_GUI.NPC);
        hideNpcDialog();
        textureMenuDialog.visible = true;

        foreach(id, menuDialog in dialog.generateDialogMenu())
        {
            //local draw = GUI.Button(8129/2 - anx(300), 6000 + (anx(60) * id), anx(600), any(35), "MENU_INGAME.TGA", menuDialog);
			local draw = GUI.Button({
				relativePositionPx = {x = 8129/2 - anx(300), y = 6000 + (anx(60) * id)}
				sizePx = {width = anx(600), height = any(35)}
				file = "MENU_INGAME.TGA"
				label = {text = ""}
				collection = menuDialog
			})
            draw.setColor({r = 55, g = 5, b = 5});
            draw.setVisible(true);

            buttons.append(draw);
        }

        textureMenuDialog.setSize(anx(640), any(dialog.generateDialogMenu().len() * 45) + 200);
    }

    function hide()
    {
        Interface.baseInterface(false);
        npcDialog.stopDialogue();
        workingDialog = -1;
        textureMenuDialog.visible = false;
        foreach(_butt in buttons)
            _butt.setVisible(false);

        buttons.clear();
    }

    function regenerateDialogButtons()
    {
        if(Player.gui != PLAYER_GUI.NPC)
            return;

        foreach(_butt in buttons)
            _butt.setVisible(false);

        buttons.clear();
        textureMenuDialog.visible = true;

        foreach(id, menuDialog in workingDialog.generateDialogMenu())
        {
            local draw = GUI.Button(8129/2 - anx(300), 6000 + (anx(60) * id), anx(600), any(35), "MENU_INGAME.TGA", menuDialog);
			local draw = GUI.Button({
				relativePositionPx = {x = 8129/2 - anx(300), y = 6000 + (anx(60) * id)}
				sizePx = {width = anx(600), height = any(35)}
				file = "MENU_INGAME.TGA"
				label = {text = ""}
				collection = menuDialog
			})
            draw.setColor({r = 35, g = 5, b = 5});
            draw.setVisible(true);
            buttons.append(draw);
        }
        textureMenuDialog.setSize(anx(640), 40 + any(workingDialog.generateDialogMenu().len() * 45) + 200);
    }
}

function getDialog(dialogId)
{
    return DialogManager.All[dialogId];
}

function getDialoueNpc()
{
    return npcDialog;
}

addEventHandler("GUI.onClick", function(self)
{
    foreach(id, _menuDialog in buttons)
    {
        if(_menuDialog == self)
            workingDialog.openOption(id);
    }
})

addEventHandler("onKeyDown", function(key) {
    if(workingDialog == -1)
        return;

    if(key != KEY_SPACE)
        return;

    workingDialog.move();
})
