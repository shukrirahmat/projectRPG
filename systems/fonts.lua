local fonts = {}

function fonts.load()
    fonts.small = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Medium.ttf', 14)
    fonts.medium = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Medium.ttf', 16)
    fonts.large = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Medium.ttf', 18)
    fonts.bold = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Bold.ttf', 20)
    fonts.xlarge = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Medium.ttf', 20)
    fonts.smallMono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Medium.ttf', 14)
    fonts.mediumMono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Medium.ttf', 16)
    fonts.largeMono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Medium.ttf', 18)
    fonts.boldMono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Bold.ttf', 20)
    fonts.xlargeMono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Medium.ttf', 20)
    fonts.small:setFilter("nearest", "nearest")
    fonts.medium:setFilter("nearest", "nearest")
    fonts.large:setFilter("nearest", "nearest")
    fonts.bold:setFilter("nearest", "nearest")
    fonts.xlarge:setFilter("nearest", "nearest")
    fonts.smallMono:setFilter("nearest", "nearest")
    fonts.mediumMono:setFilter("nearest", "nearest")
    fonts.largeMono:setFilter("nearest", "nearest")
    fonts.boldMono:setFilter("nearest", "nearest")
    fonts.xlargeMono:setFilter("nearest", "nearest")
end

return fonts