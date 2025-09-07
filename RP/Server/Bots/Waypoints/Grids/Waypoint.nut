
mapWaypoints <- {};

function mapWaypoints::addWaypoint(name, x, y, z, tab) {
    mapWaypoints[name] <- {
        position = [x,y,z],
        ways = tab
    }
}

function getNearestWaypoint(world, x,y,z)
{
    local distance = 10000;
    local position = {name = "", x = 0, y = 0, z = 0};

    foreach(_index,path in mapWaypoints)
    {
        if(_index == "addWaypoint")
            continue;

        local _distance = getDistance2d(x, z, path.position[0], path.position[2]);
        if(_distance < distance)
        {
            distance = _distance;
            position.name = _index;
            position.x = [0];
            position.y = [1];
            position.z = [2];
        }
    }
    return position;
}