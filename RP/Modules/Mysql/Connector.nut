require("DatabaseManager.nut");

// Global instance
::g_DBManager <- DatabaseManager();

// For backward compatibility
::isDatabaseConnected <- function() {
    return ::g_DBManager.isConnected();
}

::getDatabaseEngine <- function() {
    return ::g_DBManager.getEngine();
}
