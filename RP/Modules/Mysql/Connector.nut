::g_DatabaseEngine <- null;
::g_IsDatabaseConnected <- false;

ORM.engine = ORM.MySQL("host", "root", "pass", "db_name");

class Database_Health extends ORM.Model </ table="Database_Health" /> {
    </ primary_key=true, auto_increment=true />
    id = -1
}

function checkDatabaseConnection() {
    if (!g_IsDatabaseConnected) return;

    try {
        Database_Health.count();
    } catch (error) {
        ::g_IsDatabaseConnected = false;
        local errorMessage = "[DB-CRITICAL] Lost connect! Error: " + error;
        print(errorMessage);
        serverLog(errorMessage + " Exit server...");

        for (local id = 0; id < getMaxSlots(); id++) {
            if (isPlayerConnected(id)) {
                kick(id, "DATABASE ERROR!");
            }
        }
        exit();
    }
}

function initializeDatabase() {
    try {
        ::g_DatabaseEngine = ORM.engine;
        g_DatabaseEngine.execute("SET NAMES 'cp1250' COLLATE 'cp1250_polish_ci'");

        ::g_IsDatabaseConnected = true;
        print("[DB-SUCCESS] Database Connected!");

        setTimer(checkDatabaseConnection, 15000, 0);
    } catch(error) {
        ::g_IsDatabaseConnected = false;
        local errorMessage = "[DB-ERROR] Failed to connect with database. Error: " + error;
        print(errorMessage);
        serverLog(errorMessage);
    }
}

addEventHandler("onInit", initializeDatabase);

::isDatabaseConnected <- function() {
    return ::g_IsDatabaseConnected;
}

::getDatabaseEngine <- function() {
    return ::g_DatabaseEngine;
}