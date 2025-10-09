class AISheep extends AIMonster {
    instance = "SHEEP"

    function Setup() {
        setPlayerName(this.id, "Sheep")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}


class AIHammel extends AIMonster {
    instance = "HAMMEL"

    function Setup() {
        setPlayerName(this.id, "Hammel")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}
