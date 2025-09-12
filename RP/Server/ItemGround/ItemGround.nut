// Globalna tablica do przechowywania instancji odradzających się przedmiotów
local registeredItemsGround = [];

// Klasa odpowiedzialna za zarządzanie pojedynczym punktem odradzania przedmiotu
class RegisterGroundItem
{
    // Właściwości klasy
    item = null; // Przechowuje obiekt przedmiotu na ziemi
    timeLeft = -1; // Czas pozostały do odrodzenia (-1 oznacza, że przedmiot jest na ziemi)
    respawnTime = 180; // Domyślny czas odrodzenia w sekundach
    position = null; // Pozycja (Vec3) gdzie przedmiot ma się odrodzić
    world = null; // Nazwa świata

    // Konstruktor - wywoływany przy tworzeniu nowego obiektu
    constructor(x, y, z, worldName = "NEWWORLD\\NEWWORLD.ZEN")
    {
        // Inicjalizacja pozycji i świata
        position = Vec3(x, y, z);
        world = worldName;

        // Pierwsze odrodzenie przedmiotu
        respawn();

        // Dodanie nowej instancji do globalnej listy
        registeredItemsGround.append(this);
    }

    // Funkcja pomocnicza do obliczania całkowitej "wagi" szansy na wylosowanie przedmiotów
    function getAllCFGGroundCount()
    {
        local totalWeight = 0;
        foreach(itemConfig in CFG.GroundItems)
        {
            // [2] to indeks wagi/szansy w konfiguracji
            totalWeight += itemConfig[2];
        }
        return totalWeight;
    }

    // Funkcja losująca przedmiot z konfiguracji (CFG.GroundItems)
    function getRandomItem()
    {
        local totalWeight = getAllCFGGroundCount();
        if (totalWeight == 0) return false;

        local randomNumber = rand() % totalWeight;
        local currentWeight = 0;

        foreach(itemConfig in CFG.GroundItems)
        {
            if(randomNumber >= currentWeight && randomNumber < (currentWeight + itemConfig[2]))
            {
                // Zwraca tabelę z danymi wylosowanego przedmiotu
                return {
                    id = Daedalus.index(itemConfig[0]),
                    instanceName = itemConfig[0], // Przechowujemy również nazwę instancji
                    amount = itemConfig[1],
                    respawn = itemConfig[3] // Czas odrodzenia dla tego konkretnego przedmiotu
                };
            }
            currentWeight += itemConfig[2];
        }
        return false;
    }

    // Metoda wywoływana, gdy gracz podniesie przedmiot
    function onTake()
    {
        // Ustawia czas do odrodzenia na podstawie wartości z wylosowanego przedmiotu
        timeLeft = respawnTime;
        item = null; // Usuwamy referencję do podniesionego przedmiotu
    }

    // Metoda odpowiedzialna za odrodzenie przedmiotu
    function respawn()
    {
        local itemData = getRandomItem();
        timeLeft = -1; // Resetujemy czas (przedmiot jest na ziemi)

        if(itemData)
        {
            // Tworzy przedmiot na ziemi używając danych z wylosowanej konfiguracji
            // Używamy instanceName zamiast id
            item = ItemsGround.create({
                instance = itemData.instanceName, // Teraz przekazujemy string z nazwą instancji
                amount = itemData.amount,
                position = position,
                world = world
            });
            respawnTime = itemData.respawn; // Ustawia czas odrodzenia specyficzny dla tego przedmiotu
        }
        else
        {
            // Jeśli nie udało się wylosować przedmiotu, spróbuj ponownie za 1 sekundę
            timeLeft = 1;
        }
    }
}

// Event wywoływany, gdy gracz podniesie przedmiot
addEventHandler("onPlayerTakeItem", function(pid, takenItem) {
    foreach(groundItemInstance in registeredItemsGround)
    {
        // Sprawdza, czy podniesiony przedmiot jest zarządzany przez naszą klasę
        if(groundItemInstance.item == takenItem)
        {
            groundItemInstance.onTake();
            break; // Przerywamy pętlę, bo znaleźliśmy odpowiedni obiekt
        }
    }
});

// Event wywoływany co minutę (60 sekund)
addEventHandler("onTime", function (day, hour, min) {
    // Sprawdzamy czy minęła minuta (ignorujemy północ)
    if (hour == 0 && min == 0) return;

    foreach(groundItemInstance in registeredItemsGround)
    {
        // Ignorujemy przedmioty, które już leżą na ziemi
        if(groundItemInstance.timeLeft == -1)
            continue;
        
        // Zmniejszamy czas do odrodzenia o 60 sekund
        groundItemInstance.timeLeft -= 60;

        // Jeśli czas minął, odradzamy przedmiot
        if(groundItemInstance.timeLeft <= 0)
            groundItemInstance.respawn();
    }
});

// Funkcja do pobierania listy zarejestrowanych przedmiotów (może być użyteczna do debugowania)
function getRegisteredGroundItems()
{
    return registeredItemsGround;
}