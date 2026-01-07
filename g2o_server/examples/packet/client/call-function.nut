local clientReceivers = {}

function registerClientFunc(funcName, func)
{
	clientReceivers[funcName] <- func
}

function callServerFunc(funcName, ...)
{
	// create instance of Packet class
	local packet = Packet()
	
	// write packet unique id
	// NOTE! the order in which data is being written/read inside packet matters
	packet.writeUInt8(PacketId.CALL)

	// write unique function name as string
	packet.writeString(funcName)

	// write the number of arguments passed to callServerFunc
	packet.writeUInt8(vargv.len())

	// iterate over varadic arguments (...)
	// write argument id + argument value (if needed)
	foreach(arg in vargv)
	{
		switch (typeof(arg))
		{
		case "null":
			packet.writeInt8('n')
			break

		case "bool":
			packet.writeInt8('b')
			packet.writeBool(arg)
			break

		case "integer":
			packet.writeInt8('i')
			packet.writeInt32(arg)
			break

		case "float":
			packet.writeInt8('f')
			packet.writeFloat(arg)
			break

		case "string":
			packet.writeInt8('s')
			packet.writeString(arg)
			break
		}
	}

	// send packet to the server
	// RELIABLE constant passed as argument to the method call..
	// makes sure that packet will get eventually to the server, 
	// and the order in which the packet will be received in onPacket event isn't guaranteed.
	packet.send(RELIABLE_ORDERED)
}

addEventHandler("onPacket", function(packet)
{
	// read unique packet id
	local id = packet.readUInt8()

	// if the packet id doesn't match => stop code execution
	if (id != PacketId.CALL)
		return

	// read function name
	local funcName = packet.readString()

	// read args count
	local len = packet.readUInt8()
	
	// if function with given name wasn't registered by the registerClientFunc => stop code execution
	if (!(funcName in clientReceivers))
		return

	// get the function by it's unique name
	local func = clientReceivers[funcName]

	// create arguments array with env set to this (root table)
	local args = [this]
	
	// iterate over saved arguments in packet
	// identify the argument, and read it + push it to args array
	for (local i = 0; i < len; ++i)
	{
		switch (packet.readInt8())
		{
		case 'n':
			args.push(null)
			break

		case 'b':
			args.push(packet.readBool())
			break

		case 'i':
			args.push(packet.readInt32())
			break

		case 'f':
			args.push(packet.readFloat())
			break

		case 's':
			args.push(packet.readString())
			break
		}
	}
	
	// call the function with args array
	func.acall(args)
})

/*

	Usage Example

*/

addEventHandler("onInit", function()
{
	callServerFunc("testFunction", null, false, "It WORK!")
})

registerClientFunc("testFunction", function(a, b, c)
{
	print("Function called with " + a + ", " + b + ", " + c)
})