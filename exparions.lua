gui.get_config_item("lua>lua>allow unsafe scripts"):set_bool(true)

cb = gui.add_checkbox
sl = gui.add_slider
dd = gui.add_combo
mdd = gui.add_multi_combo
btn = gui.add_button
txt = gui.add_textbox
lb = gui.add_listbox
kb = gui.add_keybind
cp = gui.add_colorpicker
find = gui.get_config_item
size={render.get_screen_size()}
clipboard = require("clipboard")
playerstate = 0;
ConditionalStates = { }
configs = {}

yawadd = find("Rage>Anti-Aim>Angles>Yaw add");
manual_left = find("rage>anti-aim>angles>left")
manual_right = find("rage>anti-aim>angles>right")
manual_freestand = find("rage>anti-aim>angles>freestand")

refs = {
    yawadd = find("Rage>Anti-Aim>Angles>Yaw add");
    yawaddamount = find("Rage>Anti-Aim>Angles>Add");
    spin = find("Rage>Anti-Aim>Angles>Spin");
    jitter = find("Rage>Anti-Aim>Angles>Jitter");
    spinrange = find("Rage>Anti-Aim>Angles>Spin range");
    spinspeed = find("Rage>Anti-Aim>Angles>Spin speed");
    jitterrandom = find("Rage>Anti-Aim>Angles>Random");
    enabledesync = find("Rage>Anti-aim>Desync>Fake");
    jitterrange = find("Rage>Anti-Aim>Angles>Jitter Range");
    desync = find("Rage>Anti-Aim>Desync>Fake amount");
    compAngle = find("Rage>Anti-Aim>Desync>Compensate angle");
    freestandFake = find("Rage>Anti-Aim>Desync>Freestand fake");
    flipJittFake = find("Rage>Anti-Aim>Desync>Flip fake with jitter");
    leanMenu = find("Rage>Anti-Aim>Desync>Roll lean");
    leanamount = find("Rage>Anti-Aim>Desync>Lean amount");
    ensureLean = find("Rage>Anti-Aim>Desync>Ensure Lean");
    flipJitterRoll = find("Rage>Anti-Aim>Desync>Flip lean with jitter");
    TargetDormant = find("rage>aimbot>aimbot>target dormant");
    checkboxes = {
    jitter = find("Rage>Anti-Aim>Angles>Jitter");
    back = find("rage>anti-aim>angles>back");
    left = find("rage>anti-aim>angles>left");
    right = find("rage>anti-aim>angles>right");
    fake = find("rage>anti-aim>desync>fake");
    }
};

local var = {
    player_states = {"Standing", "Moving", "Slowwalk", "Air", "Air Crouch", "Crouch"};
};


---speed function
function get_local_speed()
    local local_player = entities.get_entity(engine.get_local_player())
    if local_player == nil then
      return
    end
  
    local velocity_x = local_player:get_prop("m_vecVelocity[0]")
    local velocity_y = local_player:get_prop("m_vecVelocity[1]")
    local velocity_z = local_player:get_prop("m_vecVelocity[2]")
  
    local velocity = math.vec3(velocity_x, velocity_y, velocity_z)
    local speed = math.ceil(velocity:length2d())
    if speed < 10 then
        return 0
    else 
        return speed 
    end
end

--fps stuff
function accumulate_fps()
    return math.ceil(1 / global_vars.frametime)
end
--tickrate function
function get_tickrate()
    if not engine.is_in_game() then return end

    return math.floor( 1.0 / global_vars.interval_per_tick )
end
---ping function
function get_ping()
    if not engine.is_in_game() then return end

    return math.ceil(utils.get_rtt() * 1000);
end

-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
local function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
local function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

--import and export system
local function str_to_sub(text, sep)
    local t = {}
    for str in string.gmatch(text, "([^"..sep.."]+)") do
        t[#t + 1] = string.gsub(str, "\n", " ")
    end
    return t
end

local function to_boolean(str)
    if str == "true" or str == "false" then
        return (str == "true")
    else
        return str
    end
end

local function animation(check, name, value, speed) 
    if check then 
        return name + (value - name) * global_vars.frametime * speed / 1.5
    else 
        return name - (value + name) * global_vars.frametime * speed / 1.5
        
    end
end

function animate(value, cond, max, speed, dynamic, clamp)

    -- animation speed
    speed = speed * global_vars.frametime * 20

    -- static animation
    if dynamic == false then
        if cond then
            value = value + speed
        else
            value = value - speed
        end
    
    -- dynamic animation
    else
        if cond then
            value = value + (max - value) * (speed / 100)
        else
            value = value - (0 + value) * (speed / 100)
        end
    end

    -- clamp value
    if clamp then
        if value > max then
            value = max
        elseif value < 0 then
            value = 0
        end
    end

    return value
end

function drag(var_x, var_y, size_x, size_y)
    local mouse_x, mouse_y = input.get_cursor_pos()

    local drag = false

    if input.is_key_down(0x01) then
        if mouse_x > var_x:get_int() and mouse_y > var_y:get_int() and mouse_x < var_x:get_int() + size_x and mouse_y < var_y:get_int() + size_y then
            drag = true
        end
    else
        drag = false
    end

    if (drag) then
        var_x:set_int(mouse_x - (size_x / 2))
        var_y:set_int(mouse_y - (size_y / 2))
    end

end

local function vtable_bind( class, _type, index )
    local this = ffi.cast( "void***", class )
    local ffitype = ffi.typeof( _type )
    return function ( ... )
        return ffi.cast( ffitype, this[ 0 ][ index ] )( this, ... )
    end
end

local IConsole = utils.find_interface( "vstdlib.dll", "VEngineCvar007" )
local GetConvarFN = vtable_bind( IConsole, "unsigned int(__thiscall*)(void*, char*)", 15 )

local BackupCallbackSize = { }

local function SetCallbacks( cvar, n )
    if not cvar then return end
    BackupCallbackSize[ cvar ] = ffi.cast( "unsigned int*", cvar + 0x60 )[ 0 ]
    ffi.cast( "unsigned int*", cvar + 0x60 )[ 0 ] = n or 0
end

print("-> BEST LUA LOADING ...")
print("-> ..")
print("-> .")
print("-> Nice, good luck")
print(" _____________________________________ ")
print("| exparionscrackbyfreez3e__ Loaded               |")
print("| Alpha version                       |")
print("| Version: 1.0                        |")
print("| Dev: crackbyfreez3e_      |")
print("| Support: crackbyfreez3e_                  |")
print("|_____________________________________|")

menu = lb("exparionscrackbyfreez3e_ | Menu", "lua>tab a", 5, false, { "Global", "Rage", "Anti-aim", "Visuals", "Misc" })

forcheck = lb("Tab", "lua>tab a", 1, false, { "Global tab" })

ConditionalStates[0] = {
	player_state = dd("[Conditions]", "lua>tab b", var.player_states);
}
for i=1, 6 do
	ConditionalStates[i] = {
        ---Anti-Aim
        yawadd = cb("Yaw add " .. var.player_states[i], "lua>tab b");
        yawaddamount = sl("Add " .. var.player_states[i], "lua>tab b", -180, 180, 1);
        spin = cb("Spin " .. var.player_states[i], "lua>tab b");
        spinrange = sl("Spin range " .. var.player_states[i], "lua>tab b", 0, 360, 1);
        spinspeed = sl("Spin speed " .. var.player_states[i], "lua>tab b", 0, 360, 1);
        jitter = cb("Jitter " .. var.player_states[i], "lua>tab b");
        jittertype = dd("Jitter Type " .. var.player_states[i], "lua>tab b", {"Center", "Offset", "Random"});
        jitterrange = sl("Jitter range " .. var.player_states[i], "lua>tab b", 0, 360, 1);
        ---Desync
        desynctype = dd("Desync Type " .. var.player_states[i], "lua>tab b", {"Static", "Jitter", "Random"});
        desync = sl("Desync " .. var.player_states[i], "lua>tab b", -60, 60, 1);
        compAngle = sl("Comp " .. var.player_states[i], "lua>tab b", 0, 100, 1);
        flipJittFake = cb("Flip fake " .. var.player_states[i], "lua>tab b");
        leanMenu = dd("Roll lean " .. var.player_states[i], "lua>tab b", {"None", "Static", "Extend fake", "Invert fake", "Freestand", "Freestand Opposite", "Jitter"});
        leanamount = sl("Lean amount " .. var.player_states[i], "lua>tab b", 0, 50, 1);
    };
end
local cImport = btn("Import settings", "LUA>TAB b", function() configs.import() end);
local cExport = btn("Export settings", "LUA>TAB b", function() configs.export() end);
local cDefault = btn("Load default settings", "LUA>TAB b", function() configs.importDefault() end);


--rage
local lerp = function(precenteges, start, destination) return start+(destination-start)*precenteges end
function get_velocity()
    if not engine.is_in_game() then return end
    local first_velocity = entities.get_entity(engine.get_local_player()):get_prop("m_vecVelocity[0]")
    local second_velocity = entities.get_entity(engine.get_local_player()):get_prop("m_vecVelocity[1]")
    local speed = math.floor(math.sqrt(first_velocity*first_velocity+second_velocity*second_velocity))
    
    return speed
end
function get_state(speed)
    if not engine.is_in_game() then return end
    if not entities.get_entity(engine.get_local_player()):is_alive() then return end
    local flags = entities.get_entity(engine.get_local_player()):get_prop("m_fFlags")
    if bit.band(flags, 1) == 1 then
        if bit.band(flags, 4) == 4 or info.fatality.in_fakeduck then 
            return 4 -- Crouching
        else
            if speed <= 3 then
                return 1 -- Standing
            else
                if info.fatality.in_slowwalk then
                    return 3 -- Slowwalk
                else
                    return 2 -- Moving
                end
            end
        end
    elseif bit.band(flags, 1) == 0 then
        if bit.band(flags, 4) == 4 then
            return 6 -- Air Crouch
        else
            return 5 -- Air
        end
    end
end

enabled = cb("Defensive on peek", "lua>tab a")
pitch = gui.add_slider("Pitch on peek", "lua>tab a", -89, 89, 1)
pitch2 = gui.add_slider("Pitch 2 on peek", "lua>tab a", -89, 89, 1)
onairrrr = cb("Defensive on air", "lua>tab a")
pitchair = gui.add_slider("Pitch on air", "lua>tab a", -89, 89, 1)
pitch2air = gui.add_slider("Pitch 2 on air", "lua>tab a", -89, 89, 1)

hsfl = cb("Disable fakelag on HS", "lua>tab b")

brlc = cb("Break lagcomp in air", "lua>tab b")

som = cb("Static on manual", "lua>tab b")

DAMain = cb("Dormant Aimbot", "lua>tab b")
gui.add_keybind("lua>tab b>Dormant Aimbot")


--visuals
ind = cb("Indicators", "lua>tab b")
color = cp("lua>tab b>Indicators", false)

sidewm = cb("Infobar", "lua>tab b")

aspectratiocb = gui.add_checkbox("Aspect ratio", "lua>tab b")
aspectratiosl = gui.add_slider("Value", "lua>tab b", 1, 200, 1)

fog_master_boolean = gui.add_checkbox("Enable fog", "lua>tab b")
fog_color_picker = gui.add_colorpicker("lua>tab b>Enable Fog", true, render.color(255, 255, 255, 255))
fog_start_slider = gui.add_slider("Fog start", "lua>tab b", -200, 5000, 1)
fog_distance_slider = gui.add_slider("Fog distance", "lua>tab b", 0, 5000, 1)
fog_density_slider = gui.add_slider("Fog density", "lua>tab b", 0, 100, 1)
missmarker = gui.add_checkbox("Miss markers", "lua>tab b")
misscolor = gui.add_colorpicker("lua>tab b>miss markers", true, render.color(255, 0, 50))



bloom_enable = cb("Bloom", "lua>tab b")
bloom_scale = sl("Bloom scale", "lua>tab b", 0, 50, 1)

override_boolean = cb("Sunset Mode", "lua>tab b")
x_val_slider = sl("Sunset X", "lua>tab b", -100, 100, 1)
y_val_slider = sl("Sunset Y", "lua>tab b", -100, 100, 1)


--misc
clantag = gui.add_checkbox("ClanTag", "lua>tab b")
clantagtype = gui.add_combo("ClanTag Type", "lua>tab b", {"Original clantag", "CustomFlow"})

trashtalk, on_death = gui.add_multi_combo("TrashTalk", "lua>tab b", {"On Kill", "On Death"})

local pGetModuleHandle_sig =
    utils.find_pattern("engine.dll", " FF 15 ? ? ? ? 85 C0 74 0B") or error("Couldn't find signature #1")
local pGetProcAddress_sig =
    utils.find_pattern("engine.dll", " FF 15 ? ? ? ? A3 ? ? ? ? EB 05") or error("Couldn't find signature #2")


local pGetProcAddress = ffi.cast("uint32_t**", ffi.cast("uint32_t", pGetProcAddress_sig) + 2)[0][0]
local fnGetProcAddress = ffi.cast("uint32_t(__stdcall*)(uint32_t, const char*)", pGetProcAddress)

local pGetModuleHandle = ffi.cast("uint32_t**", ffi.cast("uint32_t", pGetModuleHandle_sig) + 2)[0][0]
local fnGetModuleHandle = ffi.cast("uint32_t(__stdcall*)(const char*)", pGetModuleHandle)

local function proc_bind(module_name, function_name, typedef)
    local ctype = ffi.typeof(typedef)
    local module_handle = fnGetModuleHandle(module_name)
    local proc_address = fnGetProcAddress(module_handle, function_name)
    local call_fn = ffi.cast(ctype, proc_address)

    return call_fn
end

local nativeVirtualProtect =
    proc_bind(
    "kernel32.dll",
    "VirtualProtect",
    "int(__stdcall*)(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect)"
)

local function VirtualProtect(lpAddress, dwSize, flNewProtect, lpflOldProtect)
    return nativeVirtualProtect(ffi.cast("void*", lpAddress), dwSize, flNewProtect, lpflOldProtect)
end

local function PatchByte(address, value)
    local prot = ffi.new("unsigned long[1]")
    VirtualProtect(address, 1, 0x40, prot);
    ffi.cast("unsigned char*", address)[0] = value
    VirtualProtect(address, 1, prot[0], prot);
end

ffi.cdef
[[
    struct vec3_t
    {
        float x, y, z;
    };

    struct color_t
    {
        unsigned char r, g, b, a;
    };
]]

local glowbullet = gui.add_checkbox("Glow bullet impacts", "lua>tab b")
local server_color = gui.add_colorpicker("lua>tab b>Glow bullet impacts", false, render.color("#0000FF"))


local RenderGlowBoxesFN = utils.find_pattern("client.dll", "89 6C 24 04 8B EC 83 EC 60 56 57 8B F9 89 7D DC") - 0x10
local GlowObjectManager = ffi.cast("uint32_t*", utils.find_pattern("client.dll", "0F 11 05 ? ? ? ? 83 C8 01 C7 05 ? ? ? ? 00 00 00 00") + 3)[0]
local AddGlowBoxFN = ffi.cast("int(__thiscall*)(uint32_t, struct vec3_t, struct vec3_t, struct vec3_t, struct vec3_t, struct color_t, float)", utils.find_pattern("client.dll", "55 8B EC 53 56 8D"))
local PassAddr = utils.find_pattern("client.dll", "8B 4C 24 20 57 6A") + 0x6

-- fix fucked up z stencil
PatchByte(RenderGlowBoxesFN + 0x239, 1)
-- change draw pass to always be GLOWBOX_PASS_STENCIL
PatchByte(PassAddr, 1)


local col = ffi.new("struct color_t")
local pos, ang, min, max = ffi.new("struct vec3_t"), ffi.new("struct vec3_t"), ffi.new("struct vec3_t"), ffi.new("struct vec3_t")
local function AddGlowBox(position, angle, mins, maxs, color, duration)
    pos.x, pos.y, pos.z = position:unpack()
    ang.x, ang.y, ang.z = angle:unpack()
    min.x, min.y, min.z = mins:unpack()
    max.x, max.y, max.z = maxs:unpack()

    col.r, col.g, col.b, col.a = color.r, color.g, color.b, 255

    AddGlowBoxFN(GlowObjectManager, pos, ang, min, max, col, duration)
end

local IMPACTBOX_MIN, IMPACTBOX_MAX = math.vec3(-1, -1, -1), math.vec3(1, 1, 1)

enabled = gui.add_checkbox("Slowed Down Indicator", "lua>tab b")
x1 = gui.add_slider("x", "lua>tab b", 0, size[1], 1)
y1 = gui.add_slider("y", "lua>tab b", 0, size[2], 1)
gui.set_visible("lua>tab b>x", false)
gui.set_visible("lua>tab b>y", false)


calibri13 = render.create_font("calibri.ttf", 13, render.font_flag_shadow)
verdana42 = render.create_font("verdana.ttf", 42, 10)

function slowdownind()


    if not enabled:get_bool() then return end

    local pos = {x1:get_int(), y1:get_int()}
    local size = {100 + 100, 22}
    local player=entities.get_entity(engine.get_local_player())
    if player==nil then return end
    if not player:is_alive() or enabled:get_bool()==false then  return end
    local mod=player:get_prop("m_flVelocityModifier")
    mod=mod*100
    if mod==100 and not gui.is_menu_open() then return end



    drag(x1, y1, size[1], size[2])

    alpha = animate(alpha or 0, gui.is_menu_open(),1, 0.5, false, true)
    alpha_anim = math.floor(math.abs(math.sin(global_vars.realtime) * 4) * 6)
    alpha_anim1 = math.floor(math.abs(math.sin(global_vars.realtime) * 7) * 255)

    --glow
    for i = 1, 10 do
      render.rect_filled_rounded(pos[1] - i, pos[2] - i, pos[1] + size[1] + i, pos[2] + size[2] + i, render.color(255, 255, 255, (alpha_anim - (2 * i)) ), 10)
    end


    render.rect_filled_rounded(pos[1] , pos[2] , pos[1] + size[1], pos[2] + 22,render.color(255, 255, 255, 255 ), 5)
    render.rect_filled_rounded(pos[1] + 1, pos[2] + 1, pos[1] + size[1]  - 1, pos[2] + 21, render.color(17, 17, 19, 255 ), 4)
    render.rect_filled_rounded(pos[1] + 4, pos[2] + 4, pos[1] + size[1] + mod - 104, pos[2] + 18, render.color(255, 255, 255, 255 ), 4)
    render.triangle_filled(pos[1] - 30, pos[2]- 11, pos[1] -2 , pos[2]+ 34, pos[1] -59, pos[2]+34, render.color(17, 17, 19, 255 ))
    render.triangle_filled(pos[1] - 30, pos[2]- 5, pos[1] -10 , pos[2]+ 30, pos[1] -50, pos[2]+30, render.color(255, 255, 255, 255))
    render.text(verdana42, pos[1] - 37 , pos[2]- 8, "!", render.color(17, 17, 19, alpha_anim1 ))
    render.text(calibri13, pos[1] + 20 , pos[2]+ 5, "Slowed down: "..tostring(math.floor(mod)).."%" , render.color(255, 255, 255, 255 ))

end

ragebotlogs = cb("Hitlog", "lua>tab b")
rglonsc = cb("HitLog on screen", "lua>tab b")

local function is_mouse_in_bounds(pos, size)
    local x, y = pos.x, pos.y
    local w, h = size.x, size.y

    local mouse_position = {input.get_cursor_pos()}

    return ((mouse_position[1] >= x and mouse_position[1] < x + w and mouse_position[2] >= y and mouse_position[2] < y + h) and gui.is_menu_open())
end



local e_global = {
    SCREEN = {render.get_screen_size()}
}


function table.count(tbl)
    if tbl == nil then
        return 0
    end

    if #tbl == 0 then
        local count = 0

        for data in pairs(tbl) do
            count = count + 1
        end

        return count
    end
    return #tbl
end


--animation
local animation4 = {}

animation4.data = {}


function animation4.lerp(start, end_pos, time)
    if (type(start) == "table") then
        local color_data = {0, 0, 0, 0}

        for i, color_key in ipairs({"r", "g", "b", "a"}) do
            color_data[i] = animation.lerp(start[color_key], end_pos[color_key], time)
        end

        return render.color(unpack(color_data))
    end

    return (end_pos - start) * (global_vars.frametime * time) + start
end


function animation4.new(name, value, time)
    if (animation4.data[name] == nil) then
        animation4.data[name] = value
    end

    animation4.data[name] = animation4.lerp(animation4.data[name], value, time)

    return animation4.data[name]
end


local c_drag = {}
local m_drag = { __index = c_drag }


function c_drag.new(slider_x, slider_y, x, y)
    slider_x:set_int(x)
    slider_y:set_int(y)

    return setmetatable({
        x = slider_x,
        y = slider_y,

        d_x = 0,
        d_y = 0,

        dragging = false,
        unlocked = false
    }, m_drag)
end


function c_drag:unlock()
    self.unlocked = true
end


function c_drag:lock()
    self.unlocked = false
end


function c_drag:handle(width, height)
    self.width = width
    self.height = height

    local screen = e_global.SCREEN
    local mouse_position = {input.get_cursor_pos()}

    if (is_mouse_in_bounds(math.vec3(self.x:get_int(), self.y:get_int()), math.vec3(self.width, self.height))) then
        if (input.is_key_down(0x01) and not self.dragging) then
            self.dragging = true

            self.d_x = self.x:get_int() - mouse_position[1]
            self.d_y = self.y:get_int() - mouse_position[2]
        end
    end

    if (not input.is_key_down(0x01)) then 
        self.dragging = false
    end

    if (self.dragging and gui.is_menu_open()) then
        local new_x = math.max(0, math.min(screen[1] - self.width, mouse_position[1] + self.d_x))
        local new_y = math.max(0, math.min(screen[2] - self.height, mouse_position[2] + self.d_y))
        new_x = self.unlocked and mouse_position[1] + self.d_x or new_x
        new_y = self.unlocked and mouse_position[2] + self.d_y or new_y

        self.x:set_int(new_x)
        self.y:set_int(new_y)
    end
end


function c_drag:get()
    return self.x:get_int(), self.y:get_int()
end


--draw function
local draw = {}


function draw.rect(pos, size, color1, round, round_flags)
    local a, b = pos, pos + size

    if (round ~= nil) then
        render.rect_filled_rounded(a.x, a.y, b.x, b.y, color1, round, round_flags or render.all)
        return
    end

    return render.rect_filled(a.x, a.y, b.x, b.y, color1)
end


function draw.rect_outline(pos, size, color1)
    local a, b = pos, pos + size

    return render.rect(a.x, a.y, b.x, b.y, color1)
end


function draw.gradient(pos, size, color1, color2, ltr, normal)
    local a, b = pos, pos + size

    if (normal == true) then
        a, b = pos, size
    end

    if (ltr == true) then
        render.rect_filled_multicolor(a.x, a.y, b.x, b.y, color1, color2, color1, color2)
        return
    end

    return render.rect_filled_multicolor(a.x, a.y, b.x, b.y, color1, color1, color2, color2)
end


function draw.push_clip_rect(pos, size, ...)
    local a, b = pos, pos + size

    return render.push_clip_rect(a.x, a.y, b.x, b.y, ...)
end

--- @return: void
function draw.pop_clip_rect()
    return render.pop_clip_rect()
end


function draw.circle_outline(pos, color1, radius, angle, percentage, thickness, segments)
    local x, y = pos.x, pos.y

    return render.circle(x, y, radius, color1, thickness or 1, segments or 12, percentage or 1, angle or 0)
end


function draw.shadow(pos, size, color1, length)
    local r, g, b, a = color1.r, color1.g, color1.b, color1.a

    for i = 1, 10 do
        draw.rect_outline(pos - math.vec3(i, i), size + math.vec3(i * 2, i * 2), render.color(r, g, b, (60 - (60 / length) * i) * (a / 255)))
    end
end


function draw.window(pos, size, color1)
    local round = 4
    local x, y = pos.x, pos.y
    local width, height = x + size.x, y + size.y

    local r, g, b, a = color1.r, color1.g, color1.b, color1.a
    alpha = animate(alpha or 0, gui.is_menu_open() or override_active or other_binds_active, 1, 0.5, false, true)
    alpha_anim = math.floor(math.abs(math.sin(global_vars.realtime) * 4) * 6)
    alpha_anim1 = math.floor(math.abs(math.sin(global_vars.realtime) * 7) * 255)

    draw.rect(pos, size, render.color(0,0,0, (175 / 255) * a), round)
end


--fonts
local fonts = {}

fonts.verdana = {}

fonts.verdana.default = render.create_font("verdana.ttf", 12, render.font_flag_shadow)
fonts.verdana.bold = render.create_font("calibrib.ttf", 12, render.font_flag_shadow)



local ui_general = {}

ui_general_keybinds = cb("Keybinds", "lua>tab b")
ui_general.keybinds_check = cb("Keybinds color", "lua>tab b")
keybinds_color = gui.add_colorpicker("lua>tab b>Keybinds color", true)

ui_general.watermark = cb("Watermark", "lua>tab b")
ui_general.watermark_check = cb("Watermark color", "lua>tab b")
watermark_color = gui.add_colorpicker("lua>tab b>Watermark color", true)


keybinds_x = sl("Keybinds x", "lua>tab a", 0, e_global.SCREEN[1], 1); gui.set_visible("lua>tab a>Keybinds x", false)
keybinds_y = sl("Keybinds y", "lua>tab a", 0, e_global.SCREEN[2], 1); gui.set_visible("lua>tab a>Keybinds y", false)



--watermark
local watermark = {}

function watermark.handle()
    if (not ui_general.watermark:get_bool()) then
        return
    end

    local watermark_color = watermark_color:get_color()
    local w_r, w_g, w_b = watermark_color.r, watermark_color.g, watermark_color.b

    local player = entities.get_entity(engine.get_local_player())

    local prefix = " | "..engine.get_player_info(engine.get_local_player()).name.." "

    local ping = math.floor((utils.get_rtt() or 0) * 1000)
    local latency = ping >= 1 and ("| %dms"):format(ping) or ""

    local time = utils.get_time()
    local actual_time = ("%s:%s"):format(time.hour, time.min)

    local text = ("%s%s | %s"):format(prefix, latency, actual_time)
    local text_size = {render.get_text_size(fonts.verdana.bold, text)}

    local x, y = e_global.SCREEN[1], 8
    local width, height = animation4.new("watermark width", text_size[1] + 12, 8), 22

    x = x - width - 10

    draw.window(math.vec3(x, y), math.vec3(width, height), render.color(255, 255, 255, 255))
    render.text(fonts.verdana.bold, x + (width / 2) - (text_size[1] / 2), y + (height / 2) - (text_size[2] / 2) + 1, text, render.color(w_r, w_g, w_b, 255))
end


--keybinds
local keybinds = {}

keybinds.active = {}

keybinds.list = {
    ["Double tap"] = "rage>aimbot>aimbot>double tap",
    ["On shot anti-aim"] = "rage>aimbot>aimbot>hide shot",
    ["Minimum damage"] = "rage>aimbot>ssg08>scout>override",
    ["Force safepoint"] = "rage>aimbot>aimbot>force extra safety",
    ["Headshot only"] = "rage>aimbot>aimbot>headshot only",
    ["Duck peek assist"] = "misc>movement>fake duck",
    ["Quick peek assist"] = "misc>movement>peek assist",
    ["Left manual"] = "rage>anti-aim>angles>left",  
    ["Right manual"] = "rage>anti-aim>angles>right", 
    ["Back manual"] = "rage>anti-aim>angles>back",
    ["Slow Walk"] = "misc>movement>Slide",
    ["Auto Manual"] = "rage>anti-aim>angles>Freestand",
}

keybinds.width = 0

keybinds.modes = { 
    [0] = "always",
    [1] = "holding",
    [2] = "toggled",
    [3] = "off"
}

keybinds_dragging = c_drag.new(keybinds_x, keybinds_y, 0, 0)

function keybinds.handle()
    if (not ui_general_keybinds:get_bool()) then
        return
    end

    local keybinds_color = keybinds_color:get_color()
    local k_r, k_g, k_b = keybinds_color.r, keybinds_color.g, keybinds_color.b

    local latest_item = false
    local maximum_offset = 66

    for bind_name, path in pairs(keybinds.list) do
        local item_active = gui.get_config_item(path):get_bool()

        if (item_active) then
            latest_item = true

            if (keybinds.active[bind_name] == nil) then
                keybinds.active[bind_name] = {mode = "", alpha = 0, offset = 0, active = false}
            end

            local key_code, key_type = gui.get_keybind(path)
            local bind_mode = keybinds.modes[key_type]

            local bind_name_size = {render.get_text_size(fonts.verdana.default, bind_name)}
            local bind_state_size = {render.get_text_size(fonts.verdana.default, bind_mode)}

            keybinds.active[bind_name].mode = bind_mode

            keybinds.active[bind_name].alpha = animation4.lerp(keybinds.active[bind_name].alpha, 1, 12)
            keybinds.active[bind_name].offset = bind_name_size[1] + bind_state_size[1]

            keybinds.active[bind_name].active = true
        elseif (keybinds.active[bind_name] ~= nil) then
            keybinds.active[bind_name].alpha = animation4.lerp(keybinds.active[bind_name].alpha, 0, 12)
            keybinds.active[bind_name].active = false

            if (keybinds.active[bind_name].alpha < 0.1) then
                keybinds.active[bind_name] = nil
            end
        end

        if (keybinds.active[bind_name] ~= nil and keybinds.active[bind_name].offset > maximum_offset) then
            maximum_offset = keybinds.active[bind_name].offset
        end
    end

    local alpha = animation4.new("keybinds alpha", (gui.is_menu_open() or table.count(keybinds.active) > 0 and latest_item) and 1 or 0, 12)

    local text = "KeyBinds"
    local text_size = {render.get_text_size(fonts.verdana.bold, text)}

    local x, y = keybinds_dragging:get()

    local width, height = animation4.new("keybinds width", 48 + maximum_offset, 8), 22
    local height_offset = height + 3

    draw.window(math.vec3(x, y), math.vec3(width, height), render.color(80, 80, 80, 255 * alpha))
    render.text(fonts.verdana.bold, x + (width / 2) - (text_size[1] / 2), y + (height / 2) - (text_size[2] / 2) + 1, text, render.color(k_r, k_g, k_b, 255 * alpha))

    for bind_name, value in pairs(keybinds.active) do
        local key_type = "[" .. (value.mode or "?") .. "]"
        local key_type_size = {render.get_text_size(fonts.verdana.default, key_type)}

        render.text(fonts.verdana.default, x + 5, y + height_offset, bind_name, render.color(255, 255, 255, 255 * alpha * value.alpha))
        render.text(fonts.verdana.default, x + width - key_type_size[1] - 5, y + height_offset, key_type, render.color(255, 255, 255, 255 * alpha * value.alpha))

        height_offset = height_offset + 15 * value.alpha
    end

    keybinds_dragging:handle(width, (table.count(keybinds.active) > 0 and height_offset or height))
end


dsc = btn("Join discord","lua>tab b",function() print("exparionscrackbyfreez3e_crackbyfreez3e_ discord server - https://discord.gg/c27uVNA7") end)

function get_muzzle_pos()
    local lp = entities.get_entity(engine.get_local_player())
    if not lp or not lp:is_alive() then return end
    local lp_address = get_client_entity(engine.get_local_player())
    local weapon = lp:get_weapon()
    if not weapon then return end
    local weapon_address = get_client_entity(weapon:get_index())
    local vec3 = ffi.new("Vector")
    local vec3_pos = math.vec3(vec3.x, vec3.y, vec3.z)
    return vec3_pos
end


function menu_elements()
    for i=1, 6 do
        local tab = menu:get_int()
        local state = ConditionalStates[0].player_state:get_int() + 1
        local yawAddCheck = ConditionalStates[i].yawadd:get_bool()
        local spinCheck = ConditionalStates[i].spin:get_bool()
        local jitterCheck = ConditionalStates[i].jitter:get_bool()
        local leanamountCheck = ConditionalStates[i].leanamount:get_int()


        aspectratiocbx = aspectratiocb:get_bool()
        fog = fog_master_boolean:get_bool()
        xypos = enabled:get_bool()
        bloom = bloom_enable:get_bool()
        sunset_mode = override_boolean:get_bool()

    gui.set_visible("lua>tab a>Tab", tab == 0)
    gui.set_visible("lua>tab b>Join discord", tab == 0)

    --rage
    gui.set_visible("lua>tab b>Disable fakelag on HS", tab == 1)
    gui.set_visible("lua>tab b>Break lagcomp in air", tab == 1)
    gui.set_visible("lua>tab b>Static on manual", tab == 1)
    gui.set_visible("lua>tab b>Dormant Aimbot", tab == 1)


    --antiaim
    gui.set_visible("lua>tab b>[Conditions]", tab == 2 )

    gui.set_visible("lua>tab b>Yaw add " .. var.player_states[i], tab == 2 and state == i )
    gui.set_visible("lua>tab b>Add " .. var.player_states[i], tab == 2 and state == i and yawAddCheck )
    gui.set_visible("lua>tab b>Spin " .. var.player_states[i], tab == 2 and state == i )
    gui.set_visible("lua>tab b>Spin range " .. var.player_states[i], tab == 2 and state == i and spinCheck )
    gui.set_visible("lua>tab b>Spin speed " .. var.player_states[i], tab == 2 and state == i and spinCheck )
    gui.set_visible("lua>tab b>Jitter " .. var.player_states[i], tab == 2 and state == i )
    gui.set_visible("lua>tab b>Jitter Type " .. var.player_states[i], tab == 2 and state == i and jitterCheck)
    gui.set_visible("lua>tab b>Jitter range " .. var.player_states[i], tab == 2 and state == i and jitterCheck )

    --desync
    gui.set_visible("lua>tab b>Desync Type " .. var.player_states[i], tab == 2 and state == i )
    gui.set_visible("lua>tab b>Desync " .. var.player_states[i], tab == 2 and state == i )
    gui.set_visible("lua>tab b>Comp " .. var.player_states[i], tab == 2 and state == i )
    gui.set_visible("lua>tab b>Flip fake " .. var.player_states[i], tab == 2 and state == i )
    gui.set_visible("lua>tab b>Roll lean " .. var.player_states[i], tab == 2 and state == i )
    gui.set_visible("lua>tab b>Lean Amount " .. var.player_states[i], tab == 2 and state == i)

    gui.set_visible("lua>tab a>Defensive on peek", tab == 2)
	gui.set_visible("lua>tab a>Pitch on peek", tab == 2)
	gui.set_visible("lua>tab a>Pitch 2 on peek", tab == 2)
	gui.set_visible("lua>tab a>Defensive on air", tab == 2)
	gui.set_visible("lua>tab a>Pitch on air", tab == 2)
	gui.set_visible("lua>tab a>Pitch 2 on air", tab == 2)

    --configs
    gui.set_visible("lua>tab b>Import settings", tab == 2)
    gui.set_visible("lua>tab b>Export settings", tab == 2)
    gui.set_visible("lua>tab b>Load default settings", tab == 2)

    --visuals
    gui.set_visible("lua>tab b>Indicators", tab == 3)
    gui.set_visible("lua>tab b>Infobar", tab == 3)
    gui.set_visible("lua>tab b>Bloom", tab == 3)
    gui.set_visible("lua>tab b>Bloom Scale", tab == 3 and bloom)
	gui.set_visible("lua>tab b>Sunset Mode", tab == 3)
	gui.set_visible("lua>tab b>Sunset X", tab == 3 and sunset_mode)
	gui.set_visible("lua>tab b>Sunset Y", tab == 3 and sunset_mode)
    gui.set_visible("lua>tab b>Aspect ratio", tab == 3)
    gui.set_visible("lua>tab b>Value", tab == 3 and aspectratiocbx)
    gui.set_visible("lua>tab b>Enable fog", tab == 3)
    gui.set_visible("lua>tab b>Fog start", tab == 3 and fog)
    gui.set_visible("lua>tab b>Fog distance", tab == 3 and fog)
    gui.set_visible("lua>tab b>Fog density", tab == 3 and fog)
    gui.set_visible("lua>tab b>Miss markers", tab == 3)
	gui.set_visible("lua>tab b>Glow bullet impacts", tab == 3)
	gui.set_visible("lua>tab b>Keybinds", tab == 3)
	gui.set_visible("lua>tab b>Keybinds Color", tab == 3)
    gui.set_visible("lua>tab b>Watermark", tab == 3)
	gui.set_visible("lua>tab b>Watermark Color", tab == 3)

    --misc
    gui.set_visible("lua>tab b>ClanTag", tab == 4)
    gui.set_visible("lua>tab b>ClanTag Type", tab == 4 and clantag:get_bool())
    gui.set_visible("lua>tab b>TrashTalk", tab == 4)

    gui.set_visible("lua>tab b>Slowed Down Indicator", tab == 4)
    gui.set_visible("lua>tab b>x", tab == 4 and xypos)
    gui.set_visible("lua>tab b>y", tab == 4 and xypos)

    gui.set_visible("lua>tab b>Hitlog", tab == 4)
	gui.set_visible("lua>tab b>HitLog on screen", tab == 4)
end
end


function UpdateStateandAA()

    local isSW = info.fatality.in_slowwalk
    local local_player = entities.get_entity(engine.get_local_player())
    local inAir = local_player:get_prop("m_hGroundEntity") == -1
    local vel_x = math.floor(local_player:get_prop("m_vecVelocity[0]"))
    local vel_y = math.floor(local_player:get_prop("m_vecVelocity[1]"))
    local still = math.sqrt(vel_x ^ 2 + vel_y ^ 2) < 5
    local cupic = bit.band(local_player:get_prop("m_fFlags"),bit.lshift(2, 0)) ~= 0
    local flag = local_player:get_prop("m_fFlags")

    playerstate = 0

    if inAir and cupic then
        playerstate = 5
    else
        if inAir then
            playerstate = 4
        else
            if isSW then
                playerstate = 3
            else
                if cupic then
                    playerstate = 6
                else
                    if still and not cupic then
                        playerstate = 1
                    elseif not still then
                        playerstate = 2
                    end
                end
            end
        end
    end

    refs.yawadd:set_bool(ConditionalStates[playerstate].yawadd:get_bool());
    if ConditionalStates[playerstate].jittertype:get_int() == 1 then
        refs.yawaddamount:set_int((ConditionalStates[playerstate].yawaddamount:get_int()) + (global_vars.tickcount % 4 >= 2 and 0 or ConditionalStates[playerstate].jitterrange:get_int()))
    else
        refs.yawaddamount:set_int(ConditionalStates[playerstate].yawaddamount:get_int());
    end
    refs.spin:set_bool(ConditionalStates[playerstate].spin:get_bool());
    refs.jitter:set_bool(ConditionalStates[playerstate].jitter:get_bool());
    refs.spinrange:set_int(ConditionalStates[playerstate].spinrange:get_int());
    refs.spinspeed:set_int(ConditionalStates[playerstate].spinspeed:get_int());
    refs.jitterrandom:set_bool(ConditionalStates[playerstate].jittertype:get_int() == 2);
    --jitter types
    if ConditionalStates[playerstate].jittertype:get_int() == 0 or ConditionalStates[playerstate].jittertype:get_int() == 2 then
            refs.jitterrange:set_int(ConditionalStates[playerstate].jitterrange:get_int());
        else
            refs.jitterrange:set_int(0);
        end
    --desync
    if ConditionalStates[playerstate].desync:get_int() == 60 and ConditionalStates[playerstate].desynctype:get_int() == 0 then
        refs.desync:set_int((ConditionalStates[playerstate].desync:get_int() * 1.666666667) - 2);
        else if ConditionalStates[playerstate].desync:get_int() == -60 and ConditionalStates[playerstate].desynctype:get_int() == 0 then
            refs.desync:set_int((ConditionalStates[playerstate].desync:get_int() * 1.666666667) + 2);
              else if ConditionalStates[playerstate].desynctype:get_int() == 0 then 
                refs.desync:set_int(ConditionalStates[playerstate].desync:get_int() * 1.666666667);
                    else if ConditionalStates[playerstate].desynctype:get_int() == 1 and 0 >= ConditionalStates[playerstate].desync:get_int() then 
                        refs.desync:set_int(global_vars.tickcount % 4 >= 2 and -18 * 1.666666667 or ConditionalStates[playerstate].desync:get_int() * 1.666666667 + 2);
                            else if ConditionalStates[playerstate].desynctype:get_int() == 1 and ConditionalStates[playerstate].desync:get_int() >= 0 then 
                                refs.desync:set_int(global_vars.tickcount % 4 >= 2 and 18 * 1.666666667 or ConditionalStates[playerstate].desync:get_int() * 1.666666667 - 2);
                                    else if ConditionalStates[playerstate].desynctype:get_int() == 2 and ConditionalStates[playerstate].desync:get_int() >= 0 then 
                                        refs.desync:set_int(utils.random_int(0, ConditionalStates[playerstate].desync:get_int() * 1.666666667));
                                            else if ConditionalStates[playerstate].desynctype:get_int() == 2 and ConditionalStates[playerstate].desync:get_int() <= 0 then 
                                                refs.desync:set_int(utils.random_int(ConditionalStates[playerstate].desync:get_int() * 1.666666667, 0));
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
    refs.compAngle:set_int(ConditionalStates[playerstate].compAngle:get_int());
    refs.flipJittFake:set_bool(ConditionalStates[playerstate].flipJittFake:get_bool());
    refs.leanMenu:set_int(ConditionalStates[playerstate].leanMenu:get_int());
    refs.leanamount:set_int(ConditionalStates[playerstate].leanamount:get_int());
end


--Aspect

local r_aspectratio = cvar.r_aspectratio

local default_value = r_aspectratio:get_float()

local function set_aspect_ratio(multiplier)
    local screen_width,screen_height = render.get_screen_size()

    local value = (screen_width * multiplier) / screen_height

    if multiplier == 1 then
        value = 0
    end
    r_aspectratio:set_float(value)
end

function aspect_ratio2()
    local aspect_ratio = aspectratiosl:get_int() * 0.01
    aspect_ratio = 2 - aspect_ratio
    set_aspect_ratio(aspect_ratio)
end


--Miss Marker

local SVGData = [[
    <svg width="24" height="24" viewBox="0 0 24 24">
    <path stroke-width="1" stroke="#000" fill="#fff" d="M20 6.91 17.09 4 12 9.09 6.91 4 4 6.91 9.09 12 4 17.09 6.91 20 12 14.91 17.09 20 20 17.09 14.91 12 20 6.91Z"/>
    </svg>
]]

local Texture = render.create_texture_svg(SVGData, 17)
local Width, Height = render.get_texture_size(Texture)

local function OnTickMiss(Shot)
    return string.format("%it", Shot.backtrack)
end

local ValueFuncs = 
{
    spread = function (Shot)
        return string.format("%i%%", Shot.hitchance)
    end,

    resolve = function (Shot)
        return string.format("SP: %s", Shot.secure)
    end,
    extrapolation       = OnTickMiss,
    ["anti-exploit"]    = OnTickMiss,
}

local ShotReasonFmt = 
{
    resolve = "resolver",
}

local Shots = {}
function shot_maker(Shot)
    if Shot.manual or Shot.result == "hit" then
        return 
    end

    table.insert(Shots, 
    {
        Position    = Shot.client_impacts[#Shot.client_impacts],
        FadeTime    = 1,
        WaitTime    = 1,
        Reason      = ShotReasonFmt[Shot.result] or Shot.result,
        Value       = ValueFuncs[Shot.result] and ValueFuncs[Shot.result](Shot) or nil
    })
end


function miss_maker()
    if not missmarker:get_bool() or not engine.is_in_game() then
        Shots = {}
        return
    end

    local Color = misscolor:get_color()

    for i, Shot in pairs(Shots) do
        local x, y = utils.world_to_screen(Shot.Position:unpack())
        if x then
            render.push_texture(Texture)
            render.rect_filled(x - Width / 2, y - Height / 2, x + Width / 2, y + Height / 2, render.color(Color.r, Color.g, Color.b, Color.a * Shot.FadeTime))
            render.pop_texture()

            local MoveOffset = (10 * (1 - Shot.FadeTime))
            render.text(render.font_esp, x + Width / 2, y - 7 - MoveOffset, Shot.Reason, render.color(255, 255, 255, Color.a * Shot.FadeTime))
            if Shot.Value then
                render.text(render.font_esp, x + Width / 2, y + 1 - MoveOffset, Shot.Value, render.color(255, 255, 255, Color.a * Shot.FadeTime))
            end
        end

        Shot.WaitTime = Shot.WaitTime - (1 / 3) * global_vars.frametime
        if Shot.WaitTime <= 0 then  
            Shot.FadeTime = Shot.FadeTime - (1 / 0.25) * global_vars.frametime
        end

        if Shot.FadeTime <= 0 then
            table.remove(Shots, i)
        end
    end
end

function on_level_init()
    Shots = {}
end

--Fog changer


function fog_changer()
    if not engine.is_in_game( ) then return end
    
    local color = fog_color_picker:get_color( )

    cvar.fog_override:set_int( fog_master_boolean:get_bool( ) and 1 or 0 )
    cvar.fog_color:set_string( fog_master_boolean:get_bool( ) and string.format( "%s %s %s", color.r, color.g, color.b ) or "0, 0, 0" )
    cvar.fog_start:set_int( fog_master_boolean:get_bool( ) and fog_start_slider:get_int( ) or 0 )
    cvar.fog_end:set_int( fog_master_boolean:get_bool( ) and fog_distance_slider:get_int( ) or 0 )
    cvar.fog_maxdensity:set_float( fog_master_boolean:get_bool( ) and fog_density_slider:get_int( ) / 100 or 0 )
end

--bloom

local remove_post_processing = gui.get_config_item("visuals>misc>various>Disable post-processing")

function on_frame_stage_notify( stage, pre_original )
    if( stage == csgo.frame_render_start and pre_original ) then
      local bloom_scale = bloom_scale:get_int( )

      entities.for_each( function( entity )
        if( entity:get_class( ) == "CEnvTonemapController" ) then
          entity:set_prop( "m_bUseCustomBloomScale", 0, bloom_enable:get_bool( ) )
          entity:set_prop( "m_flCustomBloomScale", 0, bloom_scale )
        end
      end )

      if(bloom_enable:get_bool() and remove_post_processing:get_bool()) then
        utils.error_print("Bloom can't be used if \"Post-processing\" is disabled!")
        bloom_enable:set_bool( false )
      end
    end
  end



--Sunset mode

local cl_csm_rot_override = cvar.cl_csm_rot_override
local cl_csm_rot_x = cvar.cl_csm_rot_x
local cl_csm_rot_y = cvar.cl_csm_rot_y

function sunset()
    if override_boolean:get_bool() then
        cl_csm_rot_override:set_int(1)
        cl_csm_rot_x:set_int(x_val_slider:get_int())
        cl_csm_rot_y:set_int(y_val_slider:get_int())
    else
        cl_csm_rot_override:set_int(0)
        cl_csm_rot_x:set_int(0)
        cl_csm_rot_y:set_int(0)
    end
end

local shots = {}
local hitgroup = {
    [0] = "generic",
    [1] = "head",
    [2] = "chest",
    [3] = "stomach",
    [4] = "left arm",
    [5] = "right arm",
    [6] = "left leg",
    [7] = "right leg",
    [10] = "gear"
}


local hitgroup_str = {
    [0] = 'generic',
    'head', 'chest', 'stomach',
    'left arm', 'right arm',
    'left leg', 'right leg',
    'neck', 'generic', 'gear'
}
local logs_data = {}
local functions = {}
local ss = {}
ss.x,ss.y = render.get_screen_size()
local font = render.create_font("verdana.ttf", 11, render.font_flag_shadow)


functions.multi_color = function(data,x,y,font,alphamod)
    local textp = 0
    local totaltext = ""
    for k,v in pairs(data) do
        totaltext = totaltext .. v.text
    end
    local ttx = {}
        ttx.x,ttx.y = render.get_text_size(font,totaltext)
    for k,v in pairs(data) do
        if alphamod then
            v.clr.a = alphamod
        end
        render.text(font, x+textp-ttx.x/2,y,v.text,v.clr)
        textp = textp + render.get_text_size(font,v.text)
    end
end
functions.on_hit = function (e)
    local attacker = e:get_int("attacker")
    local attacked = e:get_int("userid")
    local attacked_index = engine.get_player_for_user_id(attacked)
    local attacked_name = engine.get_player_info(attacked_index)['name']
    if engine.get_player_for_user_id(attacker)== engine.get_local_player() and attacked ~= attacker then
		local main =  render.color(r, g, b)
        local accent = render.color("#FFFFFF")
        local rescol = render.color("#FFFFFF")

        table.insert(logs_data,
        {
            data = {
			    {
                    text = "exparionscrackbyfreez3e_ crackbyfreez3e_",
                    clr = main
                },
                {
                    text = "- Hit",
                    clr = accent
                },
                {
                    text = (" %s"):format(attacked_name),
                    clr = rescol
                },
                {
                    text = ("'s"),
                    clr = accent
                },
                {
                    text = (" %s"):format(hitgroup_str[e:get_int("hitgroup")]),
                    clr = rescol
                },
                {
                    text = (" for"),
                    clr = accent
                },
                {
                    text = (" %s"):format(e:get_int("dmg_health")),
                    clr = rescol
                },
                {
                    text = (" damage ("),
                    clr = accent
                },
                {
                    text = ("%s"):format(e:get_int("health")),
                    clr = rescol
                },
                {
                    text = ([[ health remaining)]]),
                    clr = accent
                },
            },
            info = {
                tick = global_vars.tickcount,
                alpha = render.create_animator_float(4, .5)
                }
            }
        )
    end
end

functions.on_draw = function()
    for k, v in pairs(logs_data) do
        v.info.alpha:direct(255)
        if 4.9-(global_vars.tickcount/64-v.info.tick/64) < 0 then
            v.info.alpha:direct(0)
        end
        functions.multi_color(v.data,ss.x/2,ss.y/2 + 200 + (20 * (k-1))+(v.info.alpha:get_value()/255*20),font,v.info.alpha:get_value())
        if v.info.alpha:get_value() <= 2.3 and (4.9-(global_vars.tickcount/64-v.info.tick/64) < 0) then
            table.remove(logs_data,k)
        end
    end
end


local counter = 0

local function main(shot)
    if shot.manual then return end
        local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}
        local p = entities.get_entity(shot.target)
        local n = p:get_player_info()
        local hitgroup = shot.server_hitgroup
        local clienthitgroup = shot.client_hitgroup
        local health = p:get_prop("m_iHealth")
            if ragebotlogs:get_bool() then
                if shot.server_damage > 0 and ragebotlogs:get_bool() then
                -- hit !n.name for !server_damage hp in !hitbox
                counter = counter + 1
                if shot.server_damage == shot.client_damage then
                    utils.print_dev_console("[" .. counter .. "] hit " .. n.name .. " for " .. shot.server_damage .. " hp in " .. hitgroup_names[hitgroup + 1] .. " [hc=" .. math.floor(shot.hitchance) .. ", bt=" .. math.floor(shot.backtrack) .. "] \n")
                    utils.print_console("[exparionscrackbyfreez3e_ crackbyfreez3e_] ", color:get_color()); utils.print_console("[" .. counter .. "] hit " .. n.name .. " for " .. shot.server_damage .. " hp in " .. hitgroup_names[hitgroup + 1] .. " [hc=" .. math.floor(shot.hitchance) .. ", bt=" .. math.floor(shot.backtrack) .. "] \n", render.color("#ffffff"));
                else
                    utils.print_dev_console("[" .. counter .. "] hit " .. n.name .. " for " .. shot.server_damage .. "(" .. shot.client_damage .. ") hp in " .. hitgroup_names[hitgroup + 1] .. "(" .. hitgroup_names[shot.client_hitgroup + 1] .. ") [hc=" .. math.floor(shot.hitchance) .. ", bt=" .. math.floor(shot.backtrack) .. "] \n")
                    utils.print_console("[exparionscrackbyfreez3e_ crackbyfreez3e_] ", color:get_color()); utils.print_console("[" .. counter .. "] hit " .. n.name .. " for " .. shot.server_damage .. "(" .. shot.client_damage .. ") hp in " .. hitgroup_names[hitgroup + 1] .. "(" .. hitgroup_names[shot.client_hitgroup + 1] .. ") [hc=" .. math.floor(shot.hitchance) .. ", bt=" .. math.floor(shot.backtrack) .. "] \n", render.color("#ffffff"));
                end
            end
                if (shot.result == "spread" or shot.result == "resolver" or shot.result == "server correction" or shot.result == "extrapolation" or shot.result == "anti-exploit") then
                    counter = counter + 1
                    utils.print_dev_console("[" .. counter .. "] miss " .. n.name .. " due to " .. shot.result .. " in " .. hitgroup_names[shot.client_hitgroup + 1] .. "\n")
                    utils.print_console("[exparionscrackbyfreez3e_ crackbyfreez3e_] ", color:get_color()); utils.print_console("[" .. counter .. "] miss " .. n.name .. " due to " .. shot.result .. " in " .. hitgroup_names[shot.client_hitgroup + 1] .. "\n", render.color("#ffffff"));
                end
            end

    end
local function round_start(event)
    if event == round_start then
    print("---------------------New Round Started---------------------")
end    end


current_stage3 = 0
current_stage5 = 0


spin = find("Rage>Anti-Aim>Angles>Spin");
spinrange = find("Rage>Anti-Aim>Angles>Spin range");
spinspeed = find("Rage>Anti-Aim>Angles>Spin speed");
scouthc = find("rage>aimbot>ssg08>scout>override")

pa = find("misc>movement>peek assist")
fs = find("rage>anti-aim>angles>freestand")
dtap = find("rage>aimbot>aimbot>double tap")
hccache = scouthc:get_int()
dtapcache = dtap:get_bool()
fscache = fs:get_bool()

hs = find("Rage>Aimbot>Aimbot>Hide shot")
dt = find("Rage>Aimbot>Aimbot>Double tap")
limit = find("Rage>Anti-Aim>Fakelag>Limit")


function staticonmanual()
    left = find("rage>anti-aim>angles>left"):get_bool()
    right = find("rage>anti-aim>angles>right"):get_bool()
    back = find("rage>anti-aim>angles>back"):get_bool()
    freestand = find("rage>anti-aim>angles>freestand"):get_bool()
    if som:get_bool() then
        if left or right or back or freestand then
            refs.yawadd:set_bool(false)
            refs.spin:set_bool(false)
            refs.jitter:set_bool(true)
            refs.jitterrandom:set_bool(false)
            refs.jitterrange:set_int(0)
            refs.enabledesync:set_bool(true)
            refs.desync:set_int(0)
            refs.compAngle:set_int(0)
            refs.flipJittFake:set_bool(false)
        end
    end
end

local function DA()

    refs.TargetDormant:set_bool(DAMain:get_bool())
        local local_player = entities.get_entity(engine.get_local_player())
        if not engine.is_in_game() or not local_player:is_valid() or not DAMain:get_bool() then
            return
        end
    end


function get_local_speed()
    local_player = entities.get_entity(engine.get_local_player())
    if local_player == nil then
        return
    end

    velocity_x = local_player:get_prop("m_vecVelocity[0]")
    velocity_y = local_player:get_prop("m_vecVelocity[1]")
    velocity_z = local_player:get_prop("m_vecVelocity[2]")

    velocity = math.vec3(velocity_x, velocity_y, velocity_z)
    speed = math.ceil(velocity:length2d())
    if speed < 10 then
        return 0
    else
        return speed
    end
end

playerstate = 0


desync_get = 0

function desyncupd()
    lp = entities.get_entity(engine.get_local_player())
    if not lp then return end
    desync_get = lp:get_prop("m_flPoseParameter", 11) * 120 - 60
end


function stateupd()
    if global_vars.tickcount % 4 < 2 and info.fatality.lag_ticks == 0 then
        current_stage5 = current_stage5 + 1
    end
    if global_vars.tickcount % 4 < 2 and info.fatality.lag_ticks == 0 then
        current_stage3 = current_stage3 + 1
    end
end



hs = find("Rage>Aimbot>Aimbot>Hide shot")
dt = find("Rage>Aimbot>Aimbot>Double tap")
limit = find("Rage>Anti-Aim>Fakelag>Limit")

local function to_boolean(str)
    if str == "true" or str == "false" then
        return (str == "true")
    else
        return str
    end
end

function lerp(a, b, t)
    return a + (b - a) * t;
end

pixel = render.font_esp
calibrib = render.create_font("calibrib.ttf", 12, render.font_flag_shadow)
ib = render.create_font("calibrib.ttf", 13, render.font_flag_shadow)
verdana = render.create_font("verdana.ttf", 11, render.font_flag_shadow)
verdanab = render.create_font("verdanab.ttf", 12, render.font_flag_shadow)


screen_size_x, screen_size_y = render.get_screen_size()
x = screen_size_x / 2
y = screen_size_y / 2
offset_scope = 0
scope_factor = 0;

function drag(var_x, var_y, size_x, size_y)
    local mouse_x, mouse_y = input.get_cursor_pos()

    local drag = false

    if input.is_key_down(0x01) then
        if mouse_x > var_x:get_int() and mouse_y > var_y:get_int() and mouse_x < var_x:get_int() + size_x and mouse_y < var_y:get_int() + size_y then
            drag = true
        end
    else
        drag = false
    end

    if (drag) then
        var_x:set_int(mouse_x - (size_x / 2))
        var_y:set_int(mouse_y - (size_y / 2))
    end

end


function infobar()
    screen_size_x, screen_size_y = render.get_screen_size()
    x = screen_size_x / 2
    y = screen_size_y / 2
    r, g, b = color:get_color().r, color:get_color().g, color:get_color().b
    local player = entities.get_entity(engine.get_local_player())
    alpha2 = math.floor(math.abs(math.sin(global_vars.realtime) * 1) * 255)
    if not lp then return end
  	if not lp:is_alive() then return end

	if sidewm:get_bool() then
    	render.text(ib, 30, y + 15, "Expar ", render.color(255, 255, 255, 255), render.align_left)
        render.text(ib, 60, y + 15, "ions", render.color(r, g, b), render.align_left)
    	render.text(ib, 100, y + 15, "[ALPHA]", render.color(r, g, b, alpha2), render.align_left) 
    end
end

local function animation(check, name, value, speed) 
    if check then 
        return name + (value - name) * global_vars.frametime * speed / 2.5
    else 
        return name - (value + name) * global_vars.frametime * speed / 2.5
        
    end
end

local offset_scope = 0
local alpha = 0


function indicator()

    dtkey = find("rage>aimbot>aimbot>double tap"):get_bool()
    dmgkey = find("rage>aimbot>ssg08>scout>override"):get_bool()
    oskey = find("rage>aimbot>aimbot>hide shot"):get_bool()
    dakey = find("lua>tab b>Dormant Aimbot"):get_bool()

    leftkey = find("rage>anti-aim>angles>left"):get_bool()
    backkey = find("rage>anti-aim>angles>back"):get_bool()
    rightkey = find("rage>anti-aim>angles>right"):get_bool()
    freestandkey = find("rage>anti-aim>angles>freestand"):get_bool()

    local lp = entities.get_entity(engine.get_local_player())
    if not lp then return end
    if not lp:is_alive() then return end
    local scoped = lp:get_prop("m_bIsScoped")
    offset_scope = animation(scoped, offset_scope, 5, 25)
    r, g, b = color:get_color().r, color:get_color().g, color:get_color().b
    
    local function Clamp(Value, Min, Max)
        return Value < Min and Min or (Value > Max and Max or Value)
    end
        
        local alpha2 = math.floor(math.abs(math.sin(global_vars.realtime) * 2) * 255)
        local lp = entities.get_entity(engine.get_local_player())
        if not lp then return end
        if not lp:is_alive() then return end
        local screen_width, screen_height = render.get_screen_size()
        local x = screen_width / 2
        local y = screen_height / 2
        local ay = 0

    if ind:get_bool() then
        
    if not scoped then
        render.text(pixel, x+ offset_scope + 5, y + 24, "exparionscrackbyfreez3e_crackbyfreez3e_", render.color(r, g, b), render.align_center) 
    elseif scoped then
        render.text(pixel, x+ offset_scope, y + 24, "exparionscrackbyfreez3e_crackbyfreez3e_", render.color(r, g, b))
    end

        if playerstate == 1 and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 32, "stand", render.color(r, g, b), render.align_center)
        elseif playerstate == 2 and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 32, "move", render.color(r, g, b), render.align_center)
        elseif playerstate == 3 and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 32, "slowwalk", render.color(r, g, b), render.align_center)
        elseif playerstate == 4 and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 32, "air", render.color(r, g, b), render.align_center)
        elseif playerstate == 5 and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 32, "air+crouch", render.color(r, g, b), render.align_center)
        elseif playerstate == 6 and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 32, "crouch", render.color(r, g, b), render.align_center)
        elseif playerstate == 1 and scoped then
            render.text(pixel, x+ offset_scope, y + 32, "stand", render.color(r, g, b))
        elseif playerstate == 2 and scoped then
            render.text(pixel, x+ offset_scope, y + 32, "move", render.color(r, g, b))
        elseif playerstate == 3 and scoped then
            render.text(pixel, x+ offset_scope, y + 32, "slowwalk", render.color(r, g, b))
        elseif playerstate == 4 and scoped then
            render.text(pixel, x+ offset_scope, y + 32, "air", render.color(r, g, b))
        elseif playerstate == 5 and scoped then
            render.text(pixel, x+ offset_scope, y + 32, "air+crouch", render.color(r, g, b))
        elseif playerstate == 6 and scoped then
            render.text(pixel, x+ offset_scope, y + 32, "crouch", render.color(r, g, b))
        end




        if dtkey and info.fatality.can_fastfire and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 40 + ay, "dt", render.color(255, 255, 255, 255), render.align_center)
            ay = ay + 10
        elseif dtkey and not info.fatality.can_fastfire and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 40 + ay, "dt", render.color(255, 100, 100, 255), render.align_center)
            ay = ay + 10
        elseif dtkey and info.fatality.can_fastfire and scoped then
            render.text(pixel, x+ offset_scope, y + 40 + ay, "dt", render.color(r, g, b))
            ay = ay + 10
        elseif dtkey and not info.fatality.can_fastfire and scoped then
            render.text(pixel, x+ offset_scope, y + 40 + ay, "dt", render.color(255, 100, 100, 255))
            ay = ay + 10
        end

        if oskey and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 40 + ay, "Hide", render.color(254, 141, 141, 255), render.align_center)
            ay = ay + 10
        elseif oskey and scoped then
            render.text(pixel, x+ offset_scope, y + 40 + ay, "Hide", render.color(r, g, b))
            ay = ay + 10
        end
        if dmgkey and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 40 + ay, "dmg", render.color(135, 180, 255, 255), render.align_center)
            ay = ay + 10
        elseif dmgkey and scoped then
            render.text(pixel, x+ offset_scope, y + 40 + ay, "dmg", render.color(r, g, b))
            ay = ay + 10
        end
        if dakey and not scoped then
            render.text(pixel, x+ offset_scope + 5, y + 40 + ay, "da", render.color(135, 180, 255, 255), render.align_center)
            ay = ay + 10
        elseif dakey and scoped then
            render.text(pixel, x+ offset_scope, y + 40 + ay, "da", render.color(r, g, b))
            ay = ay + 10
        end


    end
end


--import and export system
configs.import = function(input)
    local protected = function()
        local clipboardP = input == nil and dec(clipboard.get()) or input
        local tbl = str_to_sub(clipboardP, "|")
        ConditionalStates[1].yawadd:set_bool(to_boolean(tbl[1]))
        ConditionalStates[1].yawaddamount:set_int(tonumber(tbl[2]))
        ConditionalStates[1].spin:set_bool(to_boolean(tbl[3]))
        ConditionalStates[1].spinrange:set_int(tonumber(tbl[4]))
        ConditionalStates[1].spinspeed:set_int(tonumber(tbl[5]))
        ConditionalStates[1].jitter:set_bool(to_boolean(tbl[6]))
        ConditionalStates[1].jittertype:set_int(tonumber(tbl[7]))
        ConditionalStates[1].jitterrange:set_int(tonumber(tbl[8]))
        ConditionalStates[1].desynctype:set_int(tonumber(tbl[9]))
        ConditionalStates[1].desync:set_int(tonumber(tbl[10]))
        ConditionalStates[1].compAngle:set_int(tonumber(tbl[11]))
        ConditionalStates[1].flipJittFake:set_bool(to_boolean(tbl[12]))
        ConditionalStates[1].leanMenu:set_int(tonumber(tbl[13]))
        ConditionalStates[1].leanamount:set_int(tonumber(tbl[14]))
        ConditionalStates[2].yawadd:set_bool(to_boolean(tbl[15]))
        ConditionalStates[2].yawaddamount:set_int(tonumber(tbl[16]))
        ConditionalStates[2].spin:set_bool(to_boolean(tbl[17]))
        ConditionalStates[2].spinrange:set_int(tonumber(tbl[18]))
        ConditionalStates[2].spinspeed:set_int(tonumber(tbl[19]))
        ConditionalStates[2].jitter:set_bool(to_boolean(tbl[20]))
        ConditionalStates[2].jittertype:set_int(tonumber(tbl[21]))
        ConditionalStates[2].jitterrange:set_int(tonumber(tbl[22]))
        ConditionalStates[2].desynctype:set_int(tonumber(tbl[23]))
        ConditionalStates[2].desync:set_int(tonumber(tbl[24]))
        ConditionalStates[2].compAngle:set_int(tonumber(tbl[25]))
        ConditionalStates[2].flipJittFake:set_bool(to_boolean(tbl[26]))
        ConditionalStates[2].leanMenu:set_int(tonumber(tbl[27]))
        ConditionalStates[2].leanamount:set_int(tonumber(tbl[28]))
        ConditionalStates[3].yawadd:set_bool(to_boolean(tbl[29]))
        ConditionalStates[3].yawaddamount:set_int(tonumber(tbl[30]))
        ConditionalStates[3].spin:set_bool(to_boolean(tbl[31]))
        ConditionalStates[3].spinrange:set_int(tonumber(tbl[32]))
        ConditionalStates[3].spinspeed:set_int(tonumber(tbl[33]))
        ConditionalStates[3].jitter:set_bool(to_boolean(tbl[34]))
        ConditionalStates[3].jittertype:set_int(tonumber(tbl[35]))
        ConditionalStates[3].jitterrange:set_int(tonumber(tbl[36]))
        ConditionalStates[3].desynctype:set_int(tonumber(tbl[37]))
        ConditionalStates[3].desync:set_int(tonumber(tbl[38]))
        ConditionalStates[3].compAngle:set_int(tonumber(tbl[39]))
        ConditionalStates[3].flipJittFake:set_bool(to_boolean(tbl[40]))
        ConditionalStates[3].leanMenu:set_int(tonumber(tbl[41]))
        ConditionalStates[3].leanamount:set_int(tonumber(tbl[42]))
        ConditionalStates[4].yawadd:set_bool(to_boolean(tbl[43]))
        ConditionalStates[4].yawaddamount:set_int(tonumber(tbl[44]))
        ConditionalStates[4].spin:set_bool(to_boolean(tbl[45]))
        ConditionalStates[4].spinrange:set_int(tonumber(tbl[46]))
        ConditionalStates[4].spinspeed:set_int(tonumber(tbl[47]))
        ConditionalStates[4].jitter:set_bool(to_boolean(tbl[48]))
        ConditionalStates[4].jittertype:set_int(tonumber(tbl[49]))
        ConditionalStates[4].jitterrange:set_int(tonumber(tbl[50]))
        ConditionalStates[4].desync:set_int(tonumber(tbl[51]))
        ConditionalStates[4].desynctype:set_int(tonumber(tbl[52]))
        ConditionalStates[4].compAngle:set_int(tonumber(tb4l[53]))
        ConditionalStates[4].flipJittFake:set_bool(to_boolean(tbl[54]))
        ConditionalStates[4].leanMenu:set_int(tonumber(tbl[55]))
        ConditionalStates[4].leanamount:set_int(tonumber(tbl[56]))
        ConditionalStates[5].yawadd:set_bool(to_boolean(tbl[57]))
        ConditionalStates[5].yawaddamount:set_int(tonumber(tbl[58]))
        ConditionalStates[5].spin:set_bool(to_boolean(tbl[59]))
        ConditionalStates[5].spinrange:set_int(tonumber(tbl[60]))
        ConditionalStates[5].spinspeed:set_int(tonumber(tbl[61]))
        ConditionalStates[5].jitter:set_bool(to_boolean(tbl[62]))
        ConditionalStates[5].jittertype:set_int(tonumber(tbl[63]))
        ConditionalStates[5].jitterrange:set_int(tonumber(tbl[64]))
        ConditionalStates[5].desynctype:set_int(tonumber(tbl[65]))
        ConditionalStates[5].desync:set_int(tonumber(tbl[66]))
        ConditionalStates[5].compAngle:set_int(tonumber(tbl[67]))
        ConditionalStates[5].flipJittFake:set_bool(to_boolean(tbl[68]))
        ConditionalStates[5].leanMenu:set_int(tonumber(tbl[69]))
        ConditionalStates[5].leanamount:set_int(tonumber(tbl[70]))
        ConditionalStates[6].yawadd:set_bool(to_boolean(tbl[71]))
        ConditionalStates[6].yawaddamount:set_int(tonumber(tbl[72]))
        ConditionalStates[6].spin:set_bool(to_boolean(tbl[73]))
        ConditionalStates[6].spinrange:set_int(tonumber(tbl[74]))
        ConditionalStates[6].spinspeed:set_int(tonumber(tbl[75]))
        ConditionalStates[6].jitter:set_bool(to_boolean(tbl[76]))
        ConditionalStates[6].jittertype:set_int(tonumber(tbl[77]))
        ConditionalStates[6].jitterrange:set_int(tonumber(tbl[78]))
        ConditionalStates[6].desynctype:set_int(tonumber(tbl[79]))
        ConditionalStates[6].desync:set_int(tonumber(tbl[80]))
        ConditionalStates[6].compAngle:set_int(tonumber(tbl[81]))
        ConditionalStates[6].flipJittFake:set_bool(to_boolean(tbl[82]))
        ConditionalStates[6].leanMenu:set_int(tonumber(tbl[83]))
        ConditionalStates[6].leanamount:set_int(tonumber(tbl[84]))


        print("Config loaded")
        
    end
    local status, message = pcall(protected)
    if not status then
        print("Failed to load config")
        return
    end
end


configs.export = function()
    local str = { 
        tostring(ConditionalStates[1].yawadd:get_bool()) .. "|",
        tostring(ConditionalStates[1].yawaddamount:get_int()) .. "|",
        tostring(ConditionalStates[1].spin:get_bool()) .. "|",
        tostring(ConditionalStates[1].spinrange:get_int()) .. "|",
        tostring(ConditionalStates[1].spinspeed:get_int()) .. "|",
        tostring(ConditionalStates[1].jitter:get_bool()) .. "|",
        tostring(ConditionalStates[1].jittertype:get_int()) .. "|",
        tostring(ConditionalStates[1].jitterrange:get_int()) .. "|",
        tostring(ConditionalStates[1].desynctype:get_int()) .. "|",
        tostring(ConditionalStates[1].desync:get_int()) .. "|",
        tostring(ConditionalStates[1].compAngle:get_int()) .. "|",
        tostring(ConditionalStates[1].flipJittFake:get_bool()) .. "|",
        tostring(ConditionalStates[1].leanMenu:get_int()) .. "|",
        tostring(ConditionalStates[1].leanamount:get_int()) .. "|",
        tostring(ConditionalStates[2].yawadd:get_bool()) .. "|",
        tostring(ConditionalStates[2].yawaddamount:get_int()) .. "|",
        tostring(ConditionalStates[2].spin:get_bool()) .. "|",
        tostring(ConditionalStates[2].spinrange:get_int()) .. "|",
        tostring(ConditionalStates[2].spinspeed:get_int()) .. "|",
        tostring(ConditionalStates[2].jitter:get_bool()) .. "|",
        tostring(ConditionalStates[2].jittertype:get_int()) .. "|",
        tostring(ConditionalStates[2].jitterrange:get_int()) .. "|",
        tostring(ConditionalStates[2].desynctype:get_int()) .. "|",
        tostring(ConditionalStates[2].desync:get_int()) .. "|",
        tostring(ConditionalStates[2].compAngle:get_int()) .. "|",
        tostring(ConditionalStates[2].flipJittFake:get_bool()) .. "|",
        tostring(ConditionalStates[2].leanMenu:get_int()) .. "|",
        tostring(ConditionalStates[2].leanamount:get_int()) .. "|",
        tostring(ConditionalStates[3].yawadd:get_bool()) .. "|",
        tostring(ConditionalStates[3].yawaddamount:get_int()) .. "|",
        tostring(ConditionalStates[3].spin:get_bool()) .. "|",
        tostring(ConditionalStates[3].spinrange:get_int()) .. "|",
        tostring(ConditionalStates[3].spinspeed:get_int()) .. "|",
        tostring(ConditionalStates[3].jitter:get_bool()) .. "|",
        tostring(ConditionalStates[3].jittertype:get_int()) .. "|",
        tostring(ConditionalStates[3].jitterrange:get_int()) .. "|",
        tostring(ConditionalStates[3].desynctype:get_int()) .. "|",
        tostring(ConditionalStates[3].desync:get_int()) .. "|",
        tostring(ConditionalStates[3].compAngle:get_int()) .. "|",
        tostring(ConditionalStates[3].flipJittFake:get_bool()) .. "|",
        tostring(ConditionalStates[3].leanMenu:get_int()) .. "|",
        tostring(ConditionalStates[3].leanamount:get_int()) .. "|",
        tostring(ConditionalStates[4].yawadd:get_bool()) .. "|",
        tostring(ConditionalStates[4].yawaddamount:get_int()) .. "|",
        tostring(ConditionalStates[4].spin:get_bool()) .. "|",
        tostring(ConditionalStates[4].spinrange:get_int()) .. "|",
        tostring(ConditionalStates[4].spinspeed:get_int()) .. "|",
        tostring(ConditionalStates[4].jitter:get_bool()) .. "|",
        tostring(ConditionalStates[4].jittertype:get_int()) .. "|",
        tostring(ConditionalStates[4].jitterrange:get_int()) .. "|",
        tostring(ConditionalStates[4].desynctype:get_int()) .. "|",
        tostring(ConditionalStates[4].desync:get_int()) .. "|",
        tostring(ConditionalStates[4].compAngle:get_int()) .. "|",
        tostring(ConditionalStates[4].flipJittFake:get_bool()) .. "|",
        tostring(ConditionalStates[4].leanMenu:get_int()) .. "|",
        tostring(ConditionalStates[4].leanamount:get_int()) .. "|",
        tostring(ConditionalStates[5].yawadd:get_bool()) .. "|",
        tostring(ConditionalStates[5].yawaddamount:get_int()) .. "|",
        tostring(ConditionalStates[5].spin:get_bool()) .. "|",
        tostring(ConditionalStates[5].spinrange:get_int()) .. "|",
        tostring(ConditionalStates[5].spinspeed:get_int()) .. "|",
        tostring(ConditionalStates[5].jitter:get_bool()) .. "|",
        tostring(ConditionalStates[5].jittertype:get_int()) .. "|",
        tostring(ConditionalStates[5].jitterrange:get_int()) .. "|",
        tostring(ConditionalStates[5].desynctype:get_int()) .. "|",
        tostring(ConditionalStates[5].desync:get_int()) .. "|",
        tostring(ConditionalStates[5].compAngle:get_int()) .. "|",
        tostring(ConditionalStates[5].flipJittFake:get_bool()) .. "|",
        tostring(ConditionalStates[5].leanMenu:get_int()) .. "|",
        tostring(ConditionalStates[5].leanamount:get_int()) .. "|",
        tostring(ConditionalStates[6].yawadd:get_bool()) .. "|",
        tostring(ConditionalStates[6].yawaddamount:get_int()) .. "|",
        tostring(ConditionalStates[6].spin:get_bool()) .. "|",
        tostring(ConditionalStates[6].spinrange:get_int()) .. "|",
        tostring(ConditionalStates[6].spinspeed:get_int()) .. "|",
        tostring(ConditionalStates[6].jitter:get_bool()) .. "|",
        tostring(ConditionalStates[6].jittertype:get_int()) .. "|",
        tostring(ConditionalStates[6].jitterrange:get_int()) .. "|",
        tostring(ConditionalStates[6].desynctype:get_int()) .. "|",
        tostring(ConditionalStates[6].desync:get_int()) .. "|",
        tostring(ConditionalStates[6].compAngle:get_int()) .. "|",
        tostring(ConditionalStates[6].flipJittFake:get_bool()) .. "|",
        tostring(ConditionalStates[6].leanMenu:get_int()) .. "|",
        tostring(ConditionalStates[6].leanamount:get_int()) .. "|",
    }
    
        clipboard.set(enc(table.concat(str)))
        print("config was copied")

end

configs.importDefault = function(input)
    input = "dHJ1ZXwtMzJ8ZmFsc2V8MHwwfHRydWV8MXw2MHwyfC02MHwxMDB8ZmFsc2V8MHwwfHRydWV8LTMwfGZhbHNlfDB8MHx0cnVlfDF8NjB8MXw2MHwxMDB8ZmFsc2V8MHwwfHRydWV8LTIwfGZhbHNlfDB8MHx0cnVlfDF8NDV8MHwtNjB8MTAwfGZhbHNlfDB8MHx0cnVlfDN8ZmFsc2V8MHwwfHRydWV8MHw1MnwxfC02MHwxMDB8dHJ1ZXwwfDB8dHJ1ZXw2fGZhbHNlfDB8MHx0cnVlfDB8NDJ8MXw2MHwxMDB8dHJ1ZXwwfDB8dHJ1ZXwzfGZhbHNlfDB8MHx0cnVlfDB8MjR8Mnw2MHwxMDB8dHJ1ZXwwfDB8"
    local clipboardp = dec(input)
    local tbl = str_to_sub(clipboardp, "|")
    ConditionalStates[1].yawadd:set_bool(to_boolean(tbl[1]))
    ConditionalStates[1].yawaddamount:set_int(tonumber(tbl[2]))
    ConditionalStates[1].spin:set_bool(to_boolean(tbl[3]))
    ConditionalStates[1].spinrange:set_int(tonumber(tbl[4]))
    ConditionalStates[1].spinspeed:set_int(tonumber(tbl[5]))
    ConditionalStates[1].jitter:set_bool(to_boolean(tbl[6]))
    ConditionalStates[1].jittertype:set_int(tonumber(tbl[7]))
    ConditionalStates[1].jitterrange:set_int(tonumber(tbl[8]))
    ConditionalStates[1].desynctype:set_int(tonumber(tbl[9]))
    ConditionalStates[1].desync:set_int(tonumber(tbl[10]))
    ConditionalStates[1].compAngle:set_int(tonumber(tbl[11]))
    ConditionalStates[1].flipJittFake:set_bool(to_boolean(tbl[12]))
    ConditionalStates[1].leanMenu:set_int(tonumber(tbl[13]))
    ConditionalStates[1].leanamount:set_int(tonumber(tbl[14]))
    ConditionalStates[2].yawadd:set_bool(to_boolean(tbl[15]))
    ConditionalStates[2].yawaddamount:set_int(tonumber(tbl[16]))
    ConditionalStates[2].spin:set_bool(to_boolean(tbl[17]))
    ConditionalStates[2].spinrange:set_int(tonumber(tbl[18]))
    ConditionalStates[2].spinspeed:set_int(tonumber(tbl[19]))
    ConditionalStates[2].jitter:set_bool(to_boolean(tbl[20]))
    ConditionalStates[2].jittertype:set_int(tonumber(tbl[21]))
    ConditionalStates[2].jitterrange:set_int(tonumber(tbl[22]))
    ConditionalStates[2].desynctype:set_int(tonumber(tbl[23]))
    ConditionalStates[2].desync:set_int(tonumber(tbl[24]))
    ConditionalStates[2].compAngle:set_int(tonumber(tbl[25]))
    ConditionalStates[2].flipJittFake:set_bool(to_boolean(tbl[26]))
    ConditionalStates[2].leanMenu:set_int(tonumber(tbl[27]))
    ConditionalStates[2].leanamount:set_int(tonumber(tbl[28]))
    ConditionalStates[3].yawadd:set_bool(to_boolean(tbl[29]))
    ConditionalStates[3].yawaddamount:set_int(tonumber(tbl[30]))
    ConditionalStates[3].spin:set_bool(to_boolean(tbl[31]))
    ConditionalStates[3].spinrange:set_int(tonumber(tbl[32]))
    ConditionalStates[3].spinspeed:set_int(tonumber(tbl[33]))
    ConditionalStates[3].jitter:set_bool(to_boolean(tbl[34]))
    ConditionalStates[3].jittertype:set_int(tonumber(tbl[35]))
    ConditionalStates[3].jitterrange:set_int(tonumber(tbl[36]))
    ConditionalStates[3].desynctype:set_int(tonumber(tbl[37]))
    ConditionalStates[3].desync:set_int(tonumber(tbl[38]))
    ConditionalStates[3].compAngle:set_int(tonumber(tbl[39]))
    ConditionalStates[3].flipJittFake:set_bool(to_boolean(tbl[40]))
    ConditionalStates[3].leanMenu:set_int(tonumber(tbl[41]))
    ConditionalStates[3].leanamount:set_int(tonumber(tbl[42]))
    ConditionalStates[4].yawadd:set_bool(to_boolean(tbl[43]))
    ConditionalStates[4].yawaddamount:set_int(tonumber(tbl[44]))
    ConditionalStates[4].spin:set_bool(to_boolean(tbl[45]))
    ConditionalStates[4].spinrange:set_int(tonumber(tbl[46]))
    ConditionalStates[4].spinspeed:set_int(tonumber(tbl[47]))
    ConditionalStates[4].jitter:set_bool(to_boolean(tbl[48]))
    ConditionalStates[4].jittertype:set_int(tonumber(tbl[49]))
    ConditionalStates[4].jitterrange:set_int(tonumber(tbl[50]))
    ConditionalStates[4].desync:set_int(tonumber(tbl[51]))
    ConditionalStates[4].desynctype:set_int(tonumber(tbl[52]))
    ConditionalStates[4].compAngle:set_int(tonumber(tbl[53]))
    ConditionalStates[4].flipJittFake:set_bool(to_boolean(tbl[54]))
    ConditionalStates[4].leanMenu:set_int(tonumber(tbl[55]))
    ConditionalStates[4].leanamount:set_int(tonumber(tbl[56]))
    ConditionalStates[5].yawadd:set_bool(to_boolean(tbl[57]))
    ConditionalStates[5].yawaddamount:set_int(tonumber(tbl[58]))
    ConditionalStates[5].spin:set_bool(to_boolean(tbl[59]))
    ConditionalStates[5].spinrange:set_int(tonumber(tbl[60]))
    ConditionalStates[5].spinspeed:set_int(tonumber(tbl[61]))
    ConditionalStates[5].jitter:set_bool(to_boolean(tbl[62]))
    ConditionalStates[5].jittertype:set_int(tonumber(tbl[63]))
    ConditionalStates[5].jitterrange:set_int(tonumber(tbl[64]))
    ConditionalStates[5].desynctype:set_int(tonumber(tbl[65]))
    ConditionalStates[5].desync:set_int(tonumber(tbl[66]))
    ConditionalStates[5].compAngle:set_int(tonumber(tbl[67]))
    ConditionalStates[5].flipJittFake:set_bool(to_boolean(tbl[68]))
    ConditionalStates[5].leanMenu:set_int(tonumber(tbl[69]))
    ConditionalStates[5].leanamount:set_int(tonumber(tbl[70]))
    ConditionalStates[6].yawadd:set_bool(to_boolean(tbl[71]))
    ConditionalStates[6].yawaddamount:set_int(tonumber(tbl[72]))
    ConditionalStates[6].spin:set_bool(to_boolean(tbl[73]))
    ConditionalStates[6].spinrange:set_int(tonumber(tbl[74]))
    ConditionalStates[6].spinspeed:set_int(tonumber(tbl[75]))
    ConditionalStates[6].jitter:set_bool(to_boolean(tbl[76]))
    ConditionalStates[6].jittertype:set_int(tonumber(tbl[77]))
    ConditionalStates[6].jitterrange:set_int(tonumber(tbl[78]))
    ConditionalStates[6].desynctype:set_int(tonumber(tbl[79]))
    ConditionalStates[6].desync:set_int(tonumber(tbl[80]))
    ConditionalStates[6].compAngle:set_int(tonumber(tbl[81]))
    ConditionalStates[6].flipJittFake:set_bool(to_boolean(tbl[82]))
    ConditionalStates[6].leanMenu:set_int(tonumber(tbl[83]))
    ConditionalStates[6].leanamount:set_int(tonumber(tbl[84]))

    print("Config loaded")
end

local hs = gui.get_config_item("Rage>Aimbot>Aimbot>Hide shot")
local limit = gui.get_config_item("Rage>Anti-Aim>Fakelag>Limit")

-- cache fakelag limit
local cache = {
    backup = limit:get_int(),
    override = false,
}

function hsf()
    local hs = gui.get_config_item("Rage>Aimbot>Aimbot>Hide shot")
    local limit = gui.get_config_item("Rage>Anti-Aim>Fakelag>Limit")


    if hs:get_bool() and hsfl:get_bool() then
        limit:set_int(1)
        cache.override = true
    else
        if cache.override then
            limit:set_int(cache.backup)
            cache.override = false
        else
            cache.backup = limit:get_int()
        end
    end
end

dt = find("rage>aimbot>aimbot>double tap"):get_bool()
function lagcomp()
  defensive = find("rage>aimbot>aimbot>extend peek")
  defensivecache = find("rage>aimbot>aimbot>extend peek"):get_bool()
  if brlc:get_bool() then
    if dt then
      if playerstate == 4 or playerstate == 5 then
        defensive:set_bool(global_vars.tickcount % 4 >= 2 and true or false)
      else
        defensivecache:set_bool(defensivecache)
      end
    end
  end
end


local death = {
  "Ты ведь понимаешь, что тебе просто повезло",
  "Фууу... за счёт везения только играет!",
  "Пидарас везучий",
  "Нищего ведь чит забустит",
  "0 iq даун убивает",
  "iqless, куда тебе 1 тебя ведь чит бустит",
  "Фууу... долбаёб с хуйнёй убивает",
  "Когда exparionscrackbyfreez3e_ появился, ты пишешь  | Miss shot due to Долбаёб",
  "Нищий ведь аншотнет",
  "Долбаёбу же повезёт",
  "Хуесос выйди ты уже с вв",
  "Боже чел вспотел против меня"

}

local first = {
  "freez3e_ = 𝔹𝔼𝕊𝕋 cracker and sliver",
  "𝕓𝕚𝕥𝕔𝕙 𝕓𝕦𝕪 ℂ𝕗𝕘 𝕒𝕟𝕕 𝕝𝕦𝕒 𝕓𝕪 freez3e_ ℍ𝕧ℍ",
  "ЗАОВНИЛИ МАЛЬЦА",
  "дᴇᴛᴄᴛʙᴏ ɜᴀᴋᴀнчиʙᴀᴇᴛᴄя ᴛᴏᴦдᴀ, ᴋᴏᴦдᴀ у ᴛᴇбя ᴨᴏяʙᴧяᴇᴛᴄя crackbyfreez3e_",
  "МАШКА С 3 ПОДЪЕЗДА НА МОЙ ПЕНИС СЕЛА",
  "Я рекомендую тебе прикупить crackbyfreez3e_",
  "отправляйся на небо Долбоёбик"

}

Expclan = {

    "$ crackbyfreez3e_&",
    "|$ crackbyfreez3e_&",
    "$| crackbyfreez3e_=",
    "$ |BEST LUA crackbyfreez3e_",
    "$ crackbyfreez3e_",
    "$ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_|",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_",
    "$ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",
    "|$ crackbyfreez3e_ crackbyfreez3e_",
    "$ crackbyfreez3e_ crackbyfreez3e_",

}

customclan = {

    "BestLua",
    
}

--TrashTalk

function on_player_death(event)
    local lp = engine.get_local_player();
    local attacker = engine.get_player_for_user_id(event:get_int('attacker'));
    local userid = engine.get_player_for_user_id(event:get_int('userid'));
    if trashtalk:get_bool() then
        if attacker == lp and userid ~= lp then
            engine.exec("say " .. first[utils.random_int(1, #first)] .. "")
        end
    end
    if on_death:get_bool() then
        if userid == lp then
            engine.exec("say " .. death[utils.random_int(1, #death)] .. "")
        end
    end
end

local old_time = 0

local clantag_cache = false

--Clantag
function clantagfc()
    local ctype = clantagtype:get_int()
    if clantag:get_bool() then
        local defaultct = gui.get_config_item("misc>various>clan tag")
        local realtime = math.floor((global_vars.realtime) * 1.5)
        if old_time ~= realtime then
            if ctype == 0 then
                utils.set_clan_tag(Expclan[realtime % #Expclan+1]);
            end
            if ctype == 1 then
                utils.set_clan_tag(customclan[realtime % #customclan+1]);
            end
        old_time = realtime;
        defaultct:set_bool(false);
        end
    end
end

function on_player_hurt(e)
    functions.on_hit(e)
end
function on_shot_registered(shot)
    main(shot)
    shot_maker(shot)

    if not glowbullet:get_bool() then
        return
    end

    for _, ServerImpact in pairs(shot.server_impacts) do
        AddGlowBox(ServerImpact, math.vec3(0), IMPACTBOX_MIN, IMPACTBOX_MAX, server_color:get_color(), 4)
    end
end

function on_paint()

    menu_elements()

    indicator()
    if sidewm:get_bool() then
    	infobar()
    end
    aspect_ratio2()
    fog_changer()
    miss_maker()
    functions.on_draw()
    keybinds.handle()
    watermark.handle()
    sunset()
    slowdownind()
    hsf()
    clantagfc()


end

local dt = gui.get_config_item ( "rage>aimbot>aimbot>Double Tap" )

local fl_frozen = bit.lshift ( 1, 6 )

local in_attack = bit.lshift ( 1, 0 )
local in_attack2 = bit.lshift ( 1, 11 )


local checker = 0
local defensive = false

function on_create_move( cmd )
    stateupd()
    desyncupd()
    UpdateStateandAA()
    staticonmanual()

    local me = entities.get_entity ( engine.get_local_player ( ) )
    if not me or not me:is_valid ( ) then
        return
    end

    local tickbase = me:get_prop ( "m_nTickBase" )

    defensive = math.abs ( tickbase - checker ) >= 3
    checker = math.max ( tickbase, checker or 0 )
end

function on_player_spawn ( event )
    if engine.get_player_for_user_id ( event:get_int ( 'userid' ) ) == engine.get_local_player ( ) then
        checker = 0
    end
end

function on_run_command ( cmd )
	local state = get_state(get_velocity())
    if not enabled:get_bool ( ) or not dt:get_bool ( ) then
        return
    end

    local buttons = cmd:get_buttons ( )
    if bit.band ( buttons, in_attack ) == in_attack or bit.band ( buttons, in_attack2 ) == in_attack2 then
        return
    end

    local me = entities.get_entity ( engine.get_local_player ( ) )
    if not me or not me:is_valid ( ) then
        return
    end

    local flags = me:get_prop ( 'm_fFlags' )
    if bit.band ( flags, fl_frozen ) == fl_frozen then
        return
    end

    if info.fatality.lag_ticks > 3 then
        return
    end

    if defensive then
        cmd:set_view_angles ( utils.random_int ( pitch:get_int(), pitch2:get_int() ), utils.random_int ( -359, 359 ), 0 )
    elseif info.fatality.can_fastfire == false then
        cmd:set_view_angles ( utils.random_int ( pitch:get_int(), pitch2:get_int() ), utils.random_int ( -359, 359 ), 0 )
    end
    
    if onairrrr:get_bool() then
    if state == 5 then
		cmd:set_view_angles ( utils.random_int ( pitchair:get_int(), pitch2air:get_int() ), utils.random_int ( -359, 359 ), 0 )
	elseif state == 6 then
		cmd:set_view_angles ( utils.random_int ( pitchair:get_int(), pitch2air:get_int() ), utils.random_int ( -359, 359 ), 0 )
end
end
end

function on_shutdown()
	r_aspectratio:set_float(default_value)
    PatchByte(RenderGlowBoxesFN + 0x239, 3)
    PatchByte(PassAddr, 0)
    limit:set_int(cache.backup)
    utils.set_clan_tag("");

    for i, v in pairs( BackupCallbackSize ) do
        SetCallbacks( i, v )
    end
end

function on_game_event(event)
    round_start(event)
end
