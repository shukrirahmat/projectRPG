local loop = {}

local is_active = nil

function loop.load(parent_battle, queue)
    is_active = true
    
    for i, action in ipairs(queue) do
        print(action.user.name)
        print(action.data.name)
        print(action.targets[1].name)
        print('--------')
    end
end

function loop.update(dt)
    if not is_active then return end
end

return loop