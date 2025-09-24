Map <- 
{
	texture = Texture(0, 0, 8192, 8192, "")
	world = ""
	
	coordinates = 
	{
		x = -1,
		y = -1,
		width = -1,
		height = -1
	}
	
	playerMarker = array(getMaxSlots(), null)
}

class Map.PlayerMarker extends Draw
{
	pid = -1

	constructor(pid)
	{
		base.constructor(0, 0, "")
		this.pid = pid
	}
	
	function update(x, y)
	{
		setPosition(x, y)
		top();
		text = "+ "+getPlayerName(pid)
		
		if (!visible)
			visible = true
	}
}


function Map::init()
{

	for (local pid = 0; pid < getMaxSlots(); ++pid)
		playerMarker[pid] = Map.PlayerMarker(pid)
}

function Map::setLevelCoords(world, x, y, width, height)
{
	this.world = world

	coordinates.x = x
	coordinates.y = y
	coordinates.width = width
	coordinates.height = height
}

function Map::changeLevel()
{
	local world = getWorld()
	
	switch (world)
	{
		case "NEWWORLD\\NEWWORLD.ZEN":
			local position = getPlayerPosition(heroId)
						
			if (position.x > -6900 && position.x < 21600
			&& position.z < 11800 && position.z > -9400)
			{
				texture.file = "Map_NwCity.tga"
				setLevelCoords(world, -6900, 11800, 21600, -9400)
			}
			else
			{
				texture.file = "Map_NewWorld.tga"
				setLevelCoords(world, -28000, 50500, 95500, -42500)
			}
			break
			
		case "OLDWORLD\\OLDWORLD.ZEN":
			texture.file = "Map_OldWorld.tga"
			setLevelCoords(world, -78500, 47500, 54000, -53000)
			break
			
		case "ADDON\\ADDONWORLD.ZEN":
			texture.file = "Map_AddonWorld.tga"
			setLevelCoords(world, -47783, 36300, 43949, -32300)
			break
	}
}

function Map::isPlayerAt(pid)
{
	if (!isPlayerCreated(pid))
		return false
		
	if (getWorld() != world)
		return false

	if(pid != heroId && CFG.MapShowOthers == false)
		return false

	if(CFG.MapShowYourself == false && heroId == pid)
		return false;
	
	return true
}

function Map::toggleMarkers(value)
{
	for (local pid = 0; pid < getMaxSlots(); ++pid)
	{
		if (!isPlayerAt(pid))
			continue
			
		playerMarker[pid].visible = value
	}
}

function Map::updatePlayerMarkers()
{
	if (!texture.visible)
		return
		
	for (local pid = 0; pid < getMaxSlots(); ++pid)
	{	
		if (!isPlayerAt(pid))
			continue
			
		local playerPosition = getPlayerPosition(pid)
		
		playerPosition.x -= coordinates.x
		playerPosition.z -= coordinates.y
		
		local maxX = coordinates.width - coordinates.x
		local maxY = coordinates.height - coordinates.y
		
		playerPosition.x = (playerPosition.x / maxX.tofloat()) * 8192
		playerPosition.z = (playerPosition.z / maxY.tofloat()) * 8192
		
		playerMarker[pid].update(playerPosition.x, playerPosition.z)
	}
}

function Map::show()
{
	if(Player.gui != -1) return;

	Interface.baseInterface(true, PLAYER_GUI.MAP);
	changeLevel()
	
	toggleMarkers(true)
	texture.visible = true
}

function Map::hide()
{
	if(Player.gui != PLAYER_GUI.MAP) return;
	
	Interface.baseInterface(false);
	toggleMarkers(false)
	texture.visible = false
}

function Map::toggle()
{
	!texture.visible ? show() : hide()
}


Map.init()


addEventHandler("onRender", function()
{
	if(CFG.MapShowOthers == true || CFG.MapShowYourself == true)
		Map.updatePlayerMarkers()
})

addEventHandler("onPlayerDestroy",function(pid)
{
	Map.playerMarker[pid].visible = false
})

addEventHandler("onKeyDown",function(key)
{
	if (chatInputIsOpen())
		return
		
	if (isConsoleOpen())
		return

	if (key == KEY_M)
		Map.toggle()
	else if (key == KEY_ESCAPE)
		Map.hide()
})
