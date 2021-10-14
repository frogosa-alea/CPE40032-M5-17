
LevelMaker = Class{}

function LevelMaker.generate(width, height,generateKey)
    local tiles = {}
    local entities = {}
    local objects = {}
    
    local tileID = TILE_ID_GROUND
    
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)
    
    local keySelection = math.random(#KEYS)

    local flagPoleSelection = math.random(6)
    
    for x = 1, height do
        table.insert(tiles, {})
    end

    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        if math.random(7) == 1 and x < width then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            if math.random(8) == 1 then
                blockHeight = 2
                
                if math.random(8) == 1 and x < width then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false,
                            type = "bushes"
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            elseif math.random(8) == 1 and x < width then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false,
                        type = "bushes"
                    }
                )
            end

            if math.random(10) == 1 and x < width then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,
                        type = "jump block",

                        -- collision function takes itself
                        onCollide = function(obj,player)

                            -- spawn a gem or special object if we haven't already hit the block
                            if not obj.hit then
                                
                                if math.random(3) == 1 then
                                    -- spawn either gem or special object (if allowed)
                                    local specialObject = false
                                    if not specialObject then
                                        local gem = GameObject {
                                            texture = 'gems',
                                            x = (x - 1) * TILE_SIZE,
                                            y = (blockHeight - 1) * TILE_SIZE - 4,
                                            width = 16,
                                            height = 16,
                                            frame = math.random(#GEMS),
                                            collidable = true,
                                            consumable = true,
                                            solid = false,
                                            type = "gem",
                                            onConsume = function(player, object)
                                                gSounds['pickup']:play()
                                                player.score = player.score + 100
                                            end
                                        }
                                    
                                        Timer.tween(0.1, {
                                            [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                        })
                                        gSounds['powerup-reveal']:play()

                                        table.insert(objects, gem)
                                    end
                                    
                                end
                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end

        end
    end
    
    local map = TileMap(width, height)
    map.tiles = tiles

    if generateKey then
        local emptyX, emptyY = LevelMaker.findEmptySpace(width, height,tiles,objects)
        table.insert(objects,
            GameObject {
                texture = 'keys-and-locks',
                x = emptyX,
                y = emptyY,
                width = 16,
                height = 16,
                frame = KEYS[keySelection],
                collidable = true,
                consumable = true,
                solid = false,
                type = "key",
                onConsume = function(player, object)
                    gSounds['pickup']:play()
                    player.goal = "Unlock the Lock Block!"
                    player.keyObtained = true
                    for i = 1, table.getn(objects) do
                        if objects[i].type == "lock block" then
                            objects[i].consumable = true
                            objects[i].solid = false
                            break
                        end        
                    end     
                end
            }
        )    
        emptyX, emptyY = LevelMaker.findEmptySpace(width, height,tiles,objects)                    
        table.insert(objects,
            GameObject {
                texture = 'keys-and-locks',
                x = emptyX,
                y = emptyY,
                width = 16,
                height = 16,
                frame = LOCK_BLOCKS[keySelection],
                consumable = false,
                solid = true,
                type = "lock block",
                onCollide = function()
                end,
                onConsume = function(player, object)
                    gSounds['pickup']:play()
                    player.goal = "Capture the Flag!"
                    local flagY = LevelMaker.findTopper(width, height,tiles)
                    table.insert(objects,
                        GameObject {
                            texture = 'flags',
                            x = (width - 1 ) * TILE_SIZE + 6,
                            y = flagY - 1 * TILE_SIZE,
                            width = 16,
                            height = 16,
                            orientation = 3.17,
                            frame = FLAGS[math.random(#FLAGS)],
                            collidable = false,
                            consumable = true,
                            type = "flag",
                            onConsume = function(player, object)
                                gSounds['pickup']:play()
                                player.goal = "Flag Captured!"
                                player.message = "Level Completed!"
                            end             
                        }
                    )
                end
            }
        )    
        local flagY = LevelMaker.findTopper(width, height,tiles)
        for y1 = 0, 2 do
            table.insert(objects,
                GameObject {
                    texture = 'flags',
                    x = (width - 1 ) * TILE_SIZE,
                    y = flagY - (2 - y1) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = FLAGPOLES[flagPoleSelection + (y1 * 6)],
                    collidable = true,
                    consumable = false,
                    type = "flag pole ",
                    onCollide = function() 
                    end
                }
            )
        end
    end
    

    return GameLevel(entities, objects, map)

end

function LevelMaker.findObject (x,y,objects)
    local objectFound = false
    for i = 1, table.getn(objects) do
        if objects[i].x == x and objects[i].y == y then
            objectFound = true
        end        
    end     
    return objectFound     
end    
    
function LevelMaker.findEmptySpace(width, height,tiles,objects)
    -- look for first column with ground
    local x1 = 0
    local y1 = 0
    local objectCleared = false
    repeat
        x1 = (math.random(5,width-5)) 
        -- default row to ground level in case of gap
        y1 = 6  
        for y = 1, height do
           if tiles[y][x1].topper then
              -- found ground so place y1 one above ground
              y1 = y - 1
          end
       end
       y1 = (y1 - math.random(3)) * TILE_SIZE
       x1 = (x1 - 1)  * TILE_SIZE
       if LevelMaker.findObject(x1,y1,objects) == false then
          objectCleared = true
       end    
   until(objectCleared == true)
   return (x1), (y1)
end


function LevelMaker.findTopper(width, height,tiles)
    local flagY = 6  
    for y = 1, height do
        if tiles[y][width].topper then
           flagY = y - 1
       end
    end
    flagY = (flagY - 1) * TILE_SIZE
    return flagY
end
