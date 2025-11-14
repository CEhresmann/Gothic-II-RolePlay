class AIMinecrawler extends AIMonster {
    instance = "MINECRAWLER"
    attack_distance = 400
    target_distance = 1200
    chase_distance = 1000
    warn_time = 4000

    function Setup() {
        setPlayerName(this.id, "Minecrawler")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIMinecrawlerWarrior extends AIMonster {
    instance = "MINECRAWLERWARRIOR"
    attack_distance = 400
    target_distance = 1200
    chase_distance = 1000
    warn_time = 4000

    function Setup() {
        setPlayerName(this.id, "Minecrawler Warrior")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}