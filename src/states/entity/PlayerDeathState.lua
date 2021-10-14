
PlayerDeathState = Class{__includes = BaseState}

function PlayerDeathState:init(player)
    self.player = player

    self.animation = Animation {
        frames = {1},
        interval = 1
    }

end

function PlayerDeathState:update(dt)
    gSounds['death']:play()
        self.player.message = "Player Died!"
end