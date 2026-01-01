/**
 * @file FractionLoader.nut
 * @description
 * Responsible for loading and configuring all game fractions and classes.
 */

/**
 * @function LoadFractions
 * @description Creates and returns a table of all configured fractions.
 * @returns {table} A table of FractionEntity objects, keyed by fraction ID.
 */
function LoadFractions() {
    local fractions = {};

    // --- Example Fraction: Citizens ---
    local citizens = FractionEntity(0, "Citizens");
    citizens.addClass(0, "Peasant");
    citizens.addClass(1, "Townsman", true); // true indicates leader
    fractions[0] <- citizens;

    // --- Example Fraction: Guards ---
    local guards = FractionEntity(1, "Guards");
    guards.addClass(0, "Recruit");
    guards.addClass(1, "Soldier");
    guards.addClass(2, "Captain", true);
    fractions[1] <- guards;

    // --- Add other fractions here ---
    
    return fractions;
}
