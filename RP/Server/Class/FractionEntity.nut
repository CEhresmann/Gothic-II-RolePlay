/**
 * @file FractionEntity.nut
 * @description
 * Domain entities for Fractions and Classes.
 */

/**
 * @class ClassEntity
 * @description Represents a specific class within a fraction.
 */
class ClassEntity {
    id = -1;
    name = "";
    isLeader = false;

    constructor(id, name, isLeader = false) {
        this.id = id;
        this.name = name;
        this.isLeader = isLeader;
    }
}

/**
 * @class FractionEntity
 * @description Represents a player fraction.
 */
class FractionEntity {
    id = -1;
    name = "";
    classes = null;

    constructor(id, name) {
        this.id = id;
        this.name = name;
        this.classes = {};
    }

    function addClass(id, name, isLeader = false) {
        local newClass = ClassEntity(id, name, isLeader);
        this.classes[id] <- newClass;
        return newClass;
    }

    function getClass(classId) {
        return classes.rawin(classId) ? classes[classId] : null;
    }
}
