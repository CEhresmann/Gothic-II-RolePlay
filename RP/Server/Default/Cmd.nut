/*

	Script: cmd-handler.nut
	Side: Shared
	
	Author: Patrix

*/

local event_name

local commands = {}

if ("exitGame" in getroottable())
{
	event_name = "onCommand"
}
else if ("ban" in getroottable())
{
	event_name = "onPlayerCommand"
}

addEventHandler(event_name,function(...)
{		
	local cmd = event_name == "onCommand" ? vargv[0] : vargv[1]

	foreach(i,v in commands)
	{
		if (cmd == i)
		{
			foreach(func in commands[cmd])
			{
				if (event_name == "onCommand")
				{
					func(vargv[1])
				}
				else
				{
					func(vargv[0],vargv[2])
				}
			}
		}
	}
})

function addCommand(cmd, func)
{
	function add(cmd)
	{
		if (!commands.rawin(cmd))
		{
			commands[cmd] <- []
		}
	
		commands[cmd].append(func)
	}

	if (type(func) == "function")
	{
		if (type(cmd) == "array")
		{
			foreach (v in cmd)
			{
				add(v)
			}
		}
		else if (type(cmd) == "string")
		{
			add(cmd)
		}
	}
}

function removeCommand(cmd, func=null)
{
	function remove(cmd)
	{
		if (type(func) == "function")
		{
			foreach (i,v in commands[cmd])
			{
				if (v == func)
				{
					commands[cmd].remove(i)
				}
			}
		}
		else
		{
			delete commands[cmd]
		}
	}

	if (type(cmd) == "array")
	{
		foreach(v in cmd)
		{
			if (v in commands)
			{
				remove(v)
			}
		}
	}
	else if (type(cmd) == "string" && cmd in commands)
	{
		remove(cmd)
	}
}
