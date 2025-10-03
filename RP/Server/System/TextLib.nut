StringLib <- {};

function StringLib::distanceChat(pid, color, distance, message)
{
    for(local i = 0; i < getMaxSlots(); i++)
    {
        if(!isPlayerConnected(i))
            continue;

        if(!Player[i].loggIn)
            continue;

        if(distance != -1)
            if(getDistancePlayerToPlayer(pid, i) > distance)
                continue;

        local stripedText = StringLib.textWrap(message);
        foreach(tekst in stripedText)
            sendMessageToPlayer(i, color.r, color.g, color.b, tekst);
    }
}

function StringLib::textWrap(text)
{
    local result = [];
    if(CFG.TextWrap == false)
        return [text];

    if(text.len() < 55)
        return [text];

    local findSpaces = findInTextChar(text, " ");

    local textLen = text.len()/55;
    local recognize = text;

    for(local i = 0; i <= textLen; i ++)
    {
        if(recognize.len() > 55)
        {
            local tekstToAppend = recognize.slice(0, 55);
            local findSpaces = findInTextChar(tekstToAppend, " ");
            if(findSpaces.len() == 0 )
                findSpaces = [55];

            local findCharSpace = findSpaces[findSpaces.len()-1];
            tekstToAppend = recognize.slice(0, findCharSpace);
            recognize = recognize.slice(findCharSpace+1, (recognize.len()));
            result.append(tekstToAppend);
        }else{
            result.append(recognize.slice(0, recognize.len()))
        }
    }

    return result;
}

function StringLib::findInTextChar(text, char)
{
    local returnTab = [];
    local index = 999;
    local wordCount = 0;

    do {
        index = text.find(char);

        if (index != null) {
            text = text.slice(index + char.len());
            wordCount++;
            if(returnTab.len() == 0)
                returnTab.append(index);
            else
                returnTab.append((index+1) + returnTab[returnTab.len()-1]);
        }
    } while (index != null);

    return returnTab;
}
