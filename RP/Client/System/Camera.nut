_Camera <- Camera;

class CameraManagment
{
    stopped = false;
    vobCamera = null;

    constructor()
    {
        stopped = false;
        vobCamera = Vob("CAMERA.3D");
    }

    function setPosition(x,y,z)
    {
        _Camera.setPosition(x,y,z);
    }

    function setRotation(x,y,z)
    {
        _Camera.setRotation(x,y,z)
    }

    function getPosition()
    {
        return _Camera.getPosition();
    }

    function getRotation()
    {
        return _Camera.getPosition();
    }

    function setMode(val)
    {
        _Camera.setMode(val);
    }

    function getMode()
    {
        return _Camera.getMode();
    }

    function setBeforePlayer(pid=heroId, distance = 120)
    {
        local pos = getPlayerPosition(pid);
        local angle = getPlayerAngle(pid);
        local x = pos.x, y = pos.y, z = pos.z;

        setBeforePos(distance, x, y, z, angle);
    }

    function setBeforePos(distance = 120,x = 0,y = 0,z = 0, angle=0)
    {
        vobCamera.setPosition(x,y,z);
        vobCamera.setRotation(0, angle, 0);

        x = x + (sin(angle * 3.14 / 180.0) * distance);
        z = z + (cos(angle * 3.14 / 180.0) * distance);

        vobCamera.setPosition(x, y, z);
        vobCamera.setRotation(0, angle + 180, 0);

        _Camera.setTargetVob(vobCamera);
    }

    function setTargetPlayer(pid=heroId)
    {
        _Camera.setTargetPlayer(pid)
        _Camera.modeChangeEnabled = false;
    }

    function setFreeze(val)
    {
        if(!val)
            setDefaultCamera();
        else {
            _Camera.movementEnabled = false
            _Camera.modeChangeEnabled = false
        }
    }

    function setDefaultCamera()
    {
        _Camera.setTargetPlayer(heroId)
        _Camera.movementEnabled = true
        _Camera.modeChangeEnabled = true
    }
}

Camera <- CameraManagment();