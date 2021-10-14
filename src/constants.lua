--[[
    GD50
    Super Mario Bros. Remake

    -- constants --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Some global constants for our application.
]]

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 256
VIRTUAL_HEIGHT = 144

-- global standard tile size
TILE_SIZE = 16

-- width and height of screen in tiles
SCREEN_TILE_WIDTH = VIRTUAL_WIDTH / TILE_SIZE
SCREEN_TILE_HEIGHT = VIRTUAL_HEIGHT / TILE_SIZE

-- camera scrolling speed
CAMERA_SPEED = 100

-- speed of scrolling background
BACKGROUND_SCROLL_SPEED = 10

-- number of tiles in each tile set
TILE_SET_WIDTH = 5
TILE_SET_HEIGHT = 4

-- number of tile sets in sheet
TILE_SETS_WIDE = 6
TILE_SETS_TALL = 10

-- number of topper sets in sheet
TOPPER_SETS_WIDE = 6
TOPPER_SETS_TALL = 18

-- total number of topper and tile sets
TOPPER_SETS = TOPPER_SETS_WIDE * TOPPER_SETS_TALL
TILE_SETS = TILE_SETS_WIDE * TILE_SETS_TALL

-- player walking speed
PLAYER_WALK_SPEED = 60

-- player jumping velocity
PLAYER_JUMP_VELOCITY = -150

-- score bonus for completing a level
-- multipled by the level completed
SCORING_BONUS_LEVEL = 100

-- Score for extra life award
SCORE_FOR_EXTRA_LIFE = 1000

-- invincibility duration in seconds
INVINCIBILITYDUURATION = 15

-- snail movement speed
SNAIL_MOVE_SPEED = 10

--
-- tile IDs
--
TILE_ID_EMPTY = 5
TILE_ID_GROUND = 3

-- table of tiles that should trigger a collision
COLLIDABLE_TILES = {
    TILE_ID_GROUND
}

--
-- game object IDs
--
BUSH_IDS = {
    1, 2, 5, 6, 7
}

COIN_IDS = {
    1, 2, 3
}

CRATES = {
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
}

GEMS = {
    1, 2, 3, 4, 5, 6, 7, 8
}

JUMP_BLOCKS = {}

for i = 1, 30 do
    table.insert(JUMP_BLOCKS, i)
end

KEYS = {
    1, 2, 3, 4
}

LOCK_BLOCKS = {
    5, 6, 7, 8
}

FLAGPOLES = {
    1, 2, 3, 4, 5, 6, 10, 11,12, 13, 14, 15, 19, 20, 21, 22, 23, 24
}

FLAGS = {
    -- only take first two columns of flag as last column flags are too wavy
    7, 8, 16, 17, 25, 26,  34, 35
}

HEARTS = {
    -- 5 is full heart for player life, 6 is star for invincibility
    5, 6
}

