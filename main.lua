----------------------------------------------
--- LUDUM DARE 48
--- Jenny Pans (Fliflifly)
--- 2021-04-24
----------------------------------------------
io.stdout:setvbuf('no')
----------------------------------------------
--- CONSTANTS
----------------------------------------------
SX = 1
SY = 1
DEBUG = false
----------------------------------------------
--- VARIABLES
----------------------------------------------
local musics = {}
local graphics = {}
local player = {}
local animations = {}
local screen = {
    current = "title_screen"
}
----------------------------------------------
--- ANIMATIONS
----------------------------------------------
local function newAnimation(image, width, height)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
    animation.width = width
    animation.height = height
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    return animation
end

local function updateAnimation(sprite, dt)
    if sprite.currentAnimation ~= "" then
        if not sprite.stoppedAnimation then
            sprite.currentTimeAnimation = sprite.currentTimeAnimation + dt
            if sprite.currentTimeAnimation >= sprite.durationAnimation then
                sprite.currentTimeAnimation = sprite.currentTimeAnimation - sprite.durationAnimation
                print(tostring(sprite.isRepeatAnimation))
                if not sprite.isRepeatAnimation then
                    sprite.stoppedAnimation = true
                end
            end
        end
    end
end

local function drawAnimation(sprite)
    local animation = animations[sprite.currentAnimation]
    local spriteNum = math.floor(sprite.currentTimeAnimation / sprite.durationAnimation * #animation.quads) + 1
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], 
    sprite.x, sprite.y, sprite.r, sprite.sx * SX, sprite.sy * SY, sprite.ox, sprite.oy)
end
----------------------------------------------
--- SPRITES
----------------------------------------------
local function changeAnimation(sprite, animation_name, duration, isRepeatAnimation)
    sprite.currentTimeAnimation = 0
    sprite.stoppedAnimation = false
    if animations[animation_name] then
        sprite.currentAnimation = animation_name
        sprite.isRepeatAnimation = isRepeatAnimation
        sprite.durationAnimation = duration
    else
        sprite.currentAnimation = ""
    end
end

local function changeState(sprite, state, duration, isRepeatAnimation)
    sprite.state = state
    print(tostring(sprite.state)..tostring(isRepeatAnimation))
    if isRepeatAnimation == nil then isRepeatAnimation = true end
    changeAnimation(sprite, state, duration or 1, isRepeatAnimation)
end
--------- NEW
----------------------------------------------
local function newSprite(screen, type, x, y)
    local sprite = {}
    sprite.x = x
    sprite.y = y
    sprite.vx = 0
    sprite.vy = 0
    sprite.ax = 0
    sprite.ay = 0
    sprite.r = 0
    sprite.sx = 1
    sprite.sy = 1
    sprite.moveUp = false
    sprite.moveRight = false
    sprite.moveDown = false
    sprite.moveLeft = false
    sprite.box = {w = 32, h = 32}
    sprite.currentAnimation = ""
    sprite.currentTimeAnimation = 0
    sprite.durationAnimation = 1
    sprite.isRepeatAnimation = false
    sprite.stoppedAnimation = false
    sprite.type = type
    table.insert(screen, sprite)
    return sprite
end

local function newPlayer(screen, x, y)
    player = newSprite(screen.sprites, "player", x, y)
    player.ax = 50
    player.ay = 50
    player.sx = 8
    player.sy = 8
    changeState(player, "player_idle")
    return player
end

local function newPlanet(screen, type, x, y)
    local planet = newSprite(screen.sprites, "planet", x, y)
    planet.type = "planet"
    changeState(planet, type, 8)
    table.insert(screen.planets, planet)
    return planet
end
--------- UPDATE
----------------------------------------------
local function updateSprites(sprites, dt)
    for index, sprite in ipairs(sprites) do
        sprite.vx = 0
        sprite.vy = 0
        updateAnimation(sprite, dt)
    end
end

local function updatePlayerIdle(dt)
    player.vx = 0
    player.vy = 0
    if player.moveUp then player.vy = -player.ay * dt end
    if player.moveRight then player.vx = player.ax * dt end
    if player.moveDown then player.vy = player.ay * dt end
    if player.moveLeft then player.vx = -player.ax * dt end
    player.x = player.x + player.vx
    player.y = player.y + player.vy
end

local function updatePlayerAttack(dt)
    if player.stoppedAnimation then
        changeState(player, "player_idle")
    end
end

local function updatePlayer(dt)
    if player.state == "player_idle" then
        updatePlayerIdle(dt)
    elseif player.state == "player_attack" then
        updatePlayerAttack(dt)
    end
end
--------- DRAW
----------------------------------------------
local function drawSprite(sprite)
    love.graphics.setColor(1, 1, 1, 1)
    if DEBUG then
        love.graphics.rectangle("fill", sprite.x, sprite.y, sprite.box.w, sprite.box.h)
    else
        if sprite.currentAnimation == "" then
            love.graphics.rectangle("fill", sprite.x, sprite.y, sprite.box.w, sprite.box.h)
        else
            drawAnimation(sprite)
        end
    end
end

local function drawSprites(sprites)
    for index, sprite in ipairs(sprites) do
        drawSprite(sprite)
    end
end
----------------------------------------------
--- GAME LOOP
----------------------------------------------
--------- LOAD
----------------------------------------------
local function loadMusics()
    path = "musics/"
    musics["Spacearray"] = love.audio.newSource(path.."Spacearray.ogg", "stream")
end

local function loadGraphics()
    local path = "graphics/"
    graphics["earth"] = love.graphics.newImage(path.."earth.png")
    graphics["sun"] = love.graphics.newImage(path.."sun.png")
    graphics["player_idle"] = love.graphics.newImage(path.."player_idle.png")
    graphics["player_attack"] = love.graphics.newImage(path.."player_attack.png")
end

local function loadAnimations()
    animations["earth"] = newAnimation(graphics["earth"], 100, 100)
    animations["sun"] = newAnimation(graphics["sun"], 200, 200)
    animations["player_idle"] = newAnimation(graphics["player_idle"], 24, 37)
    animations["player_attack"] = newAnimation(graphics["player_attack"], 43, 37)
end

local function loadScreen()
    local screen = {sprites = {}, planets={}}
    return screen
end

local function loadTitleScreen()
    screen = {}
    screen.current = "title_screen"
    screen.title_screen = loadScreen()
    local planet = newPlanet(screen.title_screen, "earth", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    planet.sx = 3
    planet.sy = 3
    planet.ox = animations[planet.currentAnimation].width / 2
    planet.oy = animations[planet.currentAnimation].height / 2
    musics["Spacearray"]:setLooping(true)
    musics["Spacearray"]:play()
end

local function loadGame()
    screen.current = "game"
    screen.game = loadScreen()
    newPlayer(screen.game, 0, 0)
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    loadMusics()
    loadGraphics()
    loadAnimations()
    loadTitleScreen()
end
--------- KEYS
----------------------------------------------
local function keypressedTitleScreen(key)
    if key == "space" then 
        loadGame()
        screen.current = "game"
    end
end

local function keypressedGame(key)
    if key == "z" then player.moveUp = true end
    if key == "d" then player.moveRight = true end
    if key == "s" then player.moveDown = true end
    if key == "q" then player.moveLeft = true end
    if key == "space" then changeState(player, "player_attack", 1, false) end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
    if key == "f3" then DEBUG = not DEBUG end
    if screen.current == "title_screen" then
        keypressedTitleScreen(key)
    elseif screen.current == "game" then
        keypressedGame(key)
    end
end

local function keyreleasedGame(key)
    if key == "z" then player.moveUp = false end
    if key == "d" then player.moveRight = false end
    if key == "s" then player.moveDown = false end
    if key == "q" then player.moveLeft = false end
end

function love.keyreleased(key, scancode)
    if screen.current == "game" then
        keyreleasedGame(key)
    end
end
--------- UPDATE
----------------------------------------------
local function updateTitleScreen(dt)
    updateSprites(screen.title_screen.sprites, dt)
end

local function updateGame(dt)
    updateSprites(screen.game.sprites, dt)
end

function love.update(dt)
    if screen.current == "title_screen" then
        updateTitleScreen(dt)
    elseif screen.current == "game" then
        updatePlayer(dt)
        updateGame(dt)
    end
end
--------- DRAW
----------------------------------------------
local function drawTitleScreen()
    drawSprites(screen.title_screen.sprites)
end

local function drawGame()
    love.graphics.setBackgroundColor(0.8, 0.5, 0.5, 1)
    drawSprites(screen.game.sprites)
end

function love.draw()
    if screen.current == "title_screen" then
        drawTitleScreen()
    elseif screen.current == "game" then
        drawGame()
    end
end
----------------------------------------------