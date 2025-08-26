# Open Roleplay 2.0

#Autor: Artii#

**Ten projekt jest rozwiniêt¹ i zaktualizowan¹ wersj¹ oryginalnej paczki Gothic Roleplay autorstwa Quahodron** — dostêpnej pod adresem: https://gitlab.com/g2o/gamemodes/gothicroleplay.

## Opis

Projekt zosta³ zaktualizowany tak, aby paczka mog³a **bezproblemowo dzia³aæ na najnowszym API G2O**. Oryginalna wersja by³a tworzona pod G2O v0.1.4 i nie uruchamia siê na obecnych wersjach.  

Ze wzglêdu na du¿¹ ró¿nicê pomiêdzy starym a obecnym API, mog¹ wyst¹piæ **nieoczekiwane problemy z dzia³aniem**. Jeœli znajdziesz jakieœ b³êdy, zg³oœ je w Issues lub skontaktuj siê bezpoœrednio.  

Wersja 2.0 obejmuje m.in.:  
- **Obs³uga MySQL** – zamiast wczeœniejszego zapisu plikowego.  
- **Nowa organizacja GUI** – poprawione skalowanie i rozmieszczenie elementów (na bazie starego uk³adu).  
- **Kompatybilnoœæ z G2O v0.3.+** – wszystkie kluczowe systemy dostosowane do obecnego API.  
- **Plany rozwoju** – Dalsze usprawnienia w kolejnych wydaniach.  

## Instalacja

Zmieñ dane logowania mysql w ``RP\Modules\Mysql\Connector.nut`` ``ORM.MySQL("host", "user", "password", "database_name");``

* Skrypt korzysta z: modu³u MySQL, Framework ORM i GUI.Framework.