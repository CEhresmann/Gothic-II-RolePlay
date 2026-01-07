local begin_vob_pos = {x = 0.0, y = 0.0, z = 0.0}
local end_vob_pos = {x = 250.0, y = 100.0, z = 0.0}
local current_vob_pos = {x = 0.0, y = 0.0, z = 0.0}

local current_lerp_time = 0
local lerp_time = 5000

local timer_id = -1

local function stop_lerp()
{
	// if timer isn't running => stop code execution
	if (timer_id == -1)
		return
	
	// kill timer, lerp_vob_pos function won't be called after this operation
	killTimer(timer_id)
	timer_id = -1
}

local function lerp_vob_pos()
{
	// update current interpolation time
	current_lerp_time += getTimerInterval(timer_id)

	// calculate current delta time
	local t = clamp(current_lerp_time / lerp_time.tofloat() 0.0, 1.0)

	// interpolate vob position
	current_vob_pos.x = lerp(begin_vob_pos.x, end_vob_pos.x, t)
	current_vob_pos.y = lerp(begin_vob_pos.y, end_vob_pos.y, t)
	current_vob_pos.z = lerp(begin_vob_pos.z, end_vob_pos.z, t)
	
	// create instance of Packet class
	local packet = Packet()

	// write packet unique id
	// NOTE! the order in which data is being written/read inside packet matters
	packet.writeUInt8(PacketId.LERP)

	// write interpolated vob position
	packet.writeFloat(current_vob_pos.x)
	packet.writeFloat(current_vob_pos.y)
	packet.writeFloat(current_vob_pos.z)

	// send packet to all players connected to the server
	// UNRELIABLE constant passed as argument to the method call..
	// will send the packet, keep in mind that packet may not arrive to destination at all
	packet.sendToAll(UNRELIABLE)

	// are we finished interpolating?
	if (t == 1.0)
	{
		// stop interpolation
		stop_lerp()

		// swap begin_vob_pos with end_vob_pos
		local tmp = begin_vob_pos
		begin_vob_pos = end_vob_pos
		end_vob_pos = tmp
		
		// reset current_lerp_time
		current_lerp_time = 0.0
	}
}

addEventHandler("onPlayerCommand", function(pid, cmd, arg)
{
	switch (cmd)
	{
		case "start_lerp":
			// if timer is running => stop code execution
			if (timer_id != -1)
				return

			// start timer on function lerp_vob_pos that will be called infinite amount of times with interval set to 100ms
			timer_id = setTimer(lerp_vob_pos, 100, 0)
			break

		case "stop_lerp":
			stop_lerp()
			break
	}    
})