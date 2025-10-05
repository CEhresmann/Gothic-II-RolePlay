local playerLanguage = null;
local registeredLangs = {};

playerLanguage = CFG.DefaultLanguage;

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

function setPlayerLanguage(lang) {
    playerLanguage = lang;
    callEvent("onChangeLanguage", lang);

    local packet = Packet();
    packet.writeUInt8(PacketId.Language)
    packet.writeString(lang);
    packet.send(RELIABLE_ORDERED);
    packet = null;
}

function _L(text, ...) {
    return registeredLangs[playerLanguage].getFormat(text, vargv);
}

foreach(langName, property in CFG.Languages)
    registeredLangs[langName] <- languagePackage(property.layout);