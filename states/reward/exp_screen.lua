local party_sprites = require('graphics.party_sprites')
local fonts = require('fonts')
local exp_data = require('data.exp_data')

local exp_screen = {
    timer = 0,
    READY_TIME = 0.5
}

local function get_alive_member(party_members)
    local alive = {}
    for i, member in ipairs(party_members) do
        if member:is_alive() then
            table.insert(alive, member)
        end
    end    
    return alive
end

function exp_screen.load(party, total_exp, textbox)
    exp_screen.party = party
    exp_screen.textbox = textbox
    exp_screen.alive_member = get_alive_member(exp_screen.party.members)
    exp_screen.exp_per_member = math.floor(total_exp / #exp_screen.alive_member)
    exp_screen.level_up_queue = {}
    exp_screen.distribute_speed = math.max(1, math.floor(exp_screen.exp_per_member * 0.75))
    
    for i, member in ipairs(exp_screen.party.members) do
        member.display_exp = member.total_exp
        member.display_lvl = member.lvl
        if member:is_alive() then
            local level_ups = member:increase_exp(exp_screen.exp_per_member)

            for i, data in ipairs(level_ups) do
                table.insert(exp_screen.level_up_queue, data)
            end
        end
    end
    
    exp_screen.timer = 0
    exp_screen.is_active = true
    exp_screen.phase = 'start'
end

function exp_screen.update(dt)
    if not exp_screen.is_active then return end

    if exp_screen.phase == 'start' then
        exp_screen.timer = exp_screen.timer + dt
        if exp_screen.timer >= exp_screen.READY_TIME then
            exp_screen.phase = 'wait_for_textbox'
        end
    elseif exp_screen.phase == 'wait_for_textbox' then
        if exp_screen.textbox.is_busy() then return end
        exp_screen.phase = 'distributing'
        
    elseif exp_screen.phase == 'distributing' then
        local all_done = true
        for i, member in ipairs(exp_screen.alive_member) do
            if member.display_exp < member.total_exp then
                all_done = false

                member.display_exp = math.min(
                    member.display_exp + exp_screen.distribute_speed * dt, 
                    member.total_exp
                )

                local required_exp = exp_data[member.display_lvl + 1]
                if required_exp and member.display_exp >= required_exp then
                    member.display_lvl = member.display_lvl + 1
                end
            end
        end

        if all_done then 
            exp_screen.is_active = false
            for i, data in ipairs(exp_screen.level_up_queue) do
                local lines = {}
                table.insert(lines, ''..data.member.name..' has leveled up to LVL '..data.lvl..'!')
                if data.skill then
                    table.insert(lines, 'Learned: '..data.skill..'.')
                end
                exp_screen.textbox.queue(lines)
            end
        end
    end
end

function exp_screen.skip()
    for i, member in ipairs(exp_screen.alive_member) do
        member.display_exp = member.total_exp
        member.display_lvl = member.lvl
    end
end

function exp_screen.draw()
    
    local lg = love.graphics
    
    local text_height = 140
    local monsterSpriteDimension = 128
    
    local display_t = math.min(1, exp_screen.timer / exp_screen.READY_TIME)
    local start_x = 20
    local start_y = 20
    local box_width = ((lg.getWidth() - start_x * 2) / 4) - 10
    local box_height = lg.getHeight() - 20 - text_height - 20 - start_y

    for i, member in ipairs(exp_screen.party.members) do

        local box_x = start_x + 5 + (i - 1) * (box_width + 10)
        local box_y = start_y
        local inner_x = box_x + 15
        local inner_width = box_width - 30
        
        lg.setScissor(box_x, box_y + (box_height / 2) * (1 - display_t), 
            box_width, box_height * display_t)

        local sprite_x = box_x + box_width * 0.5 - monsterSpriteDimension * 0.5
        local sprite_y = box_y + 20
        local sprite = member.sprite
        if member.is_dead then sprite = party_sprites.get_sprite('coffin') end
        
        if member.is_dead then
            lg.setColor(0.25, 0.25, 0.25)
        else
            lg.setColor(1, 1, 1)
        end
        lg.draw(sprite, sprite_x, sprite_y)
        lg.rectangle('line', sprite_x, sprite_y, monsterSpriteDimension, monsterSpriteDimension)

        local name_x = inner_x
        local name_y = sprite_y + monsterSpriteDimension + 10
        local name_width = inner_width

        lg.setFont(fonts.large)
        lg.printf(member.name, name_x, name_y, name_width, 'center')

        local lvl_x = inner_x
        local lvl_y = name_y + 40
        local lvl_width = inner_width

        lg.setFont(fonts.large)
        lg.printf('LVL '..member.display_lvl..'', lvl_x, lvl_y, lvl_width, 'left')

        local plus_x = inner_x
        local plus_y = name_y + 43
        local plus_width = inner_width

        if member:is_alive() then
            lg.setFont(fonts.medium)
            lg.printf('+ '..exp_screen.exp_per_member..' EXP', plus_x, plus_y, plus_width, 'right')
        end

        local bar_x = inner_x
        local bar_y = lvl_y + 27
        local bar_width = inner_width

        lg.rectangle('line', bar_x, bar_y, inner_width, 15)

        local current_exp = member.display_exp - exp_data[member.display_lvl]
        local diff_exp = exp_data[member.display_lvl + 1] - exp_data[member.display_lvl]
        local filled = inner_width * (current_exp / diff_exp)

        lg.rectangle('fill', bar_x, bar_y, filled, 15)

        local next_x = inner_x
        local next_y = bar_y + 20
        local next_width = inner_width
        local next_exp = exp_data[member.display_lvl + 1]
        local remaining_exp = math.ceil(next_exp - member.display_exp)

        lg.setFont(fonts.medium)
        lg.printf('Next: '..remaining_exp..'', next_x, next_y, next_width, 'right')
        
        lg.setScissor()
        
        lg.setColor(1, 1, 1)
        lg.rectangle('line', box_x, box_y + (box_height / 2) * (1 - display_t), 
            box_width, box_height * display_t)
    end
end

return exp_screen