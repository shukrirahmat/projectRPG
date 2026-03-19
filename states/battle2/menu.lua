local mainMenu = require('states.battle2.mainMenu')
local battlerMenu = require('states.battle2.battlerMenu')

local menu = {}

local state = {}

function menu.load(party, enemies)
    state.height = 180
    state.marginX = 20
    state.marginY = 20
    state.paddingX = 20
    state.paddingY = 10
    state.itemHeight = (state.height - state.paddingY * 2) / 4
    state.width = windowWidth - state.marginX * 2
    state.gap = 10
    
    state.party = party
    state.enemies = enemies
    
    state.isActive = false
    state.currentMenu = nil
    mainMenu.load(menu, state)
    battlerMenu.load(menu, state)
end

function menu.start()
    state.isActive = true
    menu.toMain()
end

function menu.finish()
    state.isActive = false
end

function menu.isActive()
    return state.isActive
end

function menu.toMain()
    state.currentMenu = mainMenu
    mainMenu.reset()
end

function menu.toBattler(index)
    battlerMenu.setBattler(index)
    battlerMenu.reset()
    state.currentMenu = battlerMenu
end

function menu.previousBattler()
    local index = battlerMenu.getIndex() - 1
    local found = false
    while not found and index > 0 do
        local battler = state.party[index]
        if not battler.isDead and not battler:cannotAct() then
            found = true
        else
            index = index - 1
        end
    end
    
    if found then 
        menu.toBattler(index)
    else
        menu.toMain()
    end
end

function menu.nextBattler()    
    local index;
    local found = false
    if state.currentMenu == mainMenu then
        index = 1
    elseif state.currentMenu == battlerMenu then
        index = battlerMenu.getIndex() + 1
    end
    
    while not found and index <= #state.party do
        local battler = state.party[index]
        if not battler.isDead and not battler:cannotAct() then
            found = true
        else
            index = index + 1
        end
    end
    
    if found then 
        menu.toBattler(index)
    else
        menu.finish()
    end
end

function menu.draw()
    state.currentMenu.draw()
end

function menu.keypressed(key)
    state.currentMenu.keypressed(key)
end

return menu