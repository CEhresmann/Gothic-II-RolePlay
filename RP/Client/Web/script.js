/**
 * @file Main script for the CEF-based UI.
 * Handles communication with the game client.
 */

const authCodeElement = document.getElementById('auth-code');
const errorContainerElement = document.getElementById('error-container');

/**
 * Displays the authentication code received from the server.
 * This function is called from the Squirrel client code.
 * @param {string} code The authentication code.
 */
function setAuthCode(code) {
    if (authCodeElement) {
        authCodeElement.textContent = code;
    }
    if (errorContainerElement) {
        errorContainerElement.textContent = ''; // Clear previous errors
    }
    console.log("Received auth code: " + code);
}

/**
 * Displays an error message received from the server.
 * This function is called from the Squirrel client code.
 * @param {string} message The error message.
 */
function showError(message) {
    if (errorContainerElement) {
        errorContainerElement.textContent = message;
    }
    console.error("Received error: " + message);
}

/**
 * Requests a new authentication code from the game client.
 * This function is called when the user clicks the "Request New Code" button.
 */
function requestNewCode() {
    // In CEF, we can bind a JavaScript function to a global object that can be called from JS.
    // Let's assume the game client has exposed a function `requestNewAuthCode` on the window object.
    try {
        window.squirrel.requestNewAuthCode();
    } catch (e) {
        console.error("The 'squirrel.requestNewAuthCode' function is not available.", e);
        showError("Could not communicate with the game client. Please try again later.");
    }
}

console.log("UI Script Loaded and ready.");
