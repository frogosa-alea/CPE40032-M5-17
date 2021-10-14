CharSelectState = Class{__includes = BaseState}

paletteColors = {
    -- green
    [1] = {
        ['r'] = 0,
        ['g'] = 102,
        ['b'] = 0
    },
    -- blue
    [2] = {
        ['r'] = 0,
        ['g'] = 48,
        ['b'] = 143
    },
    -- pink
    [3] = {
        ['r'] = 255,
        ['g'] = 103,
        ['b'] = 129
    }
}

function CharSelectState:enter(params)
    self.background = math.random(3)
end

function CharSelectState:init()
    self.currentChar = 1
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)
    self.psystem:setAreaSpread('normal', 10, 10)

    
end

function CharSelectState:update(dt)
    if love.keyboard.wasPressed('left') then
        if self.currentChar == 1 then
            gSounds['death']:play()
        else
            gSounds['jump']:play()
            self.currentChar = self.currentChar - 1
        end
    elseif love.keyboard.wasPressed('right') then
        if self.currentChar == 3 then
            gSounds['death']:play()
        else
            gSounds['jump']:play()
            self.currentChar = self.currentChar + 1
        end
    end

    if love.keyboard.wasPressed('left') or love.keyboard.wasPressed('right') then
        self.psystem:setColors(
            paletteColors[self.color].r,
            paletteColors[self.color].g,
            paletteColors[self.color].b,
            80,
            paletteColors[self.color].r,
            paletteColors[self.color].g,
            paletteColors[self.color].b,
            0
        )
        self.psystem:emit(80)
    end

    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        gSounds['jump']:play()

        gStateMachine:change('play', {
            --  start new game with player score at 0
            -- level width at 50, game level at 1
            -- 3 player lives and not used score bonus        
            score = 0,
            width = 50,
            gameLevel = 1,
            lives = 3,
            usedScoreBonus = false,
            currentChar = self.charSelectedSkin
         })
    end

    if self.currentChar == 1 then
        self.charSelectedSkin = 'green-alien'
        self.color = 2
    elseif self.currentChar == 2 then
        self.charSelectedSkin = 'blue-alien'
        if love.keyboard.wasPressed('left') then
            self.color = 1
        elseif love.keyboard.wasPressed('right') then
                self.color = 3
        end

    elseif self.currentChar == 3    then
        self.charSelectedSkin = 'pink-alien'
        self.color = 2
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    self.psystem:update(dt)

end

function CharSelectState:render()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 127)

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf("Select your character",0,51,256,('center'))
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf("Select your character",1,50,256,('center'))

    if self.currentChar == 2 then
        -- tint; give it a dark gray with half opacity
        love.graphics.setFont(gFonts['small'])
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.printf("BLUE ALIEN",0,130,256,('center'))
    end
    love.graphics.setColor(255, 255, 255, 255)
    -- left arrow; should render normally if we're higher than 1, else
    -- in a shadowy form to let us know we're as far left as we can go
    if self.currentChar == 1 then
        -- tint; give it a dark gray with half opacity
        love.graphics.setFont(gFonts['small'])
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.printf("GREEN ALIEN",0,130,256,('center'))
        love.graphics.setColor(40, 40, 40, 128)
    end
   
    
    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24,
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
   
    -- reset drawing color to full white for proper rendering
    love.graphics.setColor(255, 255, 255, 255)

    -- right arrow; should render normally if we're less than 4, else
    -- in a shadowy form to let us know we're as far right as we can go
    if self.currentChar == 3 then
        -- tint; give it a dark gray with half opacity
        love.graphics.setFont(gFonts['small'])
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.printf("PINK ALIEN",0,130,256,('center'))
        love.graphics.setColor(40, 40, 40, 128)
    end
    
    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    
    -- reset drawing color to full white for proper rendering
    love.graphics.setColor(255, 255, 255, 255)

    -- draw the paddle itself, based on which we have selected
    if self.currentChar == 1 then
        love.graphics.draw(gTextures['green-alien'],gFrames['green-alien'][1],
        VIRTUAL_WIDTH / 2 - 8, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    elseif self.currentChar == 2 then
        love.graphics.draw(gTextures['blue-alien'],gFrames['blue-alien'][1],
        VIRTUAL_WIDTH / 2 - 8, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    elseif self.currentChar == 3 then
        love.graphics.draw(gTextures['pink-alien'],gFrames['blue-alien'][1],
        VIRTUAL_WIDTH / 2 - 8, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    end

    
    love.graphics.draw(self.psystem, (VIRTUAL_WIDTH / 2 - 8) + 10, (VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3) + 8)
    
end