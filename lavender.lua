
ffi.cdef[[
    typedef struct
    {
        char   pad0[0x14];             //0x0000
        bool        bProcessingMessages;    //0x0014
        bool        bShouldDelete;          //0x0015
        char   pad1[0x2];              //0x0016
        int         iOutSequenceNr;         //0x0018 last send outgoing sequence number
        int         iInSequenceNr;          //0x001C last received incoming sequence number
        int         iOutSequenceNrAck;      //0x0020 last received acknowledge outgoing sequence number
        int         iOutReliableState;      //0x0024 state of outgoing reliable data (0/1) flip flop used for loss detection
        int         iInReliableState;       //0x0028 state of incoming reliable data
        int         iChokedPackets;         //0x002C number of choked packets
    } INetChannel; // Size: 0x0444

    typedef bool(__thiscall* file_exists_t)(void* this, const char* pFileName, const char* pPathID);
    typedef int BOOL;
    typedef long LONG;
    typedef unsigned long HWND;
    typedef struct{
        LONG x, y;
    }POINT, *LPPOINT;
    typedef unsigned long DWORD, *PDWORD, *LPDWORD;

    typedef struct {
        DWORD  nLength;
        void* lpSecurityDescriptor;
        BOOL   bInheritHandle;
    } SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;

    short GetAsyncKeyState(int vKey);
    typedef struct mask {
        char m_pDriverName[512];
        unsigned int m_VendorID;
        unsigned int m_DeviceID;
        unsigned int m_SubSysID;
        unsigned int m_Revision;
        int m_nDXSupportLevel;
        int m_nMinDXSupportLevel;
        int m_nMaxDXSupportLevel;
        unsigned int m_nDriverVersionHigh;
        unsigned int m_nDriverVersionLow;
        int64_t pad_0;
        union {
            int xuid;
            struct {
                int xuidlow;
                int xuidhigh;
            };
        };
        char name[128];
        int userid;
        char guid[33];
        unsigned int friendsid;
        char friendsname[128];
        bool fakeplayer;
        bool ishltv;
        unsigned int customfiles[4];
        unsigned char filesdownloaded;
    };
    typedef int(__thiscall* get_current_adapter_fn)(void*);
    typedef void(__thiscall* get_adapters_info_fn)(void*, int adapter, struct mask& info);
    typedef bool(__thiscall* file_exists_t)(void* this, const char* pFileName, const char* pPathID);
    typedef long(__thiscall* get_file_time_t)(void* this, const char* pFileName, const char* pPathID);
]]
m_hwid = {
    get = function()
         material_system = utils.find_interface('materialsystem.dll', 'VMaterialSystem080')
         material_interface = ffi.cast('void***', material_system)[0]

         get_current_adapter = ffi.cast('get_current_adapter_fn', material_interface[25])
         get_adapter_info = ffi.cast('get_adapters_info_fn', material_interface[26])

         current_adapter = get_current_adapter(material_interface)

         adapter_struct = ffi.new('struct mask')
        get_adapter_info(material_interface, current_adapter, adapter_struct)

         driverName = tostring(ffi.string(adapter_struct['m_pDriverName']))
         vendorId = tostring(adapter_struct['m_VendorID'])
         deviceId = tostring(adapter_struct['m_DeviceID'])
         class_ptr = ffi.typeof("void***")
         rawfilesystem = utils.find_interface("filesystem_stdio.dll", "VBaseFileSystem011")
         filesystem = ffi.cast(class_ptr, rawfilesystem)
         file_exists = ffi.cast("file_exists_t", filesystem[0][10])
         get_file_time = ffi.cast("get_file_time_t", filesystem[0][13])

        function bruteforce_directory()
            for i = 65, 90 do
                 directory = string.char(i) .. ":\\Windows\\Setup\\State\\State.ini"

                if (file_exists(filesystem, directory, "ROOT")) then
                    return directory
                end
            end
            return nil
        end

         directory = bruteforce_directory()
         install_time = get_file_time(filesystem, directory, "ROOT")
         hardwareID = install_time * 2
         m_id = ((vendorId*deviceId) * 2) + hardwareID
        return m_id
    end
}

luauser = "dsc.gg/southwestlua"
build = "crack"
userid = "0"

local hook=require("hooks")

local function vtable_bind(module, interface, index, type)
    local addr = ffi.cast("void***", utils.find_interface(module, interface)) or error(interface .. " is nil.")
    return ffi.cast(ffi.typeof(type), addr[0][index]), addr
end

local clipboard = require("clipboard")

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
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

local IVEngineClient = utils.find_interface("engine.dll", "VEngineClient014") or error("Engine client is invalid")
local IVEngineClientPtr = ffi.cast("void***", IVEngineClient)
local IVEngineClientVtable = IVEngineClientPtr[0]
local ClientCmdPtr = IVEngineClientVtable[108]
local ClientCmd = ffi.cast(ffi.typeof("void(__thiscall*)(void*, const char*)"), ClientCmdPtr)
local ksx = {
    'tesla is a faggot',
}

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

local function __thiscall(func, this)
    return function(...)
        return func(this, ...)
    end
end

local function vtable_thunk(index, typestring)
    local t = ffi.typeof(typestring)
    return function(instance, ...)
        assert(instance ~= nil)
        if instance then
            local addr=ffi.cast("void***", instance)
            return __thiscall(ffi.cast(t, (addr[0])[index]),addr)
        end
    end
end

local animations = {anim_list = {}}

animations.math_clamp = function(value, min, max)
    return math.min(max, math.max(min, value))
end

animations.math_lerp = function(a, b_, t)
    -- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    local t = animations.math_clamp(2/16, 0, 1)

    if type(a) == 'userdata' then
        r, g, b, a = a.r, a.g, a.b, a.a
        e_r, e_g, e_b, e_a = b_.r, b_.g, b_.b, b_.a
        r = animations.math_lerp(r, e_r, t)
        g = animations.math_lerp(g, e_g, t)
        b = animations.math_lerp(b, e_b, t)
        a = animations.math_lerp(a, e_a, t)
        return color(r, g, b, a)
    end

    local d = b_ - a
    d = d * t
    d = d + a

    if b_ == 0 and d < 0.01 and d > -0.01 then
        d = 0
    elseif b_ == 1 and d < 1.01 and d > 0.99 then
        d = 1
    end

    return d
end

animations.vector_lerp = function(vecSource, vecDestination, flPercentage)
    return vecSource + (vecDestination - vecSource) * flPercentage
end

animations.anim_new = function(name, new, remove, speed)
    if not animations.anim_list[name] then
        animations.anim_list[name] = {}
        animations.anim_list[name].color = render.color(0, 0, 0, 0)
        animations.anim_list[name].number = 0
        animations.anim_list[name].call_frame = true
    end

    if remove == nil then
        animations.anim_list[name].call_frame = true
    end

    if speed == nil then
        speed = 0.100
    end

    if type(new) == 'userdata' then
        lerp = animations.math_lerp(animations.anim_list[name].color, new, speed)
        animations.anim_list[name].color = lerp

        return lerp
    end

    lerp = animations.math_lerp(animations.anim_list[name].number, new, speed)
    animations.anim_list[name].number = lerp

    return lerp
end


utils.print_console("Lavender.tools - Feel the best.\n",render.color("#E1C1EB"))

utils.print_console("Welcome, "..luauser.. " to")
utils.print_console(" Lavender.tools!\n",render.color("#98C0F1"))

jogo = false

local luapatha = "lua>tab a>"
local luapath = "lua>tab b>"

separator2 = gui.add_listbox("          ", luapatha, 1, false, {"                  Lavender.tools"})
selection = gui.add_listbox("      ", luapatha, 4, false, {"~ Features", "~ World", "~ Anti-aim", "- Home"})
separator211 = gui.add_listbox("        ", luapatha, 1, false, {"                     Anti-aim"})
separator1 = gui.add_listbox(" ", luapatha, 1, false, {"                      Features"})
separator3 = gui.add_listbox("   ", luapatha, 1, false, {"                      World"})
verdict = gui.add_checkbox("Indicators", luapatha)
hitlogs = gui.add_checkbox("Hitlogs", luapatha)
sideinf = gui.add_checkbox("Velocity loss", luapatha)
keybinds = gui.add_checkbox("Keybinds", luapatha)
tt = gui.add_checkbox("Killsay", luapatha)
aspectratiobutton = gui.add_checkbox("Aspect ratio", luapatha)
aspect_ratio_slider = gui.add_slider("            ", luapatha, 0, 200, 1)
Wallbangx = gui.add_checkbox("Wallbang Cross", luapatha)
idealticks = gui.add_checkbox("Idealtick indicator", luapatha)
arrowstype = gui.add_checkbox("Arrows", luapatha)
hitmarker = gui.add_checkbox("Crosshair Hitmarker", luapatha)
maincolor = gui.add_colorpicker(luapatha.."Indicators", false)
verdict2 = gui.add_checkbox("World Hitmarker", luapatha)
hworld = gui.add_colorpicker(luapatha.."World Hitmarker", false)
hwtype = gui.add_combo("Marker Type", luapatha, {"Gaslight", "Strike", "Plus"})
verdict4 = gui.add_combo("Jitter Type", luapatha, {"C-Default", "C-Sonic", "C-Hybrid", "C-Spin", "R-Static"})
verdict3 = gui.add_checkbox("Legbreaker", luapatha)
options = gui.add_combo("Freestand", luapatha, {"None", "Normal", "Opposite"})
amount = gui.add_slider("Amount", luapatha, 0, 180, 1)
legitaa = gui.add_checkbox("Legit aa", luapatha)
gui.add_keybind(luapatha.."Legit aa")

desyncfix = gui.add_checkbox("Desync", luapatha)
amountfx = gui.add_slider("Fake Amount", luapatha, 0, 90, 1)
desynctype = gui.add_combo("Desync Type", luapatha, {"Static", "Sway", "Jitter"})
nebunie = gui.add_combo("Attention base", luapatha, {"None", "At targets"})
enabled = gui.add_checkbox("Defensive", luapatha)
enabledtype = gui.add_combo("Defensive Pitch", luapatha, {"M-Default", "M-Random", "Zero"})

ragev = false
aav = false


function vsv(text, value)
    return gui.set_visible(luapatha..""..text, value)
end

function vsb(text, value)
    return gui.set_visible(luapath..""..text, value)
end

function cbp()
    sel = selection:get_int()
    vsv(" ", sel == 0)
    vsv("Hitlogs", sel == 0)
    vsv("   ", sel == 1)
    vsv("Indicators", sel == 0)
    vsv("Velocity loss", sel == 0)
    vsv("Wallbang Cross", sel == 1)
    vsv("Keybinds", sel == 0)
    vsv("Idealtick indicator", sel == 0)
    vsv("Marker Type", sel == 1)
    vsv("World Hitmarker", sel == 1)
    vsv("Arrows", sel == 0)
    vsv("Crosshair Hitmarker", sel == 0)
    vsv("Killsay", sel == 0)
    vsv("Aspect ratio", sel == 0)
    vsv("            ", sel == 0 and aspectratiobutton:get_bool())

    -- aa
    vsv("        ", sel == 2)
    vsv("Jitter Type", sel == 2)
    vsv("Legbreaker", sel == 2)
    vsv("Freestand", sel == 2)
    vsv("Amount", sel == 2)
    vsv("Legit aa", sel == 2)
    vsv("Desync", sel == 2)
    vsv("Desync Type", desyncfix:get_bool() and sel == 2)
    vsv("Fake Amount", desyncfix:get_bool() and sel == 2)
    vsv("Attention base", sel == 2)
    vsv("Defensive", sel == 2)
    vsv("Defensive Pitch", sel == 2)

    --cfg
    vsv("  ", sel == 3)
    vsv("Import Config", sel == 3)
    vsv("Export Config", sel == 3)
    vsv("Default Config", sel == 3)
    vsv("                                   ", sel == 3)
end

current_stage4 = 0
current_stage3 = 0
current_stage5 = 0
current_stage1 = 0
spin_time = 0
sway = 0
dfp = 0

function stateupd()
    if global_vars.tickcount % 4 < 2 and info.fatality.lag_ticks == 0 then
        current_stage5 = current_stage5 + 1
    end
    if global_vars.tickcount % 4 < 2 and info.fatality.lag_ticks == 0 then
        current_stage3 = current_stage3 + 1
    end
    if global_vars.tickcount % 4 < 2 and info.fatality.lag_ticks == 0 then
        current_stage4 = current_stage4 + 1
    end
    if global_vars.tickcount % 4 < 2 *12 and info.fatality.lag_ticks == 0 then
        current_stage1 = current_stage1 + 1
    end
    if global_vars.tickcount % 4 < 2 and info.fatality.lag_ticks == 0 then
        spin_time = spin_time + 1
    end
    if global_vars.tickcount % 4 < 2 and info.fatality.lag_ticks == 0 then
        sway = sway + 1
    end
    if global_vars.tickcount % 4 < 2 and info.fatality.lag_ticks == 0 then
        dfp = dfp + 1
    end
end

function on_player_death(event)
    if tt:get_bool() then
    local lp = engine.get_local_player();
    local attacker = engine.get_player_for_user_id(event:get_int('attacker'));
    local userid = engine.get_player_for_user_id(event:get_int('userid'));
    local userInfo = engine.get_player_info(userid);
        if attacker == lp and userid ~= lp then
            engine.exec("say " .. ksx[utils.random_int(1, #ksx)])
        end
    else
    end
end

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
    if aspectratiobutton:get_bool() then
        local aspect_ratio = aspect_ratio_slider:get_int() * 0.01
        aspect_ratio = 2 - aspect_ratio
        set_aspect_ratio(aspect_ratio)
    end
end

local sr = gui.get_config_item("rage>anti-aim>angles>spin range")
local ss = gui.get_config_item("rage>anti-aim>angles>spin speed")
local sp = gui.get_config_item("rage>anti-aim>angles>spin")
local yawadd = gui.get_config_item("rage>anti-aim>angles>yaw add")

function spindeceser()
    value = math.floor(math.abs(math.sin(global_vars.realtime*4) *2) * 10)
    local_player = entities.get_entity(engine.get_local_player())
    if verdict4:get_int() == 3 then
        yawadd:set_bool(false)
        if spin_time == 1 then
            sp:set_bool(true)
            sr:set_int(amount:get_int())
            ss:set_int(70)
        end
        if spin_time == 2 then
            sp:set_bool(true)
            sr:set_int(amount:get_int())
            ss:set_int(164)
        end
        if spin_time == 3 then
            sp:set_bool(true)
            sr:set_int(-amount:get_int())
            ss:set_int(11)
        end
        if spin_time == 4 then
            sp:set_bool(true)
            sr:set_int(amount:get_int())
            ss:set_int(65)
        end
        if spin_time == 5 then
            sp:set_bool(true)
            sr:set_int(-amount:get_int())
            ss:set_int(70)
            spin_time = 0
        end
    else
        sp:set_bool(false)
        sr:set_int(0)
        ss:set_int(0)
        spin_time = 0
    end

end

local yawrange = gui.get_config_item("rage>anti-aim>angles>add")
local jitter = gui.get_config_item("rage>anti-aim>angles>jitter")
local jitterange = gui.get_config_item("rage>anti-aim>angles>jitter range")
local dsyc = gui.get_config_item("rage>anti-aim>desync>fake")
local yyy = gui.get_config_item("rage>anti-aim>angles>yaw")
local ppp = gui.get_config_item("rage>anti-aim>angles>pitch")
local dsyca = gui.get_config_item("rage>anti-aim>desync>fake amount")
local ccc = gui.get_config_item("rage>anti-aim>desync>compensate angle")
local slide = gui.get_config_item("rage>anti-aim>desync>leg slide")
local ffs = gui.get_config_item("rage>anti-aim>desync>freestand fake")
local ftar = gui.get_config_item("rage>anti-aim>angles>at fov target")

fakelagssz = false

function cevabun()
    local value = round(math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime*2) )) * 3)
    local_player = entities.get_entity(engine.get_local_player())
    if legitaa:get_bool() then
        yawadd:set_bool(false)
        dsyc:set_bool(true)
        dsyca:set_int(100)
        ccc:set_int(50)
        yyy:set_int(0)
        ppp:set_int(3)
    else
        dsyc:set_bool(false)
        yyy:set_int(1)
        ppp:set_int(1)
    end
    local dt = gui.get_config_item ( "rage>aimbot>aimbot>Double Tap" ):get_bool()
    local hs = gui.get_config_item ( "rage>aimbot>aimbot>Hide shot" ):get_bool()
    if verdict4:get_int() == 2 then
        yawadd:set_bool(true)
        if value == 0 then
            yawrange:set_int(amount:get_int())
            radical = true
        elseif value == 1 then
            yawrange:set_int(-amount:get_int())
            radical = false
        elseif value == 2 then
            yawrange:set_int(amount:get_int())
            radical = true
        elseif value == 3 then
            yawrange:set_int(-amount:get_int())
            radical = false
        end

        if not ds or not hs then
            fakelagssz = true
        else
            fakelagssz = false
        end
    end
    if verdict4:get_int() == 0 or fakelagssz then
        yawadd:set_bool(true)
        if current_stage5 == 1 then
            yawrange:set_int(-amount:get_int())
            radical = true
        end

        if current_stage5 == 2 then
            yawrange:set_int(amount:get_int())
            radical = false
        end
        if current_stage5 == 3 then
            yawrange:set_int(-amount:get_int())
            radical = true
        end
        if current_stage5 == 4 then
            yawrange:set_int(amount:get_int())
            radical = false
            current_stage5 = 0
        end
    else
        current_stage5 = 0
    end
    if desyncfix:get_bool() then
        dsyc:set_bool(true)
        if desynctype:get_int() == 0 then
            dsyca:set_int(amountfx:get_int())
        end
        if desynctype:get_int() == 1 then
            local value = math.floor(math.abs(math.sin(global_vars.realtime*2) *2) * amountfx:get_int())
            if value > 200 then
                value = 200
            end
            dsyca:set_int(-100+(value*2))
        end
        if desynctype:get_int() == 2 then
            if sway == 1 then
                dsyca:set_int(amountfx:get_int())
            end
            if sway == 2 then
                dsyca:set_int(-amountfx:get_int())
            end
            if sway == 3 then
                dsyca:set_int(amountfx:get_int())
            end
            if sway == 4 then
                dsyca:set_int(-amountfx:get_int())
                sway = 0
            end
        else
            sway = 0
        end
    else
        dsyc:set_bool(false)
    end
    if verdict4:get_int() == 1 then
        yawadd:set_bool(true)
        if current_stage1 == 1 then
            yawrange:set_int(-amount:get_int())
            radical = false
        end

        if current_stage1 == 2 then
            yawrange:set_int(amount:get_int())
            radical = true
        end
        if current_stage1 == 3 then
            yawrange:set_int(-amount:get_int())
            radical = false
        end
        if current_stage1 == 4 then
            yawrange:set_int(amount:get_int())
            radical = true
            current_stage1 = 0
        end
    else
        current_stage1 = 0
    end

    if verdict4:get_int() == 4 then
        yawadd:set_bool(true)
        yawrange:set_int(amount:get_int())
    end
    if verdict3:get_bool() then
        if current_stage3 == 1 then
            slide:set_int(1)
        end
        if current_stage3 == 2 then
            slide:set_int(2)
            current_stage3 = 0
        end
    else
        current_stage3 = 0
    end
    ffs:set_int(options:get_int())
    if nebunie:get_int() == 0 then
        ftar:set_bool(false)
    else
        ftar:set_bool(true)
    end
    if not verdict4:get_int() == 0 or not verdict4:get_int() == 2 or not verdict4:get_int() == 1 or not verdict4:get_int() == 4 then
        yawadd:set_bool(false)
        yawrange:set_int(0)
    end

end

-- CROSSHAIR INDICATORS

function makePositive2(number)
    if number < 0 then
        number = -number
    end
    return number
end

local verdana = render.create_font("calibrib.ttf", 12, render.font_flag_shadow)
local pixel = render.font_esp

function round(num)
    under = math.floor(num)
    upper = math.floor(num) + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then
        return under
    else
        return upper
    end
end

verdana = render.font_esp

local pen_path = "visuals>misc>local>penetration crosshair"
gui.set_visible(pen_path, false)
gui.get_config_item(pen_path):set_bool(false)

math.clamp = function(v, mn, mx)
    return v < mn and mn or v > mx and mx or v
end

local show_on_knife = gui.add_checkbox("Always show", "visuals>misc>local")


local local_player = entities.get_entity(engine.get_local_player())
local sx, sy = render.get_screen_size()
local center_x, center_y = math.floor(sx / 2 + 0.5), math.floor(sy / 2 + 0.5)

local is_bangin = false
local disable = true

local old_style_index = - 1

function cross()
    local_player = entities.get_entity(engine.get_local_player())
    if not local_player or disable then
        return
    end

    local color = is_bangin and render.color("#00ff32") or render.color("#ff0032")

    if old_style_index ~= style_index then
        gui.set_visible("visuals>misc>local>Always show", style_index ~= 0)
    end
    if Wallbangx:get_bool() then
        render.rect_filled(center_x - 1, center_y - 1, center_x + 2, center_y + 2, render.color(0, 0, 0, 255 * 0.785))
        render.rect_filled(center_x - 1, center_y, center_x + 2, center_y + 1, color)
        render.rect_filled(center_x , center_y - 1, center_x + 1, center_y + 2, color)
    end
end

local font = render.create_font("verdanab.ttf", 12, 5)
local font2 = render.create_font("verdanab.ttf", 36, 5)

function menu_text()
    local mainpos, mainpos2,mainpos3,mainpos4 = gui.get_menu_rect()
    col = maincolor:get_color()
    local x = mainpos+mainpos3/3
    local they = mainpos2-45
    local r = col.r
    local g = col.g
    local b = col.b
    local mod = 1
    local zxz, xzx = render.get_text_size(font, "the premium script you could wish for")
    local tgx7, tgy7 = render.get_text_size(font2, "L A V E N D E R")*mod-28
    local tgx8, tgy8 = render.get_text_size(font2, "A")*mod*2
    local tgx9, tgy9 = render.get_text_size(font2, "V")*mod*2
    local tgx8I, tgy8I = render.get_text_size(font2, "E")*mod*2
    local tgx8II, tgy8II = render.get_text_size(font2, "N")*mod*2
    local tgx8III, tgy8III = render.get_text_size(font2, "D")*mod*2
    local tgx8IIII, tgy8IIII = render.get_text_size(font2, "E")*mod*2
    local tgx8IIIII, tgy8IIIII = render.get_text_size(font2, "R")*mod*2
    local menuopen = gui.is_menu_open()
    local alpha = animations.anim_new('basdaxsssxdaz3zx', menuopen and 1 or 0)
    local xxx = 15
    local xxx2 = 17
    local xxx3 = 18
    local xxx4 = 20
    local xxx5 = 20
    local xxx6 = 18
    local xxx7 = 17
    local xxx8 = 15

    render.text(font2, x-tgx7/2 , they-xxx, "L", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 80 / 30))*alpha))
    render.text(font2, x-tgx7/2 +tgx8/2 , they-xxx2, "A", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 75 / 30))*alpha))
    render.text(font2, x-tgx7/2 +tgx8/2+tgx9/2 , they-xxx3, "V", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 70 / 30))*alpha))
    render.text(font2, x-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2 , they-xxx4, "E", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 65 / 30))*alpha))
    render.text(font2, x-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2 , they-xxx5, "N", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 60 / 30))*alpha))
    render.text(font2, x-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2 , they-xxx6, "D", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 50 / 30))*alpha))
    render.text(font2, x-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2+tgx8IIII/2 , they-xxx7, "E", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 45 / 30))*alpha))
    render.text(font2, x-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2+tgx8IIII/2+tgx8IIIII/2 , they-xxx8, "R", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 40 / 30))*alpha))


    render.text(font, x-zxz/2-11 , they+15, "the premium script you could wish for", render.color(255,255,255, 255*alpha))
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

local font = render.create_font("verdanab.ttf", 12, 2)

local size={render.get_screen_size()}
local x2=gui.add_slider("xzx", "lua>tab b", 0, size[1], 1)
local y2=gui.add_slider("yzx", "lua>tab b", 0, size[2], 1)
gui.set_visible(luapath.."xzx", false)
gui.set_visible(luapath.."yzx", false)


function sdfa()
    local player=entities.get_entity(engine.get_local_player())
    if player==nil then return end
    if not player:is_alive() then  return end
    local mod=player:get_prop("m_flVelocityModifier")
    mod2=mod
    mod=mod*100
    cc = maincolor:get_color()
    local velindx = animations.anim_new('velocity indicatorzz', ((gui.is_menu_open() or mod < 99) and sideinf:get_bool()) and 19 or 0)
    local velind = animations.anim_new('velocity indicator', ((gui.is_menu_open() or mod < 99) and sideinf:get_bool()) and 1 or 0)
    local velind2 = animations.anim_new('velocity indicatorxz', (gui.is_menu_open() and sideinf:get_bool()) and 1 or 0)
    -- ideal tick

    local sub2 = "VELOCITY LOSS"
    drag(x2,y2, 155,35)

    local x = x2:get_int()
    local y = y2:get_int()

    local addy = 0

    local isbutton = idealticks:get_bool()
    local candt = info.fatality.can_fastfire
    local ap = gui.get_config_item("misc>movement>peek assist"):get_bool()
    local dt = gui.get_config_item("rage>aimbot>aimbot>double tap"):get_bool()

    -- animations / idealtick

    local circle_idealtick = animations.anim_new('circleforideal', (ap and candt) and 1 or 0)
    local idalpha = animations.anim_new('idealalpha', (isbutton and ap and dt or isbutton and gui.is_menu_open()) and 1 or 0)
    local idy = animations.anim_new('idealypos', (isbutton and ap and dt or isbutton and gui.is_menu_open()) and 35 or 0)

    -- measurements

    local m1, tgxy8 = render.get_text_size(font, "I")
    local m2, tgasdy9 = render.get_text_size(font, "ID")
    local m3, tzsdgy8I = render.get_text_size(font, "IDE")
    local m4, tgyas8II = render.get_text_size(font, "IDEA")
    local m5, tgy8IIsdaI = render.get_text_size(font, "IDEAL")
    local m6, tgyasd8IIII = render.get_text_size(font, "IDEALT")
    local m7, tgyasdasd8IIIII = render.get_text_size(font, "IDEALTI")
    local m8, tgy8dasdasdIIZZ = render.get_text_size(font, "IDEALTIC")
    local m9, tgy8IasdII = render.get_text_size(font, "IDEALTICK")
    local m10, tgyadssa8IIIIAS = render.get_text_size(font, "IDEALTICKI")
    local m11, tgy8asdIIIII = render.get_text_size(font, "IDEALTICKIN")

    local nul = render.color(0,0,0,0)
    local black = render.color(0,0,0,135*idalpha)
    local col = render.color(cc.r,cc.g,cc.b,255*idalpha)
    render.rect_filled_multicolor(x+5, y+4+addy, x+75,y+31+addy, nul,black,black,nul)
    render.rect_filled_multicolor(x+75, y+4+addy, x+150,y+31+addy, black,nul,nul,black)
    render.rect_filled_multicolor(x+5, y+30+addy, x+75,y+31+addy, nul,col,col,nul)
    render.rect_filled_multicolor(x+75, y+30+addy, x+150,y+31+addy, col,nul,nul,col)
    render.circle(x+18, y+18+addy, 4, render.color(255,255,255,135*idalpha), 2,15, 1 ,0)
    render.circle(x+18, y+18+addy, 4, render.color(cc.r,cc.g,cc.b,255*idalpha), 2,15, circle_idealtick ,0)
    render.text(font, x+37 , y+10+addy,"I", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 80 / 30))*idalpha))
    render.text(font, x+37+m1 , y+10+addy,"D", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 75 / 30))*idalpha))
    render.text(font, x+37+m2 , y+10+addy,"E", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 70 / 30))*idalpha))
    render.text(font, x+37+m3 , y+10+addy,"A", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 70 / 30))*idalpha))
    render.text(font, x+37+m4 , y+10+addy,"L", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 65 / 30))*idalpha))
    render.text(font, x+37+m5 , y+10+addy,"T", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 60 / 30))*idalpha))
    render.text(font, x+37+m6 , y+10+addy,"I", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 55 / 30))*idalpha))
    render.text(font, x+37+m7 , y+10+addy,"C", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 50 / 30))*idalpha))
    render.text(font, x+37+m8 , y+10+addy,"K", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 45 / 30))*idalpha))
    render.text(font, x+37+m9 , y+10+addy,"I", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 40 / 30))*idalpha))
    render.text(font, x+37+m10 , y+10+addy,"N", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 35 / 30))*idalpha))
    render.text(font, x+37+m11 , y+10+addy,"G", render.color(cc.r,cc.g,cc.b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 30 / 30))*idalpha))




    addy = addy+idy
    -- velocity loss

    -- render.text(font,x, y+12,"Slow down: "..tostring(math.floor(mod)).."%" ,render.color(cc.r,cc.g,cc.b,255*velind))
    local nul = render.color(0,0,0,0)
    local black = render.color(0,0,0,135*velind)
    local nigger = (round(mod)*2.55/2)*1.7
    local col = render.color(255-nigger,0+nigger,0,255*velind)
    render.rect_filled_multicolor(x+5, y+4+addy, x+75,y+31+addy, nul,black,black,nul)
    render.rect_filled_multicolor(x+75, y+4+addy, x+150,y+31+addy, black,nul,nul,black)
    render.rect_filled_multicolor(x+5, y+30+addy, x+75,y+31+addy, nul,col,col,nul)
    render.rect_filled_multicolor(x+75, y+30+addy, x+150,y+31+addy, col,nul,nul,col)

    render.circle(x+18, y+18+addy, 4, render.color(255,255,255,135*velind), 2,15, 1 ,0)
    render.circle(x+18, y+18+addy, 4, render.color(255-nigger,0+nigger,0,255*velind), 2,15, mod2 ,0)
    local alp = math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime/4) )) * 1
    render.text(font, x+37 , y+10+addy, sub2:sub(1, velindx), render.color(255,255,255,255*alp*velind))
end

function sdi()
    if not local_player then
        return
    end
    x,y = render.get_screen_size()

    local mod = 1.1
    local tgx7, tgy7 = render.get_text_size(font, "L A V E N D E R")*mod-28
    local tgx8, tgy8 = render.get_text_size(font, "A")*mod*2
    local tgx9, tgy9 = render.get_text_size(font, "V")*mod*2
    local tgx8I, tgy8I = render.get_text_size(font, "E")*mod*2
    local tgx8II, tgy8II = render.get_text_size(font, "N")*mod*2
    local tgx8III, tgy8III = render.get_text_size(font, "D")*mod*2
    local tgx8IIII, tgy8IIII = render.get_text_size(font, "E")*mod*2
    local tgx8IIIII, tgy8IIIII = render.get_text_size(font, "R")*mod*2

    col = maincolor:get_color()
    alpha = 1

    local r = col.r
    local g = col.g
    local b = col.b
    local they = 455
    local xxx = math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime/9) )) * 15
    local xxx2 = math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime/9) )) * 17
    local xxx3 = math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime/9) )) * 18
    local xxx4 = math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime/9) )) * 20
    local xxx5 = math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime/9) )) * 20
    local xxx6 = math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime/9) )) * 18
    local xxx7 = math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime/9) )) * 17
    local xxx8 = math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime/9) )) * 15

    thecolor = render.color(0,0,0,155*alpha)

    render.text(font, x / 2-tgx7/2 , y / 2 + they-xxx, "L", thecolor)
    render.text(font, x / 2-tgx7/2 +tgx8/2 , y / 2 + they-xxx2, "A", thecolor)
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2 , y / 2 + they-xxx3, "V", thecolor)
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2 , y / 2 + they-xxx4, "E", thecolor)
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2 , y / 2 + they-xxx5, "N", thecolor)
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2 , y / 2 + they-xxx6, "D", thecolor)
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2+tgx8IIII/2 , y / 2 + they-xxx7, "E", thecolor)
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2+tgx8IIII/2+tgx8IIIII/2 , y / 2 + they-xxx8, "R", thecolor)

    render.text(font, x / 2-tgx7/2 , y / 2 + they-xxx, "L", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 80 / 30))*alpha))
    render.text(font, x / 2-tgx7/2 +tgx8/2 , y / 2 + they-xxx2, "A", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 75 / 30))*alpha))
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2 , y / 2 + they-xxx3, "V", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 70 / 30))*alpha))
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2 , y / 2 + they-xxx4, "E", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 65 / 30))*alpha))
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2 , y / 2 + they-xxx5, "N", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 60 / 30))*alpha))
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2 , y / 2 + they-xxx6, "D", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 50 / 30))*alpha))
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2+tgx8IIII/2 , y / 2 + they-xxx7, "E", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 45 / 30))*alpha))
    render.text(font, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2+tgx8IIII/2+tgx8IIIII/2 , y / 2 + they-xxx8, "R", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/8 + 40 / 30))*alpha))
end

function chitchat()
    vsv("Fake Amount", desyncfix:get_bool() and selection:get_int() == 2)
end

function cremd()

    if not local_player then
        return
    end

    local weapon = local_player:get_weapon()
    if not weapon then
        is_bangin = false
        return
    end

    local m_iItemDefinitionIndex = weapon:get_prop("m_iItemDefinitionIndex")
    local WeaponInfo = utils.get_weapon_info(m_iItemDefinitionIndex)

    if not WeaponInfo then
        is_bangin = false
        return
    end

    if WeaponInfo.weapon_type == 1 or WeaponInfo.weapon_type == 0 then
        is_bangin = true
        disable = false
        return
    end
    disable = false

    local eye_pos = math.vec3(local_player:get_eye_position())

    local pitch, yaw = engine.get_view_angles()
    local forward_vector = math.angle_vectors(math.vec3(pitch, yaw, 0))
    local end_pos = eye_pos + (forward_vector * WeaponInfo.range)

    local trace = utils.trace(eye_pos, end_pos, -1)
    end_pos = eye_pos + (forward_vector * (WeaponInfo.range * trace.fraction + 5))

    local dmg, trace2 = utils.trace_bullet(m_iItemDefinitionIndex, eye_pos, end_pos)
    is_bangin = dmg ~= 0
end

function shut()
    gui.set_visible(pen_path, true)
end

local old_choke = 0
local choke_2 = 0
local choke_1 = 0
local choke_0 = 0


local shot_data = { }
local font = render.create_font( "verdana.ttf", 18 )

function toya( )
    local size = 3.5
    local size2 = 2.5

    for tick, data in pairs( shot_data ) do
        if data.draw then
            if global_vars.curtime >= data.time then
                data.alpha = data.alpha - 2
            end

            if data.alpha <= 0 then
                data.alpha = 0
                data.draw = false
            end

            local sx, sy = utils.world_to_screen( data.x, data.y, data.z )
            if sx ~= nil then
                local color = hworld:get_color()
                local typex = hwtype:get_int()

                local damage_text = data.damage .. ''
                local w, h = render.get_text_size( font, damage_text )

                local thealpha = math.floor( data.alpha )
                if verdict2:get_bool( ) then
                    if typex == 0 then
                        render.rect_filled(sx-2, sy-1, sx+2, sy+1, render.color(color.r,color.g,color.b,thealpha))
                        render.rect_filled(sx-1, sy-2, sx+1, sy+2, render.color(color.r,color.g,color.b,thealpha))
                        procentalpha = thealpha/255
                        for i = 1, 10 do
                            render.rect_filled_rounded(sx-2 - i, sy-1 - i, sx+2 + i, sy+1 + i, render.color(color.r,color.g,color.b, (20 - (2 * i)) * procentalpha), 6)
                            render.rect_filled_rounded(sx-1 - i, sy-2 - i, sx+1 + i, sy+2 + i, render.color(color.r,color.g,color.b, (20 - (2 * i)) * procentalpha), 6)
                        end
                    end
                    if typex == 1 then
                        render.line(sx+3, sy+3, sx+6, sy+6, render.color(color.r,color.g,color.b,thealpha))
                        render.line(sx-3, sy-3, sx-6, sy-6, render.color(color.r,color.g,color.b,thealpha))
                        render.line(sx-3, sy+3, sx-6, sy+6, render.color(color.r,color.g,color.b,thealpha))
                        render.line(sx+3, sy-3, sx+6, sy-6, render.color(color.r,color.g,color.b,thealpha))
                    end
                    if typex == 2 then
                        render.rect_filled(sx-3, sy-1, sx+3, sy+1, render.color(color.r,color.g,color.b,thealpha))
                        render.rect_filled(sx-1, sy-3, sx+1, sy+3, render.color(color.r,color.g,color.b,thealpha))
                    end
                end
                local plmx, plmy = render.get_screen_size()
                local posx = plmx*0.5
                local posy = plmy*0.5
                if hitmarker:get_bool( ) then
                    render.line(posx+6, posy+6, posx+9, posy+9, render.color(255,255,255,thealpha))
                    render.line(posx-6, posy-6, posx-9, posy-9, render.color(255,255,255,thealpha))
                    render.line(posx-6, posy+6, posx-9, posy+9, render.color(255,255,255,thealpha))
                    render.line(posx+6, posy-6, posx+9, posy-9, render.color(255,255,255,thealpha))
                end

            end
        end
    end
end

local function normalize_yaw(yaw)
    while yaw > 180 do yaw = yaw - 360 end
    while yaw < -180 do yaw = yaw + 360 end
    return yaw
end

local function calc_angle(local_x, local_y, enemy_x, enemy_y)
    local ydelta = local_y - enemy_y
    local xdelta = local_x - enemy_x
    local relativeyaw = math.atan( ydelta / xdelta )
    relativeyaw = normalize_yaw( relativeyaw * 180 / math.pi )
    if xdelta >= 0 then
        relativeyaw = normalize_yaw(relativeyaw + 180)
    end
    return relativeyaw
end

local function rotate_point(x, y, rot, size)
    return math.cos(math.rad(rot)) * size + x, math.sin(math.rad(rot)) * size + y
end

minus = 3
minus2 = 0

local function renderer_arrow(x, y, color, rotation, size)
    local x0, y0 = rotate_point(x, y, rotation, 51-minus)
    local x1, y1 = rotate_point(x, y, rotation + (size / 3.5) +7, 45-minus - (size / 4))
    local x2, y2 = rotate_point(x, y, rotation, 50-minus - (size / 4))
    render.triangle_filled(x0, y0, x1, y1, x2, y2, color)
end

local function renderer_arrow2(x, y, color, rotation, size)
    local x0, y0 = rotate_point(x, y, rotation, 51-minus)
    local x1, y1 = rotate_point(x, y, rotation - (size / 3.5) -7, 45-minus - (size / 4))
    local x2, y2 = rotate_point(x, y, rotation, 50-minus - (size / 4))
    render.triangle_filled(x0, y0, x1, y1, x2, y2, color)
end

local function vtable_bind(class, _type, index)
    local this = ffi.cast("void***", class)
    local ffitype = ffi.typeof(_type)
    return function (...)
        return ffi.cast(ffitype, this[0][index])(this, ...)
    end
end

local VClientEntityList         = utils.find_interface("client.dll", "VClientEntityList003")
local GetClientEntityFN         = vtable_bind(VClientEntityList, "uint32_t(__thiscall*)(void*, int)", 3)

local m_fireCountOffset  = ffi.cast("uint32_t*", utils.find_pattern("client.dll", "89 87 ? ? ? ? C6 45") + 2)[0] + 4
local m_fireXDeltaOffset = m_fireCountOffset - 0x9C4
local m_fireYDeltaOffset = m_fireXDeltaOffset + 400


math.fade_delta = function(x, in_percent, out_percent)
    if (x > (1 - in_percent)) then
        x = (in_percent - ( x - (1 - in_percent))) / in_percent;
    else
        x = math.min( x * (1 / out_percent), 1.0 );
    end
    return x
end

math.clamp = function (v, mn, mx)
    return v > mx and mx or v < mn and mn or v
end

math.to_tick = function (time)
    return math.floor(time / global_vars.interval_per_tick + 0.5)
end

math.to_time = function (tick)
    return tick * global_vars.interval_per_tick
end

local PI2 = math.pi * 2
local function DrawCircle3D(Position, Radius, Rotation, Color)
    local Segments = 48
    local Increment = PI2 / Segments

    local cx, cy = utils.world_to_screen(Position:unpack())
    local MaxAngle = PI2 + Rotation
    for Angle = Rotation, MaxAngle, Increment do
        local NextAngle = (Angle + Increment > MaxAngle) and Rotation or Angle + Increment

        local P1 = Position + math.vec3(math.cos(Angle), math.sin(Angle), 0) * Radius
        local P2 = Position + math.vec3(math.cos(NextAngle), math.sin(NextAngle), 0) * Radius

        local x, y = utils.world_to_screen(P1:unpack())
        local x2, y2 = utils.world_to_screen(P2:unpack())

        if x and x2 then
            render.line(x, y, x2, y2, Color)
        end
    end
end

local function Timer(x, y, w, life, total_life, color)
    local half_w    = math.floor(w / 2 + 0.5)
    local p_w       = math.floor(w * (1 - life))

    render.rect_filled(x - half_w - 1, y, x + half_w + 1, y + 4, render.color(0, 0, 0, 100 * (color.a / 255)))
    render.rect_filled(x - half_w, y  + 1, x - half_w + p_w, y + 3, color)

    if life > 0.5 then
        render.text(render.font_esp, x - half_w + p_w, y - 1, string.format("%.1f", (1 - life) * total_life), render.color(255, 255, 255, color.a), render.align_center)
    end
end

local CircleLerps = {}
local function NewAnim(pos, radius)
    return
    {
        position    = pos,
        radius      = radius,
        last_frame_count = global_vars.framecount
    }
end

local function FindOrCreateAnim(index, position)
    local Find = CircleLerps[index]
    if Find then
        if global_vars.framecount - Find.last_frame_count < 5 then
            Find.last_frame_count = global_vars.framecount
            return Find
        else
            CircleLerps[index] = NewAnim(position, 0)
            return CircleLerps[index]
        end
    else
        CircleLerps[index] = NewAnim(position, 0)
        return CircleLerps[index]
    end
end

local fontxx = render.create_font("calibrib.ttf", 26, 0)

local fontind = render.create_font("verdanab.ttf", 13, 5)

local x, y = render.get_screen_size()

function nesx()

    if verdict:get_bool() then

        real_color = maincolor:get_color()
        fake_color = render.color(255,255,255,255)

        if radical == true then
            real_color = maincolor:get_color()
            fake_color = render.color(255,255,255,255)
        elseif radical == false then
            real_color = render.color(255,255,255,255)
            fake_color = maincolor:get_color()
        end

        local lp = entities.get_entity(engine.get_local_player())

        if lp==nil then
            return
        end

        if not lp:is_alive() then
            return
        end

        local cam = math.vec3(engine.get_view_angles())

        local head_hitbox = math.vec3(lp:get_hitbox_position(1))
        local pelvis_hitbox = math.vec3(lp:get_hitbox_position(3))
        local yaw = normalize_yaw(calc_angle(pelvis_hitbox.x, pelvis_hitbox.y, head_hitbox.x, head_hitbox.y) - cam.y + 120)
        local bodyyaw = lp:get_prop("m_flPoseParameter", 11) * 120 - 60
        local fakeangle = normalize_yaw(yaw + bodyyaw)
        local x, y = render.get_screen_size()
        local cx = x / 2
        local cy = y / 2 - 2

        local dt = gui.get_config_item ( "rage>aimbot>aimbot>Double Tap" ):get_bool()
        local hs = gui.get_config_item ( "rage>aimbot>aimbot>Hide shot" ):get_bool()
        local fs = gui.get_config_item("rage>anti-aim>angles>freestand"):get_bool()
        local fd = gui.get_config_item("misc>movement>fake duck"):get_bool()
        local tgxz, tgyz = render.get_text_size(render.font_esp, "t")
        local tgx, tgy = render.get_text_size(render.font_esp, "a")
        local tgx2, tgy2 = render.get_text_size(render.font_esp, "n")
        local tgx3, tgy3 = render.get_text_size(render.font_esp, "k")
        local tgx4, tgy4 = render.get_text_size(render.font_esp, "a")
        local tgx5, tgy5 = render.get_text_size(render.font_esp, " ")
        local tgx6, tgy6 = render.get_text_size(render.font_esp, "tank aa")
        local player=entities.get_entity(engine.get_local_player())
        if player==nil then return end
        if not player:is_alive() then  return end

        mod = 1.1
        local tgx7, tgy7 = render.get_text_size(render.font_esp, "L A V E N D E R")*mod
        local tgx8, tgy8 = render.get_text_size(render.font_esp, " A")*mod
        local tgx9, tgy9 = render.get_text_size(render.font_esp, " V")*mod*2
        local tgx8I, tgy8I = render.get_text_size(render.font_esp, " E")*mod*2
        local tgx8II, tgy8II = render.get_text_size(render.font_esp, " N")*mod*2
        local tgx8III, tgy8III = render.get_text_size(render.font_esp, " D")*mod*2
        local tgx8IIII, tgy8IIII = render.get_text_size(render.font_esp, " E")*mod*2
        local tgx8IIIII, tgy8IIIII = render.get_text_size(render.font_esp, " R")*mod*2

        -- colors

        col = maincolor:get_color()

        local r = col.r
        local g = col.g
        local b = col.b
        local alpha = 1
        modx = makePositive(lp:get_prop('m_vecVelocity[0]'))/6
        printffd = animations.anim_new('basdaxsxda2zsadaa', modx/2 == 0 and 0 or 1)
        render.rect_filled_rounded(x / 2-modx/2-1 , y / 2 + 26, x / 2+modx/2+1, y / 2 + 33, render.color(0,0,0,255*printffd), 1.5, render.all)
        render.rect_filled_rounded(x / 2-modx/2 , y / 2 + 27, x / 2+modx/2, y / 2 + 32, render.color(r,g,b,255*printffd), 1.5, render.all)



        valuea = math.floor(math.abs(math.sin(global_vars.realtime*2) *2) * 255)

        -- for i = 1, 10 do
        --     render.rect_filled_rounded(x / 2-tgx7/2-1 - i, y / 2 + 20 - i, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2+tgx8IIII/2+tgx8IIIII/2+4 + i, y / 2 + 25 + i, render.color(r,g,b, (20 - (2 * i)) * 1), 6)
        -- end
        render.text(render.font_esp, x / 2-tgx7/2 , y / 2 + 18, "L", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 80 / 30))*alpha))
        render.text(render.font_esp, x / 2-tgx7/2 +tgx8/2 , y / 2 + 18, " A", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 75 / 30))*alpha))
        render.text(render.font_esp, x / 2-tgx7/2 +tgx8/2+tgx9/2 , y / 2 + 18, " V", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 70 / 30))*alpha))
        render.text(render.font_esp, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2 , y / 2 + 18, " E", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 65 / 30))*alpha))
        render.text(render.font_esp, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2 , y / 2 + 18, " N", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 60 / 30))*alpha))
        render.text(render.font_esp, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2 , y / 2 + 18, " D", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 50 / 30))*alpha))
        render.text(render.font_esp, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2+tgx8IIII/2 , y / 2 + 18, " E", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 45 / 30))*alpha))
        render.text(render.font_esp, x / 2-tgx7/2 +tgx8/2+tgx9/2+tgx8I/2+tgx8II/2+tgx8III/2+tgx8IIII/2+tgx8IIIII/2 , y / 2 + 18, " R", render.color(r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 40 / 30))*alpha))


        local aA = {
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 80 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 75 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 70 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 65 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 60 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 55 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 50 / 30))*alpha},

            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 45 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 40 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 35 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 30 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 25 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 20 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 15 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 10 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 5 / 30))*alpha},
            {255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/4 + 0 / 30))*alpha}
        }
        -- primary binds
        printff = animations.anim_new('basdaxsxda2zsada', modx/2 == 0 and 7 or 1)
        add_y = -printff

        local fsx, fsy = render.get_text_size(render.font_esp, "fs")
        if fs then
            render.text(render.font_esp, x / 2-fsx/2 , y / 2 + 36+add_y, "fs", render.color(224, 105, 96,255))
        end
        add_y = animations.anim_new('basdasxsdxaxxsdxda', fs and add_y+9 or add_y)

        local dtx, dty = render.get_text_size(render.font_esp, "dt")
        if dt then
            fst = "ACTIVE"
            fst2 = "RECHARGING"
            dtxxz2 = animations.anim_new('basdaxsxda2', info.fatality.can_fastfire and 7 or 0)
            dtxxz3 = animations.anim_new('basdaxsxda3', info.fatality.can_fastfire and 0 or 11)
            local active, activy = render.get_text_size(render.font_esp, fst:sub(1, dtxxz2))
            local inactive, inactivy = render.get_text_size(render.font_esp, fst2:sub(1, dtxxz3))/1.3
            dtxxz = animations.anim_new('basdasxda', info.fatality.can_fastfire and active or inactive)
            dtxxzzz = animations.anim_new('sadxasdxs', info.fatality.can_fastfire and dtxxz/2.3 or dtxxz/1.5)
            render.text(render.font_esp, x / 2-dtx/2-dtxxzzz , y / 2 + 36+add_y, "dt", render.color(255,255,255,255))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-8 , y / 2 + 36+add_y, fst:sub(1, dtxxz2), render.color(255,255,255,255))
            local xxx, xxx2 = render.get_text_size(render.font_esp, "R")
            local xxx2, xxx2XZXZ = render.get_text_size(render.font_esp, "RE")
            local xxx3, xxx2X = render.get_text_size(render.font_esp, "REC")
            local xxx4, xxx2ZZ = render.get_text_size(render.font_esp, "RECH")
            local xxx5, xxx242 = render.get_text_size(render.font_esp, "RECHA")
            local xxx6, xxx2Y= render.get_text_size(render.font_esp, "RECHAR")
            local xxx7, xxx2ASD = render.get_text_size(render.font_esp, "RECHARG")
            local xxx8, xxx2ASDX = render.get_text_size(render.font_esp, "RECHARGI")
            local xxx9, xxx2ASDXX = render.get_text_size(render.font_esp, "RECHARGIN")
            -- pos x'es

            local rmx = 23

            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx , y / 2 + 36+add_y, fst2:sub(1, dtxxz3), render.color(150, 151, 153, 255))
            alpha = animations.anim_new('basdaxsxdaz3', info.fatality.can_fastfire and 0 or 1)

            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx , y / 2 + 36+add_y, "R", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 80 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx+xxx , y / 2 + 36+add_y, "E", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 75 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx+xxx2 , y / 2 + 36+add_y, "C", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 70 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx+xxx3 , y / 2 + 36+add_y, "H", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 65 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx+xxx4 , y / 2 + 36+add_y, "A", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 60 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx+xxx5 , y / 2 + 36+add_y, "R", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 55 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx+xxx6 , y / 2 + 36+add_y, "G", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 50 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx+xxx7 , y / 2 + 36+add_y, "I", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 45 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx+xxx8 , y / 2 + 36+add_y, "N", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 45 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-rmx+xxx9 , y / 2 + 36+add_y, "G", render.color(255, 0 ,0, 255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 45 / 30))*alpha))

            alpha = animations.anim_new('basdaxsxdaz3Z', info.fatality.can_fastfire and 1 or 0)
            local xxx, xxx2 = render.get_text_size(render.font_esp, "A")
            local xxx2, xxx2XZXZ = render.get_text_size(render.font_esp, "AC")
            local xxx3, xxx2X = render.get_text_size(render.font_esp, "ACT")
            local xxx4, xxx2ZZ = render.get_text_size(render.font_esp, "ACTI")
            local xxx5, xxx242 = render.get_text_size(render.font_esp, "ACTIV")
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-8 , y / 2 + 36+add_y, "A", render.color(0,255,0,255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 80 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-8+xxx , y / 2 + 36+add_y, "C", render.color(0,255,0,255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 75 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-8+xxx2 , y / 2 + 36+add_y, "T", render.color(0,255,0,255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 70 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-8+xxx3 , y / 2 + 36+add_y, "I", render.color(0,255,0,255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 65 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-8+xxx4 , y / 2 + 36+add_y, "V", render.color(0,255,0,255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 60 / 30))*alpha))
            render.text(render.font_esp, x / 2-dtx/2+dtxxz/3.5-8+xxx5 , y / 2 + 36+add_y, "E", render.color(0,255,0,255 * math.abs(1 * math.cos(2 * math.pi * global_vars.curtime/2 + 55 / 30))*alpha))
        end
        add_y = animations.anim_new('basdasxsdxasdxda', dt and add_y+9 or add_y)

        local hsx, hsy = render.get_text_size(render.font_esp, "osaa")
        if hs then
            render.text(render.font_esp, x / 2-hsx/2 , y / 2 + 36+add_y, "osaa", render.color(255,255,255,255))
        end
        add_y = animations.anim_new('basdasxsdxasdxda2', hs and add_y+9 or add_y)

        local lcx, lcy = render.get_text_size(render.font_esp, "lc")
        if not dt and not hs then
            render.text(render.font_esp, x / 2-lcx/2 , y / 2 + 36+add_y, "lc", render.color(224, 105, 96,255))
            add_y = animations.anim_new('basdasxsdxasdxda3', not dt and not hs and add_y+9 or add_y)
        end


        -- secondary binds
    end
end

local function LerpAnim(Anims, WantPos, WantRadius)

    local PosDelta =  WantPos - Anims.position
    local RadiusDelta = WantRadius - Anims.radius

    if PosDelta:length() < 1 then
        Anims.position = WantPos
    end

    if RadiusDelta > 1 then
        Anims.radius = Anims.radius+RadiusDelta
    end

    Anims.last_frame_count = global_vars.framecount

    return Anims
end
local screen_size = {render.get_screen_size()}
local keybinds_x = gui.add_slider("keybinds_x", luapath, 0, screen_size[1], 1)
local keybinds_y = gui.add_slider("keybinds_y", luapath, 0, screen_size[2], 1)
gui.set_visible(luapath.."keybinds_x", false)
gui.set_visible(luapath.."keybinds_y", false)

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

local font = render.create_font("verdanab.ttf", 12, 5)

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

local logger = function(array, font, x, y, alpha, shift)
    local highlight = maincolor:get_color()
    local size = 0
    local step_size = 0

    for _, v in pairs(array) do -- calc total size
        size = size + render.get_text_size(font, v[1])

        if shift then size = size * (math.min(alpha, 150)/150) end
    end

    for _, v in pairs(array) do
        if v[2] then
            v[2].a = alpha
        end

        render.text(font, x + step_size, y, v[1], v[2] or render.color(255, 255, 255, alpha))

        step_size = step_size + render.get_text_size(font, v[1])
    end
end

function onhurtp(e)
    local a = e:get_int("attacker")
    local highlight = maincolor:get_color()
    local a_idx = engine.get_player_for_user_id(a)

    if a_idx ~= engine.get_local_player() then return end

    local u_name = engine.get_player_info( engine.get_player_for_user_id( e:get_int("userid") ) ).name

    shots[#shots + 1] = {
        text = {
            {"lavender.tools >> ", highlight},
            {"Registered shot in "..u_name},
            {" in the "},
            {hitgroup[e:get_int("hitgroup")]},
            {" for "},
            {("%s dmg "):format(e:get_int("dmg_health"), e:get_int("dmg_armor")),},
            {"with "},
            {e:get_string("weapon"):upper()},
        },
        a = 0,
        time = global_vars.realtime + 3
    }
end

--hitlogsconsole
function on_shot_registered(shot)
    if not hitlogs:get_bool() then return end
    if shot.manual then return end
    local p = entities.get_entity(shot.target)
    local n = p:get_player_info()
    print(string.format("lavender.tools ~ Registered shot in %s damage ~ %s hitchance ~ %s backtrack ~ %s",
    n.name, shot.server_damage, shot.hitchance,  shot.backtrack))
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

function hitpaint()
    if not hitlogs:get_bool() then return end
    local highlight = maincolor:get_color()
    local offset = 0

    for _, v in pairs(shots) do
        if v.a <= 0 and global_vars.realtime > v.time and _ == #shots then
            shots[_] = nil
        end

        v.a = global_vars.realtime < v.time and math.min(v.a + 5, 255) or math.max(v.a - 5, 0)
        adxx = 19

        if offset <= 5 then
            render.rect_filled(8, 422 + 25 * offset, 10, 422+adxx + 25 * offset, highlight)
            render.rect_filled_multicolor(10, 422 + 25 * offset, 415, 441 + 25 * offset, render.color(0,0,0,v.a-122), render.color(0,0,0,0), render.color(0,0,0,0), render.color(0,0,0,v.a-122))
            logger(v.text, font, 15, 425 + 25 * offset,v.a)
        end

        offset = offset + math.min(v.a/40, 1)
    end
end

local solus = {}

function solus.render1()

end

local fontind = render.create_font("verdanab.ttf", 12, 5)
verdana = render.font_esp
local fonts = {}

fonts.verdana = {}

fonts.verdana.default = render.create_font("verdana.ttf", 12, render.font_flag_shadow)
function onkeybinds()

    if not keybinds:get_bool() then return end

    local pos = {keybinds_x:get_int(), keybinds_y:get_int()}

    local size_offset = 0

    local binds =
    {
        gui.get_config_item("rage>aimbot>aimbot>double tap"):get_bool(),
        gui.get_config_item("rage>aimbot>aimbot>hide shot"):get_bool(),
        gui.get_config_item("rage>aimbot>ssg08>scout>override"):get_bool(), -- override dmg is taken from the scout
        gui.get_config_item("rage>aimbot>aimbot>headshot only"):get_bool(),
        gui.get_config_item("misc>movement>fake duck"):get_bool()
    }

    local binds_name =
    {
        "Double tap",
        "onshot anti-aim",
        "damage override",
        "Force Head",
        "Duck peek assist",
        "Force Head",
    }

    size_offset = 34

    animated_size_offset = animate(animated_size_offset or 0, true, size_offset, 60, true, false)

    local size = {85 + animated_size_offset, 18 + 3}
    r = maincolor:get_color().r
    g = maincolor:get_color().g
    b = maincolor:get_color().b

    local enabled = " ()"
    local text_size = render.get_text_size(verdana, enabled) + 7

    local override_active = binds[3] or binds[4] or binds[5] or binds[6] or binds[7] or binds[8]
    local other_binds_active = binds[1] or binds[2] or binds[9] or binds[10] or binds[11]

    drag(keybinds_x, keybinds_y, size[1], size[2])
    local alpha2 = math.floor(math.abs(math.sin(global_vars.realtime) * 2) * 255)

    alpha = animate(alpha or 0, gui.is_menu_open() or override_active or other_binds_active, 1, 0.5, false, true)
    local vertical, horizontal = render.get_text_size(render.font_esp, "keybinds")

    -- glow
    agan = 35
    -- top rect
    render.rect_filled(pos[1]-2, pos[2]-2, pos[1] + size[1]+4,  pos[2] + size[2]+2, render.color(0,0,0, 255*alpha))
    render.rect_filled(pos[1]-1, pos[2]-1, pos[1] + size[1]+3,  pos[2] + size[2]+1, render.color(40,40,40, 255*alpha))
    render.rect_filled(pos[1]+1, pos[2]+1, pos[1] + size[1]+1,  pos[2] + size[2]-1, render.color(0,0,0, 255*alpha))
    render.rect_filled(pos[1]+2, pos[2]+2, pos[1] + size[1],  pos[2] + size[2]-2, render.color(16,16,16, 255*alpha))
    render.rect_filled_multicolor(pos[1]+3, pos[2]+3, pos[1] + size[1]/2,  pos[2] + 4, render.color(59+agan,84+agan,96+agan, 255*alpha), render.color(99+agan,60+agan,98+agan, 255*alpha), render.color(99+agan,60+agan,98+agan, 255*alpha), render.color(59+agan,84+agan,96+agan, 255*alpha))
    render.rect_filled_multicolor(pos[1]+size[1]/2, pos[2]+3, pos[1] + size[1]-1,  pos[2] + 4, render.color(99+agan,60+agan,98+agan, 255*alpha), render.color(110+agan,115+agan,77+agan, 255*alpha), render.color(110+agan,115+agan,77+agan, 255*alpha), render.color(99+agan,60+agan,98+agan, 255*alpha))

    render.text(render.font_esp, pos[1]+9+size[2]+vertical/3, pos[2]+8, "keybinds", render.color(255,255,255, 255 * alpha))

    local bind_offset = 2
    local fsxx = gui.get_config_item("rage>anti-aim>angles>freestand")


    dt_alpha = animate(dt_alpha or 0, binds[1], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 12, pos[2] + size[2] + 2+bind_offset, binds_name[1], render.color(255, 255, 255, 255 * dt_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 3, render.color(0, 0, 0, 255 * dt_alpha))
    local dtcolor = info.fatality.can_fastfire and render.color(r,g,b,255*dt_alpha) or render.color(255,0,0,255*dt_alpha)
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 2, dtcolor)
    bind_offset = animations.anim_new('bind1', binds[1] and bind_offset + 11 or bind_offset)

    hs_alpha = animate(hs_alpha or 0, binds[2], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 12, pos[2] + size[2] + 2 + bind_offset, binds_name[2], render.color(255, 255, 255, 255 * hs_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 3, render.color(0, 0, 0, 255 * hs_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 2, render.color(r, g, b, 255 * hs_alpha))
    bind_offset = animations.anim_new('bind2', binds[2] and bind_offset + 11 or bind_offset)

    dmg_alpha = animate(dmg_alpha or 0, binds[3], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 12, pos[2] + size[2] + 2 + bind_offset, binds_name[3], render.color(255, 255, 255, 255 * dmg_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 3, render.color(0, 0, 0, 255 * dmg_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 2, render.color(r, g, b, 255 * dmg_alpha))
    bind_offset = animations.anim_new('bind3', binds[3] and bind_offset + 11 or bind_offset)

    fs_alpha = animate(fs_alpha or 0, binds[4], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 12, pos[2] + size[2] + 2 + bind_offset, binds_name[4], render.color(255, 255, 255, 255 * fs_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 3, render.color(0, 0, 0, 255 * fs_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 2, render.color(r, g, b, 255 * fs_alpha))
    bind_offset = animations.anim_new('bind4', binds[4] and bind_offset + 11 or bind_offset)

    ho_alpha = animate(ho_alpha or 0, binds[5], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 12, pos[2] + size[2] + 2 + bind_offset, binds_name[5], render.color(255, 255, 255, 255 * ho_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 3, render.color(0, 0, 0, 255 * ho_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 2, render.color(r, g, b, 255 * ho_alpha))
    bind_offset = animations.anim_new('bind5', binds[5] and bind_offset + 11 or bind_offset)

    fd_alpha = animate(fd_alpha or 0, binds[6], 1, 0.5, false, true)
    render.text(verdana, pos[1] + 12, pos[2] + size[2] + 2 + bind_offset, binds_name[6], render.color(255, 255, 255, 255 * fd_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 3, render.color(0, 0, 0, 255 * fd_alpha))
    render.circle_filled(pos[1] + 6, pos[2] + size[2] + 6+bind_offset, 2, render.color(r, g, b, 255 * fd_alpha))

end

local font = render.create_font("calibrib.ttf", 12, 0)
local font2 = render.create_font("calibrib.ttf", 12, 0)


function vesmant(e)

    local victim_index = entities.get_entity( engine.get_player_for_user_id( e:get_int( "userid" ) ) )
    local attacker_index = engine.get_player_for_user_id( e:get_int( "attacker" ) )

    if attacker_index ~= engine.get_local_player( ) then
        return
    end

    local tick = global_vars.tickcount
    local data = shot_data[ tick ]

    if shot_data[ tick ] == nil or data.impacts == nil then
        return
    end

    local hitgroups = {
        [1] = { 0, 1 },
        [2] = { 4, 5, 6 },
        [3] = { 2, 3 },
        [4] = { 13, 15, 16 },
        [5] = { 14, 17, 18 },
        [6] = { 7, 9, 11 },
        [7] = { 8, 10, 12 }
    }

    local impacts = data.impacts
    local hitboxes = hitgroups[ e:get_int( "hitgroup" ) ]

    local hit = nil
    local closest = math.huge

    for i=1, #impacts do
        local impact = impacts[ i ]

        if hitboxes ~= nil then
            for j=1, #hitboxes do
                local x, y, z = victim_index:get_hitbox_position( hitboxes[ j ] )
                local distance = math.sqrt( ( impact.x - x )^2 + ( impact.y - y )^2 + ( impact.z - z )^2 )

                if distance < closest then
                    hit = impact
                    closest = distance
                end
            end
        end
    end

    if hit == nil then
        return
    end

    shot_data[ tick ] = {
        x = hit.x,
        y = hit.y,
        z = hit.z,
        time = global_vars.curtime + 1 - 0.25,
        alpha = 255,
        damage = e:get_int( "dmg_health" ),
        kill = e:get_int( "health" ) <= 0,
        hs = e:get_int( "hitgroup" ) == 0 or e:get_int( "hitgroup" ) == 1,
        draw = true,
    }
end

function besitus(e)

    if engine.get_player_for_user_id( e:get_int( "userid" ) ) ~= engine.get_local_player( ) then
        return
    end

    local tick = global_vars.tickcount

    if shot_data[ tick ] == nil then
        shot_data[ tick ] = {
            impacts = { }
        }
    end

    local impacts = shot_data[ tick ].impacts

    if impacts == nil then
        impacts = { }
    end

    impacts[ #impacts + 1 ] = {
        x = e:get_int( "x" ),
        y = e:get_int( "y" ),
        z = e:get_int( "z" )
    }
end

function makePositive(number)
    if number < 0 then
        number = -number
    end
    return number
end

function velocity_arrows()
    local player=entities.get_entity(engine.get_local_player())
    c = maincolor:get_color()
    if player==nil then return end
    if not player:is_alive() then  return end
    if arrowstype:get_bool() then
        mod = makePositive(player:get_prop('m_vecVelocity[0]'))

        nx,ny = render.get_screen_size()
        dimensiunex = 15
        maw = mod/12
        dimensiuney = 8

        render.triangle_filled(nx/2+35+maw, ny/2, nx/2+35+dimensiunex+maw, ny/2-dimensiuney, nx/2+35+dimensiunex+maw, ny/2+dimensiuney, render.color(0,0,0,125))

        render.rect_filled(nx/2+37+dimensiunex+maw ,ny/2-dimensiuney, nx/2+39+dimensiunex+maw, ny/2+dimensiuney, render.color(c.r,c.g,c.b,255))

        render.triangle_filled(nx/2-35-maw, ny/2, nx/2-35-dimensiunex-maw, ny/2-dimensiuney, nx/2-35-dimensiunex-maw, ny/2+dimensiuney, render.color(0,0,0,125))

        render.rect_filled(nx/2-37-dimensiunex-maw ,ny/2-dimensiuney, nx/2-39-dimensiunex-maw, ny/2+dimensiuney, render.color(c.r,c.g,c.b,255))
    end

end

local verdana = render.create_font("calibrib.ttf", 12, render.font_flag_shadow)


local dt = gui.get_config_item ( "rage>aimbot>aimbot>Double Tap" )
local hs = gui.get_config_item ( "rage>aimbot>aimbot>Hide shot" )

local fl_frozen = bit.lshift ( 1, 6 )

local in_attack = bit.lshift ( 1, 0 )
local in_attack2 = bit.lshift ( 1, 11 )


local checker = 0
local defensive = false

function gambetti ( cmd )
    local me = entities.get_entity ( engine.get_local_player ( ) )
    if not me or not me:is_valid ( ) then
        return
    end

    local tickbase = me:get_prop ( "m_nTickBase" )

    defensive = math.abs ( tickbase - checker ) >= 3
    checker = math.max ( tickbase, checker or 0 )
end

function spanw ( event )
    if engine.get_player_for_user_id ( event:get_int ( 'userid' ) ) == engine.get_local_player ( ) then
        checker = 0
    end
end

function chiloti ( cmd )
    if not enabled:get_bool ( ) then return end
    if not dt:get_bool() then return end

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

    if info.fatality.lag_ticks > 1 then
        return
    end
    value = round(math.abs(1 * math.cos(2 * math.pi * (global_vars.curtime*8) )) * 180)
    value2 = math.floor(math.abs(math.sin(global_vars.realtime*7) *5) * 70)
    value3 = math.floor(math.abs(math.sin(global_vars.realtime*15) *5) * 90)
    reg = 0
    preg = 0
    xxx = utils.random_int ( 0, 6 )
    xxx2 = utils.random_int ( 0, 20 )
    reg = utils.random_int ( -value, value3+value2 )

    if xxx2 == 1 then
        preg = -33
    end
    if xxx2 == 2 then
        preg = 33
    end
    if enabledtype:get_int() == 0 then
        preg = preg
    elseif enabledtype:get_int() == 1 then
        preg = utils.random_int (-90, 90 )
    elseif enabledtype:get_int() == 2 then
        preg = 0
    end
    if defensive then
        cmd:set_view_angles ( preg, reg, 0 )
    elseif info.fatality.can_fastfire == false then
        cmd:set_view_angles (preg, reg, 0 )
    end
end




local configs = {}

configs.import = function(input)
    local protected = function()
        local clipboardP = input == nil and dec(clipboard.get()) or input
        local tbl = str_to_sub(clipboardP, "|")
        verdict:set_bool(to_boolean(tbl[1]))
        idealticks:set_bool(to_boolean(tbl[2]))
        arrowstype:set_int(tonumber(tbl[3]))
        hitmarker:set_bool(to_boolean(tbl[4]))
        verdict2:set_bool(to_boolean(tbl[5]))
        hwtype:set_int(tonumber(tbl[6]))
        verdict3:set_bool(to_boolean(tbl[7]))
        enabled:set_bool(to_boolean(tbl[8]))

        verdict4:set_int(tonumber(tbl[9]))
        options:set_int(tonumber(tbl[10]))
        amount:set_int(tonumber(tbl[11]))
        desyncfix:set_bool(to_boolean(tbl[12]))
        nebunie:set_int(tonumber(tbl[13]))
        keybinds:set_bool(to_boolean(tbl[14]))
        Wallbangx:set_bool(to_boolean(tbl[15]))
        sideinf:set_bool(to_boolean(tbl[16]))
        tt:set_bool(to_boolean(tbl[17]))
        desynctype:set_int(tonumber(tbl[18]))
        hitlogs:set_bool(to_boolean(tbl[19]))
        print("-- loaded config")

    end
    local status, message = pcall(protected)
    if not status then
        print("lavender.tools ~ imported config")
        return
    end
end

configs.default = function(input)
    local protected = function()
        local clipboardP = input == nil and dec("dHJ1ZXxmYWxzZXxmYWxzZXxmYWxzZXx0cnVlfDJ8dHJ1ZXx0cnVlfDJ8MnwzM3xmYWxzZXwwfGZhbHNlfHRydWV8dHJ1ZXx0cnVlfDB8ZmFsc2V8") or input
        local tbl = str_to_sub(clipboardP, "|")
        verdict:set_bool(to_boolean(tbl[1]))
        idealticks:set_bool(to_boolean(tbl[2]))
        arrowstype:set_int(tonumber(tbl[3]))
        hitmarker:set_bool(to_boolean(tbl[4]))
        verdict2:set_bool(to_boolean(tbl[5]))
        hwtype:set_int(tonumber(tbl[6]))
        verdict3:set_bool(to_boolean(tbl[7]))
        enabled:set_bool(to_boolean(tbl[8]))

        verdict4:set_int(tonumber(tbl[9]))
        options:set_int(tonumber(tbl[10]))
        amount:set_int(tonumber(tbl[11]))
        desyncfix:set_bool(to_boolean(tbl[12]))
        nebunie:set_int(tonumber(tbl[13]))
        keybinds:set_bool(to_boolean(tbl[14]))
        Wallbangx:set_bool(to_boolean(tbl[15]))
        sideinf:set_bool(to_boolean(tbl[16]))
        tt:set_bool(to_boolean(tbl[17]))
        desynctype:set_int(tonumber(tbl[18]))
        hitlogs:set_bool(to_boolean(tbl[19]))
        print("-- Imported config 'Default")

    end
    local status, message = pcall(protected)
    if not status then
        print("lavender.tools ~ imported config")
        return
    end
end

configs.export = function()
    local str = {
        tostring(verdict:get_bool()) .. "|",
        tostring(idealticks:get_bool()) .. "|",
        tostring(arrowstype:get_bool()) .. "|",
        tostring(hitmarker:get_bool()) .. "|",
        tostring(verdict2:get_bool()) .. "|",
        tostring(hwtype:get_int()) .. "|",
        tostring(verdict3:get_bool()) .. "|",
        tostring(enabled:get_bool()) .. "|",
        tostring(verdict4:get_int()) .. "|",
        tostring(options:get_int()) .. "|",
        tostring(amount:get_int()) .. "|",
        tostring(desyncfix:get_bool()) .. "|",
        tostring(nebunie:get_int()) .. "|",
        tostring(keybinds:get_bool()) .. "|",
        tostring(Wallbangx:get_bool()) .. "|",
        tostring(sideinf:get_bool()) .. "|",
        tostring(tt:get_bool()) .. "|",
        tostring(desynctype:get_int()) .. "|",
        tostring(hitlogs:get_bool()) .. "|",
    }

        clipboard.set(enc(table.concat(str)))
        print("lavender.tools ~ copied!")

end


separator3 = gui.add_listbox("  ", luapatha, 1, false, {"           lavender.tools ~ configs"})

local theimport = gui.add_button("Import Config", luapatha, function() configs.import() end);
local theexport = gui.add_button("Export Config", luapatha, function() configs.export() end);
local thedefaultconfig = gui.add_button("Default Config", luapatha, function() configs.default() end);
sigma = gui.add_listbox("                                   ", luapatha, 1, false, {"           Last update: 26.11.2023"})

function cratos()

    shot_data = { }
end

function on_round_start()
    cratos()
end

function on_player_spawn(event)
    spanw(event)
end

function on_bullet_impact(e)
    besitus(e)
end
function on_run_command(cmd)
    chiloti(cmd)
end

function on_player_hurt(e)

    vesmant(e)
    onhurtp(e)
end

function on_create_move()
    cremd()
    cevabun()
    stateupd()
    spindeceser()
    gambetti(cmd)
end

function on_esp_flag(index)
    return
    {
        render.esp_flag("first extra flag", render.color("#FFFFFF")),
        render.esp_flag("second extra flag", render.color("#FFFFFF")),
    }
end

function on_paint()
    menu_text()
    cross()
    sdfa()
    aspect_ratio2()
    nesx()
    onkeybinds()
    sdi()
    toya()
    velocity_arrows()
    cbp()
    hitpaint()
    chitchat()
    render.esp_flag("some flag", render.color("#FFFFFF"))
end
