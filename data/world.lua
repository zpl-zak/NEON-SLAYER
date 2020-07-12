boundsMesh = nil

local terrain, terrainMaterial, backdropModel, boundsMaterial, gradientMaterial
local gradientMesh, sunMesh, sunGlareMesh
local bdMesh = {}
local ACTIVE_TILE_TEX_SLOT = 42

world = {}
local terrainShader

function initWorld()
    terrain = Model("terrain.fbx")
    terrainMaterial = Material("tile_base.png")
    terrainMaterial:setDiffuse(0x815192)
    terrainMaterial:setPower(120)
    terrain:getMeshes()[1]:setMaterial(0, terrainMaterial)

    terrainMaterial:loadFile("tile_active.png", ACTIVE_TILE_TEX_SLOT)

    boundsMaterial = Material("bounds.png")
    boundsMaterial:setShaded(false)
    boundsMaterial:alphaIsTransparency(true)

    gradientMaterial = Material("gradient.png")
    gradientMaterial:setShaded(false)
    
    world = cols.newWorld()
    
    local meshNode = terrain:getRootNode():findNode("terrain")
    local mesh = meshNode:getMeshParts()[1][1]
    local baseCols = cols.newTriangleMeshFromPart(mesh, meshNode:getFinalTransform():translate(Vector3()))
    
    for i=0,(WORLD_TILES[1]-1),1 do
        for j=0,(WORLD_TILES[2]-1),1 do
            addTile(baseCols, Vector3(WORLD_SIZE*i,0,WORLD_SIZE*j))
        end
    end
    
    terrainShader = Effect("terrain.fx")

    backdropModel = Model("backdrop.fbx")
    backdropRoot = backdropModel:getRootNode()
    boundsMesh = backdropRoot:findNode("bounds")
    gradientMesh = backdropRoot:findNode("gradient")
    sunMesh = backdropRoot:findNode("sun")
    sunGlareMesh = backdropRoot:findNode("sunglare")
    boundsMesh:getMeshes()[1]:setMaterial(0, boundsMaterial)
    gradientMesh:getMeshes()[1]:setMaterial(0, gradientMaterial)
    
    bdMesh = backdropRoot:findNode("bd"):getNodes()

    for _, bd in pairs(bdMesh) do
        local dm = bd:getMeshes()[1]
        local m = dm:getMaterial(1)
        m:setShaded(false)
    end

    sunMesh:getMeshes()[1]:getMaterial(1):setShaded(false)
    sunGlareMesh:getMeshes()[1]:getMaterial(1):setShaded(false)
    sunGlareMesh:getMeshes()[1]:getMaterial(1):alphaTest(false)
    sunGlareMesh:getMeshes()[1]:getMaterial(1):setAlphaRef(0)
end

function addTile(col, pos)
    local b = col.bounds

    local terrainMesh = setmetatable({
        tris = col.tris,
        mat = col.mat,
        bounds = cols.newBox({b.min-pos, b.max-pos})
    }, col.__index)
    terrainMesh.pos = Matrix():translate(pos)

    world:addCollision(terrainMesh)
end

function drawWorld()
    terrainShader:begin("Main")
    terrainShader:beginPass("Default")
    terrainShader:setFloat("time", time)
    terrainShader:setVector3("campos", player.pos:neg())
    terrainShader:setLight("sun", light)
    terrainShader:setTexture("active_tile", terrainMaterial:getHandle(ACTIVE_TILE_TEX_SLOT))
    terrainShader:commit()
    for _, w in pairs(world.shapes) do
        terrain:draw(w.pos)
    end
    terrainShader:endPass()
    terrainShader:done()
    
    local wmat = Matrix():scale(WORLD_TILES[1], WORLD_TILES[1], WORLD_TILES[1])
    gradientMesh:draw(wmat)
    sunGlareMesh:draw(wmat)
    sunMesh:draw(wmat)
    for i=#bdMesh,1,-1 do
        bdMesh[i]:draw(wmat)
    end
end
