local owState = require('overworldState')

local overworldInput = {}

function overworldInput.executeMenu()
    if not owState.menuOpen then
        owState.menuOpen = true
    end
end

function overworldInput.executeCancel()
    if owState.menuOpen then
        owState.menuOpen = false
    end
end

function overworldInput.executeUp()
    if owState.currentMove == nil and not owState.menuOpen then
        owState.currentMove = 'up'
    end
end

function overworldInput.executeDown()
    if owState.currentMove == nil and not owState.menuOpen then
        owState.currentMove = 'down'
    end
end

function overworldInput.executeRight()
    if owState.currentMove == nil and not owState.menuOpen then
        owState.currentMove = 'right'
    end
end

function overworldInput.executeLeft()
    if owState.currentMove == nil and not owState.menuOpen then
        owState.currentMove = 'left'
    end
end

return overworldInput