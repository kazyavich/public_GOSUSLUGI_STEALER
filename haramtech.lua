local clipboard = require("clipboard")
local playerstate = 0;
local ConditionalStates = { }
local configs = {}

print ("██╗░░██╗░█████╗░██████╗░░█████╗░███╗░░░███╗░░░████████╗███████╗░█████╗░██╗░░██╗")
print ("██║░░██║██╔══██╗██╔══██╗██╔══██╗████╗░████║░░░╚══██╔══╝██╔════╝██╔══██╗██║░░██║")
print ("███████║███████║██████╔╝███████║██╔████╔██║░░░░░░██║░░░█████╗░░██║░░╚═╝███████║")
print ("██╔══██║██╔══██║██╔══██╗██╔══██║██║╚██╔╝██║░░░░░░██║░░░██╔══╝░░██║░░██╗██╔══██║")
print ("██║░░██║██║░░██║██║░░██║██║░░██║██║░╚═╝░██║██╗░░░██║░░░███████╗╚█████╔╝██║░░██║")
print ("╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░░░░╚═╝╚═╝░░░╚═╝░░░╚══════╝░╚════╝░╚═╝░░╚═╝")




engine.exec("fps_max 500")

print(" _____________________________________ ")
print("| haram.tech                          |")
print("| Version: beta                       |")
print("| Dev: def0r41k                       |")
print("|_____________________________________|")


find = gui.get_config_item
yawAdd = find("rage>anti-aim>angles>add")

checkbox = gui.add_checkbox
slider = gui.add_slider

local delay_jitter_tick = 0
local flip = false

enable_delay_jitter = checkbox("Enable", "lua>tab b")
yaw_delay = slider("Delay", "lua>tab b", 1, 20, 1)
yaw_range = slider("Delay Jitter Amount", "lua>tab b", 0, 90, 1)

local abs = function(val)
    if val < 0 then
        return -val
    end

    return val
end


    


function delay_jitter()
    if not enable_delay_jitter:get_bool() then return end
    local int_delay = yaw_delay:get_int()
    local int_range = yaw_range:get_int()
    local tickcount = global_vars.tickcount

    for i = 0, 6 do 
        if abs(delay_jitter_tick - tickcount) > int_delay then
            flip = not flip
            delay_jitter_tick = tickcount
        end

        yawAdd:set_int(flip and int_range or -int_range)
    end
end



local function gradient_text(r1, g1, b1, a1, r2, g2, b2, a2, text)
    local output = ""
    local len = #text-1
    local rinc = (r2 - r1) / len
    local ginc = (g2 - g1) / len
    local binc = (b2 - b1) / len
    local ainc = (a2 - a1) / len
    for i=1, len+1 do
        output = output .. ("\a%02x%02x%02x%02x%s"):format(r1, g1, b1, a1, text:sub(i, i))
        r1 = r1 + rinc
        g1 = g1 + ginc
        b1 = b1 + binc
        a1 = a1 + ainc
    end

    return output
end


local function vtable_bind(class, _type, index)
    local this = ffi.cast("void***", class)
    local ffitype = ffi.typeof(_type)
    return function (...)
        return ffi.cast(ffitype, this[0][index])(this, ...)
    end
end

local function vtable_thunk(_type, index)
    local ffitype = ffi.typeof(_type)
    return function (class, ...)
        local this = ffi.cast("void***", class)
        return ffi.cast(ffitype, this[0][index])(this, ...)
    end
end


ffi.cdef [[
    struct vec3_t{ float x, y, z; };
    typedef struct{
        float x;
        float y;
        float z;
    }Vector;


    void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK);

    typedef void(__fastcall*FX_ElectricSparkFn)(const Vector*,int,int,const Vector*);

    typedef int(__thiscall* get_clipboard_text_count)(void*);
	typedef void(__thiscall* set_clipboard_text)(void*, const char*, int);
	typedef void(__thiscall* get_clipboard_text)(void*, int, const char*, int);

    struct pose_parameters_t
    {
        char pad[8];
        float m_flStart;
        float m_flEnd;
        float m_flState;
    };
]]
local font2 = render.create_font("verdana.ttf", 12, 0)

 local function print_logo()
    local menuopen = gui.is_menu_open()
    local menupos_x1, menupos_y1, menupos_x2, menupos_y2 = gui.get_menu_rect()
    local textsize_w, textsize_h = render.get_text_size(font2, "Haram.tech")
    if menuopen then
        render.push_uv(0, 0, 1, 1)
        render.pop_uv()
        render.pop_uv()
        render.text(font2, menupos_x2 - textsize_w - 10, menupos_y1 - textsize_h, "Haram.tech", render.color(255, 255, 255, 255))
    end
end






local vec3_t        = ffi.typeof("struct vec3_t")
local nullchar      = ffi.cast("const char*", 0)

local VClientEntityList = utils.find_interface("client.dll", "VClientEntityList003")
local GetClientEntityFN = vtable_thunk("void*(__thiscall*)(void*, int)", 3)
local IEffects          = utils.find_interface("client.dll", "IEffects001")
local EnergySplash      = vtable_bind(IEffects, "void(__thiscall*)(void*, const struct vec3_t&, const struct vec3_t&, bool)", 7)

local pose_parameter_pattern = "55 8B EC 8B 45 08 57 8B F9 8B 4F 04 85 C9 75 15"
get_pose_parameters = ffi.cast("struct pose_parameters_t*(__thiscall* )(void*, int)", utils.find_pattern("client.dll", pose_parameter_pattern))
local IMaterialSystem   = utils.find_interface("materialsystem.dll",	"VMaterialSystem080")
local FindMaterial      = vtable_bind(IMaterialSystem, "void*(__thiscall*)(void*, const char*, const char*, bool, const char*)", 84)
local AlphaModulate     = vtable_thunk("void(__thiscall*)(void*, float)", 27)
local ColorModulate     = vtable_thunk("void(__thiscall*)(void*, float, float, float)", 28)









local AutoPeekPos = nil
local SparkMaterial = nil
local OldTickCount = -1

 local version = "beta"
--  local version = "beta"
--  local version = "release"


 


local MenuSelection = gui.add_listbox("Menu Selection", "lua>tab a", 4, false, {" >> Ragebot", " >> AntiAim", " >> Visuals", " >> Misc"})
--local Rage_list = gui.add_listbox("Rage Tab", "lua>tab a", 2, false, {"123", " 123"})
local AntiAim_list = gui.add_listbox("AntiAim Tab", "lua>tab a", 2, false, {" AntiAim ", " Custom AntiAim"})
local Misc_list = gui.add_listbox("Visuals Tab", "lua>tab a", 1, false, {" Indicators"})


-- ragebot

local resolver_custom = gui.get_config_item("rage>aimbot>aimbot>resolver mode")
local anti_nl = gui.get_config_item("rage>aimbot>aimbot>anti-exploit")
local rollsolver = gui.add_checkbox("Custom Resolver", "lua>tab b")

local better_hide = gui.add_checkbox("Better Hideshots", "lua>tab b")
local hstype = gui.add_combo("Hideshots Type", "lua>tab b", {"Favor firerate", "Favor fakelag", "Break lagcomp"})
local ragebotlogs = gui.add_checkbox("Ragebot logs", "lua>tab b")


-- visuals










local keybinds_bcolor = gui.add_checkbox("UI color", "lua>tab b")
local keybinds_color = gui.add_colorpicker("lua>tab b>ui color", true, render.color(101, 93, 132))
local watermarkd = gui.add_checkbox("Watermark", "lua>tab b")
local keybinds = gui.add_checkbox("Keybinds", "lua>tab b")
local slowdaun = gui.add_checkbox("Slow Dawn", "lua>tab b")
local indicatorsmain = gui.add_checkbox("Indicators", "lua>tab b")
local indicatorstype = gui.add_combo("Indicators | Type", "lua>tab b", {"New", "Old"})


-- others
local ideal_peek_enable = gui.add_checkbox("Ideal peek", "lua>tab b")
local trashtalk = gui.add_checkbox("Trash talk", "lua>tab b")
local sound = gui.add_checkbox("Custom Sounds", "lua>tab b")
local soundsel = gui.add_combo("Select", "lua>tab b", {"Aways", "Flick", "Stapler"})
local clantag = gui.add_checkbox("Clantag", "lua>tab b")
local clantagtype = gui.add_combo("Clantag Type", "lua>tab b", {"Old", "New"})
local aspectratiobutton = gui.add_checkbox("Aspect ratio", "lua>tab b")
local aspect_ratio_slider = gui.add_slider("[value]", "lua>tab b", 1, 200, 100)



local spark_enable, Master = gui.add_multi_combo("ElectricSpark", "lua>tab b", {"ElectricSpark from bullets","ElectricSpark Autopeek"})
local  spark_radius = gui.add_slider("Radius", "lua>tab b", 3, 10, 1)
local  spark_length = gui.add_slider("Length", "lua>tab b", 1, 10, 1)
local Color     = gui.add_colorpicker("lua>tab b>ElectricSpark", true, render.color(0, 150, 255, 255))

-- aa 


local inverter_spam = gui.add_checkbox("Invert Spammer", "lua>tab b")
gui.add_keybind("lua>tab b>Invert Spammer")
local builder_enable = gui.add_checkbox("Builder", "lua>tab b")


local tank_enable = gui.add_checkbox("Tank Anti aims", "lua>tab b")
local degree_aa = gui.add_slider("Degree", "lua>tab b", 10, 120, 30)



-- data
--local logo_wm = render.create_font("new_zelek.ttf", 13, render.font_flag_shadow)
local nextfont = render.create_font("calibri.ttf", 23, render.font_flag_shadow)
local nextfont2 = render.create_font("calibri.ttf", 13, render.font_flag_shadow)
local nextfont3 = render.create_font("calibrib.ttf", 23, render.font_flag_shadow)
local fontdmg = render.create_font("verdana.ttf", 13, render.font_flag_shadow)
local pixel = render.font_esp
local calibri11 = render.create_font("calibri.ttf", 11, render.font_flag_outline)
local calibri13 = render.create_font("calibri.ttf", 13, render.font_flag_shadow)
local verdana = render.create_font("verdana.ttf", 13, render.font_flag_outline)
local verdana42 = render.create_font("verdana.ttf", 42, 10)
local tahoma = render.create_font("tahoma.ttf", 13, render.font_flag_shadow)
local verdana2 = render.create_font("verdana.ttf", 12, 0)
local logo = render.create_font("verdana.ttf", 45, render.font_flag_outline)
--local font_zelek1 = render.create_font("new zelek.ttf", 16, render.font_flag_shadow)

-- vars


local x, y = render.get_screen_size()
local hs = gui.get_config_item("Rage>Aimbot>Aimbot>Hide shot")
local limit = gui.get_config_item("Rage>Anti-Aim>Fakelag>Limit")
local cache = {
    backup = limit:get_int(),
    override = false,
}

local first = {
    "харамчик забустил опять",
    "1",
    "ohhh daddy",
    "ахх харамчик",
    "1",
	"как же я тя выебал",}
local old_time = 0;
local animation = { 

    "",
    "%",
    "h&%",
    "ha%#",
    "har#(",
    "hara(-",
    "haram-^",
    "haram.^@",
    "haram.t@%",
    "haram.te%",
    "haram.tec",
    "haram.tech",
    "haram.tec%",
    "haram.te@%",
    "haram.t^@",
    "haram.-^",
    "haram(-",
    "hara(",
    "har%#",
    "ha&%",
    "h%",
    "",
  
}

local animation2 = { 

    " ➙➙➙➙➙ ", 
    " ➘➙➙➙➙ ",
    " h➚➙➙➙ ",
    " ha➘➙➙ ",
    " har➚➙ ",
    " hara➘ ",
    " haram ",
    " haram➙ ",
    " haram➙➙ ",
    " haram➙➙➙ ",
    " haram.t➙➙ ",
    " haram.te➙ ",
    " haram.tech ",
    " haram.tech ",
    " haram.tec| ",
    " haram.te| ",
    " haram.t ",
    " haram.| ",
    " haram| ",
    " hara| ",
    " har| ",
    " ha| ",
    " ➘ ",
    " ➚ ",
    " ➙ ",
    " ➙➙ ",
    " ➙➙➙ ",
    " ➙➙➙➙ ",
    " ➙➙➙➙➙ ",

  
}
 


local function get_muzzle_pos()
    local lp = entities.get_entity(engine.get_local_player())
    if not lp or not lp:is_alive() then return end
    local lp_address = get_client_entity(engine.get_local_player())
    local weapon = lp:get_weapon()
    if not weapon then return end
    local weapon_address = get_client_entity(weapon:get_index())
    local viewmodel_handle = lp:get_prop("m_hViewModel[0]")
    local viewmodel = entities.get_entity_from_handle(viewmodel_handle)
    local viewmodel_address = get_client_entity(viewmodel:get_index())
    local viewmodel_vtbl = ffi.cast(interface_type, viewmodel_address)[0]
    local weapon_vtbl = ffi.cast(interface_type, weapon_address)[0]
    local get_viewmodel_attachment_fn = ffi.cast("c_entity_get_attachment_t", viewmodel_vtbl[84])
    local get_muzzle_attachment_index_fn = ffi.cast("c_weapon_get_muzzle_attachment_index_first_person_t", weapon_vtbl[468])
    local vec3 = ffi.new("Vector")
    local muzzle_attachment_index = get_muzzle_attachment_index_fn(weapon_address, viewmodel_address)
    local state = get_viewmodel_attachment_fn(viewmodel_address, muzzle_attachment_index, vec3)
    local vec3_pos = math.vec3(vec3.x, vec3.y, vec3.z)
    return vec3_pos
end

function guiscc()
    local tab = MenuSelection:get_int()
    --local rage_tab = Rage_list:get_int()
    local misc_tab = Misc_list:get_int()
    local indicatorsenb = indicatorsmain:get_bool()
    local sounden = sound:get_bool()
    local aspectratiobuttonx = aspectratiobutton:get_bool()
    local spark =  spark_enable:get_bool()
    local BH = better_hide:get_bool()
    -- ragebot
    --gui.set_visible("lua>tab a>Rage Tab", tab == 1)


gui.set_visible("lua>tab b>Enable", tab == 1)
gui.set_visible("lua>tab b>Delay", tab == 1)
gui.set_visible("lua>tab b>Delay Jitter Amount", tab == 1)

    gui.set_visible("lua>tab b>Custom Resolver", tab == 0)
    gui.set_visible("lua>tab b>Better Hideshots", tab == 0)
    gui.set_visible("lua>tab b>Hideshots Type", tab == 0 and BH)
    gui.set_visible("lua>tab b>Ideal peek", tab == 0)
    gui.set_visible("lua>tab b>Ragebot logs", tab == 0)

    -- antiaims


    -- visuals
    gui.set_visible("lua>tab a>Visuals Tab", tab == 2)
    gui.set_visible("lua>tab b>ui color", tab == 2 and misc_tab == 0)
    gui.set_visible("lua>tab b>Watermark", tab == 2 and misc_tab == 0)
    gui.set_visible("lua>tab b>keybinds", tab == 2 and misc_tab == 0)
    gui.set_visible("lua>tab b>Slow Dawn", tab == 2 and misc_tab == 0)
    gui.set_visible("lua>tab b>indicators", tab == 2 and misc_tab == 0)
    gui.set_visible("lua>tab b>indicators | type", tab == 2 and indicatorsenb and misc_tab == 0)




    -- others
    gui.set_visible("lua>tab b>select", tab == 3 and sounden)
    gui.set_visible("lua>tab b>custom sounds", tab == 3)
    gui.set_visible("lua>tab b>Trash talk", tab == 3)
    gui.set_visible("lua>tab b>Clantag", tab == 3)
    gui.set_visible("lua>tab b>Clantag Type", tab == 3 and clantag:get_bool())
    gui.set_visible("lua>tab b>Aspect ratio", tab == 3)
    gui.set_visible("lua>tab b>[value]", tab == 3 and aspectratiobuttonx)
    gui.set_visible("lua>tab b>ElectricSpark", tab == 3)
    gui.set_visible("lua>tab b>Radius", tab == 3 and spark)
    gui.set_visible("lua>tab b>Length", tab == 3 and spark)




end

function clantagfc()
    local ctype = clantagtype:get_int()
    if clantag:get_bool() then
        local defaultct = gui.get_config_item("misc>various>clan tag")
        local realtime = math.floor((global_vars.realtime) * 1.5)
        if old_time ~= realtime then
            if ctype == 0 then
                utils.set_clan_tag(animation[realtime % #animation+1]);
            end
            if ctype == 1 then
                utils.set_clan_tag(animation2[realtime % #animation2+1]);
            end

        old_time = realtime;
        defaultct:set_bool(false);
        end
    end
end

function on_player_death(event)
    if trashtalk:get_bool() then
    local lp = engine.get_local_player();
    local attacker = engine.get_player_for_user_id(event:get_int('attacker'));
    local userid = engine.get_player_for_user_id(event:get_int('userid'));
    local userInfo = engine.get_player_info(userid);
        if attacker == lp and userid ~= lp then
            engine.exec("say " .. first[utils.random_int(1, #first)] .. "")
        end
    else
    end
end



local function main(shot)
    if shot.manual then return end
        local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}
        local p = entities.get_entity(shot.target)
        local n = p:get_player_info()
        local hitgroup = shot.server_hitgroup
        local clienthitgroup = shot.client_hitgroup
        local health = p:get_prop("m_iHealth")
    
            if ragebotlogs:get_bool() then
                if shot.server_damage > 0 then
                    print( "[haram] Hit " , n.name ," for ",shot.server_damage, " hp " ,"in ", hitgroup_names[hitgroup + 1]," - hitchance " , math.floor(shot.hitchance),  " [bt=", math.floor(shot.backtrack),"]")
                else
                    print( "[haram] Missed " , n.name ," ", hitgroup_names[shot.client_hitgroup + 1]," due to ", shot.result)
                end
            end
    
    end






    






local doubletap =  gui.get_config_item("rage>aimbot>aimbot>double tap")
local hideshots =  gui.get_config_item("rage>aimbot>aimbot>hide shot")
local fakelag   =  gui.get_config_item("rage>anti-aim>fakelag>limit")

local cache = {
    backup = fakelag:get_int(),
    override = false,
  }
  
  function RB()
  
  if better_hide:get_bool() then
    if hstype:get_int() == 0 and not doubletap:get_bool() then
      if hideshots:get_bool() then
        fakelag:set_int(1)
          cache.override = true
      else
          if cache.override then
            fakelag:set_int(cache.backup)
          cache.override = false
          else
          cache.backup = fakelag:get_int()
          end
        end
      end
    end
  
    if better_hide:get_bool() then
      if hstype:get_int() == 1 and not doubletap:get_bool() then
        if hideshots:get_bool() then
            fakelag:set_int(9)
            cache.override = true
        else
            if cache.override then
            fakelag:set_int(cache.backup)
            cache.override = false
            else
            cache.backup = fakelag:get_int()
            end
          end
        end
      end
  
  if better_hide:get_bool() then
      if hstype:get_int() == 2 and not doubletap:get_bool() then
          if hideshots:get_bool() then
           fakelag:set_int(global_vars.tickcount % 32 >= 4 and 14 or 1)
              cache.override = true
          else
              if cache.override then
                fakelag:set_int(cache.backup)
              cache.override = false
              else
              cache.backup = fakelag:get_int()
              end
          end
      end
  end
  end




-- screen size
local screen_size = {render.get_screen_size()}

-- fonts
local verdana = render.create_font("verdana.ttf", 12, 0)

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
    local aspect_ratio = aspect_ratio_slider:get_int() * 0.01
    aspect_ratio = 2 - aspect_ratio
    set_aspect_ratio(aspect_ratio)
end

function watermark()
    if watermarkd:get_bool() then 
        local player = entities.get_entity(engine.get_local_player())
        if player == nil then return end
        local latency  = math.floor((utils.get_rtt() or 0)*1000)
        local Time = utils.get_time()
        local realtime = string.format("%02d:%02d:%02d", Time.hour, Time.min, Time.sec)
        --local water_logo = render.text(logo_wm, 0,0, "Haram", render.color(255,255,255,255)) font_zelek1
        --local user = player:get_player_info(name)
        local watermarkText = "haram.tech ·  [" .. version.."] · ".. "1.6" .. ' · ' .. latency .. ' ms · '.. realtime;
        
            w, h = render.get_text_size(verdana, watermarkText);
            local watermarkWidth = w;
            x, y = render.get_screen_size();
            x, y = x - watermarkWidth - 5, y * 0.010;

            local pos = {x/2 + 807, 10}
            local size = {249 , 10}
            alpha_anim = math.floor(math.abs(math.sin(global_vars.realtime) * 4) * 6)
            for i = 1, 10 do
                render.rect_filled_rounded(pos[1] - i + watermarkWidth/ 6 + 15, pos[2] - i, pos[1] + size[1] + i + 40, pos[2] + size[2] + i+ 10, render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b, (alpha_anim - (2 * i)) * 1), 10)
            end
        
            render.rect_filled_rounded(x - 4, y - 3, x + watermarkWidth + 2, y + h + 4, keybinds_color:get_color(), 5, render.all);
            render.rect_filled_rounded(x - 2, y - 1, x + watermarkWidth, y + h + 2 , render.color(17, 17, 19, 255), 4, render.all);
            render.text(verdana, x - 2.5, y + 1, watermarkText, render.color(255, 255, 255));

            --render.text(font_zelek1, x + watermarkWidth - 191, y, "A", render.color(255, 255, 255));
            --render.text(font_zelek1, x + watermarkWidth - 180, y, "N", keybinds_color:get_color());

end
end







font = render.font_esp

local function animation(check, name, value, speed) 
    if check then 
        return name + (value - name) * global_vars.frametime * speed / 1.5
    else 
        return name - (value + name) * global_vars.frametime * speed / 1.5
        
    end
end

local offset_scope = 0
local dton = 0
local alpha = 0

function indicators()

    local lp = entities.get_entity(engine.get_local_player())
    if not lp then return end
    if not lp:is_alive() then return end
    local scoped = lp:get_prop("m_bIsScoped")
    offset_scope = animation(scoped, offset_scope, 25, 10)
    
    local function Clamp(Value, Min, Max)
        return Value < Min and Min or (Value > Max and Max or Value)
    end
        
        local alpha2 = math.floor(math.abs(math.sin(global_vars.realtime) * 2) * 255)
        local lp = entities.get_entity(engine.get_local_player())
        if not lp then return end
        if not lp:is_alive() then return end
        local screen_width, screen_height = render.get_screen_size( )
        local x = screen_width / 2
        local y = screen_height / 2
        local ay = 0
    
    
    if indicatorsmain:get_bool() and indicatorstype:get_int() == 0 then
        
        local alpha2 = math.floor(math.abs(math.sin(global_vars.realtime) * 2) * 255)
        local lp = entities.get_entity(engine.get_local_player())
        if not lp then return end
        if not lp:is_alive() then return end
        local local_player = entities.get_entity(engine.get_local_player())
        local ay = 0
        local desync_percentage = Clamp(math.abs(local_player:get_prop("m_flPoseParameter", 11) * 120 - 60.5), 0.5 / 60, 60) / 56
        local w, h = 35, 3
        local screen_width, screen_height = render.get_screen_size( )
        local x = screen_width / 2
        local y = screen_height / 2
        local textx , texty = render.get_text_size(font, "haram") 
        local color1 = render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b, 255)
        local color2 = render.color(keybinds_color:get_color().r - 70, keybinds_color:get_color().g - 90, keybinds_color:get_color().b - 70, 185)
    
        local text =  "Haram.tech°"
        local textx, texty = render.get_text_size(pixel, text)
        local alpha3 = math.floor(math.abs(math.sin(global_vars.realtime) * 2) * 255)

        local textx , texty = render.get_text_size(font, "Fatality") 
        render.text(font, x+ offset_scope - textx + 45  , y + 25 + texty  , "Fatality", render.color(218, 96, 96, alpha3))
    
        render.text(font, x+offset_scope + 4 , y + 15 + texty, "Haram.tech°", render.color("#FFFFFF"))
        local dt = gui.get_config_item("Rage>Aimbot>Aimbot>Double tap"):get_bool()

        local alpha2 = math.floor(math.abs(math.sin(global_vars.realtime) * 4) * 255)


        if not dt then
            local textx , texty = render.get_text_size(font, "DT") 
            render.text(font, x+ offset_scope - textx + 14  , y + 35 + texty  , "DT", render.color(255,255,255,150))
        elseif dt then

            local textx , texty = render.get_text_size(font, "DT") 
            render.text(font, x+ offset_scope - textx + 14  , y + 35 + texty  , "DT", render.color(161, 255, 151,alpha2))
        end

        local dmg = gui.get_config_item("rage>aimbot>ssg08>scout>override"):get_bool()
        if not dmg then
            local textx , texty = render.get_text_size(font, "DMG") 
            render.text(font, x+ offset_scope - textx + 56  , y + 35 + texty , "DMG", render.color(255,255,255,150))
        elseif dmg then

            local textx , texty = render.get_text_size(font, "DMG") 
            render.text(font, x+ offset_scope - textx + 56  , y + 35 + texty  , "DMG", render.color(255,255,255,alpha2))
        end

        local hs = gui.get_config_item("Rage>Aimbot>Aimbot>Hide shot"):get_bool()
        if not hs then
            local textx , texty = render.get_text_size(font, "HS") 
            render.text(font, x+ offset_scope - textx + 26  , y + 35 + texty  , "HS", render.color(255,255,255,150))
        elseif hs then

            local textx , texty = render.get_text_size(font, "HS") 
            render.text(font, x+ offset_scope - textx + 26 , y + 35 + texty  , "HS", render.color(217,107,45,alpha2))
        end

        local freestand =  gui.get_config_item("rage>anti-aim>angles>freestand"):get_bool()
        if not freestand then
            local textx , texty = render.get_text_size(font, "FS") 
            render.text(font, x+ offset_scope - textx + 38  , y + 35 + texty  , "FS", render.color(255,255,255,150))
        elseif freestand then

            local textx , texty = render.get_text_size(font, "FS") 
            render.text(font, x+ offset_scope - textx + 38 , y+ 35 + texty  , "FS", render.color(255,255,255,alpha2))
        end

        local manual =  gui.get_config_item("rage>anti-aim>angles>antiaim override"):get_bool() 

        local left =  gui.get_config_item("rage>anti-aim>angles>left"):get_bool()
            if left and manual then

            local textx , texty = render.get_text_size(font, "LEFT") 
            render.text(font, x+ offset_scope - textx + 66  , y + 25 + texty  , "LEFT", render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b,  alpha3))
        end

        local right =  gui.get_config_item("rage>anti-aim>angles>right"):get_bool()
            if right and manual then

            local textx , texty = render.get_text_size(font, "RIGHT") 
            render.text(font, x+ offset_scope - textx + 70  , y + 25 + texty  , "RIGHT", render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b,  alpha3))

        end
    end
end

local auto_peek  = gui.get_config_item("misc>movement>peek assist")

function spark_autopeek()
    
    if not Master:get_bool() then
        AutoPeekPos = nil
        return
    end

 
    if OldTickCount == global_vars.tickcount then
        return
    else
        OldTickCount = global_vars.tickcount
    end

    local LocalPlayer = entities.get_entity(engine.get_local_player())
    if not auto_peek:get_bool() or not LocalPlayer then
        AutoPeekPos = nil
        return
    end

    if not AutoPeekPos then
        if bit.band(LocalPlayer:get_prop("m_fFlags"), 1) == 1 then
            AutoPeekPos = math.vec3(LocalPlayer:get_prop("m_vecOrigin"))
        else
            return
        end
    end


    if not SparkMaterial then
        SparkMaterial = FindMaterial("effects/spark", nullchar, true, nullchar)
    else
        local ColorTable = Color:get_color()

        AlphaModulate(SparkMaterial, ColorTable.a / 255)
        ColorModulate(SparkMaterial, ColorTable.r / 255, ColorTable.g / 255, ColorTable.b / 255)
    end


    local Angle = (global_vars.realtime * 6) % 360
    EnergySplash(vec3_t((AutoPeekPos + math.vec3(math.cos(Angle), math.sin(Angle), 0) * 30):unpack()), vec3_t(), false)
end





local FX_ElectricSpark = ffi.cast("FX_ElectricSparkFn",utils.find_pattern("client.dll","55 8B EC 83 EC 3C 53 8B D9 89 55 FC 8B 0D ?? ?? ?? ?? 56 57"))

local vec3 = ffi.new("Vector")
local QAngle = ffi.new("Vector")


QAngle.x = 0
QAngle.y = 0
QAngle.z = 0

function on_bullet_impact(event)
    local a =  spark_radius:get_int()
    local b =  spark_length:get_int()
    if not vec3.x or not vec3.y or not vec3.z then return end
    local lp = entities.get_entity(engine.get_local_player())
    if not lp then return end
    local userid = lp:get_player_info().user_id
    if   spark_enable:get_bool() then
 
        if userid ~= event:get_int("userid") then return end
    end
    vec3.x = event:get_float("x")
    vec3.y = event:get_float("y")
    vec3.z = event:get_float("z")

    if   spark_enable:get_bool() == true then
        FX_ElectricSpark(vec3,a,b,QAngle) 
    end


end

function ID()

    local lp = entities.get_entity(engine.get_local_player())
    if not lp then return end
    if not lp:is_alive() then return end
    local scoped = lp:get_prop("m_bIsScoped")
    offset_scope = animation(scoped, offset_scope, 25, 10)
    
        
        local alpha2 = math.floor(math.abs(math.sin(global_vars.realtime) * 2) * 255)
        local lp = entities.get_entity(engine.get_local_player())
        if not lp then return end
        if not lp:is_alive() then return end
        local screen_width, screen_height = render.get_screen_size( )
        local x = screen_width / 2
        local y = screen_height / 2
        local ay = 0
    
    
    if indicatorsmain:get_bool() and indicatorstype:get_int() == 1 then
        
        
        local lp = entities.get_entity(engine.get_local_player())
        if not lp then return end
        if not lp:is_alive() then return end
        local local_player = entities.get_entity(engine.get_local_player())
        local desync_percentage = math.floor(math.abs(local_player:get_prop("m_flPoseParameter", 11) * 120 - 60.5), 0.5 / 60, 60) / 40
        local ay = 0
        local w, h = 0, 3
        local screen_width, screen_height = render.get_screen_size( )
        local x = screen_width / 2
        local y = screen_height / 2
        local color1 = render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b,  255 * 1)
        local color2 = render.color(keybinds_color:get_color().r - 70, keybinds_color:get_color().g - 90, keybinds_color:get_color().b - 70, 185)

        local text =  "Haram.tech°"
        local text2 = version
        local textx, texty = render.get_text_size(pixel, text)
        local textx2, texty2 = render.get_text_size(pixel, text2)
    
        render.text(pixel, x+offset_scope + 5, y + 16, text, render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b, 255))
        render.text(pixel, x+offset_scope + 15, y + 30, text2, render.color(71, 71, 71, alpha2))
    
        render.rect_filled(x + 0 +offset_scope + 5, y + 24, x+offset_scope + 35 + 11, y + 25 + h + 1, render.color("#000000"))
        render.rect_filled(x+offset_scope + 6, y + 25, x+offset_scope + desync_percentage, y + 25 + h, render.color(255, 255, 255, 255))
    
    end
    end

-- screen size
local screen_size = {render.get_screen_size()}

-- fonts
local verdana = render.create_font("verdana.ttf", 12, 0)

-- menu
local keybinds_x = gui.add_slider("keybinds_x", "lua>tab a", 0, screen_size[1], 1)
local keybinds_y = gui.add_slider("keybinds_y", "lua>tab a", 0, screen_size[2], 1)
gui.set_visible("lua>tab a>keybinds_x", false)
gui.set_visible("lua>tab a>keybinds_y", false)

local slow_x = gui.add_slider("slow_x", "lua>tab a", 0, screen_size[1], 1)
local slow_y = gui.add_slider("slow_y", "lua>tab a", 0, screen_size[2], 1)
gui.set_visible("lua>tab a>slow_x", false)
gui.set_visible("lua>tab a>slow_y", false)


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
function on_keybinds()

    if not keybinds:get_bool() then return end

    local pos = {keybinds_x:get_int(), keybinds_y:get_int()}

    local size_offset = 0

    local binds =
    {
        gui.get_config_item("rage>aimbot>aimbot>double tap"):get_bool(),
        gui.get_config_item("rage>aimbot>aimbot>hide shot"):get_bool(),
        gui.get_config_item("rage>aimbot>ssg08>scout>override"):get_bool(), 
        gui.get_config_item("rage>aimbot>aimbot>headshot only"):get_bool(),
        gui.get_config_item("misc>movement>fake duck"):get_bool()
    }

    local binds_name = 
    {
        "Doubletap",
        "Hideshots",
        "Min. Damage",
        "HeadShot Only",
        "Fake duck",
        "HeadShot Only",
    }

    if not binds[4] then
        if not binds[5] then
            if not binds[3] then
                if not binds[1] then
                    if not binds[6] then
                        if not binds[2] then
                            size_offset = 0
                        else
                            size_offset = 38
                        end
                    else
                        size_offset = 40
                    end
                else
                    size_offset = 41
                end
            else
                size_offset = 54
            end
        else
            size_offset = 63
        end
    else
        size_offset = 70
    end

    animated_size_offset = animate(animated_size_offset or 0, true, size_offset, 60, true, false)

    local size = {100 + animated_size_offset, 22}

    local enabled = "[enabled]"
    local text_size = render.get_text_size(calibri13, enabled) + 7
    local toh1 = "·"
    local toh_text2 = render.get_text_size(calibri13, toh1) + 7

    local override_active = binds[3] or binds[4] or binds[5] or binds[6] or binds[7] or binds[8]
    local other_binds_active = binds[1] or binds[2] or binds[9] or binds[10] or binds[11]

    drag(keybinds_x, keybinds_y, size[1], size[2])

    alpha = animate(alpha or 0, gui.is_menu_open() or override_active or other_binds_active, 1, 0.5, false, true)
    alpha_anim = math.floor(math.abs(math.sin(global_vars.realtime) * 4) * 6)

    -- glow
    for i = 1, 10 do
        render.rect_filled_rounded(pos[1] - i, pos[2] - i, pos[1] + size[1] + i, pos[2] + size[2] + i, render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b, (alpha_anim - (2 * i)) * alpha), 10)
    end


    render.rect_filled_rounded(pos[1] , pos[2] , pos[1] + size[1] , pos[2] + 22,render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b,  255 * alpha), 5)
    render.rect_filled_rounded(pos[1] + 2, pos[2] + 2, pos[1] + size[1] - 2, pos[2] + 20, render.color(17, 17, 19, 255 * alpha), 4)
    render.text(calibri13, pos[1] + size[1] / 2 - render.get_text_size(calibri13, "Keybinds") / 2 - 1, pos[2] + 5, "Keybinds", render.color(255, 255, 255, 255 * alpha))


    local bind_offset = 0
    dt_alpha = animate(dt_alpha or 0, binds[1], 1, 0.5, false, true)
    render.text(calibri13, pos[1] + 6, pos[2] + size[2] + 2, binds_name[1], render.color(255, 255, 255, 255 * dt_alpha))
    render.text(calibri13, pos[1] + size[1] - text_size, pos[2] + size[2] + 2, enabled, render.color(137, 134, 134, 255 * dt_alpha))

    if binds[1] then
        bind_offset = bind_offset + 11
    end

    hs_alpha = animate(hs_alpha or 0, binds[2], 1, 0.5, false, true)
    render.text(calibri13, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[2], render.color(255, 255, 255, 255 * hs_alpha))
    render.text(calibri13, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(103, 103, 103, 255 * hs_alpha))

    if binds[2] then
        bind_offset = bind_offset + 11
    end

    dmg_alpha = animate(dmg_alpha or 0, binds[3], 1, 0.5, false, true)
    render.text(calibri13, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[3], render.color(255, 255, 255, 255 * dmg_alpha))
    render.text(calibri13, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(103, 103, 103, 255 * dmg_alpha))
    if binds[3] then
        bind_offset = bind_offset + 11
    end

    fs_alpha = animate(fs_alpha or 0, binds[4], 1, 0.5, false, true)
    render.text(calibri13, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[4], render.color(255, 255, 255, 255 * fs_alpha))
    render.text(calibri13, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(103, 103, 103, 255 * fs_alpha))
    if binds[4] then
        bind_offset = bind_offset + 11
    end

    ho_alpha = animate(ho_alpha or 0, binds[5], 1, 0.5, false, true)
    render.text(calibri13, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[5], render.color(255, 255, 255, 255 * ho_alpha))
    render.text(calibri13, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(103, 103, 103, 255 * ho_alpha))
    if binds[5] then
        bind_offset = bind_offset + 11
    end

    fd_alpha = animate(fd_alpha or 0, binds[6], 1, 0.5, false, true)
    render.text(calibri13, pos[1] + 6, pos[2] + size[2] + 2 + bind_offset, binds_name[6], render.color(255, 255, 255, 255 * fd_alpha))
    render.text(calibri13, pos[1] + size[1] - text_size, pos[2] + size[2] + 2 + bind_offset, enabled, render.color(103, 103, 103, 255 * fd_alpha))

end

function on_slow()

    if not slowdaun:get_bool() then return end

    local pos = {slow_x:get_int(), slow_y:get_int()}
    local size = {100 + 100, 22}
    local player=entities.get_entity(engine.get_local_player())
    if player==nil then return end
    if not player:is_alive() or slowdaun:get_bool()==false then  return end
    local mod=player:get_prop("m_flVelocityModifier")
    mod=mod*100
    if mod==100 and not gui.is_menu_open() then return end



    drag(slow_x, slow_y, size[1], size[2])

    --alpha = animate(alpha or 0, gui.is_menu_open() or override_active or other_binds_active, 1, 0.5, false, true)
    alpha_anim = math.floor(math.abs(math.sin(global_vars.realtime) * 4) * 6)
    alpha_anim1 = math.floor(math.abs(math.sin(global_vars.realtime) * 7) * 255)

    -- glow
    for i = 1, 10 do
        render.rect_filled_rounded(pos[1] - i, pos[2] - i, pos[1] + size[1] + i, pos[2] + size[2] + i, render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b, (alpha_anim - (2 * i)) ), 10)
    end


    render.rect_filled_rounded(pos[1] , pos[2] , pos[1] + size[1], pos[2] + 22,render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b,  255 ), 5)
    render.rect_filled_rounded(pos[1] + 2, pos[2] + 2, pos[1] + size[1]  - 2, pos[2] + 20, render.color(17, 17, 19, 255 ), 4)
    render.rect_filled_rounded(pos[1] + 4, pos[2] + 4, pos[1] + size[1] + mod - 104, pos[2] + 18, render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b,  255 ), 4)
    render.triangle_filled(pos[1] - 30, pos[2]- 15, pos[1] -6 , pos[2]+ 32, pos[1] -54, pos[2]+32, render.color(17, 17, 19, 255 )) 
    render.triangle_filled(pos[1] - 30, pos[2]- 10, pos[1] -10 , pos[2]+ 30, pos[1] -50, pos[2]+30, render.color(keybinds_color:get_color().r, keybinds_color:get_color().g, keybinds_color:get_color().b,  255)) 
    render.text(verdana42, pos[1] - 37 , pos[2]- 10, "!", render.color(17, 17, 19, alpha_anim1 ))
    render.text(calibri13, pos[1] + 20 , pos[2]+ 5, "Slow down: "..tostring(math.floor(mod)).."%" , render.color(255, 255, 255, 255 ))

 

end





autopeek = gui.get_config_item("Misc>Movement>Peek Assist")
doubletap = gui.get_config_item("Rage>Aimbot>Aimbot>Double tap")
freestand = gui.get_config_item("Rage>Anti-Aim>Angles>Freestand")
local powrot = (0)
savedd = doubletap:get_bool()
savedf = doubletap:get_bool()
function ideal_peek()
	if ideal_peek_enable:get_bool() then 
		if autopeek:get_int() == 1 and getsave == (1) then
			savedd = doubletap:get_bool()
			savedf = freestand:get_bool()
			getsave = (0)
			end
       if autopeek:get_int() == 1 then
			doubletap:set_int(1)
			freestand:set_int(1)
			powrot = (1)
	   end
	   if autopeek:get_int() == 0 and powrot == (1) then 
		doubletap:set_bool(savedd)
		freestand:set_bool(savedf)
		powrot = (0)
		getsave = (1)
		end
	end
end

function on_shot_registered(shot)
    local sounds = soundsel:get_int()
    if sounds == 0 and sound:get_bool() then
        if shot.server_damage <= 0 then return end
        engine.exec("play aways.wav")
    end
    if sounds == 1 and sound:get_bool() then
        if shot.server_damage <= 0 then return end
        engine.exec("play flick.wav")
    end
    if sounds == 2 and sound:get_bool() then
        if shot.server_damage <= 0 then return end
        engine.exec("play stapler.wav")
    end
end










local fake_amount = gui.get_config_item("Rage>Anti-Aim>Desync>Fake amount")
local yawadd = gui.get_config_item("Rage>Anti-Aim>Angles>Yaw add");
local yawaddamount = gui.get_config_item("Rage>Anti-Aim>Angles>Add");
local spin = gui.get_config_item("Rage>Anti-Aim>Angles>Spin");
local jitter = gui.get_config_item("Rage>Anti-Aim>Angles>Jitter");
local spinrange = gui.get_config_item("Rage>Anti-Aim>Angles>Spin range");
local spinspeed = gui.get_config_item("Rage>Anti-Aim>Angles>Spin speed");
local jitterrandom = gui.get_config_item("Rage>Anti-Aim>Angles>Random");
local jitterrange = gui.get_config_item("Rage>Anti-Aim>Angles>Jitter Range");
local desync = gui.get_config_item("Rage>Anti-Aim>Desync>Fake amount");
local compAngle = gui.get_config_item("Rage>Anti-Aim>Desync>Compensate angle");
local freestandFake = gui.get_config_item("Rage>Anti-Aim>Desync>Freestand fake");
local flipJittFake = gui.get_config_item("Rage>Anti-Aim>Desync>Flip fake with jitter");
local fsfake = gui.get_config_item("rage>anti-aim>desync>freestand fake");



local var = {

    player_states = {"[Standing]", "[Moving]", "[Slow motion]", "[Air]", "[Air Duck]", "[Crouch]"};
    states_tab = {"[S]", "[M]", "[S]", "[A]", "[A+D]", "[C]"};
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








ConditionalStates[0] = {
	player_state = gui.add_combo("[Conditions]", "lua>tab b", var.player_states);
}

for i=1, 6 do

	ConditionalStates[i] = {
        ---Anti-Aim
        yawadd = gui.add_checkbox("Yaw add" .. var.player_states[i] , "lua>tab b");
        yawaddamount = gui.add_slider("Add " .. var.player_states[i], "lua>tab b", -180, 180, 1);
        spin = gui.add_checkbox("Spin " .. var.player_states[i], "lua>tab b");
        spinrange = gui.add_slider("Spin range " .. var.player_states[i], "lua>tab b", 0, 360, 1);
        spinspeed = gui.add_slider("Spin speed " .. var.player_states[i], "lua>tab b", 0, 360, 1);
        jitter = gui.add_checkbox("Jitter " .. var.player_states[i], "lua>tab b");
        jittertype = gui.add_combo("Jitter Type " .. var.player_states[i], "lua>tab b", {"Center", "Offset", "Random"});
        jitterrange = gui.add_slider("Jitter range " .. var.player_states[i], "lua>tab b", 0, 360, 1);
        ---Desync
        desynctype = gui.add_combo("Desync Type " .. var.player_states[i], "lua>tab b", {"Static", "Jitter", "Random"});
        desync = gui.add_slider("Desync " .. var.player_states[i], "lua>tab b", -100, 100, 1);
        compAngle = gui.add_slider("Comp " .. var.player_states[i], "lua>tab b", 0, 100, 1);
        flipJittFake = gui.add_checkbox("Flip fake " .. var.player_states[i], "lua>tab b");

    };
end


local cImport = gui.add_button("Import settings", "lua>tab a", function() configs.import() end);
local cExport = gui.add_button("Export settings", "lua>tab a", function() configs.export() end);


function MenuElements()
    for i=1, 6 do
        local tab = MenuSelection:get_int()
        local state = ConditionalStates[0].player_state:get_int() + 1
        local yawAddCheck = ConditionalStates[i].yawadd:get_bool()
        local spinCheck = ConditionalStates[i].spin:get_bool()
        local jitterCheck = ConditionalStates[i].jitter:get_bool()
        local antiaim_tab = AntiAim_list:get_int()
        local aa_enable= builder_enable:get_bool()
        local tank_e = tank_enable:get_bool()





        --antiaim


        gui.set_visible("lua>tab a>AntiAim Tab", tab == 1);
        gui.set_visible("lua>tab b>Builder", tab == 1  and antiaim_tab == 0 );
        gui.set_visible("lua>tab b>Invert Spammer", tab == 1  and antiaim_tab == 1);
        gui.set_visible("lua>tab b>Tank Anti aims", tab == 1  and antiaim_tab == 1);
        gui.set_visible("lua>tab b>Degree", tab == 1  and antiaim_tab == 1 and tank_e)
        gui.set_visible("lua>tab b>[Conditions]", tab == 1 and antiaim_tab == 0 and aa_enable);
        gui.set_visible("lua>tab b>Yaw add" .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i);
        gui.set_visible("lua>tab b>Add " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i and yawAddCheck);
        gui.set_visible("lua>tab b>Spin " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i);
        gui.set_visible("lua>tab b>Spin range " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i and spinCheck);
        gui.set_visible("lua>tab b>Spin speed " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i and spinCheck);
        gui.set_visible("lua>tab b>Jitter " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i);
        gui.set_visible("lua>tab b>Jitter Type " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i and jitterCheck);
        gui.set_visible("lua>tab b>Jitter range " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i and jitterCheck);

        --desync
        gui.set_visible("lua>tab b>Desync Type " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i);
        gui.set_visible("lua>tab b>Desync " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i);
        gui.set_visible("lua>tab b>Comp " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i);
        gui.set_visible("lua>tab b>Flip fake " .. var.player_states[i], tab == 1 and antiaim_tab == 0  and aa_enable and state == i);

        --config system
        gui.set_visible("lua>tab a>Import settings", tab == 1 and antiaim_tab == 0 and aa_enable);
        gui.set_visible("lua>tab a>Export settings", tab == 1 and antiaim_tab == 0 and aa_enable);



    end
end

-- cache fakelag limit


function UpdateStateandAA()
    if builder_enable:get_bool() then
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


    yawadd:set_bool(ConditionalStates[playerstate].yawadd:get_bool());
    if ConditionalStates[playerstate].jittertype:get_int() == 1 then
        yawaddamount:set_int((ConditionalStates[playerstate].yawaddamount:get_int()) + (global_vars.tickcount % 4 >= 2 and 0 or ConditionalStates[playerstate].jitterrange:get_int()))
    else
        yawaddamount:set_int(ConditionalStates[playerstate].yawaddamount:get_int());
    end
    spin:set_bool(ConditionalStates[playerstate].spin:get_bool());
    jitter:set_bool(ConditionalStates[playerstate].jitter:get_bool());
    spinrange:set_int(ConditionalStates[playerstate].spinrange:get_int());
    spinspeed:set_int(ConditionalStates[playerstate].spinspeed:get_int());
    jitterrandom:set_bool(ConditionalStates[playerstate].jittertype:get_int() == 2);
    --jitter types
    if ConditionalStates[playerstate].jittertype:get_int() == 0 or ConditionalStates[playerstate].jittertype:get_int() == 2 then
            jitterrange:set_int(ConditionalStates[playerstate].jitterrange:get_int());
        else
            jitterrange:set_int(0);
        end
    --desync
    if ConditionalStates[playerstate].desync:get_int() == 60 and ConditionalStates[playerstate].desynctype:get_int() == 0 then
        desync:set_int((ConditionalStates[playerstate].desync:get_int() * 1.666666667) - 2);
        else if ConditionalStates[playerstate].desync:get_int() == -60 and ConditionalStates[playerstate].desynctype:get_int() == 0 then
            desync:set_int((ConditionalStates[playerstate].desync:get_int() * 1.666666667) + 2);
              else if ConditionalStates[playerstate].desynctype:get_int() == 0 then 
                desync:set_int(ConditionalStates[playerstate].desync:get_int() * 1.666666667);
                    else if ConditionalStates[playerstate].desynctype:get_int() == 1 and 0 >= ConditionalStates[playerstate].desync:get_int() then 
                        desync:set_int(global_vars.tickcount % 4 >= 2 and -18 * 1.666666667 or ConditionalStates[playerstate].desync:get_int() * 1.666666667 + 2);
                            else if ConditionalStates[playerstate].desynctype:get_int() == 1 and ConditionalStates[playerstate].desync:get_int() >= 0 then 
                                desync:set_int(global_vars.tickcount % 4 >= 2 and 18 * 1.666666667 or ConditionalStates[playerstate].desync:get_int() * 1.666666667 - 2);
                                    else if ConditionalStates[playerstate].desynctype:get_int() == 2 and ConditionalStates[playerstate].desync:get_int() >= 0 then 
                                        desync:set_int(utils.random_int(0, ConditionalStates[playerstate].desync:get_int() * 1.666666667));
                                            else if ConditionalStates[playerstate].desynctype:get_int() == 2 and ConditionalStates[playerstate].desync:get_int() <= 0 then 
                                                desync:set_int(utils.random_int(ConditionalStates[playerstate].desync:get_int() * 1.666666667, 0));
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
    compAngle:set_int(ConditionalStates[playerstate].compAngle:get_int());
    flipJittFake:set_bool(ConditionalStates[playerstate].flipJittFake:get_bool());
end
end
--end of getting AA states and setting valeus
--start of static freestand
local AAfreestand = gui.get_config_item("Rage>Anti-Aim>Angles>Freestand")
local add = gui.get_config_item("Rage>Anti-Aim>Angles>Add")
local jitter = gui.get_config_item("Rage>Anti-Aim>Angles>Jitter Range")
local attargets = gui.get_config_item("Rage>Anti-Aim>Angles>At fov target")
local flipfake = gui.get_config_item("Rage>Anti-Aim>Desync>Flip fake with jitter")
local compfreestand = gui.get_config_item("Rage>Anti-Aim>Desync>Compensate Angle")
local fakefreestand = gui.get_config_item("Rage>Anti-Aim>Desync>Fake Amount")
local freestandfake  = gui.get_config_item("Rage>Anti-Aim>Desync>Freestand Fake")
local fsfake = gui.get_config_item("rage>anti-aim>desync>freestand fake")
local add_backup = add:get_int()
local jitter_backup = jitter:get_int()
local attargets_backup = attargets:get_bool()
local compfreestand_backup = compfreestand:get_int()
local fakefreestand_backup = fakefreestand:get_int()
local freestandfake_backup = freestandfake:get_int()
local restore_aa = false



--end of fakeflick

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
        ConditionalStates[2].yawadd:set_bool(to_boolean(tbl[13]))
        ConditionalStates[2].yawaddamount:set_int(tonumber(tbl[14]))
        ConditionalStates[2].spin:set_bool(to_boolean(tbl[15]))
        ConditionalStates[2].spinrange:set_int(tonumber(tbl[17]))
        ConditionalStates[2].spinspeed:set_int(tonumber(tbl[18]))
        ConditionalStates[2].jitter:set_bool(to_boolean(tbl[19]))
        ConditionalStates[2].jittertype:set_int(tonumber(tbl[21]))
        ConditionalStates[2].jitterrange:set_int(tonumber(tbl[21]))
        ConditionalStates[2].desynctype:set_int(tonumber(tbl[22]))
        ConditionalStates[2].desync:set_int(tonumber(tbl[23]))
        ConditionalStates[2].compAngle:set_int(tonumber(tbl[24]))
        ConditionalStates[2].flipJittFake:set_bool(to_boolean(tbl[25]))
        ConditionalStates[3].yawadd:set_bool(to_boolean(tbl[26]))
        ConditionalStates[3].yawaddamount:set_int(tonumber(tbl[27]))
        ConditionalStates[3].spin:set_bool(to_boolean(tbl[28]))
        ConditionalStates[3].spinrange:set_int(tonumber(tbl[29]))
        ConditionalStates[3].spinspeed:set_int(tonumber(tbl[30]))
        ConditionalStates[3].jitter:set_bool(to_boolean(tbl[31]))
        ConditionalStates[3].jittertype:set_int(tonumber(tbl[32]))
        ConditionalStates[3].jitterrange:set_int(tonumber(tbl[33]))
        ConditionalStates[3].desynctype:set_int(tonumber(tbl[34]))
        ConditionalStates[3].desync:set_int(tonumber(tbl[35]))
        ConditionalStates[3].compAngle:set_int(tonumber(tbl[36]))
        ConditionalStates[3].flipJittFake:set_bool(to_boolean(tbl[37]))
        ConditionalStates[4].yawadd:set_bool(to_boolean(tbl[38]))
        ConditionalStates[4].yawaddamount:set_int(tonumber(tbl[39]))
        ConditionalStates[4].spin:set_bool(to_boolean(tbl[40]))
        ConditionalStates[4].spinrange:set_int(tonumber(tbl[41]))
        ConditionalStates[4].spinspeed:set_int(tonumber(tbl[42]))
        ConditionalStates[4].jitter:set_bool(to_boolean(tbl[43]))
        ConditionalStates[4].jittertype:set_int(tonumber(tbl[44]))
        ConditionalStates[4].jitterrange:set_int(tonumber(tbl[45]))
        ConditionalStates[4].desync:set_int(tonumber(tbl[46]))
        ConditionalStates[4].desynctype:set_int(tonumber(tbl[47]))
        ConditionalStates[4].compAngle:set_int(tonumber(tbl[48]))
        ConditionalStates[4].flipJittFake:set_bool(to_boolean(tbl[49]))
        ConditionalStates[5].yawadd:set_bool(to_boolean(tbl[50]))
        ConditionalStates[5].yawaddamount:set_int(tonumber(tbl[51]))
        ConditionalStates[5].spin:set_bool(to_boolean(tbl[52]))
        ConditionalStates[5].spinrange:set_int(tonumber(tbl[53]))
        ConditionalStates[5].spinspeed:set_int(tonumber(tbl[54]))
        ConditionalStates[5].jitter:set_bool(to_boolean(tbl[55]))
        ConditionalStates[5].jittertype:set_int(tonumber(tbl[56]))
        ConditionalStates[5].jitterrange:set_int(tonumber(tbl[57]))
        ConditionalStates[5].desynctype:set_int(tonumber(tbl[58]))
        ConditionalStates[5].desync:set_int(tonumber(tbl[59]))
        ConditionalStates[5].compAngle:set_int(tonumber(tbl[60]))
        ConditionalStates[5].flipJittFake:set_bool(to_boolean(tbl[61]))
        ConditionalStates[6].yawadd:set_bool(to_boolean(tbl[62]))
        ConditionalStates[6].yawaddamount:set_int(tonumber(tbl[63]))
        ConditionalStates[6].spin:set_bool(to_boolean(tbl[64]))
        ConditionalStates[6].spinrange:set_int(tonumber(tbl[65]))
        ConditionalStates[6].spinspeed:set_int(tonumber(tbl[66]))
        ConditionalStates[6].jitter:set_bool(to_boolean(tbl[67]))
        ConditionalStates[6].jittertype:set_int(tonumber(tbl[68]))
        ConditionalStates[6].jitterrange:set_int(tonumber(tbl[69]))
        ConditionalStates[6].desynctype:set_int(tonumber(tbl[71]))
        ConditionalStates[6].desync:set_int(tonumber(tbl[72]))
        ConditionalStates[6].compAngle:set_int(tonumber(tbl[73]))
        ConditionalStates[6].flipJittFake:set_bool(to_boolean(tbl[74]))


        print("Config loaded")
        
    end
    local status, message = pcall(protected)
    if not status then
        print("Loaded!")
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
    }
    
        clipboard.set(enc(table.concat(str)))
        print("config was copied")

end

-- local tank_enable = gui.add_checkbox("Tank Anti aims", "lua>tab b")
-- local degree_aa = gui.add_slider("Degree", "lua>tab b", 10, 120, 30)


function iverter()
    if engine.is_in_game() == false then return 
    end

    if inverter_spam:get_bool() == true then
        fake_amount:set_int(-fake_amount:get_int())
    else
        fake_amount:set_int(fake_amount:get_int())
    end
end


function tank_anti()
    if engine.is_in_game() == false then return 
    end


    if tank_enable:get_bool() == true then
        yawaddamount:set_int(-yawaddamount:get_int())
        fake_amount:set_int(-fake_amount:get_int())
    else
        yawaddamount:set_int(yawaddamount:get_int())
        fake_amount:set_int(fake_amount:get_int())
    end
end







function resolvermode()
        if rollsolver:get_bool() then 
        resolver_custom:set_int(0) 
    else 
        if not rollsolver:get_bool() then 
        resolver_custom:set_int(1) 
        end
    end
end

function on_shot_registered(shot)
    main(shot)
end

function on_shutdown()
    utils.set_clan_tag("");

end

function on_create_move()
    
    UpdateStateandAA()
end

function on_create_move()
    delay_jitter()
end


function on_paint()
    iverter()
    print_logo()
    watermark()
    ideal_peek()
    guiscc()
    on_keybinds()
    on_slow()
    clantagfc()
    MenuElements()
    aspect_ratio2()
    indicators()
    ID()
    RB()
    tank_anti()
    spark_autopeek()
    resolvermode()
end