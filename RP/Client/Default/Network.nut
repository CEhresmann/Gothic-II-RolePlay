/////////////////////////////////////////
///	Network statistics class
/////////////////////////////////////////

NetStats <- {
	_title = Draw(anx(5), any(5), "Network debug"),
	_ping = null,
	_fps = null,
	_receivedPackets = null,
	_lostPackets = null,
	_lostLastSec = null,
	_messageResend = null,
	_byteToResend = null,
	_messageSend = null,
	_byteToSend = null,
	showed = false
}

//---------------------------------------

function NetStats::constructor()
{
	local height = _title.heightPx;

	_ping = Draw(anx(5), any(7 + height), "");
	_fps = Draw(anx(5), any(7 + height * 2), "");
	_receivedPackets = Draw(anx(5), any(7 + height * 3), "");
	_lostPackets = Draw(anx(5), any(7 + height * 4), "");
	_lostLastSec = Draw(anx(5), any(7 + height * 5), "");
	_messageResend = Draw(anx(5), any(7 + height * 6), "");
	_byteToResend = Draw(anx(5), any(7 + height * 7), "");
	_messageSend = Draw(anx(5), any(7 + height * 8), "");
	_byteToSend = Draw(anx(5), any(7 + height * 9), "");

	setTimer(function()
	{
		NetStats.update();
	}, 500, 0);
}

//---------------------------------------

function NetStats::show()
{
	if (showed) return;
	showed = true;

	Interface.baseInterface(true, PLAYER_GUI.NETWORK);

	_title.visible = true;
	_ping.visible = true;
	_fps.visible = true;
	_receivedPackets.visible = true;
	_lostPackets.visible = true;
	_lostLastSec.visible = true;
	_messageResend.visible = true;
	_byteToResend.visible = true;
	_messageSend.visible = true;
	_byteToSend.visible = true;
}

//---------------------------------------

function NetStats::hide()
{
	if (!showed) return;
	showed = false;

	Interface.baseInterface(false);

	_title.visible = false;
	_ping.visible = false;
	_fps.visible = false;
	_receivedPackets.visible = false;
	_lostPackets.visible = false;
	_lostLastSec.visible = false;
	_messageResend.visible = false;
	_byteToResend.visible = false;
	_messageSend.visible = false;
	_byteToSend.visible = false;
}

//---------------------------------------

function NetStats::update()
{
	local stats = getNetworkStats();

	_ping.text = format("Ping: %i ms", getPlayerPing(heroId));
	_fps.text = format("FPS: %i", getFpsRate());
	_receivedPackets.text = format("Received packets: %i", stats.packetReceived);
	_lostPackets.text = format("Lost packets: %i", stats.packetlossTotal);
	_lostLastSec.text = format("Lost packet last second: %i", stats.packetlossLastSecond);
	_messageResend.text = format("Message to resend: %i", stats.messagesInResendBuffer);
	_byteToResend.text = format("Message to send: %i", stats.messageInSendBuffer);
	_messageSend.text = format("Bytes to resend: %i", stats.bytesInResendBuffer);
	_byteToSend.text = format("Bytes to send: %i", stats.bytesInSendBuffer);
}

/////////////////////////////////////////
///	Events
/////////////////////////////////////////

function initHandler()
{
	NetStats.constructor();
}

addEventHandler("onInit", initHandler);

//---------------------------------------

local function keyHandler(key)
{
	if (key == KEY_F6)
	{
		if (!chatInputIsOpen() && !NetStats.showed && Player.gui == -1)
			NetStats.show();
		else if (NetStats.showed)
			NetStats.hide();
	}
}

addEventHandler("onKey", keyHandler);

// Loaded
print("net.nut loaded...")
