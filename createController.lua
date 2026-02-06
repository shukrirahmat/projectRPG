local function createController(_menu)
    
    local menu = _menu

    local function executeUp()
        menu.moveUp()
    end

    local function executeDown()
        menu.moveDown()
    end
    
    local function executeForward()
        menu.proceed()
    end
    
    local function executeBack()
        menu.back()
    end

    local function execute(key)
        if key == 'up' then
            executeUp()
        elseif key == 'down' then
            executeDown()
        elseif key == 'z' then
            executeForward()
        elseif key == 'x' then
            executeBack()
        end
    end

    return {
        execute = execute
    }
end

return createController