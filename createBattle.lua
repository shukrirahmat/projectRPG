local function createBattle(_party, _enemies)
    
    local party = _party
    local enemies = _enemies
    
    local hud = createHud(party)
    local enemySprites = createEnemySprites(enemies)
    local menu = createMenu()
    
    local function draw()
        hud.draw()
        enemySprites.draw()
        menu.draw()
    end
    
    return {
        draw = draw,
        menu = menu,
    }
end

return createBattle