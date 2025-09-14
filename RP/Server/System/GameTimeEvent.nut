

class gameTimeEvent
{
	static function add(hour, minute, tag)
	{
		gameTimeEvent.events.append({
			done = false,
			tag = tag,
			hour = hour,
			min = minute,
			day = getTime().day,
			value = (getTime().day * 60 * 24) + (hour * 60) + minute,
		});
	}

	static function check()
	{
		if (gameTimeEvent.events.len() > 0)
		{
			local currTime = getTime();
			local valueCurrent = (currTime.day * 60 * 24) + (currTime.hour * 60) + currTime.min;

			foreach(_event in gameTimeEvent.events)
			{
				if(_event.done)
				{
					if(currTime.day != _event.day)
						_event.done = false;

					continue;
				}
				if(_event.value <= valueCurrent)
				{
					_event.day = currTime.day;
					_event.done = true;
					_event.value = (_event.day * 60 * 24) + (_event.hour * 60) + _event.min;
					callEvent("onGameTimeEvent", _event.tag)
				}
			}
		}
	}

	static events = array(0);
}

addEventHandler("onSecond", gameTimeEvent.check);