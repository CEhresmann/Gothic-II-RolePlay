# Open Roleplay 2.0

#Autor: Artii#

**Ten projekt jest rozwiniętą i zaktualizowaną wersją oryginalnej paczki Gothic Roleplay autorstwa Quahodron** — dostępnej pod adresem: https://gitlab.com/g2o/gamemodes/gothicroleplay.

## Opis

Projekt został zaktualizowany tak, aby paczka mogła **bezproblemowo działać na najnowszym API G2O**. Oryginalna wersja była tworzona pod G2O v0.1.4 i nie uruchamia się na obecnych wersjach.  

Ze względu na dużą różnicę pomiędzy starym a obecnym API, mogą wystąpić **nieoczekiwane problemy z działaniem**. Jeśli znajdziesz jakieś błędy, zgłoś je w Issues lub skontaktuj się bezpośrednio.  

Wersja 2.0 obejmuje m.in.:  
- **Obsługa MySQL** – zamiast wcześniejszego zapisu plikowego.  
- **Nowa organizacja GUI** – poprawione skalowanie i rozmieszczenie elementów (na bazie starego układu).  
- **Kompatybilność z G2O v0.3.+** – wszystkie kluczowe systemy dostosowane do obecnego API.  
- **Plany rozwoju** – Dalsze usprawnienia w kolejnych wydaniach.  

## Instalacja

Zmień dane logowania mysql w ``RP\Modules\Mysql\Connector.nut`` ``ORM.MySQL("host", "user", "password", "database_name");``

* Skrypt korzysta z: modułu MySQL, Framework ORM i GUI.Framework.