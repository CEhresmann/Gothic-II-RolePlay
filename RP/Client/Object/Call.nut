class CallObject
{
    obj = null;

    type = null;
    tab = null;

    constructor(obj, type, tab)
    {
        this.obj = obj;

        this.type = type;
        this.tab = tab;
    }

    function check(key)
    {
        switch(type)
        {
            case OBJECT.DISTANCE:
                local pos = getPlayerPosition(heroId);
                if(!("position" in tab))
                    return false;

                return getDistance3d(pos.x, pos.y, pos.z, tab.position.x, tab.position.y, tab.position.z) <= tab.position.distance;
            break;
            case OBJECT.KEY:
                if(!("key" in tab))
                    return false;

                return key == tab.key;
            break;
            case OBJECT.ITEM:
                if(!("item" in tab))
                    return false;

                return hasItem(tab.item.instance) >= tab.item.amount;
            break;
        }
    }

    function onEnter()
    {
        if("onEnterMessage" in tab)
            intimate(tab.onEnterMessage);
    }

    function onExit()
    {
        if("onExitMessage" in tab)
            intimate(tab.onExitMessage);
    }
}