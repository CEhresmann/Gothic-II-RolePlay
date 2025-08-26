
# Open Roleplay 2.0

# Author: Artii #

**This project is an updated and further developed version of the original Gothic Roleplay pack by Quahodron** — available at: https://gitlab.com/g2o/gamemodes/gothicroleplay.

## Description

The pack has been updated so it can **run without issues on the latest G2O API**. The original version was made for G2O v0.1.4 and does not work on current versions.  

Due to the significant differences between the old and current API, **unexpected issues may occur**. If you encounter any bugs, please report them in Issues or contact directly. (Discord: artiixdxd)  

Version 2.0 includes:  
- **MySQL support** – replacing the previous file-based saving system.  
- **Updated GUI layout** – improved scaling and positioning of elements (based on the old layout).  
- **Compatibility with G2O v0.3.+** – all key systems adapted to the current API.  
- **Future development plans** – further improvements in upcoming releases.  

## Installation

Change MySQL login data in ``RP\Modules\Mysql\Connector.nut``:  
``ORM.MySQL("host", "user", "password", "database_name");``

* Script uses: MySQL module, ORM Framework, and GUI Framework.






## ----- PL SECTION -----






# Open Roleplay 2.0

#Autor: Artii#

**Ten projekt jest rozwiniętą i zaktualizowaną wersją oryginalnej paczki Gothic Roleplay autorstwa Quahodron** — dostępnej pod adresem: https://gitlab.com/g2o/gamemodes/gothicroleplay.

## Opis

Projekt został zaktualizowany tak, aby paczka mogła **bezproblemowo działać na najnowszym API G2O**. Oryginalna wersja była tworzona pod G2O v0.1.4 i nie uruchamia się na obecnych wersjach.  

Ze względu na dużą różnicę pomiędzy starym a obecnym API, mogą wystąpić **nieoczekiwane problemy z działaniem**. Jeśli znajdziesz jakieś błędy, zgłoś je w Issues lub skontaktuj się bezpośrednio.  (Discord: artiixdxd)  

Wersja 2.0 obejmuje m.in.:  
- **Obsługa MySQL** – zamiast wcześniejszego zapisu plikowego.  
- **Nowa organizacja GUI** – poprawione skalowanie i rozmieszczenie elementów (na bazie starego układu).  
- **Kompatybilność z G2O v0.3.+** – wszystkie kluczowe systemy dostosowane do obecnego API.  
- **Plany rozwoju** – Dalsze usprawnienia w kolejnych wydaniach.  

## Instalacja

Zmień dane logowania mysql w ``RP\Modules\Mysql\Connector.nut`` ``ORM.MySQL("host", "user", "password", "database_name");``

* Skrypt korzysta z: modułu MySQL, Framework ORM i GUI.Framework.
