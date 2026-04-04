local fonts = {}

function fonts.load()
    fonts.small = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Medium.ttf', 14)
    fonts.medium = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Medium.ttf', 16)
    fonts.large = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Medium.ttf', 18)
    fonts.bold = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Bold.ttf', 20)
    fonts.xlarge = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleNext-Medium.ttf', 20)
    fonts.small_mono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Medium.ttf', 14)
    fonts.medium_mono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Medium.ttf', 16)
    fonts.large_mono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Medium.ttf', 18)
    fonts.bold_mono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Bold.ttf', 20)
    fonts.xlarge_mono = love.graphics.newFont('assets/fonts/AtkinsonHyperlegibleMono-Medium.ttf', 20)
    fonts.small:setFilter("nearest", "nearest")
    fonts.medium:setFilter("nearest", "nearest")
    fonts.large:setFilter("nearest", "nearest")
    fonts.bold:setFilter("nearest", "nearest")
    fonts.xlarge:setFilter("nearest", "nearest")
    fonts.small_mono:setFilter("nearest", "nearest")
    fonts.medium_mono:setFilter("nearest", "nearest")
    fonts.large_mono:setFilter("nearest", "nearest")
    fonts.bold_mono:setFilter("nearest", "nearest")
    fonts.xlarge_mono:setFilter("nearest", "nearest")
end

return fonts