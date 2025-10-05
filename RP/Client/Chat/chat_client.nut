
local localPlayerChatMode = "IC";
local hasNewICMessage = false;
local hasNewOOCMessage = false;
local resolution = getResolution();
local sentMessageHistory = [];
local historyIndex = -1;

local chatModeWindow = null;
local icButton = null;
local oocButton = null;

local MultiColorChatLine = class {
    _prefixDraw = null;
    _contentDraw = null;

    constructor(prefix, prefixColor, content, contentColor) {
        if (prefix && prefix.len() > 0) {
            _prefixDraw = Draw(0, 0, prefix);
            _prefixDraw.color.set(prefixColor.r, prefixColor.g, prefixColor.b);
        }
        if (content && content.len() > 0) {
            _contentDraw = Draw(0, 0, content);
            _contentDraw.color.set(contentColor.r, contentColor.g, contentColor.b);
        }
    }

    function setPosition(x, y) {
        local currentX = x;
        if (_prefixDraw) {
            _prefixDraw.setPositionPx(currentX, y);
            currentX += _prefixDraw.widthPx;
        }
        if (_contentDraw) {
            _contentDraw.setPositionPx(currentX, y);
        }
    }

    function setVisible(v) {
        if (_prefixDraw) _prefixDraw.visible = v;
        if (_contentDraw) _contentDraw.visible = v;
    }

    function heightPx() {
        if (_prefixDraw) return _prefixDraw.heightPx;
        if (_contentDraw) return _contentDraw.heightPx;
        return 0;
    }

    function destroy() {
        if (_prefixDraw) _prefixDraw.visible = false;
        if (_contentDraw) _contentDraw.visible = false;
        _prefixDraw = null;
        _contentDraw = null;
    }
}

Chat <- {
    x = 20, y = 75,
    visible = true,
    _maxLines = ChatConfig.maxLines,
    _linesIC = [],
    _linesOOC = [],
    _scrollOffset = 0,

    function _getActiveLines() {
        return localPlayerChatMode == "IC" ? _linesIC : _linesOOC;
    },

    function addMessage(mode, prefix, prefixColor, content, contentColor) {
        local targetLines = (mode == "IC") ? _linesIC : _linesOOC;
        local maxPixelWidth = resolution.x * ChatConfig.chatAreaWidthPercent;
        local isFirstLineOfMessage = true;

        foreach(line in split(content, "\n")) {
            local wrapWidth = maxPixelWidth - textWidthPx(isFirstLineOfMessage ? prefix : "  ");
            local wrappedLines = wrapText(line, wrapWidth);

            foreach(wrappedLine in wrappedLines) {
                targetLines.push(MultiColorChatLine(
                    isFirstLineOfMessage ? prefix : "  ",
                    prefixColor,
                    wrappedLine,
                    contentColor
                ));
                isFirstLineOfMessage = false;
            }
        }

        while (targetLines.len() > _maxLines * 2) {
            local oldLine = targetLines.remove(0);
            oldLine.destroy();
        }

        if (mode == localPlayerChatMode) {
            _scrollOffset = 0;
            redraw();
        }
    },

    function redraw() {
        foreach(line in _linesIC) line.setVisible(false);
        foreach(line in _linesOOC) line.setVisible(false);

        if (!visible) return;

        local activeLines = _getActiveLines();
        local offset = 0;
        local lineHeight = letterHeightPx();

        local lastLineIdx = activeLines.len() - 1 - _scrollOffset;
        local firstLineIdx = max(0, lastLineIdx - (_maxLines - 1));

        for (local i = firstLineIdx; i <= lastLineIdx; i++) {
            if (i < activeLines.len()) {
                local line = activeLines[i];
                line.setPosition(x, y + offset);
                line.setVisible(true);
                offset += lineHeight + ChatConfig.lineSpacing;
            }
        }

        if (chatInputIsOpen()) {
            chatInputSetPosition(x, any(y + offset));
        }
    },

    function setVisible(v) {
        visible = v;
        redraw();
    },

    function scroll(direction) {
        local activeLinesCount = _getActiveLines().len();
        local maxScroll = max(0, activeLinesCount - _maxLines);

        _scrollOffset -= direction;

        if (_scrollOffset > maxScroll) _scrollOffset = maxScroll;
        if (_scrollOffset < 0) _scrollOffset = 0;

        redraw();
    }
}

function wrapText(text, maxPixelWidth) {
    if (maxPixelWidth <= 0) return [text];
    local lines = [];
    local words = split(text, " ");
    if (words.len() == 0) return [""];
    if (words.len() == 1 && words[0].len() == 0) return [""];

    local currentLine = "";
    foreach(word in words) {
        if (currentLine.len() == 0) {
            currentLine = word;
        } else {
            local testLine = currentLine + " " + word;
            if (textWidthPx(testLine) <= maxPixelWidth) {
                currentLine = testLine;
            } else {
                lines.push(currentLine);
                currentLine = word;
            }
        }
    }
    lines.push(currentLine);
    return lines;
}

function getEstimatedPrefix() {
    local playerName = getPlayerName(heroId);
    if (localPlayerChatMode == "IC") {
        return playerName + " mowi: ";
    } else {
        return "((" + playerName + ": ";
    }
}

function handleInputWrapping() {
    local text = chatInputGetText();
    local maxPixelWidth = resolution.x * ChatConfig.chatAreaWidthPercent;
    local lines = split(text, "\n");
    if (lines.len() == 0) return;

    local prefixWidth = textWidthPx(getEstimatedPrefix());
    local indentWidth = textWidthPx("  ");
    local effectiveMaxWidth;

    if (lines.len() == 1) {
        effectiveMaxWidth = maxPixelWidth - prefixWidth;
    } else {
        effectiveMaxWidth = maxPixelWidth - indentWidth;
    }

    if (lines.len() >= ChatConfig.maxInputLines && textWidthPx(lines.top()) > effectiveMaxWidth) {
        local newText = text.slice(0, -1);
        chatInputSetText(newText);
        chatInputSetCaretPosition(newText.len());
        return;
    }

    local lastLine = lines.top();
    if (textWidthPx(lastLine) > effectiveMaxWidth) {
        local lastSpace = null;
        for (local i = lastLine.len() - 1; i >= 0; i--) {
            if (lastLine[i] == ' ') {
                lastSpace = i;
                break;
            }
        }
        if (lastSpace != null && lines.len() < ChatConfig.maxInputLines) {
            local lineStartIndex = text.len() - lastLine.len();
            local breakPoint = lineStartIndex + lastSpace;
            local newText = text.slice(0, breakPoint) + "\n" + text.slice(breakPoint + 1);
            chatInputSetText(newText);
            chatInputSetCaretPosition(newText.len());
        }
    }
}

function updateButtonAppearance() {
    if (!icButton || !oocButton) return;
    icButton.setColor(localPlayerChatMode == "IC" ? { r = 150, g = 255, b = 150 } : { r = 255, g = 255, b = 255 });
    oocButton.setColor(localPlayerChatMode == "OOC" ? { r = 150, g = 255, b = 150 } : { r = 255, g = 255, b = 255 });
    if (hasNewICMessage && localPlayerChatMode == "OOC") icButton.setColor({ r = 255, g = 100, b = 100 });
    if (hasNewOOCMessage && localPlayerChatMode == "IC") oocButton.setColor({ r = 255, g = 100, b = 100 });
}

function requestChatModeToggle() {
    local packet = createToggleChatModeRequest();
    local p = Packet();
    p.writeUInt8(PacketId.Other);
    p.writeUInt8(PacketOther.ChatMessage);
    writeChatPacket(packet, p);
    p.send(RELIABLE);
}

ShowChat <- function(isVisible) {
    if (chatModeWindow) chatModeWindow.setVisible(isVisible);
    if ("Chat" in getroottable()) Chat.setVisible(isVisible);
}

function onResolutionChange() {
    resolution = getResolution();
    Chat.redraw();
}

addEventHandler("onInit", function() {
    chatModeWindow = GUI.Window({
        positionPx = { x = 20, y = 20 }, sizePx = { width = 200, height = 50 },
        file = "BLACK.TGA", color = { a = 0 }, draggable = true
    });

    local windowPos = chatModeWindow.getPositionPx();
    local windowSize = chatModeWindow.getSizePx();
    Chat.y = windowPos.y + windowSize.height + 5;

    icButton = GUI.Button({
        relativePositionPx = { x = 5, y = 5 }, sizePx = { width = 90, height = 40 },
        file = "INV_SLOT_FOCUS.TGA", draw = { text = "IC" }, collection = chatModeWindow
    });
    oocButton = GUI.Button({
        relativePositionPx = { x = 105, y = 5 }, sizePx = { width = 90, height = 40 },
        file = "INV_SLOT_FOCUS.TGA", draw = { text = "OOC" }, collection = chatModeWindow
    });

    icButton.bind(EventType.Click, function(element) { if (localPlayerChatMode != "IC") requestChatModeToggle(); });
    oocButton.bind(EventType.Click, function(element) { if (localPlayerChatMode != "OOC") requestChatModeToggle(); });

    addEventHandler("onChangeResolution", onResolutionChange);
    addEventHandler("onMouseWheel", function(direction) {
        if (chatInputIsOpen() && (isKeyPressed(KEY_LCONTROL) || isKeyPressed(KEY_RCONTROL))) {
            Chat.scroll(direction);
        }
    });

    ShowChat(false);
    updateButtonAppearance();
});

addEventHandler("onKeyInput", function(key, character) {
    if (chatInputIsOpen()) {
        if (Chat._scrollOffset != 0) {
            Chat._scrollOffset = 0;
            Chat.redraw();
        }
        handleInputWrapping();
    }
});

addEventHandler("onKeyDown", function(key) {
    if (chatInputIsOpen()) {
        switch (key) {
            case KEY_ESCAPE:
                chatInputClose();
                disableControls(false);
                break;
            case KEY_RETURN:
                local textToSend = chatInputGetText();
                if (textToSend.len() > 0) {
                    chatInputSend();
                    sentMessageHistory.push(textToSend);
                    if(sentMessageHistory.len() > ChatConfig.maxSentHistory) {
                        sentMessageHistory.remove(0);
                    }
                }
                historyIndex = -1;
                chatInputClose();
                disableControls(false);
                break;
            case KEY_UP:
                if (sentMessageHistory.len() > 0) {
                    if (historyIndex == -1) {
                        historyIndex = sentMessageHistory.len() - 1;
                    } else {
                        historyIndex = max(0, historyIndex - 1);
                    }
                    chatInputSetText(sentMessageHistory[historyIndex]);
                    chatInputSetCaretPosition(chatInputGetText().len());
                }
                break;
            case KEY_DOWN:
                if (historyIndex != -1) {
                    historyIndex = min(sentMessageHistory.len(), historyIndex + 1);
                    if (historyIndex >= sentMessageHistory.len()) {
                        chatInputSetText("");
                        historyIndex = -1;
                    } else {
                        chatInputSetText(sentMessageHistory[historyIndex]);
                        chatInputSetCaretPosition(chatInputGetText().len());
                    }
                }
                break;
        }
    } else {
        if (key == KEY_T && Chat.visible) {
            chatInputOpen();
            playGesticulation(heroId);
            disableControls(true);
            Chat._scrollOffset = 0;
            historyIndex = -1;
            Chat.redraw();
        } else if (key == KEY_V) {
            requestChatModeToggle();
        }
    }
});

addEventHandler("onPacket", function(packet) {
    local mainId = packet.readUInt8();
    
    if (mainId == PacketId.Other) {
        local subId = packet.readUInt8();
        
        if (subId == PacketOther.ChatMessage) {
            try {
                local chatPacket = readChatPacket(packet);
                
                switch (chatPacket.type) {
                    case ChatPacketType.DisplayMultiColorChatMessage:
                        Chat.addMessage(chatPacket.mode, chatPacket.prefix, chatPacket.prefixColor, chatPacket.content, chatPacket.contentColor);
                        break;
                        
                    case ChatPacketType.UpdateChatModeResponse:
                        localPlayerChatMode = chatPacket.mode;
                        if (localPlayerChatMode == "IC") hasNewICMessage = false;
                        else hasNewOOCMessage = false;
                        Chat._scrollOffset = 0;
                        Chat.redraw();
                        updateButtonAppearance();
                        break;
                        
                    case ChatPacketType.NewMessageNotify:
                        if (chatPacket.mode == "IC" && localPlayerChatMode == "OOC") hasNewICMessage = true;
                        else if (chatPacket.mode == "OOC" && localPlayerChatMode == "IC") hasNewOOCMessage = true;
                        updateButtonAppearance();
                        break;
                }
            } catch (e) {}
        }
    }
});


function sendClientChatMessage (message){
	Chat.addMessage("IC", "(!) ", {r=0, g=255, b=0}, message, {r=255, g=255, b=255});
}