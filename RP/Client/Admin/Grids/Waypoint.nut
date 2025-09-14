
mapWaypoints <- {};

function mapWaypoints::addWaypoint(world, name, x, y, z, tab) {
    if(!(world in mapWaypoints))
        mapWaypoints[world] <- {};

    mapWaypoints[world][name] <- {
        position = [x,y,z],
        ways = tab
    }
}