--[[
    GD50
    Flappy Bird Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A mobile game by Dong Nguyen that went viral in 2013, utilizing a very simple 
    but effective gameplay mechanic of avoiding pipes indefinitely by just tapping 
    the screen, making the player's bird avatar flap its wings and move upwards slightly. 
    A variant of popular games like "Helicopter Game" that floated around the internet
    for years prior. Illustrates some of the most basic procedural generation of game
    levels possible as by having pipes stick out of the ground by varying amounts, acting
    as an infinitely generated obstacle course for the player.
]]

push = require 'push'

Class = require 'class'

require 'Bird'

require 'Pipe'

require 'PipePair'

W_WIDTH = 1280
W_HEIGHT = 720

V_WIDTH = 512
V_HEIGHT = 288

-- cargar las imagenes en la memoria para despues usarlas en la pantalla
local background = love.graphics.newImage('background.png')
local backgroundScroll = 0

local ground = love.graphics.newImage('ground.png')
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

local GROUND_LOOPING_POINT = 514

local bird = Bird()

local pipePairs = {}

local spawnTimer = 0

local lastY = -PIPE_HEIGHT + math.random(80) + 20

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Kiike Bird')

    math.randomseed(os.time())

    push:setupScreen(V_WIDTH, V_HEIGHT, W_WIDTH, W_HEIGHT, {
        vsync= true,
        fullscreen= false,
        resizable= true
    })

    love.keyboard.keysPressed= {}
end

function love.resize(w,h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key]=true

    if key=='escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    backgroundScroll=(backgroundScroll + BACKGROUND_SCROLL_SPEED*dt) % BACKGROUND_LOOPING_POINT

    groundScroll= (groundScroll + GROUND_SCROLL_SPEED*dt) % V_WIDTH

    spawnTimer=spawnTimer + dt

    if spawnTimer > 2 then

        local y = math.max(-PIPE_HEIGHT + 10, 
        math.min(lastY + math.random(-20, 20), V_HEIGHT - 90 - PIPE_HEIGHT))

        lastY = y

        table.insert(pipePairs, PipePair(y))
        spawnTimer=0
    end

    bird:update(dt)

    for k, pair in pairs(pipePairs) do
        pair:update(dt)
    end

    for k, pair in pairs(pipePairs) do

        if pair.remove then
            table.remove(pipePairs, k)
        end

    end

    love.keyboard.keysPressed= {}
end

function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundScroll, 0)

    for k, pair in pairs(pipePairs) do
        pair:render()
    end

    love.graphics.draw(ground, -groundScroll, V_HEIGHT-16)

    bird:render()

    push:finish()
end