class PlayerClass
{
    id = null;
    name = null;
    func = null;

    isLeader = false;

    constructor(id, name, func, fraction, isLeader = false)
    {
        this.id = id;
        this.name = name;
    
        this.func = func;
        this.isLeader = isLeader;

        fraction.classes[id] <- this;
    }

    function giveClass(pid)
    {
        Player[pid].classId = id;
        func(pid);
    }
}