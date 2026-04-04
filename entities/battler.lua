local enemy_sprites = require('graphics.enemy_sprites')
local party_sprites = require('graphics.party_sprites')
local enemy_action = require('data.enemy_action')
local action_data = require('data.action_data')
local fonts = require('fonts')

local battler = {}

function battler.new_member(data)
    local self = battler.new(data)

    self.name = data.name
    self.is_party_member = true
    self.member_id = data.id
    self.current_hp = data.current_hp
    self.max_hp = data.max_hp
    self.current_mp = data.current_mp
    self.max_mp = data.max_mp
    self.crit_rate = 64
    self.total_exp = data.total_exp
    self.sprite = party_sprites.get_sprite(data.sprite)

    function self:draw(x, y)
        local sprite = self.sprite

        if not self:is_alive() then
            sprite = party_sprites.get_sprite('coffin')
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprite, x, y)
    end

    function self:execute_action(executor)
        local action = self.current_action
        self.current_action = nil

        if action then
            action.data:execute(self, action.targets, executor)
        end
    end

    return self
end

function battler.new_enemy(data, name)

    local self = battler.new(data)

    self.ref = data.ref
    self.name = name
    self.current_hp = data.hp
    self.max_hp = data.hp
    self.current_mp = data.mp
    self.max_mp = data.mp
    self.crit_rate = 128
    self.sprite_height = data.sprite_height
    self.exp_drop = data.exp_drop
    self.gold_drop = data.gold_drop
    self.sprite = enemy_sprites.get_sprite(data.ref)

    local function draw_text(animation, x, y, text, font, color)
        if color and color == 'grey' then
            love.graphics.setColor(0.6,0.6,0.6)
        elseif color and color == 'blue' then
            love.graphics.setColor(0.4,0.2,0.6)
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
        local progress = animation.timer / animation.duration

        local offset = 0
        local scale = 1
        local peak = 0.5

        if progress < peak then
            local p = progress / peak
            offset = -10 * p
            scale = 1 + 0.1 * p
        else
            local p = (progress - peak) / (1 - peak)
            offset = -10 * (1 - p)
            scale = 1 + 0.1 * (1 - p)
        end

        local w = self.sprite:getWidth()
        local h = self.sprite:getHeight()

        local ox = w / 2
        local oy = h / 2

        local draw_x = x + ox * (1 - scale)
        local draw_y = y + oy * (1 - scale) + offset

        love.graphics.draw(
            self.sprite,
            draw_x,
            draw_y,
            0,
            scale,
            scale
        )
    end

    local function draw_damaged_animation(animation, x, y)
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
            draw_text(animation, x, y, animation.value, fonts.bold_mono)
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

    function self:draw_animation(animation, x, y)
        if self.animation.type == 'attack' then
            draw_attack_animation(animation, x, y)
        elseif self.animation.type == 'damaged' then
            draw_damaged_animation(animation, x, y)
        elseif self.animation.type == 'death' then
            draw_death_animation(animation, x, y)
        end
    end

    function self:execute_action(executor)

        local action_ref = enemy_action.get(self)
        local data = action_data[action_ref]

        local group = executor.get_party()
        if data.aim == 'allies' then
            group = executor.get_enemies()
        end

        local targets
        if data.scope == 'all' then
            targets = {unpack(group)}
        elseif data.scope == 'self' then
            targets = {self}
        elseif data.scope == 'single' then
            local target = executor.get_random_target(group)
            targets = {target}
        end
        data:execute(self, targets, executor)

        if data.animation then
            self.animation = {type = data.animation, timer = 0, duration = 0.5}
        end
    end

    return self
end

function battler.new(data)

    local self = {}

    self.lvl = data.lvl
    self.str = data.str
    self.vit = data.vit
    self.agi = data.agi
    self.dodge_rate = data.dodge_rate or 0
    self.skills = data.skills or {}
    self.passive_skills = data.passive_skills or {}
    self.passives = {}
    self.status = data.status or {}
    self.strong = data.strong or {}
    self.immune = data.immune or {}
    self.is_dead = false

    for i, ref in pairs(data.passive_skills) do
        self.passives[ref] = true
    end

    function self:is_alive()
        return not self.is_dead
    end

    function self:update(dt)
        if not self.animation then return end

        self.animation.timer = self.animation.timer + dt
        if self.animation.timer >= self.animation.duration then
            self.animation.timer = 0
            self.animation = nil
        end
    end

    function self:take_damage(damage)
        self.current_hp = self.current_hp - damage
        self.animation = {type = 'damaged', timer = 0, duration = 1, value = damage}
    end

    function self:dies()
        self.current_hp = 0
        self.is_dead = true
        self.animation = {type = 'death', timer = 0, duration = 0.5}
    end

    function self:cannot_act()
        return self.status['STUN'] or self.status['SLEEP'] or self.status['CONFUSE']
    end

    function self:get_atk()
        return self.str
    end

    function self:get_def()
        return self.vit
    end

    function self:get_spd()
        return self.agi
    end

    return self
end

return battler