class PlayerClass
{
    id = null;
    name = null;
    func = null;

    constructor(id, name, func, fraction)
    {
        this.id = id;
        this.name = name;
    
        this.func = func;

        fraction.classes[id] <- this;
    }

    function giveClass(pid)
    {
        Player.classId = id;
        func(pid);
    }
}