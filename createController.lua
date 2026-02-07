local function createController(battle)
    
    local menu = battle.menu
    
    local function executeUp()
        menu.moveUp()
    end
    
    local function executeDown()
        menu.moveDown()
    end
    
    local function execute(key)
        if key == 'up' then
            executeUp()
        elseif key == 'down' then
            executeDown()
        end
    end
    
    return {
        execute = execute
    }
end

return createController;