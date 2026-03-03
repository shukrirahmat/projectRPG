local overworldState = {}

overworldState.tileSize = 64
overworldState.currentMap = nil
overworldState.currentSprite = nil
overworldState.playerPos = { x = 0, y = 0 }
overworldState.camera = {x = 0, y = 0}
overworldState.currentMove = nil
overworldState.moveSpeed = 0.3
overworldState.moveTimer = overworldState.moveSpeed
overworldState.moveShift = { x = 0, y = 0}
overworldState.party = {}
overworldState.menuOpen = false

return overworldState 