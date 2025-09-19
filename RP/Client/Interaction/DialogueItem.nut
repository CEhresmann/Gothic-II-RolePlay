
local temporaryDraws = [];

class DialogItem 
{
    constructor(_index)
    {   
        index = _index;
        items = [];

        id = -1;
        active = 0;
        activeOption = 0;
    }

    function addMenuDialog(name, content)
    {
        items.insert(0, {name = name, content = content});
    }

    function removeMenuDialog(_name)
    {
        foreach(_index, item in items)
        {
            if(item.name == _name) {
                items.remove(_index);
            }
        }
    }

    function generateDialogMenu()
    {
        local menu = [];
        foreach(_item in items)
        {
            menu.append(_item.name);
        }
        return menu;
    }

    function openOption(_id)
    {
        DialogManager.temporaryHideDialog();

        active = 0;
        activeOption = items[_id].name;
        showDialogForOptionActive()
    }

    function hideOption()
    {
        DialogManager.temporaryShowDialog();
        callEvent("onEndDialog", this, getIdForActiveOption(), activeOption);

        active = 0;
        activeOption = 0;
        temporaryDraws.clear();
    }

    function getIdForActiveOption()
    {
        foreach(_id, _item in items)
        {
            if(_item.name == activeOption)
                return _id;
        }
        return 0;
    }

    function move()
    {
        active ++;

        if(active == items[getIdForActiveOption()].content.len()) {
            hideOption();
            return;
        }

        showDialogForOptionActive();
    }

    function showDialogForOptionActive()
    {
        temporaryDraws.clear();

        foreach(v, content in items[getIdForActiveOption()].content[active])
        {
            if(v == 0)
            {
                local draw = Draw(0,0,content);
                draw.setPosition(8129/2 - draw.width/2, 1000);
                
                if(content == "Ja") {
                    playGesticulation(heroId);
                    Camera.setBeforePlayer(heroId, 35);
                    draw.setColor(200,0,130);
                }else{
                    stopAni(heroId);
                    getDialoueNpc().playDialogue();
                    Camera.setBeforePlayer(getDialoueNpc().element, 35);
                    draw.setColor(0,200,150);
                }

                draw.visible = true;
                temporaryDraws.append(draw); 
            }else{
                local draw = Draw(0,0,content);
                draw.setPosition(8129/2 - draw.width/2, 1050 + (v*150));
                draw.visible = true;      
                temporaryDraws.append(draw);         
            }
        }

        foreach(_draw in temporaryDraws)
            _draw.visible = true;
    }

    id = -1;
    active = 0;
    activeOption = 0;

    index = "";
    items = null;
}
