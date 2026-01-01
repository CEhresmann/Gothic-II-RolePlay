class PlayerFraction
{
    classes = null;

    constructor(id, name)
    {
        id = id;
        
        name = name;
        classes = {};
    }

    function giveClass(pid, classId)
    {
        Player.fractionId = id;
        
        classes[classId].giveClass(pid);
    }
}

Fraction <- {};

function addFraction(id, name)
{
    Fraction[id] <- PlayerFraction(id, name);
    return Fraction[id];
}

function setClassPlayer(pid, fractionId, classId)
{
    Fraction[fractionId].giveClass(pid, classId);
}