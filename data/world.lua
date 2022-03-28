WORLD_SIZE = 1000.0
WORLD_TILES = {5,5}

local ACTIVE_TILE_TEX_SLOT = 42

local function addTile(colsys, col, pos)
    local b = col.bounds

    local terrainMesh = setmetatable({
        tris = col.tris,
        mat = col.mat,
        bounds = cols.newBox({b.min-pos, b.max-pos})
    }, col.__index)
    terrainMesh.pos = Matrix():translate(pos)

    colsys:addCollision(terrainMesh)
end

local class = require "class"

class "World" {
    __init__ = function (self)
        self.terrain = Model("assets/terrain.fbx")
        self.terrainMaterial = Material("assets/tile_base.png")
        self.terrainMaterial:setDiffuse(0x815192)
        self.terrainMaterial:setPower(120)
        self.terrain:getMeshes()[1]:setMaterial(self.terrainMaterial)

        self.terrainMaterial:loadFile("assets/tile_active.png", ACTIVE_TILE_TEX_SLOT)

        self.boundsMaterial = Material("assets/bounds.png")
        self.boundsMaterial:setShaded(false)
        self.boundsMaterial:alphaIsTransparency(true)

        self.gradientMaterial = Material("assets/gradient.png")
        self.gradientMaterial:setShaded(false)

        self.colsys = cols.newWorld()

        local meshNode = self.terrain:getRootNode():findNode("terrain")
        local mesh = meshNode:getMeshParts()[1][1]
        local baseCols = cols.newTriangleMeshFromPart(mesh, meshNode:getFinalTransform():translate(Vector3()))

        for i=0,(WORLD_TILES[1]-1),1 do
            for j=0,(WORLD_TILES[2]-1),1 do
                addTile(self.colsys, baseCols, Vector3(WORLD_SIZE*i,0,WORLD_SIZE*j))
            end
        end

        self.terrainShader = Effect("fx/terrain.fx")

        self.backdropModel = Model("assets/backdrop.fbx")
        self.backdropRoot = self.backdropModel:getRootNode()
        self.boundsMesh = self.backdropRoot:findNode("bounds")
        self.gradientMesh = self.backdropRoot:findNode("gradient")
        self.sunMesh = self.backdropRoot:findNode("sun")
        self.sunGlareMesh = self.backdropRoot:findNode("sunglare")
        self.boundsMesh:getMeshes()[1]:setMaterial(self.boundsMaterial)
        self.gradientMesh:getMeshes()[1]:setMaterial(self.gradientMaterial)

        self.bdMesh = self.backdropRoot:findNode("bd"):getNodes()

        for _, bd in pairs(self.bdMesh) do
            local dm = bd:getMeshes()[1]
            local m = dm:getMaterial(1)
            m:setShaded(false)
        end

        self.sunMesh:getMeshes()[1]:getMaterial(1):setShaded(false)
        self.sunGlareMesh:getMeshes()[1]:getMaterial(1):setShaded(false)
        self.sunGlareMesh:getMeshes()[1]:getMaterial(1):alphaTest(false)
        self.sunGlareMesh:getMeshes()[1]:getMaterial(1):setAlphaRef(0)

        return self
    end,

    draw = function (self)
        self.terrainShader:begin("Main")
        self.terrainShader:beginPass("Default")
        self.terrainShader:setFloat("time", time)
        self.terrainShader:setVector3("campos", localPlayer.pos:neg())
        self.terrainShader:setLight("sun", sun)
        self.terrainShader:setTexture("active_tile", self.terrainMaterial:getHandle(ACTIVE_TILE_TEX_SLOT))
        self.terrainShader:commit()
        for _, w in pairs(world.colsys.shapes) do
            self.terrain:draw(w.pos)
        end
        self.terrainShader:endPass()
        self.terrainShader:done()

        local wmat = Matrix():scale(WORLD_TILES[1], WORLD_TILES[1], WORLD_TILES[1])
        CullMode(CULLKIND_CCW)
        self.gradientMesh:draw(wmat)
        self.sunGlareMesh:draw(wmat)
        self.sunMesh:draw(wmat)
        for i=#self.bdMesh,1,-1 do
            self.bdMesh[i]:draw(wmat)
        end
    end
}

return World()