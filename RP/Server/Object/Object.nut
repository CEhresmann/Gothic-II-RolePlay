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

    function addCall(type, ...)
    {
        callers.append(CallObject(this, type, vargv));
    }
}
