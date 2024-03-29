-- YOU SHOULDN'T REQUIRE THIS LUA FILE IN ANY OF YOUR SCRIPTS!
-- YOU SHOULDN'T REQUIRE THIS LUA FILE IN ANY OF YOUR SCRIPTS!
-- YOU SHOULDN'T REQUIRE THIS LUA FILE IN ANY OF YOUR SCRIPTS!
---@diagnostic disable: lowercase-global
---@diagnostic disable: unused-function

function _init() end
function _shutdown() end
function _fixedUpdate(dt) end
function _render(dt) end
function _render2D() end
function _charInput(letter) end
function ShowMessage(caption, text) end
function LogString(text) end
function ExitGame() end
function RestartGame() end
function IsDebugMode() end
function SetFPS(fps) end
function dofile(scriptName) end
function loadfile(fileName) end
function GetTime() end
function getTime() end
function SaveState(data) end
function LoadState() end

---@return type _Sound
function Sound(path) end

_Sound = {}
function _Sound.play() end
function _Sound.pause() end
function _Sound.stop() end
function _Sound.setVolume(vol) end
function _Sound.setPan(val) end
function _Sound.setFrequency(val) end
function _Sound.setCursor(val) end
function _Sound.getPosition() end
function _Sound.setPosition(val) end
function _Sound.getTotalSize() end
function _Sound.loop(state) end
function _Sound.isLooping() end
function _Sound.isPlaying() end
function _Sound.getVolume() end
function _Sound.getPan() end
function _Sound.getFrequency() end
function _Sound.getCursor() end
function _Sound.getData() end

---@return type _Music
function Music(path) end

_Music = {}
function _Music.play() end
function _Music.pause() end
function _Music.stop() end
function _Music.setVolume(vol) end
function _Music.setPan(val)  end
function _Music.isPlaying() end
function _Music.getVolume() end
function _Music.getPosition() end
function _Music.setPosition(val) end
function _Music.getTotalSize() end
function _Music.getPan() end

function Color(r,g,b,a) end
function ColorLinear(r,g,b,a) end
function WorldToScreen(pos,view,proj) end
function ScreenToWorld(pos,view,proj) end
function str2vec(text) end
function vec2str(vec) end

---@return type _Matrix
function Matrix() end

_Matrix = {}
function _Matrix.translate(x,y,z) end
function _Matrix.rotate(x,y,z) end
function _Matrix.scale(x,y,z) end
function _Matrix.inverse() end
function _Matrix.shadow(planeVec,lightVec) end
function _Matrix.reflect(planeVec) end
function _Matrix.lookAt(eye,at,up) end
function _Matrix.m(row,col) end
function _Matrix.row(index) end
function _Matrix.col(index) end
function _Matrix.bind(kind) end
function _Matrix.persp(eye,atpos,up) end
function _Matrix.ortho(w,h,near,far,flipLH) end
function _Matrix.orthoEx(l,r,t,b,near,far,flipLH) end

---@return type _Vector
function Vector(x,y,z) end
---@return type _Vector
function Vector3(x,y,z) end
---@return type _Vector
function Vector4(x,y,z,w) end

_Vector = {}
function _Vector.cross(vec) end
function _Vector.get() end
function _Vector.color() end
function _Vector.mag() end
function _Vector.magSq() end
function _Vector.lerp(b,t) end
function _Vector.neg() end
function _Vector.normalize() end
function _Vector.m(index,val) end
function _Vector.x() end
function _Vector.y() end
function _Vector.z() end
function _Vector.w() end

function ClearScene(color) end
function CameraPerspective(fov,near,far,flipLH) end
function CameraOrthographic(w,h,near,far,flipLH) end
function CameraOrthographicEx(l,r,t,p,near,far,flipLH) end
function BindTexture(tex) end
function GetResolution() end
function GetMatrix(kind) end
function IsFocused() end
function RenderState(kind,state) end
function ToggleWireframe(state) end
function SetFog(color,kind,start,_end) end
function SetFog(color,kind,density) end
function ClearFog() end
function SamplerState(stage,kind,state) end
function EnableLighting(state) end
function ToggleDepthTest(state) end
function ToggleDepthWrite(state) end
function AmbientColor(color) end
function ClearTarget() end
function DrawBox(mat,dims,color) end
function DrawQuad(x1,x2,y1,y2,color,flipY) end
function DrawQuad3D(x1,x2,y1,y2,z1,z2,color) end
function DrawQuadEx(vec3,color,usesDepth,flipY) end
function DrawPolygon(v1,v2,v3) end
function CullMode(mode) end
function FillScreen(color,flipY) end
function RegisterFontFile(path) end

---@return type _Scene
function Scene(modelName,loadMaterials,optimizeMesh) end

---@return type _Scene
function Model(modelName,loadMaterials,optimizeMesh) end

_Scene = {}
function _Scene.draw(mat) end
function _Scene.drawSubset(index,mat) end
function _Scene.loadModel(modelName,loadMaterials,optimizeMesh) end
function _Scene.loadScene(modelName,loadMaterials,optimizeMesh) end
function _Scene.getMeshes() end
function _Scene.getLights() end
function _Scene.getFlattenNodes() end
function _Scene.getTargets() end
function _Scene.findMesh(name) end
function _Scene.findLight(name) end
function _Scene.findTarget(name) end
function _Scene.getRootNode() end

---@return type _Node
function Node() end

_Node = {}
function _Node.clone() end
function _Node.getName() end
function _Node.setName(name) end
function _Node.getTransform() end
function _Node.setTransform(mat) end
function _Node.getFinalTransform() end
function _Node.addNode(node) end
function _Node.addMesh(mesh) end
function _Node.draw(mat) end
function _Node.drawSubset(index, mat) end
function _Node.getMeshes() end
function _Node.getMeshParts() end
function _Node.getLights() end
function _Node.getTargets() end
function _Node.getNodes() end
function _Node.findMesh(name) end
function _Node.findLight(name) end
function _Node.findTarget(name) end
function _Node.findNode(name) end
function _Node.getMeta(name) end

---@return type _Mesh
function Mesh() end

_Mesh = {}
function _Mesh.addFGroup(part) end
function _Mesh.addPart(part) end
function _Mesh.draw(mat) end
function _Mesh.clone() end
function _Mesh.getFGroups() end
function _Mesh.getParts() end
function _Mesh.clear() end
function _Mesh.setName(name) end
function _Mesh.getName() end
function _Mesh.setMaterial(tex) end
function _Mesh.getMaterial(matId) end
function _Mesh.getOwner() end

---@return type _Part
function FaceGroup() end

_Part = {}
function _Part.clone() end
function _Part.addVertex(vert) end
function _Part.addIndex(index) end
function _Part.addTriangle(a,b,c) end
function _Part.setMaterial(mat) end
function _Part.getMaterial()  end
function _Part.draw(mat) end
function _Part.build() end
function _Part.calcNormals() end
function _Part.clear() end
function _Part.getVertices() end
function _Part.getIndices() end

---@return type _Material
function Material() end

---@return type _Material
function Material(textureName) end

---@return type _Material
function Material(w,h) end

_Material = {}
function _Material.setSamplerState(sampler,state) end
function _Material.getSamplerState(sampler) end
function _Material.loadFile(textureName) end
function _Material.res() end
function _Material.data() end
function _Material.getHandle(slot) end
function _Material.setHandle(slot,texHandle) end
function _Material.setDiffuse(color) end
function _Material.setAmbient(color) end
function _Material.setSpecular(color) end
function _Material.setEmission(color) end
function _Material.setPower(val) end
function _Material.setOpacity(val) end
function _Material.alphaIsTransparency(state) end
function _Material.alphaTest(state) end
function _Material.setAlphaRef(val) end
function _Material.setShaded(state) end

---@return type _Vert
function Vertex(x,y,z,su,tv,color,nx,ny,nz) end

_Vert = {}
function _Vert.get() end

---@return type _Font
function Font(fontFamily,size,boldness,italic) end

_Font = {}
function _Font.drawText(color,text,x,y,w,h,flags) end
function _Font.measureText(text,flags,width) end

---@return type _RenderTarget
function RenderTarget() end

---@return type _RenderTarget

function RenderTarget(w,h) end
---@return type _RenderTarget
function RenderTarget(w,h,hasDepth) end

_RenderTarget = {}
function _RenderTarget.getHandle() end
function _RenderTarget.bind() end

---@return type _Effect
function Effect(effectPath) end

_Effect = {}
function _Effect.begin(technique) end
function _Effect.cend() end
function _Effect.flush() end
function _Effect.beginPass(pass) end
function _Effect.endPass() end
function _Effect.commit() end
function _Effect.setBool(name,val) end
function _Effect.setFloat(name,val) end
function _Effect.setMatrix(name,mat) end
function _Effect.setVector3(name,vec) end
function _Effect.setVector4(name,vec) end
function _Effect.setInteger(name,val) end
function _Effect.setTexture(name,texHandle) end
function _Effect.setTexture(name,slot,mat) end
function _Effect.setTexture(name,rtt) end

---@return type _Light
function Light(slot) end

_Light = {}
function _Light.enable(state,slot) end
function _Light.setPosition(vec) end
function _Light.setDirection(vec) end
function _Light.setDiffuse(color) end
function _Light.setSpecular(color) end
function _Light.setAmbient(color) end
function _Light.setRange(val) end
function _Light.setFalloff(val) end
function _Light.setAttenuation(a,b,c) end
function _Light.setInnerAngle(val) end
function _Light.setOuterAngle(val) end
function _Light.setType(kind) end
function _Light.setSlot(slot) end
function _Light.getType() end
function _Light.getSlot() end
function _Light.getOwner() end

function GetKey(key) end
function GetKeyDown(key) end
function GetKeyUp(key) end
function GetMouseXY() end
function GetMouseDelta() end
function SetMouseXY(x,y) end
function GetMouse(button) end
function GetMouseDown(button) end
function GetMouseUp(button) end
function IsCursorVisible() end
function ShowCursor(state) end
function GetCursorMode() end
function SetCursorMode(mode) end
function ShowCursor(state) end
















PRIMITIVEKIND_POINTLIST = {}
PRIMITIVEKIND_LINELIST = {}
PRIMITIVEKIND_LINESTRIP = {}
PRIMITIVEKIND_TRIANGLELIST = {}
PRIMITIVEKIND_TRIANGLESTRIP = {}
PRIMITIVEKIND_TRIANGLEFAN = {}
MATRIXKIND_VIEW = {}
MATRIXKIND_PROJECTION = {}
MATRIXKIND_TEXTURE0 = {}
MATRIXKIND_TEXTURE1 = {}
MATRIXKIND_TEXTURE2 = {}
MATRIXKIND_TEXTURE3 = {}
MATRIXKIND_TEXTURE4 = {}
MATRIXKIND_TEXTURE5 = {}
MATRIXKIND_TEXTURE6 = {}
MATRIXKIND_TEXTURE7 = {}
MATRIXKIND_WORLD = {}
CLEARFLAG_COLOR = {}
CLEARFLAG_DEPTH = {}
CLEARFLAG_STENCIL = {}
CLEARFLAG_STANDARD = {}
TEXTURESLOT_ALBEDO = {}
TEXTURESLOT_SPECULAR = {}
TEXTURESLOT_NORMAL = {}
TEXTURESLOT_DISPLACE = {}
TEXTURESLOT_USER_END = {}
MAX_TEXTURE_SLOTS = {}
FOGKIND_NONE = {}
FOGKIND_EXP = {}
FOGKIND_EXP2 = {}
FOGKIND_LINEAR = {}
WORLD = {}
VIEW = {}
PROJ = {}
CULLKIND_NONE = {}
CULLKIND_CW = {}
CULLKIND_CCW = {}
LIGHTKIND_DIRECTIONAL = {}
LIGHTKIND_POINT = {}
LIGHTKIND_SPOT = {}
RENDERSTATE_ZENABLE = {}
RENDERSTATE_FILLMODE = {}
RENDERSTATE_SHADEMODE = {}
RENDERSTATE_ZWRITEENABLE = {}
RENDERSTATE_ALPHATESTENABLE = {}
RENDERSTATE_LASTPIXEL = {}
RENDERSTATE_SRCBLEND = {}
RENDERSTATE_DESTBLEND = {}
RENDERSTATE_CULLMODE = {}
RENDERSTATE_ZFUNC = {}
RENDERSTATE_ALPHAREF = {}
RENDERSTATE_ALPHAFUNC = {}
RENDERSTATE_DITHERENABLE = {}
RENDERSTATE_ALPHABLENDENABLE = {}
RENDERSTATE_FOGENABLE = {}
RENDERSTATE_SPECULARENABLE = {}
RENDERSTATE_FOGCOLOR = {}
RENDERSTATE_FOGTABLEMODE = {}
RENDERSTATE_FOGSTART = {}
RENDERSTATE_FOGEND = {}
RENDERSTATE_FOGDENSITY = {}
RENDERSTATE_RANGEFOGENABLE = {}
RENDERSTATE_STENCILENABLE = {}
RENDERSTATE_STENCILFAIL = {}
RENDERSTATE_STENCILZFAIL = {}
RENDERSTATE_STENCILPASS = {}
RENDERSTATE_STENCILFUNC = {}
RENDERSTATE_STENCILREF = {}
RENDERSTATE_STENCILMASK = {}
RENDERSTATE_STENCILWRITEMASK = {}
RENDERSTATE_TEXTUREFACTOR = {}
RENDERSTATE_WRAP0 = {}
RENDERSTATE_WRAP1 = {}
RENDERSTATE_WRAP2 = {}
RENDERSTATE_WRAP3 = {}
RENDERSTATE_WRAP4 = {}
RENDERSTATE_WRAP5 = {}
RENDERSTATE_WRAP6 = {}
RENDERSTATE_WRAP7 = {}
RENDERSTATE_CLIPPING = {}
RENDERSTATE_LIGHTING = {}
RENDERSTATE_AMBIENT = {}
RENDERSTATE_FOGVERTEXMODE = {}
RENDERSTATE_COLORVERTEX = {}
RENDERSTATE_LOCALVIEWER = {}
RENDERSTATE_NORMALIZENORMALS = {}
RENDERSTATE_DIFFUSEMATERIALSOURCE = {}
RENDERSTATE_SPECULARMATERIALSOURCE = {}
RENDERSTATE_AMBIENTMATERIALSOURCE = {}
RENDERSTATE_EMISSIVEMATERIALSOURCE = {}
RENDERSTATE_VERTEXBLEND = {}
RENDERSTATE_CLIPPLANEENABLE = {}
RENDERSTATE_POINTSIZE = {}
RENDERSTATE_POINTSIZE_MIN = {}
RENDERSTATE_POINTSPRITEENABLE = {}
RENDERSTATE_POINTSCALEENABLE = {}
RENDERSTATE_POINTSCALE_A = {}
RENDERSTATE_POINTSCALE_B = {}
RENDERSTATE_POINTSCALE_C = {}
RENDERSTATE_MULTISAMPLEANTIALIAS = {}
RENDERSTATE_MULTISAMPLEMASK = {}
RENDERSTATE_PATCHEDGESTYLE = {}
RENDERSTATE_DEBUGMONITORTOKEN = {}
RENDERSTATE_POINTSIZE_MAX = {}
RENDERSTATE_INDEXEDVERTEXBLENDENABLE = {}
RENDERSTATE_COLORWRITEENABLE = {}
RENDERSTATE_TWEENFACTOR = {}
RENDERSTATE_BLENDOP = {}
RENDERSTATE_NORMALDEGREE = {}
RENDERSTATE_SCISSORTESTENABLE = {}
RENDERSTATE_SLOPESCALEDEPTHBIAS = {}
RENDERSTATE_ANTIALIASEDLINEENABLE = {}
RENDERSTATE_MINTESSELLATIONLEVEL = {}
RENDERSTATE_MAXTESSELLATIONLEVEL = {}
RENDERSTATE_ADAPTIVETESS_X = {}
RENDERSTATE_ADAPTIVETESS_Y = {}
RENDERSTATE_ADAPTIVETESS_Z = {}
RENDERSTATE_ADAPTIVETESS_W = {}
RENDERSTATE_ENABLEADAPTIVETESSELLATION = {}
RENDERSTATE_TWOSIDEDSTENCILMODE = {}
RENDERSTATE_CCW_STENCILFAIL = {}
RENDERSTATE_CCW_STENCILZFAIL = {}
RENDERSTATE_CCW_STENCILPASS = {}
RENDERSTATE_CCW_STENCILFUNC = {}
RENDERSTATE_COLORWRITEENABLE1 = {}
RENDERSTATE_COLORWRITEENABLE2 = {}
RENDERSTATE_COLORWRITEENABLE3 = {}
RENDERSTATE_BLENDFACTOR = {}
RENDERSTATE_SRGBWRITEENABLE = {}
RENDERSTATE_DEPTHBIAS = {}
RENDERSTATE_WRAP8 = {}
RENDERSTATE_WRAP9 = {}
RENDERSTATE_WRAP10 = {}
RENDERSTATE_WRAP11 = {}
RENDERSTATE_WRAP12 = {}
RENDERSTATE_WRAP13 = {}
RENDERSTATE_WRAP14 = {}
RENDERSTATE_WRAP15 = {}
RENDERSTATE_SEPARATEALPHABLENDENABLE = {}
RENDERSTATE_SRCBLENDALPHA = {}
RENDERSTATE_DESTBLENDALPHA = {}
RENDERSTATE_BLENDOPALPHA = {}
SAMPLERSTATE_ADDRESSU = {}
SAMPLERSTATE_ADDRESSV = {}
SAMPLERSTATE_ADDRESSW = {}
SAMPLERSTATE_BORDERCOLOR = {}
SAMPLERSTATE_MAGFILTER = {}
SAMPLERSTATE_MINFILTER = {}
SAMPLERSTATE_MIPFILTER = {}
SAMPLERSTATE_MIPMAPLODBIAS = {}
SAMPLERSTATE_MAXMIPLEVEL = {}
SAMPLERSTATE_MAXANISOTROPY = {}
SAMPLERSTATE_SRGBTEXTURE = {}
SAMPLERSTATE_ELEMENTINDEX = {}
SAMPLERSTATE_DMAPOFFSET = {}
TEXF_NONE = {}
TEXF_POINT = {}
TEXF_LINEAR = {}
TEXF_ANISOTROPIC = {}
TEXF_PYRAMIDALQUAD = {}
TEXF_GAUSSIANQUAD = {}
TEXA_WRAP = {}
TEXA_MIRROR = {}
TEXA_CLAMP = {}
TEXA_BORDER = {}
TEXA_MIRRORONCE = {}
FONTFLAG_TOP = {}
FONTFLAG_LEFT = {}
FONTFLAG_CENTER = {}
FONTFLAG_RIGHT = {}
FONTFLAG_VCENTER = {}
FONTFLAG_BOTTOM = {}
FONTFLAG_WORDBREAK = {}
FONTFLAG_SINGLELINE = {}
FONTFLAG_EXPANDTABS = {}
FONTFLAG_NOCLIP = {}
FF_TOP = {}
FF_LEFT = {}
FF_CENTER = {}
FF_RIGHT = {}
FF_VCENTER = {}
FF_BOTTOM = {}
FF_WORDBREAK = {}
FF_SINGLELINE = {}
FF_EXPANDTABS = {}
FF_NOCLIP = {}
RTKIND_COLOR = {}
RTKIND_DEPTH = {}
RTKIND_COLOR16 = {}
RTKIND_COLOR32 = {}
MOUSE_LEFT_BUTTON = {}
MOUSE_MIDDLE_BUTTON = {}
MOUSE_RIGHT_BUTTON = {}
MOUSE_WHEEL_UP = {}
MOUSE_WHEEL_DOWN = {}
CURSORMODE_DEFAULT = {}
CURSORMODE_CENTERED = {}
CURSORMODE_WRAPPED = {}
KEY_LBUTTON = {}
KEY_RBUTTON = {}
KEY_CANCEL = {}
KEY_MBUTTON = {}
KEY_XBUTTON1 = {}
KEY_XBUTTON2 = {}
KEY_BACK = {}
KEY_TAB = {}
KEY_CLEAR = {}
KEY_RETURN = {}
KEY_SHIFT = {}
KEY_CONTROL = {}
KEY_MENU = {}
KEY_PAUSE = {}
KEY_CAPITAL = {}
KEY_KANA = {}
KEY_HANGEUL = {}
KEY_HANGUL = {}
KEY_JUNJA = {}
KEY_FINAL = {}
KEY_HANJA = {}
KEY_KANJI = {}
KEY_ESCAPE = {}
KEY_CONVERT = {}
KEY_NONCONVERT = {}
KEY_ACCEPT = {}
KEY_MODECHANGE = {}
KEY_SPACE = {}
KEY_PRIOR = {}
KEY_NEXT = {}
KEY_END = {}
KEY_HOME = {}
KEY_LEFT = {}
KEY_UP = {}
KEY_RIGHT = {}
KEY_DOWN = {}
KEY_SELECT = {}
KEY_PRINT = {}
KEY_EXECUTE = {}
KEY_SNAPSHOT = {}
KEY_INSERT = {}
KEY_DELETE = {}
KEY_HELP = {}
KEY_LWIN = {}
KEY_RWIN = {}
KEY_APPS = {}
KEY_SLEEP = {}
KEY_NUMPAD0 = {}
KEY_NUMPAD1 = {}
KEY_NUMPAD2 = {}
KEY_NUMPAD3 = {}
KEY_NUMPAD4 = {}
KEY_NUMPAD5 = {}
KEY_NUMPAD6 = {}
KEY_NUMPAD7 = {}
KEY_NUMPAD8 = {}
KEY_NUMPAD9 = {}
KEY_MULTIPLY = {}
KEY_ADD = {}
KEY_SEPARATOR = {}
KEY_SUBTRACT = {}
KEY_DECIMAL = {}
KEY_DIVIDE = {}
KEY_F1 = {}
KEY_F2 = {}
KEY_F3 = {}
KEY_F4 = {}
KEY_F5 = {}
KEY_F6 = {}
KEY_F7 = {}
KEY_F8 = {}
KEY_F9 = {}
KEY_F10 = {}
KEY_F11 = {}
KEY_F12 = {}
KEY_F13 = {}
KEY_F14 = {}
KEY_F15 = {}
KEY_F16 = {}
KEY_F17 = {}
KEY_F18 = {}
KEY_F19 = {}
KEY_F20 = {}
KEY_F21 = {}
KEY_F22 = {}
KEY_F23 = {}
KEY_F24 = {}
KEY_NAVIGATION_VIEW = {}
KEY_NAVIGATION_MENU = {}
KEY_NAVIGATION_UP = {}
KEY_NAVIGATION_DOWN = {}
KEY_NAVIGATION_LEFT = {}
KEY_NAVIGATION_RIGHT = {}
KEY_NAVIGATION_ACCEPT = {}
KEY_NAVIGATION_CANCEL = {}
KEY_NUMLOCK = {}
KEY_SCROLL = {}
KEY_OEM_NEC_EQUAL = {}
KEY_OEM_FJ_JISHO = {}
KEY_OEM_FJ_MASSHOU = {}
KEY_OEM_FJ_TOUROKU = {}
KEY_OEM_FJ_LOYA = {}
KEY_OEM_FJ_ROYA = {}
KEY_LSHIFT = {}
KEY_RSHIFT = {}
KEY_LCONTROL = {}
KEY_RCONTROL = {}
KEY_LMENU = {}
KEY_RMENU = {}
KEY_BROWSER_BACK = {}
KEY_BROWSER_FORWARD = {}
KEY_BROWSER_REFRESH = {}
KEY_BROWSER_STOP = {}
KEY_BROWSER_SEARCH = {}
KEY_BROWSER_FAVORITES = {}
KEY_BROWSER_HOME = {}
KEY_VOLUME_MUTE = {}
KEY_VOLUME_DOWN = {}
KEY_VOLUME_UP = {}
KEY_MEDIA_NEXT_TRACK = {}
KEY_MEDIA_PREV_TRACK = {}
KEY_MEDIA_STOP = {}
KEY_MEDIA_PLAY_PAUSE = {}
KEY_LAUNCH_MAIL = {}
KEY_LAUNCH_MEDIA_SELECT = {}
KEY_LAUNCH_APP1 = {}
KEY_LAUNCH_APP2 = {}
KEY_OEM_1 = {}
KEY_OEM_PLUS = {}
KEY_OEM_COMMA = {}
KEY_OEM_MINUS = {}
KEY_OEM_PERIOD = {}
KEY_OEM_2 = {}
KEY_OEM_3 = {}
KEY_GAMEPAD_A = {}
KEY_GAMEPAD_B = {}
KEY_GAMEPAD_X = {}
KEY_GAMEPAD_Y = {}
KEY_GAMEPAD_RIGHT_SHOULDER = {}
KEY_GAMEPAD_LEFT_SHOULDER = {}
KEY_GAMEPAD_LEFT_TRIGGER = {}
KEY_GAMEPAD_RIGHT_TRIGGER = {}
KEY_GAMEPAD_DPAD_UP = {}
KEY_GAMEPAD_DPAD_DOWN = {}
KEY_GAMEPAD_DPAD_LEFT = {}
KEY_GAMEPAD_DPAD_RIGHT = {}
KEY_GAMEPAD_MENU = {}
KEY_GAMEPAD_VIEW = {}
KEY_GAMEPAD_LEFT_THUMBSTICK_BUTTON = {}
KEY_GAMEPAD_RIGHT_THUMBSTICK_BUTTON = {}
KEY_GAMEPAD_LEFT_THUMBSTICK_UP = {}
KEY_GAMEPAD_LEFT_THUMBSTICK_DOWN = {}
KEY_GAMEPAD_LEFT_THUMBSTICK_RIGHT = {}
KEY_GAMEPAD_LEFT_THUMBSTICK_LEFT = {}
KEY_GAMEPAD_RIGHT_THUMBSTICK_UP = {}
KEY_GAMEPAD_RIGHT_THUMBSTICK_DOWN = {}
KEY_GAMEPAD_RIGHT_THUMBSTICK_RIGHT = {}
KEY_GAMEPAD_RIGHT_THUMBSTICK_LEFT = {}
KEY_OEM_4 = {}
KEY_OEM_5 = {}
KEY_OEM_6 = {}
KEY_OEM_7 = {}
KEY_OEM_8 = {}
KEY_OEM_AX = {}
KEY_OEM_102 = {}
KEY_ICO_HELP = {}
KEY_ICO_00 = {}
KEY_PROCESSKEY = {}
KEY_ICO_CLEAR = {}
KEY_PACKET = {}
KEY_OEM_RESET = {}
KEY_OEM_JUMP = {}
KEY_OEM_PA1 = {}
KEY_OEM_PA2 = {}
KEY_OEM_PA3 = {}
KEY_OEM_WSCTRL = {}
KEY_OEM_CUSEL = {}
KEY_OEM_ATTN = {}
KEY_OEM_FINISH = {}
KEY_OEM_COPY = {}
KEY_OEM_AUTO = {}
KEY_OEM_ENLW = {}
KEY_OEM_BACKTAB = {}
KEY_ATTN = {}
KEY_CRSEL = {}
KEY_EXSEL = {}
KEY_EREOF = {}
KEY_PLAY = {}
KEY_ZOOM = {}
KEY_NONAME = {}
KEY_PA1 = {}
KEY_OEM_CLEAR = {}


