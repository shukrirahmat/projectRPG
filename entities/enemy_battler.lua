local battler = require('entities.battler')
local action_data = require('data.action_data')
local enemy_sprites = require('graphics.enemy_sprites')
local fonts = require('fonts')

local enemy_battler = {}

function enemy_battler.new(data, name)

    local self = battler.new(data)

    self.ref = data.ref
    self.name = name
    self.crit_rate = 128
    self.sprite_height = data.sprite_height
    self.exp_drop = data.exp_drop
    self.gold_drop = data.gold_drop
    self.sprite = enemy_sprites.get_sprite(data.ref)
    self.species = data.species or nil

    local function draw_text(animation, x, y, text, font, color)
        if color and color == 'grey' then
            love.graphics.setColor(0.6,0.6,0.6)
        elseif color and color == 'blue' then
            love.graphics.setColor(0.5,0.3,0.7)
        elseif color and color == 'dark_blue' then
            love.graphics.setColor(0.3, 0.2 ,0.4)
        else
            love.graphics.setColor(1,1,1)
        end
        local progress = animation.timer / animation.duration
        love.graphics.setFont(font)
        love.graphics.printf(
            text,
            x,
            y + (self.sprite:getHeight() - self.sprite_height) - 20 - (20 * progress),
            self.sprite:getWidth(),
            'center'
        )
    end

    local function draw_attack_animation(animation, x, y)
        love.graphics.setColor(1, 1, 1)
        local enemy_movement = { 
            {x=-5, y=0},
            {x=-5, y=-2.5},
            {x=-5, y=-5},
            {x=-2.5, y=-5},
            {x= 0, y=-5},
            {x= 2.5, y=-5},
            {x=5, y=-5},
            {x=5, y=-2.5},
            {x=5, y=0},
            {x=5, y=2.5},
            {x=5, y=5},
            {x=2.5, y=5},
            {x= 0, y=5},
        }

        local progress = animation.timer / animation.duration
        local move_index = math.floor(progress * 13)
        local movement = enemy_movement[move_index]

        if movement then
            love.graphics.draw(self.sprite, x + movement.x, y + movement.y)
        else
            love.graphics.draw(self.sprite, x, y)
        end
    end

    local function draw_damaged_animation(animation, x, y, color)
        local progress = animation.timer / animation.duration
        local tick = math.floor(progress * 10)
        if tick == 1 or tick == 3 then
            love.graphics.setColor(0.1, 0.1, 0.1)
            love.graphics.draw(self.sprite, x, y)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.sprite, x, y)
        end

        if tick >= 1 then
            draw_text(animation, x, y, animation.value, fonts.bold_mono, color)
        end
    end

    local function draw_missed_animation(animation, x, y, color)
        local progress = animation.timer / animation.duration
        local tick = math.floor(progress * 10)
        if tick == 1 or tick == 3 then
            love.graphics.draw(self.sprite, x + 3, y)
        elseif tick == 2 then
            love.graphics.draw(self.sprite, x + 5, y)
        else
            love.graphics.draw(self.sprite, x, y)
        end

        if tick >= 1 then
            draw_text(animation, x, y, 'MISS', fonts.medium_mono, color)
        end
    end

    local function draw_immune_animation(animation, x, y)
        local progress = animation.timer / animation.duration
        local tick = math.floor(progress * 10)
        if tick == 1 or tick == 2 or tick == 3  then
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.draw(self.sprite, x, y)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.sprite, x, y)
        end
    end

    local function draw_death_animation(animation, x, y)
        local tint = math.max(0, 1 - animation.timer / animation.duration)
        love.graphics.setColor(tint, tint, tint)
        love.graphics.draw(self.sprite, x, y)
    end

    function self:draw(x, y)
        if self.animation then
            self:draw_animation(self.animation, x, y)
        else
            if not self:is_alive() then return end
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.sprite, x, y)
        end
    end

    function self:animate(type, duration, value)
        self.animation = { type = type, timer = 0, duration = duration, value = value}
    end

    function self:draw_animation(animation, x, y)
        if self.animation.type == 'attack' then
            draw_attack_animation(animation, x, y)
        elseif self.animation.type == 'damaged' then
            draw_damaged_animation(animation, x, y)
        elseif self.animation.type == 'resisted' then
            draw_damaged_animation(animation, x, y, 'grey')
        elseif self.animation.type == 'mp_damaged' then
            draw_damaged_animation(animation, x, y, 'blue')
        elseif self.animation.type == 'mp_resisted' then
            draw_damaged_animation(animation, x, y, 'dark_blue')
        elseif self.animation.type == 'missed' then
            draw_missed_animation(animation, x, y)
        elseif self.animation.type == 'missed_resist' then
            draw_missed_animation(animation, x, y, 'grey')
        elseif self.animation.type == 'immune' then
            draw_immune_animation(animation, x, y)
        elseif self.animation.type == 'death' then
            draw_death_animation(animation, x, y)
        end
    end

    function self:execute_action(engine)
        local action = self.current_action
        self.current_action = nil

        if self.status['STUN'] then return end
        if not action then return end

        action = engine.reaim_target(action)

        local data = action.data
        local targets = action.targets
        local var = {}

        if data.type == 'Magic' or data.type == 'Tech' then
            if self.status['SEAL'] or (data.cost and self.current_mp < data.cost) then
                var = { to_use = data }
                data = action_data['skill_cancelled']
                targets = {self}
            else
                self.current_mp = self.current_mp - data.cost
            end
        end

        data:execute(self, targets, engine, var)

        if data.enemy_animation then
            local animation = data.enemy_animation
            self:animate(animation.type, animation.duration * engine.BATTLE_SPEED)
        end
    end

    function self:execute_combo(combo, engine)
        combo = engine.reaim_target(combo)
        local data = combo.data
        data:execute(self, combo.targets, engine)
        if data.enemy_animation then
            local animation = data.enemy_animation
            self:animate(animation.type, animation.duration * engine.BATTLE_SPEED)
        end
    end

    function self:apply_effect(effect, engine)
        effect.data:apply(engine, effect.user, effect.target, effect.value)
        if effect.data.enemy_animation then
            local animation =  effect.data.enemy_animation
            self:animate(animation.type, animation.duration * engine.BATTLE_SPEED, effect.value)
        end
    end


    return self
end

return enemy_battler