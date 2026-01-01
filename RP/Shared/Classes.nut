local noneFraction = addFraction(0, "Brak");


PlayerClass(0, "Nieznajomy", function(pid) {
}, noneFraction)

local townFraction = addFraction(1, "Miasto");


PlayerClass(1, "Obywatel", function(pid) {
}, townFraction)


PlayerClass(2, "Strażnik", function(pid) {
}, townFraction)