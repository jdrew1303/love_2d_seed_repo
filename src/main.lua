-- allows us to have a 'virtual' resolution independent of the screen
local push = require('modules.push.push')

-- concord is the entity component system
local concord = require('modules.concord.concord');
concord.loadComponents('components');
concord.loadAssemblages('assemblages')
concord.loadSystems('systems');


function love.load()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
end

function love.keypressed(key)
end


function love.draw()
end