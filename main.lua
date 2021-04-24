----------------------------------------------
--- LUDUM DARE 48
--- Jenny Pans (Fliflifly)
----------------------------------------------

----------------------------------------------
--- CONSTANTS
----------------------------------------------
SX = 1
SY = 1
----------------------------------------------
--- VARIABLES
----------------------------------------------
local musics = {}
local graphics = {}
local menu_states = {"title_screen", "game"}
local menu = ""
local player = {}
local animations = {}
local sprites = {}
local planets_sprites = {}
local debug = false
----------------------------------------------
--- ANIMATIONS
----------------------------------------------
local function newAnimation(image, width, height)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    return animation
end

local function updateAnimation(sprite, dt)
    if sprite.currentAnimation ~= "" then
        sprite.currentTimeAnimation = sprite.currentTimeAnimation + dt
        if sprite.currentTimeAnimation >= sprite.durationAnimation then
            sprite.currentTimeAnimation = sprite.currentTimeAnimation - sprite.durationAnimation
        end
    end
end

local function drawAnimation(sprite)
    local animation = animations[sprite.currentAnimation]
    local spriteNum = math.floor(sprite.currentTimeAnimation / sprite.durationAnimation * #animation.quads) + 1
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], sprite.x, sprite.y, sprite.r, sprite.sx * SX, sprite.sy * SY)
end
----------------------------------------------
--- SPRITES
----------------------------------------------
local function changeAnimation(sprite, animation_name)
    sprite.currentTimeAnimation = 0
    if animations[animation_name] then
        sprite.currentAnimation = animation_name
    else
        sprite.currentAnimation = ""
    end
end
--------- NEW
----------------------------------------------
local function newSprite(x, y)
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
    table.insert(sprites, sprite)
    return sprite
end

local function newPlayer(x, y)
    player = newSprite(x, y)
    player.ax = 50
    player.ay = 50
    player.type = "player"
end

local function newPlanet(x, y)
    local planet = newSprite(x, y)
    planet.type = "planet"
    planet.durationAnimation = 1
    changeAnimation(planet, "earth")
    table.insert(planets_sprites, planet)
end
--------- UPDATE
----------------------------------------------
local function updatePlayer(dt)
    player.vx = 0
    player.vy = 0
    if player.moveUp then player.vy = -player.ay * dt end
    if player.moveRight then player.vx = player.ax * dt end
    if player.moveDown then player.vy = player.ay * dt end
    if player.moveLeft then player.vx = -player.ax * dt end
    player.x = player.x + player.vx
    player.y = player.y + player.vy
end

local function updateSprites(sprites, dt)
    for index, sprite in ipairs(sprites) do
        updateAnimation(sprite, dt)
    end
end
--------- DRAW
----------------------------------------------
local function drawSprite(sprite)
    love.graphics.setColor(1, 1, 1, 1)
    if debug then
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
--- KEYS
----------------------------------------------
function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
    if key == "f3" then debug = not debug end
    if menu == menu_states[1] then
        if key == "space" then menu = menu_states[2] end
    elseif menu == menu_states[2] then
        if key == "z" then player.moveUp = true end
        if key == "d" then player.moveRight = true end
        if key == "s" then player.moveDown = true end
        if key == "q" then player.moveLeft = true end
    end
end

function love.keyreleased(key, scancode)
    if menu == menu_states[2] then
        if key == "z" then player.moveUp = false end
        if key == "d" then player.moveRight = false end
        if key == "s" then player.moveDown = false end
        if key == "q" then player.moveLeft = false end
    end
end
----------------------------------------------
--- GAME LOOP
----------------------------------------------
--------- LOAD
----------------------------------------------
local function loadMusics(path)
    musics["Spacearray"] = love.audio.newSource(path.."Spacearray.ogg", "stream")
end

local function loadGraphics(path)
    graphics["earth"] = love.graphics.newImage(path.."earth.png")
end

local function loadAnimations()
    animations["earth"] = newAnimation(graphics["earth"], 100, 100, 1)
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    loadMusics("musics/")
    loadGraphics("graphics/")
    loadAnimations()
    newPlayer(0,0)
    newPlanet(0,0)
    menu = menu_states[1]
    musics["Spacearray"]:setLooping(true)
    musics["Spacearray"]:play()
end
--------- UPDATE
----------------------------------------------
function love.update(dt)
    updateSprites(sprites, dt)
    if menu == menu_states[2] then
        updatePlayer(dt)
    end
end
--------- DRAW
----------------------------------------------
function love.draw()
    if menu == menu_states[1] then
        drawSprites(planets_sprites)
    elseif menu == menu_states[2] then
        love.graphics.setBackgroundColor(0.8, 0.5, 0.5, 1)
        drawSprites(sprites)
    end
end
----------------------------------------------