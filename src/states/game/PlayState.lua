
PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.camX = 0
    self.camY = 0
    self.backgroundX = 0
    self.width = 0
    self.gravityOn = true
    self.gravityAmount = 8
    self.levelLabelY = -64 
    self.LevelMessage = ""
    self.pause = false
end

function PlayState:enter(params)
    self.score = params.score or 0    
    self.width = params.width or 100
    self.gameLevel = params.gameLevel or 1
    self.usedScoreBonus = params.usedScoreBonus or false
    self.currentChar = params.currentChar


    -- spawn a level, tile map and background
    self.level = LevelMaker.generate(self.width, 10, true)
    self.tileMap = self.level.tileMap
    self.background = math.random(3)

    self.player = Player({
        x = self:findSolidGround(0), y = 0,
        width = 16, height = 20,
        texture = self.currentChar,
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end,
            ['death'] = function() return PlayerDeathState(self.player) end,
        },
        map = self.tileMap,
        level = self.level
    })

    -- spawn enemies for this level
    self:spawnEnemies()
    
    -- set the player score
    self.player.score = self.score

    -- set the player game Level
    self.player.gameLevel = self.gameLevel
    
    self.player.usedScoreBonus = self.usedScoreBonus 
    
    -- set player to falling into this level
    self.player:changeState('falling')
    
    -- display game level message for the new game level
    -- but do not pause the game
    self.LevelMessage = 'Level ' .. tostring(self.gameLevel)
     Timer.tween(0.50, {
        [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
    })
        
    -- after that, pause for one second with Timer.after
    :finish(function()
        Timer.after(1, function()
                
            -- then, animate the label going down past the bottom edge
            Timer.tween(0.50, {
                [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
            })
            
            -- once that's complete, we're ready to play!
            :finish(function()
            end)
        end)
    end)
end

function PlayState:update(dt)
    Timer.update(dt)

    -- remove any nils from pickups, etc.
    self.level:clear()

    -- update player and level if not paused
    if not self.pause then
        -- if game is not paused
        self.player:update(dt)
        self.level:update(dt)
        self:updateCamera()
    end
    -- constrain player X no matter which state
    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end
    
    -- messages processing
    
    if self.player.message == "Extra Life Granted!" then
        -- display message for extra life granted
        -- but do not pause game
        self.levelLabelY = -64 
        self.LevelMessage = self.player.message
        self.player.message = ""
        Timer.tween(0.50, {
            [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
        })
        -- after that, pause for one second with Timer.after
        :finish(function()
            Timer.after(1, function()
                
                -- then, animate the label going down past the bottom edge
                Timer.tween(0.50, {
                    [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
                })  
            end)
        end)
    end



    
    if self.player.message == "Level Completed!" then
        self.player.score = self.player.score + SCORING_BONUS_LEVEL * self.player.gameLevel
        self.pause = true
        self.levelLabelY = -64 
        self.LevelMessage = self.player.message
        self.player.message = ""
        Timer.tween(0.50, {
            [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
        })
        :finish(function()
            Timer.after(1, function()
                Timer.tween(0.50, {
                    [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
                })  
                :finish(function()
                    self.pause = false
                    gStateMachine:change('play', {   
                        score = self.player.score,
                        width = self.width + math.floor(self.width * 0.2),
                        gameLevel = self.player.gameLevel + 1,
                        usedScoreBonus = self.player.usedScoreBonus,
                        currentChar = self.player.texture
                    })    
                end)
            end)
        end)
    end
    
    if self.player.message == "Player Died!" then
        -- display message for player has died
        -- pause the game for the message
        self.pause = true
        self.levelLabelY = -64 
        self.LevelMessage = self.player.message
        self.player.message = ""
        Timer.tween(0.50, {
            [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
        })
        -- after that, pause for one second with Timer.after
        :finish(function()
            Timer.after(1, function()
                
                -- then, animate the label going down past the bottom edge
                Timer.tween(0.50, {
                    [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
                })  
            
                -- once that's complete, we're ready to resume play!
                :finish(function()
                    self.pause = false
                    self.player.y = 0
                    self.player.dy = 0
                    self.player.x = self:findSolidGround(math.floor(self.player.x/16))
                    self.player:changeState('falling')
                end)
            end)
        end)
    end

    if self.player.message == "Game Over!" then
        -- display message for game over
        -- pause the game for the message
        self.pause = true
        self.levelLabelY = -64 
        self.LevelMessage = self.player.message
        self.player.message = ""
        Timer.tween(0.50, {
            [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
        })
        -- after that, pause for one second with Timer.after
        :finish(function()
            Timer.after(1, function()
                
                -- then, animate the label going down past the bottom edge
                Timer.tween(0.50, {
                    [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
                })  
        
                -- once that's complete, we're ready to return to start
                :finish(function()
                    self.pause = false
                    self.player:changeState('falling')
                    gStateMachine:change('start')
                end)
            end)
        end)
    end

end

function PlayState:render()
    love.graphics.push()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    
    -- translate the entire view of the scene to emulate a camera
    love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))
    
    self.level:render()

    self.player:render()
    love.graphics.pop()
    
    -- render level message
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf(self.LevelMessage,
    0, self.levelLabelY, VIRTUAL_WIDTH, 'center')

    -- render score
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("Score: "..tostring(self.player.score), 0, 2,200,("left"))
    -- render game level 
    love.graphics.printf("Level: "..tostring(self.gameLevel), 52, 2,200,("right"))
    -- render goal
    love.graphics.printf(self.player.goal, 45, 2, 200, ("center"))
    
    -- used to capture message only during program debugging
    love.graphics.printf(debugMessage, 52, 10,200,("right"))
    
end    

function PlayState:updateCamera()
    self.camX = math.max(0,
        math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

    self.backgroundX = (self.camX / 3) % 256
end

--[[
    Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
    -- spawn snails in the level
    for x = 1, self.tileMap.width do

        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    -- random chance, 1 in 20
                    if math.random(20) == 1 then
                        
                        -- instantiate snail, declaring in advance so we can pass it into state machine
                        local snail
                        snail = Snail {
                            texture = 'creatures',
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16,
                            height = 16,
                            stateMachine = StateMachine {
                                ['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
                                ['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
                                ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
                            }
                        }
                        snail:changeState('idle', {
                            wait = math.random(5)
                        })

                        table.insert(self.level.entities, snail)
                    end
                end
            end
        end
    end
end


function PlayState:findSolidGround(startingX)
    local groundX = 0
    local startingX = startingX + 1
    local groundFound = false
    for x = startingX, self.tileMap.width do
        for y = 1, self.tileMap.height do
            if LevelMaker.findObject(((x - 1) * TILE_SIZE) ,((y - 1) * TILE_SIZE),self.level.objects) then
                
                break
            end              
            if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
               groundFound = true
               groundX = (x - 1) * TILE_SIZE
               break
            end
        end
        if groundFound == true then
           break
        end    
    end
    
    return groundX
end
