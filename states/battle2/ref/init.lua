local mainMenu = require('states.battle2.menu.mainMenu')
local battlerMenu = require('states.battle2.menu.battlerMenu')
local targetMenu = require('states.battle2.menu.targetMenu')
local skillMenu = require('states.battle2.menu.skillMenu')
local actionCreator = require('entities.actionCreator')

local menu = {}

local state = {}

function menu.load(party, enemies)
    state.height = 180
    state.marginX = 20
    state.marginY = 20
    state.paddingX = 20
    state.paddingY = 10
    state.width = windowWidth - state.marginX * 2
    state.height = 180
    state.itemHeight = (state.height - state.paddingY * 2) / 4
    state.gap = 10
    
    state.party = party
    state.enemies = enemies
    
    state.isActive = false
    state.currentMenu = nil
    mainMenu.load(menu, state)
    battlerMenu.load(menu, state)
    targetMenu.load(menu, state)
    skillMenu.load(menu, state)
end

function menu.start()
    state.isActive = true
    mainMenu.reset()
    menu.switch(mainMenu)
end

function menu.finish()
    state.isActive = false
    -----TEST---
    for i, member in ipairs(state.party) do
        print(member.currentAction.user.name)
        print(member.currentAction.ref)
        print(member.currentAction.targets[1].name)
        print('****')
    end
    -------------
end

function menu.isActive()
    return state.isActive
end

function menu.switch(menu)
    state.currentMenu = menu
end

function menu.normalAttack()
    local battler = state.currentMenu.currentBattler()
    targetMenu.setup(state.currentMenu, 'normalAtk', battler, 'enemies' )
    if targetMenu.isSingular() then
        battler.currentAction = actionCreator.new('normalAtk', battler, {targetMenu.getTargetOne()})
        menu.nextBattler()
    else
        targetMenu.reset()
        menu.switch(targetMenu)
    end
end

function menu.openSkill()
    skillMenu.setup(state.currentMenu)
    skillMenu.reset()
    menu.switch(skillMenu)
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
        battlerMenu.reset()
        battlerMenu.setBattler(index)
        battlerMenu.currentBattler().currentAction = nil;
        menu.switch(battlerMenu)
    else
        mainMenu.reset()
        menu.switch(mainMenu)
    end
end

function menu.nextBattler()    
    local index;
    local found = false
    if state.currentMenu == mainMenu then
        index = 1
    elseif state.currentMenu == battlerMenu then
        index = battlerMenu.getIndex() + 1
    elseif state.currentMenu == targetMenu then
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
        battlerMenu.reset()
        battlerMenu.setBattler(index)
        menu.switch(battlerMenu)
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