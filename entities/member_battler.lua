local party_sprites = require('graphics.party_sprites')
local battler = require('entities.battler')

local member_battler = {}

function member_battler.new(data)
    local self = battler.new(data)

    self.name = data.name
    self.is_party_member = true
    self.member_id = data.id
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

    function self:execute_action(engine)
        local action = self.current_action
        self.current_action = nil

        if action then
            action = engine.reaim_target(action)
            local data = action.data
            
            if data.cost and self.current_mp > data.cost then
                self.current_mp = self.current_mp - data.cost
            end
            
            data:execute(self, action.targets, engine)
        end
    end

    function self:execute_combo(combo, engine)
        combo = engine.reaim_target(combo)
        combo.data:execute(self, combo.targets, engine)
    end

    function self:apply_effect(effect, engine, hud)
        effect.data:apply(engine, effect.user, effect.target, effect.value)
        if effect.data.party_animation then
            local animation =  effect.data.party_animation
            hud.animate(
                animation.type, 
                animation.duration * engine.BATTLE_SPEED, 
                self, 
                effect.value
            )
        end
    end

    return self
end

return member_battler