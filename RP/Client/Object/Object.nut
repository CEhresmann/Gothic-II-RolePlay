class Object
{
    id = -1;

    name = null;
    callers = null;

    constructor(name)
    {
        id = -1;
        callers = [];

        this.name = name;
    }

    function addCall(type, tab)
    {
        callers.append({caller = CallObject(this, type, tab), done = false});
    }

    function checkObjects(key = -1)
    {
        foreach(indexCall, call in callers)
        {
            local checkResult = call.caller.check(key);

            if(call.done) {
                if(!checkResult) {
                    call.done = false;
                    call.caller.onExit();
                    return;
                }
                continue;
            }

            if(checkResult)
            {
                call.done = true;
                call.caller.onEnter();

                if((indexCall+1) == callers.len()) {
                    callEvent("onObjectInteraction", name);
                    ObjectIntegration.packetCall(name);
                }
                continue;
            }
        }
    }
}
