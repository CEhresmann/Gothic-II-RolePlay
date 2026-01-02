class DatabaseManager {
    dbHost = null;
    dbUser = null;
    dbPassword = null;
    dbName = null;

    g_DatabaseEngine = null;
    g_IsDatabaseConnected = false;
    reconnectTimer = null;

    constructor() {
        this.dbHost = getEnv("DB_HOST");
        this.dbUser = getEnv("DB_USER");
        this.dbPassword = getEnv("DB_PASSWORD");
        this.dbName = getEnv("DB_NAME");

        if (this.dbHost == null || this.dbUser == null || this.dbPassword == null || this.dbName == null) {
            print("[DB-CRITICAL] Database environment variables not set. Halting.");
            return;
        }

        ORM.engine = ORM.MySQL(this.dbHost, this.dbUser, this.dbPassword, this.dbName);
        addEventHandler("onInit", this.initializeDatabase.bindenv(this));
    }

    function initializeDatabase() {
        try {
            this.g_DatabaseEngine = ORM.engine;
            this.g_DatabaseEngine.execute("SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci'");

            this.g_IsDatabaseConnected = true;
            print("[DB-SUCCESS] Database Connected!");

            if (this.reconnectTimer != null) {
                killTimer(this.reconnectTimer);
                this.reconnectTimer = null;
            }

            setTimer(this.checkDatabaseConnection.bindenv(this), 15000, 0);
        } catch(error) {
            this.handleConnectionError(error);
        }
    }

    function handleConnectionError(error) {
        this.g_IsDatabaseConnected = false;
        local errorMessage = "[DB-ERROR] Failed to connect with database. Error: " + error;
        print(errorMessage);
        serverLog(errorMessage);

        if (this.reconnectTimer == null) {
            print("[DB] Attempting to reconnect in 10 seconds...");
            this.reconnectTimer = setTimer(this.initializeDatabase.bindenv(this), 10000, 1);
        }
    }

    function checkDatabaseConnection() {
        if (!this.g_IsDatabaseConnected) return;

        try {
            Database_Health.count();
        } catch (error) {
            this.g_IsDatabaseConnected = false;
            local errorMessage = "[DB-CRITICAL] Lost connection! Error: " + error;
            print(errorMessage);
            serverLog(errorMessage);
            this.handleConnectionError(error);
        }
    }

    function isConnected() {
        return this.g_IsDatabaseConnected;
    }

    function getEngine() {
        return this.g_DatabaseEngine;
    }
}

class Database_Health extends ORM.Model </ table="Database_Health" /> {
    </ primary_key=true, auto_increment=true />
    id = -1
}
