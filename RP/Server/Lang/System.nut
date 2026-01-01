
local registeredLangs = {};
local playerLanguage = array(getMaxSlots(), CFG.DefaultLanguage)

class languagePackage
{
    packageLang = null
    keyLayout = -1

    constructor(layout)
    {
        keyLayout = layout
        packageLang = null
    }

    function parseFormat(text, arguments)
    {
        if(arguments.len() == 0)
            return text;

        arguments.insert(0, text);
        arguments.insert(0, this);

        return format.acall(arguments);
    }

    function getFormat(text, arguments)
    {
        foreach(keyText, indexText in packageLang)
        {
            if(keyText == text)
                return parseFormat(indexText, arguments);
        }

        return parseFormat(text, arguments);
    }
}

function setLanguagePackage(lang, packageLang) {
    registeredLangs[lang].packageLang = packageLang;
}

function setPlayerLanguage(pid, lang) {
    playerLanguage[pid] = lang;
}

function _L(pid, text, ...) {
    return registeredLangs[playerLanguage[pid]].getFormat(text, vargv);
}

foreach(langName, property in CFG.Languages)
    registeredLangs[langName] <- languagePackage(property.layout);


addEventHandler("onPacket", function(pid, packet) {
    local packetId = packet.readUInt8();
    if(packetId != PacketId.Language)
        return;

    local lang = packet.readString();
    playerLanguage[pid] = lang;
})