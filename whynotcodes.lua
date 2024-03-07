--#credits @ensixten deobfuscating

player = entities.get_entity(engine.get_local_player());
Find = gui.get_config_item;
Checkbox = gui.add_checkbox;
Slider = gui.add_slider;
Combo = gui.add_combo;
MultiCombo = gui.add_multi_combo;
AddKeybind = gui.add_keybind;
CPicker = gui.add_colorpicker;
AddButton = gui.add_button;
clipboard = require("clipboard");
playerstate = 0;
ConditionalStates = {};
cb = gui.add_checkbox;
sl = gui.add_slider;
dd = gui.add_combo;
mdd = gui.add_multi_combo;
btn = gui.add_button;
txt = gui.add_textbox;
lb = gui.add_listbox;
kb = gui.add_keybind;
cp = gui.add_colorpicker;
find = gui.get_config_item;
Find = gui.get_config_item;
sPath = "Rage>Aimbot>Aimbot";
iMisses = 0;
iResolverMode = gui.get_config_item("rage>aimbot>aimbot>resolver mode");
bForceSafety = gui.get_config_item("rage>aimbot>aimbot>force extra safety");
iResolverCache = iResolverMode:get_int();
bSafetyCache = bForceSafety:get_bool();
Rage = {bSwitch=gui.add_checkbox("Enable Max Misses", sPath),bNotify=gui.add_checkbox("Max Misses Notification", sPath),iSlider=gui.add_slider("Max Misses amount", sPath, 1, 8, 2),iAction=gui.add_combo("Max Misses Action", sPath, {"Roll Resolver","Force Baim","Force Safety","All"})};
function on_shot_registered(shot_info)
	if Rage.bSwitch:get_bool() then
		if (shot_info.result == "resolve") then
			iMisses = iMisses + 1;
		end
		iSlider = Rage.iSlider:get_int();
		iAction = Rage.iAction:get_int();
		if (iMisses >= iSlider) then
			if Rage.bNotify:get_bool() then
				utils.error_print("Max Misses Activated ( Missed:" .. iMisses .. " )");
			end
			if (iAction == 0) then
				iResolverMode:set_int(0);
			elseif (iAction == 1) then
			elseif (iAction == 2) then
				bForceSafety:set_bool(true);
			elseif (iAction == 3) then
				iResolverMode:set_int(0);
				bForceSafety:set_bool(true);
			end
		end
	end
end
function ResetMisses()
	if Rage.bSwitch:get_bool() then
		iMisses = 0;
		iResolverMode:set_int(iResolverCache);
		bForceSafety:set_bool(bSafetyCache);
	end
end
function on_player_death(event)
	if not Rage.bSwitch:get_bool() then
		return;
	end
	pLocalUserID = (engine.get_player_info(engine.get_local_player())).user_id;
	if ((pLocalUserID == event:get_int("attacker")) or (pLocalUserID == event:get_int("userid"))) then
		ResetMisses();
	end
end
function on_round_poststart(event)
	ResetMisses();
end
function on_round_prestart(event)
	ResetMisses();
end
function on_round_start(event)
	ResetMisses();
end
function on_round_end(event)
	ResetMisses();
end
function on_shutdown()
	ResetMisses();
end
menuFind = gui.get_config_item;
menuACombo = gui.add_combo;
menuACheck = gui.add_checkbox;
menuASlider = gui.add_slider;
menuAListbox = gui.add_listbox;
menuAMCombo = gui.add_multi_combo;
sVis = gui.set_visible;
menuABind = gui.add_keybind;
menuACPicker = gui.add_colorpicker;
menuAButton = gui.add_button;
first = {"xD","._.",":3","<33333",">w<","xD","◘_◘","ಠoಠ","(⊙ヮ⊙)","(✿｡✿)","⊙﹏⊙","◉◡◉","◉_◉","⊙︿⊙","ಠ▃ಠ","( ･_･)♡","( ﾟヮﾟ)","(¬‿¬)","(╥_╥)","(◕‿◕)","(ʘᗩʘ')","(✪㉨✪)"};
MN611 = gui.add_listbox("            ", "Misc>Various", 1, false, {"Misc"});
tag = cb("ClanTag", "Misc>Various");
gui.add_keybind("Misc>Various>ClanTag");
gui.add_checkbox("Auto accept Invite", "Misc>Various");
gui.add_keybind("Misc>Various>Auto accept Invite");
tt = gui.add_checkbox("trashtalk", "Misc>Various");
gui.add_keybind("Misc>Various>trashtalk");
chat = cvar.cl_chatfilters;
voice_chat = cvar.voice_enable;
Muted = gui.add_checkbox("Mute-Players", "Misc>Various");
gui.add_keybind("Misc>Various>Mute-Players");
Checkbox = gui.add_checkbox("Invert-Spammer", "Misc>Various");
gui.add_keybind("Misc>Various>Invert-Spammer");
cl_sidespeed = cvar.cl_sidespeed;
cl_forwardspeed = cvar.cl_forwardspeed;
cl_backspeed = cvar.cl_backspeed;
Key = gui.add_checkbox("Auto-Smoke", "Misc>Various");
gui.add_keybind("Misc>Various>Auto-Smoke");
Pressed = 0;
ticks = 78;
SmokeIdx = 128;
function on_run_command(cmd)
	if (Pressed == 0) then
		if not Key:get_bool() then
			return;
		elseif Key:get_bool() then
			Pressed = 1;
		end
	end
	Lp = entities.get_entity(engine.get_local_player());
	Weapon = Lp:get_weapon();
	WeaponIdx = Weapon:get_index();
	if ((WeaponIdx == SmokeIdx) and (Pressed == 1)) then
		Pressed = ticks - 1;
	end
	if (Pressed == 1) then
		engine.exec("use weapon_smokegrenade");
	elseif (Pressed == ticks) then
		engine.exec("+attack2");
	elseif (Pressed == (ticks + 1)) then
		engine.exec("-attack2");
	elseif (Pressed == (ticks + 10)) then
		cmd:set_view_angles(90, 90, 0);
	elseif (Pressed > (ticks + 10)) then
		Key:set_bool(false);
		Pressed = 0;
		return;
	end
	Pressed = Pressed + 1;
end
anim_breaker_combo = {menuACombo("Cheat Spoofer", "Misc>Various", {"Off","Promirdial","Skeet","Nl","Pandora","Weawe","Onetap","RaweTrip","Legendware","Morion","Airflow","BackDoor","LuckyCharms","Nixware"})};
edgeyaw = gui.add_checkbox("EdgeYaw", "Misc>Various");
gui.add_keybind("Misc>Various>EdgeYaw");
slider = gui.add_slider("Accuracy", "Misc>Various", 0, 100, 1);
slider2 = gui.add_slider("range", "Misc>Various", 0, 100, 1);
layers = 2;
range = slider2:get_int();
min = range - 5;
position = 0;
colour2 = render.color(255, 255, 255, 255);
wantedangle = 0;
skybox_bool_checkbox = gui.add_checkbox("Load skybox", "Misc>Various");
gui.add_keybind("Misc>Various>Load skybox");
skybox_value_textbox = gui.add_textbox("Skybox name", "Misc>Various");
skybox = skybox_value_textbox:get_string();
slowwalk_box = gui.add_checkbox("Slow Walk", "Misc>Various");
slowwalk_slider = gui.add_slider("Speed", "Misc>Various", 1, 100, 1);
gui.add_keybind("Misc>Various>Slow Walk");
menuFind = gui.get_config_item;
menuACombo = gui.add_combo;
menuACheck = gui.add_checkbox;
menuASlider = gui.add_slider;
menuAListbox = gui.add_listbox;
menuAMCombo = gui.add_multi_combo;
sVis = gui.set_visible;
menuABind = gui.add_keybind;
menuACPicker = gui.add_colorpicker;
menuAButton = gui.add_button;
function lowdist(start, ends, val)
	local dist = start:dist(ends);
	if ((val == position) and (dist > min)) then
		min = range - 5;
	end
	if ((dist < min) or (dist == min)) then
		colour2 = render.color(255, 0, 0, 255);
		min = dist;
		position = val;
		wantedangle = start:calc_angle(ends);
		return true;
	else
		colour2 = render.color(255, 255, 255, 255);
	end
end
function on_run_command(cmd)
	view_angles = cmd:get_view_angles();
	if ((wantedangle ~= 0) and (min < (range - 5)) and (edgeyaw:get_bool() == true)) then
		cmd:set_view_angles(view_angles, wantedangle.y, 0);
	end
end
v0, v1 = gui.add_multi_combo("Resolvers", "Rage>Aimbot>Aimbot", {"C.R.A-Resolver","C.R.A-Prediction"});
tt = gui.add_checkbox("Ax-Fix (Beta)", "Rage>Aimbot>AimBot");
in_use = false;
keycode = 69;
last_tick = global_vars.tickcount;
function set_speed(new_speed)
	if ((cl_sidespeed:get_int() == 450) and (new_speed == 450)) then
		return;
	end
	cl_sidespeed:set_float(new_speed);
	cl_forwardspeed:set_float(new_speed);
	cl_backspeed:set_float(new_speed);
end
function CT()
	defaultct = find("misc>various>clan tag");
	can_reset = false;
	if tag:get_bool() then
		realtime = math.floor(global_vars.curtime * 1.74685567);
		if (old_time ~= realtime) then
			utils.set_clan_tag(animations[(realtime % #animations) + 1]);
			old_time = realtime;
			defaultct:set_bool(false);
		end
	else
		realtime = math.floor(global_vars.curtime * 0);
		if (old_time ~= realtime) then
			old_time = realtime;
			defaultct:set_bool(false);
			utils.set_clan_tag("");
		end
	end
end
animations = {"","W","Wh","Why","WhyN","WhyNo","WhyNot","WhyNot.c","WhyNot.co","WhyNot.cod","WhyNot.code","WhyNot.codes",""};
cvar.cl_disablefreezecam:set_float(1);
cvar.cl_disablehtmlmotd:set_float(1);
cvar.r_dynamic:set_float(0);
cvar.r_3dsky:set_float(0);
cvar.r_shadows:set_float(0);
cvar.cl_csm_static_prop_shadows:set_float(0);
cvar.cl_csm_world_shadows:set_float(0);
cvar.cl_foot_contact_shadows:set_float(0);
cvar.cl_csm_viewmodel_shadows:set_float(0);
cvar.cl_csm_rope_shadows:set_float(0);
cvar.cl_csm_sprite_shadows:set_float(0);
cvar.cl_freezecampanel_position_dynamic:set_float(0);
cvar.cl_freezecameffects_showholiday:set_float(0);
cvar.cl_showhelp:set_float(0);
cvar.cl_autohelp:set_float(0);
cvar.mat_postprocess_enable:set_float(0);
cvar.fog_enable_water_fog:set_float(0);
cvar.gameinstructor_enable:set_float(0);
cvar.cl_csm_world_shadows_in_viewmodelcascade:set_float(0);
cvar.cl_disable_ragdolls:set_float(0);
print("WhyNot.codes  ");
print("Bild: Alpha");
print("Version 1.7");
print("Owner lua Ram1n#8847");
player = entities.get_entity(engine.get_local_player());
Find = gui.get_config_item;
Checkbox = gui.add_checkbox;
Slider = gui.add_slider;
Combo = gui.add_combo;
MultiCombo = gui.add_multi_combo;
AddKeybind = gui.add_keybind;
CPicker = gui.add_colorpicker;
AddButton = gui.add_button;
clipboard = require("clipboard");
playerstate = 0;
ConditionalStates = {};
cb = gui.add_checkbox;
sl = gui.add_slider;
dd = gui.add_combo;
mdd = gui.add_multi_combo;
btn = gui.add_button;
txt = gui.add_textbox;
lb = gui.add_listbox;
kb = gui.add_keybind;
cp = gui.add_colorpicker;
find = gui.get_config_item;
Find = gui.get_config_item;
menuFind = gui.get_config_item;
menuACombo = gui.add_combo;
menuACheck = gui.add_checkbox;
menuASlider = gui.add_slider;
menuAListbox = gui.add_listbox;
menuAMCombo = gui.add_multi_combo;
sVis = gui.set_visible;
menuABind = gui.add_keybind;
menuACPicker = gui.add_colorpicker;
menuAButton = gui.add_button;
font = render.create_font_gdi("Smallest pixel-7", 11, render.font_flag_outline);
font2 = render.create_font("verdanab.ttf", 35);
font3 = render.create_font("verdanab.ttf", 10);
local menu = require("oop_menu");
table.find = function(t, value)
	for _, v in pairs(t) do
		if (v == value) then
			return true;
		end
	end
	return false;
end;
math.clamp = function(v, min, max)
	return ((v < min) and min) or ((v > max) and max) or v;
end;
math.calc_fov = function(Start, End, Angle)
	local Direction = (End - Start):normalize();
	local Forward, Right, Up = math.angle_vectors(Angle);
	return math.max(math.deg(math.acos(Forward:dot(Direction))), 0);
end;
local function SetAllVisible(t, v)
	for _, element in pairs(t) do
		if (element and element.set_visible) then
			element:set_visible(v);
		end
	end
end
local function MenuElementName(p, n)
	return string.format("[%s] %s", p, n);
end
local var = {player_states={"Global","Standing","Moving","Slow motion","Air","Crouch"}};
local References = {aaYaw=menu.get_reference("Rage>Anti-Aim>Angles>Yaw"),aaYawadd=menu.get_reference("Rage>Anti-Aim>Angles>Yaw add"),Pitch=menu.get_reference("rage>anti-aim>angles>pitch"),Yaw=menu.get_reference("rage>anti-aim>angles>yaw"),YawAdd=menu.get_reference("rage>anti-aim>angles>yaw add"),YawAddValue=menu.get_reference("rage>anti-aim>angles>add"),FreeStand=menu.get_reference("rage>anti-aim>angles>freestand"),AtFOVTarget=menu.get_reference("rage>anti-aim>angles>at fov target"),Spin=menu.get_reference("rage>anti-aim>angles>spin"),SpinRange=menu.get_reference("rage>anti-aim>angles>spin range"),SpinSpeed=menu.get_reference("rage>anti-aim>angles>spin speed"),Jitter=menu.get_reference("rage>anti-aim>angles>jitter"),RandomJitter=menu.get_reference("rage>anti-aim>angles>random"),JitterRange=menu.get_reference("rage>anti-aim>angles>jitter range"),AntiAimOverride=menu.get_reference("rage>anti-aim>angles>antiaim override"),Back=menu.get_reference("rage>anti-aim>angles>back"),Left=menu.get_reference("rage>anti-aim>angles>left"),Right=menu.get_reference("rage>anti-aim>angles>right"),Fake=menu.get_reference("rage>anti-aim>desync>fake"),FakeAmount=menu.get_reference("rage>anti-aim>desync>fake amount"),CompensateAngle=menu.get_reference("rage>anti-aim>desync>compensate angle"),FreestandFake=menu.get_reference("rage>anti-aim>desync>freestand fake"),FlipFakeWithJitter=menu.get_reference("rage>anti-aim>desync>flip fake with jitter"),LegSlide=menu.get_reference("rage>anti-aim>desync>leg slide"),RollLean=menu.get_reference("rage>anti-aim>desync>roll lean"),LeanAmount=menu.get_reference("rage>anti-aim>desync>lean amount"),EnsureLean=menu.get_reference("rage>anti-aim>desync>ensure lean"),FlipLeanWithJitter=menu.get_reference("rage>anti-aim>desync>flip lean with jitter")};
SetAllVisible(References, false);
local ExtraRefs = {FakeDuck=menu.get_reference("misc>movement>fake duck"),Slide=menu.get_reference("misc>movement>slide")};
local AAStates = {"General","Standing","Moving","Slow walk","Crouching","Fake duck","Accelerating","In air","In air crouch","In air knife","Taser","Enemy missed","Repit","Throw","When fired","When-hit","When-Changing-Weapons","Fake","Real"};
local AAStateCombo = menu.add_combo("Anti-Aim Bilder", "rage>anti-aim>angles", AAStates);
local AAStateMenuElements = {};
for i, State in pairs(AAStates) do
	local function FormatStateName(n)
		return MenuElementName(State, n);
	end
	local NewTable = {OverrideGeneralConfig=((i ~= 1) and menu.add_checkbox(FormatStateName(((State:len() >= 19) and "Override general") or "Override general config"), "rage>anti-aim>angles")),CrouchOnly=((State == "In air knife") and menu.add_checkbox(FormatStateName("Crouching only"), "rage>anti-aim>angles")),FovThreshhold=((State == "Enemy missed") and menu.add_slider(FormatStateName("Fov threshhold"), "rage>anti-aim>angles", 0, 180, 1)),HoldTime=((State == "Enemy missed") and menu.add_slider(FormatStateName("Hold time (MS)"), "rage>anti-aim>angles", 1, 3000, 1)),Pitch=menu.add_combo(FormatStateName("Pitch"), "rage>anti-aim>angles", References.Pitch:get_combo_items()),Yaw=menu.add_combo(FormatStateName("Yaw"), "rage>anti-aim>angles", References.Yaw:get_combo_items()),YawAdd=menu.add_checkbox(FormatStateName("Yaw add"), "rage>anti-aim>angles"),YawAddValue=menu.add_slider(FormatStateName("Yaws"), "rage>anti-aim>angles", -360, 360, 1),AtFOVTarget=menu.add_checkbox(FormatStateName("At fov target"), "rage>anti-aim>angles"),Spin=menu.add_checkbox(FormatStateName("Spin"), "rage>anti-aim>angles"),SpinRange=menu.add_slider(FormatStateName("Range"), "rage>anti-aim>angles", -360, 360, 1),SpinSpeed=menu.add_slider(FormatStateName("Speed"), "rage>anti-aim>angles", -360, 360, 1),Jitter=menu.add_checkbox(FormatStateName("Jitter"), "rage>anti-aim>angles"),RandomJitter=menu.add_checkbox(FormatStateName("Random jitter"), "rage>anti-aim>angles"),JitterRange=menu.add_slider(FormatStateName("Range "), "rage>anti-aim>angles", -360, 360, 1),JitterFreeze=menu.add_checkbox(FormatStateName("Jitter freeze"), "rage>anti-aim>angles"),HoldChance=menu.add_slider(FormatStateName("Freeze chance"), "rage>anti-aim>angles", 0, 100, 1),Jitter7=menu.add_checkbox(FormatStateName("Avoid-Overlap"), "rage>anti-aim>angles"),Jitter11=menu.add_slider(FormatStateName("Avoid"), "rage>anti-aim>angles", 0, 100, 1),Jitter8=menu.add_checkbox(FormatStateName("Anti-Brutte"), "rage>anti-aim>angles"),Jitter14=menu.add_checkbox(FormatStateName("On-hit"), "rage>anti-aim>angles"),Jitter15=menu.add_checkbox(FormatStateName("On-miss"), "rage>anti-aim>angles"),Jitter28=menu.add_checkbox(FormatStateName("Fake"), "rage>anti-aim>angles"),Jitter16=menu.add_slider(FormatStateName("Fake 1"), "rage>anti-aim>angles", 0, 100, 1),Jitter17=menu.add_slider(FormatStateName("Fake 2"), "rage>anti-aim>angles", 0, 100, 1),Jitter18=menu.add_slider(FormatStateName("Fake 3"), "rage>anti-aim>angles", 0, 100, 1),Jitter19=menu.add_slider(FormatStateName("Fake 4"), "rage>anti-aim>angles", 0, 100, 1),Jitter20=menu.add_slider(FormatStateName("Fake 5"), "rage>anti-aim>angles", 0, 100, 1),Jitter21=menu.add_slider(FormatStateName("Fake 6"), "rage>anti-aim>angles", 0, 100, 1),Jitter22=menu.add_slider(FormatStateName("Fake 7"), "rage>anti-aim>angles", 0, 100, 1),Jitter23=menu.add_slider(FormatStateName("Fake 8"), "rage>anti-aim>angles", 0, 100, 1),Jitter24=menu.add_slider(FormatStateName("Fake 9"), "rage>anti-aim>angles", 0, 100, 1),Jitter25=menu.add_slider(FormatStateName("Fake 10"), "rage>anti-aim>angles", 0, 100, 1),Jitter26=menu.add_slider(FormatStateName("Fake 11"), "rage>anti-aim>angles", 0, 100, 1),Jitter27=menu.add_slider(FormatStateName("Fake 12"), "rage>anti-aim>angles", 0, 100, 1),Jitter29=menu.add_checkbox(FormatStateName("Angles"), "rage>anti-aim>angles"),Jitter30=menu.add_slider(FormatStateName("Desync 1"), "rage>anti-aim>desync", -200, 200, 1),Jitter31=menu.add_slider(FormatStateName("Desync 2"), "rage>anti-aim>desync", -200, 200, 1),Jitter32=menu.add_slider(FormatStateName("Desync 3"), "rage>anti-aim>desync", -200, 200, 1),Jitter33=menu.add_slider(FormatStateName("Desync 4"), "rage>anti-aim>desync", -200, 200, 1),Jitter34=menu.add_slider(FormatStateName("Desync 5"), "rage>anti-aim>desync", -200, 200, 1),Jitter35=menu.add_slider(FormatStateName("Desync 6"), "rage>anti-aim>desync", -200, 200, 1),Jitter36=menu.add_slider(FormatStateName("Desync 7"), "rage>anti-aim>desync", -200, 200, 1),Jitter37=menu.add_slider(FormatStateName("Desync 8"), "rage>anti-aim>desync", -200, 200, 1),Jitter38=menu.add_slider(FormatStateName("Desync 9"), "rage>anti-aim>desync", -200, 200, 1),Jitter39=menu.add_slider(FormatStateName("Desync 10"), "rage>anti-aim>desync", -200, 200, 1),Jitter40=menu.add_checkbox(FormatStateName("Disable fakelag on DT"), "rage>anti-aim>angles"),Jitter41=menu.add_checkbox(FormatStateName("Disable Fakelag on HS"), "rage>anti-aim>angles"),Jitter10=menu.add_checkbox(FormatStateName("Delay-ticks"), "rage>anti-aim>angles"),Jitter13=menu.add_slider(FormatStateName("Milliseconds"), "rage>anti-aim>angles", 100, 1500, 1),Jitter2=menu.add_checkbox(FormatStateName("Delay-Tick_Auto"), "rage>anti-aim>angles"),Jitter3=menu.add_checkbox(FormatStateName("Delay-Tick_AWP"), "rage>anti-aim>angles"),Jitter4=menu.add_checkbox(FormatStateName("Delay-Tick_Heavy-Pistols"), "rage>anti-aim>angles"),Jitter5=menu.add_checkbox(FormatStateName("Delay-Tick_Pistols"), "rage>anti-aim>angles"),Jitter6=menu.add_checkbox(FormatStateName("Delay-Tick_Other"), "rage>anti-aim>angles"),Fake=menu.add_checkbox(FormatStateName("Fake"), "rage>anti-aim>desync"),FakeAmount=menu.add_slider(FormatStateName("Amount"), "rage>anti-aim>desync", -360, 360, 1),CompensateAngle=menu.add_slider(FormatStateName("Compensate angle"), "rage>anti-aim>desync", -360, 360, 1),RandomFake=menu.add_combo(FormatStateName("Jitter"), "rage>anti-aim>desync", {"Off","Central","Ofset","Sway","5way","Random","Rand+5way+Ofset","Pizdec"}),FreestandFake=menu.add_combo(FormatStateName("Freestand fake"), "rage>anti-aim>desync", References.FreestandFake:get_combo_items()),FlipFakeWithJitter=menu.add_checkbox(FormatStateName("Flip fake with jitter"), "rage>anti-aim>desync"),LegSlide=menu.add_combo(FormatStateName("Leg slide"), "rage>anti-aim>desync", References.LegSlide:get_combo_items()),RollLean=menu.add_combo(FormatStateName("Roll"), "rage>anti-aim>desync", References.RollLean:get_combo_items()),LeanAmount=menu.add_slider(FormatStateName("Amount "), "rage>anti-aim>desync", -200, 200, 1),FlipLeanWithJitter=menu.add_checkbox(FormatStateName("Flip roll with jitter"), "rage>anti-aim>desync"),Callbacks={}};
	local function BindVisible(a, b, custom_compare)
		if (not a or not b) then
			utils.error_print("Cannot bind visible. %s %s", tostring(a), tostring(b));
			return;
		end
		local cb = function()
			local Value = b:get();
			local ActiveState = AAStates[AAStateCombo:get() + 1] == State;
			if custom_compare then
				a:set_visible(custom_compare(Value) and ActiveState);
			else
				a:set_visible(Value and ActiveState);
			end
		end;
		b:add_callback(cb);
		table.insert(NewTable.Callbacks, cb);
		utils.run_delayed(500, cb);
	end
	local JitterFreezeFunc = function(v)
		return v and NewTable.JitterFreeze:get();
	end;
	BindVisible(NewTable.YawAddValue, NewTable.YawAdd);
	BindVisible(NewTable.SpinRange, NewTable.Spin);
	BindVisible(NewTable.SpinSpeed, NewTable.Spin);
	BindVisible(NewTable.RandomJitter, NewTable.Jitter);
	BindVisible(NewTable.Jitter2, NewTable.Jitter10);
	BindVisible(NewTable.Jitter3, NewTable.Jitter10);
	BindVisible(NewTable.Jitter4, NewTable.Jitter10);
	BindVisible(NewTable.Jitter5, NewTable.Jitter10);
	BindVisible(NewTable.Jitter6, NewTable.Jitter10);
	BindVisible(NewTable.Jitter11, NewTable.Jitter7);
	BindVisible(NewTable.Jitter13, NewTable.Jitter10);
	BindVisible(NewTable.Jitter14, NewTable.Jitter8);
	BindVisible(NewTable.Jitter15, NewTable.Jitter8);
	BindVisible(NewTable.Jitter16, NewTable.Jitter28);
	BindVisible(NewTable.Jitter17, NewTable.Jitter28);
	BindVisible(NewTable.Jitter18, NewTable.Jitter28);
	BindVisible(NewTable.Jitter19, NewTable.Jitter28);
	BindVisible(NewTable.Jitter20, NewTable.Jitter28);
	BindVisible(NewTable.Jitter21, NewTable.Jitter28);
	BindVisible(NewTable.Jitter22, NewTable.Jitter28);
	BindVisible(NewTable.Jitter23, NewTable.Jitter28);
	BindVisible(NewTable.Jitter24, NewTable.Jitter28);
	BindVisible(NewTable.Jitter25, NewTable.Jitter28);
	BindVisible(NewTable.Jitter26, NewTable.Jitter28);
	BindVisible(NewTable.Jitter27, NewTable.Jitter28);
	BindVisible(NewTable.Jitter28, NewTable.Jitter8);
	BindVisible(NewTable.Jitter30, NewTable.Jitter29);
	BindVisible(NewTable.Jitter31, NewTable.Jitter29);
	BindVisible(NewTable.Jitter32, NewTable.Jitter29);
	BindVisible(NewTable.Jitter33, NewTable.Jitter29);
	BindVisible(NewTable.Jitter34, NewTable.Jitter29);
	BindVisible(NewTable.Jitter35, NewTable.Jitter29);
	BindVisible(NewTable.Jitter36, NewTable.Jitter29);
	BindVisible(NewTable.Jitter37, NewTable.Jitter29);
	BindVisible(NewTable.Jitter38, NewTable.Jitter29);
	BindVisible(NewTable.Jitter39, NewTable.Jitter29);
	BindVisible(NewTable.Jitter7, NewTable.Jitter);
	BindVisible(NewTable.Jitter8, NewTable.Jitter);
	BindVisible(NewTable.Jitter10, NewTable.Jitter);
	BindVisible(NewTable.JitterRange, NewTable.Jitter);
	BindVisible(NewTable.JitterFreeze, NewTable.Jitter);
	BindVisible(NewTable.HoldChance, NewTable.Jitter, JitterFreezeFunc);
	BindVisible(NewTable.HoldChance, NewTable.JitterFreeze, JitterFreezeFunc);
	BindVisible(NewTable.FakeAmount, NewTable.Fake);
	BindVisible(NewTable.CompensateAngle, NewTable.Fake);
	BindVisible(NewTable.FreestandFake, NewTable.Fake);
	BindVisible(NewTable.FlipFakeWithJitter, NewTable.Fake);
	BindVisible(NewTable.LeanAmount, NewTable.RollLean, function(v)
		return v ~= 0;
	end);
	BindVisible(NewTable.FlipLeanWithJitter, NewTable.RollLean, function(v)
		return v ~= 0;
	end);
	AAStateMenuElements[State] = NewTable;
end
AAStateCombo:add_callback(function(value)
	for StateName, Elements in pairs(AAStateMenuElements) do
		SetAllVisible(Elements, AAStates[value + 1] == StateName);
		for _, Callback in pairs(Elements.Callbacks) do
			if Callback then
				Callback();
			end
		end
	end
end, true);
local Ideal_tick_switch = gui.add_checkbox("Free-Stand", "Rage>Anti-Aim>Angles");
autopeek = gui.get_config_item("Misc>Movement>Peek Assist");
doubletap = gui.get_config_item("Rage>Aimbot>Aimbot>Double tap");
freestand = gui.get_config_item("Rage>Anti-Aim>Angles>Freestand");
powrot = 0;
AntiAimOverride = menu.add_checkbox("Antiaim override ", "rage>anti-aim>angles");
Back = menu.add_checkbox("Back ", "rage>anti-aim>angles");
Left = menu.add_checkbox("Left ", "rage>anti-aim>angles");
Right = menu.add_checkbox("Right ", "rage>anti-aim>angles");
EnsureLean = menu.add_checkbox("Ensure lean ", "rage>anti-aim>desync");
menu.add_keybind(Back);
menu.add_keybind(Left);
menu.add_keybind(Right);
menu.add_keybind(EnsureLean);
AntiAimOverride:add_callback(function(v)
	Back:set_visible(v);
	Left:set_visible(v);
	Right:set_visible(v);
end, true);
OnGroundTicks = 1;
OnGroundTickss = 1;
OldSpeed = 0;
EnemyMissedTime = 0;
CustomJitterSwitch = 1;
function IsOvr(state)
	Elements = AAStateMenuElements[state];
	return (Elements.OverrideGeneralConfig ~= nil) and Elements.OverrideGeneralConfig:get();
end
DrawAAState = false;
CurrentState = "General";
function on_setup_move(cmd)
	LocalPlayer = entities[engine.get_local_player()];
	if (not LocalPlayer or not LocalPlayer:is_alive()) then
		return;
	end
	State = "General";
	Buttons = cmd:get_buttons();
	OnGround = bit.band(LocalPlayer:get_prop("m_fFlags") or 0, 1) == 1;
	Velocity = math.vec3(LocalPlayer:get_prop("m_vecVelocity[0]") or 0, LocalPlayer:get_prop("m_vecVelocity[1]") or 0, LocalPlayer:get_prop("m_vecVelocity[2]") or 0);
	Speed = Velocity:length2d();
	FakeDucking = ExtraRefs.FakeDuck:get() == 1;
	Crouching = bit.band(Buttons, csgo.in_duck) ~= 0;
	Crouchings = bit.band(Buttons, csgo.in_duck) ~= 0;
	SlowWalking = ExtraRefs.Slide:get() == 1;
	ActiveWeapon = LocalPlayer:get_weapon();
	WeaponInfo = ActiveWeapon and utils.get_weapon_info(ActiveWeapon:get_prop("m_iItemDefinitionIndex") or -1);
	if OnGround then
		OnGroundTicks = OnGroundTicks + 1;
	else
		OnGroundTicks = 0;
	end
	if (IsOvr("Enemy missed") and ((global_vars.realtime - EnemyMissedTime) < (AAStateMenuElements["Enemy missed"].HoldTime:get() / 1000))) then
		State = "Enemy missed";
	elseif (WeaponInfo and (WeaponInfo.console_name == "weapon_taser") and IsOvr("Taser")) then
		State = "Taser";
	elseif (FakeDucking and IsOvr("Fake duck")) then
		State = "Fake duck";
	elseif (OnGroundTicks <= 1) then
		if (Crouching and IsOvr("In air crouch")) then
			State = "In air crouch";
		else
			State = "In air";
		end
		if (IsOvr("In air knife") and ActiveWeapon) then
			if WeaponInfo then
				if string.find(WeaponInfo.console_name, "knife_") then
					if AAStateMenuElements["In air knife"].CrouchOnly:get() then
						if Crouching then
							State = "In air knife";
						end
					else
						State = "In air knife";
					end
				end
			end
		end
	elseif (Crouching and IsOvr("Crouching")) then
		State = "Crouching";
	elseif (SlowWalking and IsOvr("Slow walk")) then
		State = "Slow walk";
	elseif (((Speed - OldSpeed) > 2) and IsOvr("Accelerating")) then
		State = "Accelerating";
	elseif (Speed > 5) then
		State = "Moving";
	else
		State = "Standing";
	end
	OldSpeed = Speed;
	local Settings = AAStateMenuElements[State];
	if (Settings.OverrideGeneralConfig and not Settings.OverrideGeneralConfig:get()) then
		State = "General";
		Settings = AAStateMenuElements['General'];
	end
	CurrentState = State;
	for ItemName, Item in pairs(Settings) do
		if (References[ItemName] and Item) then
			References[ItemName]:set(Item:get());
		end
	end
	local RandomFake = Settings.RandomFake:get();
	if (RandomFake == 2) then
		References.FakeAmount:set(utils.random_int(-200, 200));
	elseif (RandomFake == 1) then
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 1) == 0) and 1) or -1));
	end
	if (RandomFake == 3) then
		References.FakeAmount:set(utils.random_int(-200, 200));
	elseif (RandomFake == 4) then
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 1) == 0) and 1) or -1));
		References.FakeAmount:set(utils.random_int(-360, 3600));
	end
	if (RandomFake == 5) then
		References.FakeAmount:set(utils.random_int(-100, 100));
		References.FakeAmount:set(utils.random_int(-200, 200));
		References.FakeAmount:set(utils.random_int(-300, 300));
	elseif (RandomFake == 5) then
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 1) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 10) == 0) and 1) or -1));
	end
	if (RandomFake == 6) then
		References.FakeAmount:set(utils.random_int(-100, 100));
		References.FakeAmount:set(utils.random_int(-150, 150));
		References.FakeAmount:set(utils.random_int(-200, 200));
		References.FakeAmount:set(utils.random_int(-300, 300));
	elseif (RandomFake == 6) then
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 100) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 10) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 1) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 10) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 100) == 0) and 1) or -1));
	end
	if (RandomFake == 6) then
		References.FakeAmount:set(utils.random_int(-100, 100));
		References.FakeAmount:set(utils.random_int(-200, 200));
		References.FakeAmount:set(utils.random_int(-300, 300));
	elseif (RandomFake == 6) then
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 1) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 10) == 0) and 1) or -1));
	end
	if (RandomFake == 7) then
		References.FakeAmount:set(utils.random_int(-100, 100));
		References.FakeAmount:set(utils.random_int(-150, 150));
		References.FakeAmount:set(utils.random_int(-200, 200));
		References.FakeAmount:set(utils.random_int(-300, 300));
		References.FakeAmount:set(utils.random_int(-1, 10));
		References.FakeAmount:set(utils.random_int(-150, 234));
		References.FakeAmount:set(utils.random_int(-23, 123));
		References.FakeAmount:set(utils.random_int(-1234, 45));
	elseif (RandomFake == 7) then
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 100) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 10) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 1) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 10) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 100) == 0) and 1) or -1));
	end
	if (RandomFake == 7) then
		References.FakeAmount:set(utils.random_int(-32, 45));
		References.FakeAmount:set(utils.random_int(-45, 200));
		References.FakeAmount:set(utils.random_int(-4, 86));
	elseif (RandomFake == 7) then
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 1) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 122) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 1) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 5) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 1) == 0) and 1) or -1));
		References.FakeAmount:set(References.FakeAmount:get() * (((utils.random_int(0, 134) == 0) and 1) or -1));
	end
	if (Settings.Jitter:get() and Settings.JitterFreeze:get() and not LocalPlayer:get_prop("m_bIsDefusing")) then
		References.Jitter:set(false);
		local HadYawAdd = References.YawAdd:get() == 1;
		References.YawAdd:set(true);
		References.YawAddValue:set(((HadYawAdd and References.YawAddValue:get()) or 0) + ((References.JitterRange:get() / 2) * CustomJitterSwitch));
		if ((info.fatality.lag_ticks == 0) and (utils.random_int(0, 100) <= (100 - Settings.HoldChance:get()))) then
			CustomJitterSwitch = -CustomJitterSwitch;
		end
	end
end
function on_player_hurt(event)
	local Hurt = engine.get_player_for_user_id(event:get_int("userid"));
	local Attacker = entities[engine.get_player_for_user_id(event:get_int("attacker"))];
	if ((Hurt ~= engine.get_local_player()) or not Attacker:is_enemy()) then
		return;
	end
	EnemyMissedTime = 0;
end
if DrawAAState then
	function on_paint()
		local LP = entities[engine.get_local_player()];
		if ((CurrentState == "General") or not LP or not LP:is_alive()) then
			return;
		end
		local ScreenSizeX, ScreenSizeY = render.get_screen_size();
		render.text(render.font_control, ScreenSizeX - 5, 5, string.format("aa->%s", string.lower(CurrentState)), render.color("#FFFFFF"), render.align_right);
	end
end
local FovHitboxes = {0,2,5};
function on_bullet_impact(event)
	local Settings = AAStateMenuElements["Enemy missed"];
	if not Settings.OverrideGeneralConfig:get() then
		return;
	end
	local LocalPlayer = entities[engine.get_local_player()];
	local Shooter = entities[engine.get_player_for_user_id(event:get_int("userid"))];
	if (not LocalPlayer or not Shooter or not Shooter:is_enemy()) then
		return;
	end
	local LEyePos = math.vec3(LocalPlayer:get_eye_position());
	local EyePos = math.vec3(Shooter:get_eye_position());
	local ImpactPos = math.vec3(event:get_float("x"), event:get_float("y"), event:get_float("z"));
	local Angle = math.vector_angles((ImpactPos - EyePos):normalize());
	local HasFov = false;
	for _, Hitbox in pairs(FovHitboxes) do
		local HitboxPos = math.vec3(LocalPlayer:get_hitbox_position(Hitbox));
		local FovToHitbox = math.calc_fov(EyePos, HitboxPos, Angle);
		if (FovToHitbox <= Settings.FovThreshhold:get()) then
			HasFov = true;
			break;
		end
	end
	if not HasFov then
		return;
	end
	if (((EyePos:dist(ImpactPos) + 32) - EyePos:dist(LEyePos)) < 0) then
		return;
	end
	EnemyMissedTime = global_vars.realtime;
end
clipboard = require("clipboard");
menuFind = gui.get_config_item;
menuACombo = gui.add_combo;
menuACheck = gui.add_checkbox;
menuASlider = gui.add_slider;
menuAListbox = gui.add_listbox;
menuAMCombo = gui.add_multi_combo;
sVis = gui.set_visible;
menuABind = gui.add_keybind;
menuACPicker = gui.add_colorpicker;
menuAButton = gui.add_button;
local font = render.create_font("verdanab.ttf", 10, render.font_flag_outline);
local font2 = render.create_font("tahomabd.ttf", 12, render.font_flag_outline);
local p_state = 0;
local sAntiaim = {};
local configs = {};
local function is_mouse_in_bounds(pos, size)
	local x, y = pos.x, pos.y;
	local w, h = size.x, size.y;
	local mouse_position = {input.get_cursor_pos()};
	return (mouse_position[1] >= x) and (mouse_position[1] < (x + w)) and (mouse_position[2] >= y) and (mouse_position[2] < (y + h)) and gui.is_menu_open();
end
local e_global = {SCREEN={render.get_screen_size()}};
table.count = function(tbl)
	if (tbl == nil) then
		return 0;
	end
	if (#tbl == 0) then
		local count = 0;
		for data in pairs(tbl) do
			count = count + 1;
		end
		return count;
	end
	return #tbl;
end;
local animation = {};
animation.data = {};
animation.lerp = function(start, end_pos, time)
	if (type(start) == "table") then
		local color_data = {0,0,0,0};
		for i, color_key in ipairs({"r","g","b","a"}) do
			color_data[i] = animation.lerp(start[color_key], end_pos[color_key], time);
		end
		return render.color(unpack(color_data));
	end
	return ((end_pos - start) * global_vars.frametime * time) + start;
end;
animation.new = function(name, value, time)
	if (animation.data[name] == nil) then
		animation.data[name] = value;
	end
	animation.data[name] = animation.lerp(animation.data[name], value, time);
	return animation.data[name];
end;
local c_drag = {};
local m_drag = {__index=c_drag};
c_drag.new = function(slider_x, slider_y, x, y)
	slider_x:set_int(x);
	slider_y:set_int(y);
	return setmetatable({x=slider_x,y=slider_y,d_x=0,d_y=0,dragging=false,unlocked=false}, m_drag);
end;
c_drag.unlock = function(self)
	self.unlocked = true;
end;
c_drag.lock = function(self)
	self.unlocked = false;
end;
c_drag.handle = function(self, width, height)
	self.width = width;
	self.height = height;
	local screen = e_global.SCREEN;
	local mouse_position = {input.get_cursor_pos()};
	if (is_mouse_in_bounds(math.vec3(self.x:get_int(), self.y:get_int()), math.vec3(self.width, self.height))) then
		if (input.is_key_down(1) and not self.dragging) then
			self.dragging = true;
			self.d_x = self.x:get_int() - mouse_position[1];
			self.d_y = self.y:get_int() - mouse_position[2];
		end
	end
	if not input.is_key_down(1) then
		self.dragging = false;
	end
	if (self.dragging and gui.is_menu_open()) then
		local new_x = math.max(0, math.min(screen[1] - self.width, mouse_position[1] + self.d_x));
		local new_y = math.max(0, math.min(screen[2] - self.height, mouse_position[2] + self.d_y));
		new_x = (self.unlocked and (mouse_position[1] + self.d_x)) or new_x;
		new_y = (self.unlocked and (mouse_position[2] + self.d_y)) or new_y;
		self.x:set_int(new_x);
		self.y:set_int(new_y);
	end
end;
c_drag.get = function(self)
	return self.x:get_int(), self.y:get_int();
end;
local draw = {};
draw.rect = function(pos, size, color1, round, round_flags)
	local a, b = pos, pos + size;
	if (round ~= nil) then
		render.rect_filled_rounded(a.x, a.y, b.x, b.y, color1, round, round_flags or render.all);
		return;
	end
	return render.rect_filled(a.x, a.y, b.x, b.y, color1);
end;
draw.rect_outline = function(pos, size, color1)
	local a, b = pos, pos + size;
	return render.rect(a.x, a.y, b.x, b.y, color1);
end;
draw.gradient = function(pos, size, color1, color2, ltr, normal)
	local a, b = pos, pos + size;
	if (normal == true) then
		a, b = pos, size;
	end
	if (ltr == true) then
		render.rect_filled_multicolor(a.x, a.y, b.x, b.y, color1, color2, color1, color2);
		return;
	end
	return render.rect_filled_multicolor(a.x, a.y, b.x, b.y, color1, color1, color2, color2);
end;
draw.push_clip_rect = function(pos, size, ...)
	local a, b = pos, pos + size;
	return render.push_clip_rect(a.x, a.y, b.x, b.y, ...);
end;
draw.pop_clip_rect = function()
	return render.pop_clip_rect();
end;
draw.circle_outline = function(pos, color1, radius, angle, percentage, thickness, segments)
	local x, y = pos.x, pos.y;
	return render.circle(x, y, radius, color1, thickness or 1, segments or 12, percentage or 1, angle or 0);
end;
draw.shadow = function(pos, size, color1, length)
	local r, g, b, a = color1.r, color1.g, color1.b, color1.a;
	for i = 1, 10 do
		draw.rect_outline(pos - math.vec3(i, i), size + math.vec3(i * 2, i * 2), render.color(r, g, b, (60 - ((60 / length) * i)) * (a / 255)));
	end
end;
draw.window = function(pos, size, color1, glow)
	local round = 6;
	local x, y = pos.x, pos.y;
	local width, height = x + size.x, y + size.y;
	local r, g, b, a = color1.r, color1.g, color1.b, color1.a;
	if (glow == true) then
		draw.shadow(pos, size, render.color(r, g, b, (255 / 255) * a), 10);
	end

end;
local fonts = {};
fonts.verdana = {};
fonts.verdana.default = render.create_font("verdana.ttf", 12, render.font_flag_shadow);
local ui_general = {};
MN611 = gui.add_listbox("                ", "Misc>Various", 1, false, {"Visuals"});
local ui_general = {};
local H = "Misc>Various";
local v = "Misc>Various";
local fU = gui.add_checkbox("Skeet Indicators", "Misc>Various");
ui_general.accent_check = gui.add_checkbox("Color-Keybinds-Watermark", "Misc>Various");
ui_general.accent_color = gui.add_colorpicker("Misc>Various>Color-Keybinds-Watermark", true);
ui_general.glow = gui.add_checkbox("Glow", "Misc>Various");
ui_general.keybinds = gui.add_checkbox("Keybinds", "Misc>Various");
ui_general.watermark = gui.add_checkbox("Watermark", "Misc>Various");
ui_general.keybinds_x = gui.add_slider("Keybinds x", "Misc>Various", 0, e_global.SCREEN[1], 1);
gui.set_visible("Misc>Various>Keybinds x", false);
ui_general.keybinds_y = gui.add_slider("Keybinds y", "Misc>Various", 0, e_global.SCREEN[2], 1);
gui.set_visible("Misc>Various>Keybinds y", false);
local watermark = {};
watermark.handle = function()
	if not ui_general.watermark:get_bool() then
		return;
	end
	local accent_color = ui_general.accent_color:get_color();
	local a_r, a_g, a_b = accent_color.r, accent_color.g, accent_color.b;
	local prefix = "WhyNot.codes v3.1 Beta";
	local ping = math.floor((utils.get_rtt() or 0) * 1000);
	local latency = ((ping >= 1) and (" | %dms"):format(ping)) or "";
	local time = utils.get_time();
	local actual_time = ("%s:%s"):format(time.hour, time.min);
	sspss = "Ram1n";
	local text = ("%s | %s%s | %s"):format(prefix, sspss, latency, actual_time);
	local text_size = {render.get_text_size(fonts.verdana.default, text)};
	local x, y = e_global.SCREEN[1], 8;
	local width, height = animation.new("watermark width", text_size[1] + 12, 8), 22;
	x = (x - width) - 10;
	draw.window(math.vec3(x, y), math.vec3(width, height), render.color(a_r, a_g, a_b, 255), ui_general.glow:get_bool());
	render.text(fonts.verdana.default, (x + (width / 2)) - (text_size[1] / 2), ((y + (height / 2)) - (text_size[2] / 2)) + 1, text, render.color(255, 255, 255, 255));
end;
local keybinds = {};
keybinds.active = {};
keybinds.list = {["Double tap"]="rage>aimbot>aimbot>double tap",["On shot anti-aim"]="rage>aimbot>aimbot>hide shot",["Minimum damage"]="rage>aimbot>ssg08>scout>override",["Force safepoint"]="rage>aimbot>aimbot>force extra safety",["Headshot only"]="rage>aimbot>aimbot>headshot only",["Duck peek assist"]="misc>>movement>fake duck",["Quick peek assist"]="misc>movement>peek assist"};
keybinds.width = 0;
keybinds.modes = {[0]="always",[1]="holding",[2]="toggled",[3]="off"};
keybinds.dragging = c_drag.new(ui_general.keybinds_x, ui_general.keybinds_y, 0, 0);
keybinds.handle = function()
	if not ui_general.keybinds:get_bool() then
		return;
	end
	local accent_color = ui_general.accent_color:get_color();
	local a_r, a_g, a_b = accent_color.r, accent_color.g, accent_color.b;
	local latest_item = false;
	local maximum_offset = 66;
	for bind_name, path in pairs(keybinds.list) do
		local item_active = gui.get_config_item(path):get_bool();
		if item_active then
			latest_item = true;
			if (keybinds.active[bind_name] == nil) then
				keybinds.active[bind_name] = {mode="",alpha=0,offset=0,active=false};
			end
			local key_code, key_type = gui.get_keybind(path);
			local bind_mode = keybinds.modes[key_type];
			local bind_name_size = {render.get_text_size(fonts.verdana.default, bind_name)};
			local bind_state_size = {render.get_text_size(fonts.verdana.default, bind_mode)};
			keybinds.active[bind_name].mode = bind_mode;
			keybinds.active[bind_name].alpha = animation.lerp(keybinds.active[bind_name].alpha, 1, 12);
			keybinds.active[bind_name].offset = bind_name_size[1] + bind_state_size[1];
			keybinds.active[bind_name].active = true;
		elseif (keybinds.active[bind_name] ~= nil) then
			keybinds.active[bind_name].alpha = animation.lerp(keybinds.active[bind_name].alpha, 0, 12);
			keybinds.active[bind_name].active = false;
			if (keybinds.active[bind_name].alpha < 0.1) then
				keybinds.active[bind_name] = nil;
			end
		end
		if ((keybinds.active[bind_name] ~= nil) and (keybinds.active[bind_name].offset > maximum_offset)) then
			maximum_offset = keybinds.active[bind_name].offset;
		end
	end
	local alpha = animation.new("keybinds alpha", ((gui.is_menu_open() or ((table.count(keybinds.active) > 0) and latest_item)) and 1) or 0, 12);
	local text = "keybinds";
	local text_size = {render.get_text_size(fonts.verdana.default, text)};
	local x, y = keybinds.dragging:get();
	local width, height = animation.new("keybinds width", 30 + maximum_offset, 8), 22;
	local height_offset = height + 3;
	draw.window(math.vec3(x, y), math.vec3(width, height), render.color(a_r, a_g, a_b, 255 * alpha), ui_general.glow:get_bool());
	render.text(fonts.verdana.default, (x + (width / 2)) - (text_size[1] / 2), ((y + (height / 2)) - (text_size[2] / 2)) + 1, text, render.color(255, 255, 255, 255 * alpha));
	for bind_name, value in pairs(keybinds.active) do
		local key_type = "[" .. (value.mode or "?") .. "]";
		local key_type_size = {render.get_text_size(fonts.verdana.default, key_type)};
		render.text(fonts.verdana.default, x + 5, y + height_offset, bind_name, render.color(255, 255, 255, 255 * alpha * value.alpha));
		render.text(fonts.verdana.default, ((x + width) - key_type_size[1]) - 5, y + height_offset, key_type, render.color(255, 255, 255, 255 * alpha * value.alpha));
		height_offset = height_offset + (15 * value.alpha);
	end
	keybinds.dragging:handle(width, ((table.count(keybinds.active) > 0) and height_offset) or height);
end;
local k = require("clipboard");
local j = {anim_list={}};
j.math_clamp = function(k, j, s)
	return math.min(s, math.max(j, k));
end;
j.math_lerp = function(k, s, c)
	local N = j.math_clamp(0.02, 0, 1);
	if (type(k) == "userdata") then
		r, g, b, k = k.r, k.g, k.b, k.a;
		e_r, e_g, e_b, e_a = s.r, s.g, s.b, s.a;
		r = j.math_lerp(r, e_r, N);
		g = j.math_lerp(g, e_g, N);
		b = j.math_lerp(b, e_b, N);
		k = j.math_lerp(k, e_a, N);
		return color(r, g, b, k);
	end
	local m = s - k;
	m = m * N;
	m = m + k;
	if ((s == 0) and (m < 0.01) and (m > -0.01)) then
		m = 0;
	elseif ((s == 1) and (m < 1.01) and (m > 0.99)) then
		m = 1;
	end
	return m;
end;
j.vector_lerp = function(k, j, s)
	return k + ((j - k) * s);
end;
j.anim_new = function(k, s, c, N)
	if not j.anim_list[k] then
		j.anim_list[k] = {};
		j.anim_list[k].color = render.color(0, 0, 0, 0);
		j.anim_list[k].number = 0;
		j.anim_list[k].call_frame = true;
	end
	if (c == nil) then
		j.anim_list[k].call_frame = true;
	end
	if (N == nil) then
		N = 0.1;
	end
	if (type(s) == "userdata") then
		lerp = j.math_lerp(j.anim_list[k].color, s, N);
		j.anim_list[k].color = lerp;
		return lerp;
	end
	lerp = j.math_lerp(j.anim_list[k].number, s, N);
	j.anim_list[k].number = lerp;
	return lerp;
end;
local s = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
local function c(k)
	return (k:gsub(".", function(k)
		local j, s = "", k:byte();
		for k = 8, 1, -1 do
			j = j .. (((((s % (2 ^ k)) - (s % (2 ^ (k - 1)))) > 0) and "1") or "0");
		end
		return j;
	end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(k)
		if (#k < 6) then
			return "";
		end
		local j = 0;
		for s = 1, 6, 1 do
			j = j + (((k:sub(s, s) == "1") and (2 ^ (6 - s))) or 0);
		end
		return s:sub(j + 1, j + 1);
	end) .. ({"","==","="})[(#k % 3) + 1];
end
local function N(k)
	k = string.gsub(k, "[^" .. s .. "=]", "");
	return (k:gsub(".", function(k)
		if (k == "=") then
			return "";
		end
		local j, c = "", s:find(k) - 1;
		for k = 6, 1, -1 do
			j = j .. (((((c % (2 ^ k)) - (c % (2 ^ (k - 1)))) > 0) and "1") or "0");
		end
		return j;
	end)):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(k)
		if (#k ~= 8) then
			return "";
		end
		local j = 0;
		for s = 1, 8, 1 do
			j = j + (((k:sub(s, s) == "1") and (2 ^ (8 - s))) or 0);
		end
		return string.char(j);
	end);
end
local function m(k, j)
	local s = {};
	for k in string.gmatch(k, "([^" .. j .. "]+)") do
		s[#s + 1] = string.gsub(k, "\n", " ");
	end
	return s;
end
local function D(k)
	if ((k == "true") or (k == "false")) then
		return k == "true";
	else
		return k;
	end
end
local AU = render.font_esp;
render.window = function(k, j, s, c, N, m, D, H)
	if (ZU:get_int() == 0) then
		render.rect_filled(k, j, s, c, render.color(39, 39, 39, 255 * H));
		render.rect_filled(k + 1, j + 1, s - 1, c - 1, render.color(25, 25, 25, 255 * H));
	end
	if (ZU:get_int() == 1) then
		render.rect_filled_rounded(k, j, s, c, render.color(0, 0, 0, 105 * H), 2, render.all);
		render.rect_filled(k, j, s, j + 1, render.color(N, m, D, 255 * H));
		render.rect_filled_multicolor(k - 1, j + 1, k, c, render.color(N, m, D, 255 * H), render.color(N, m, D, 255 * H), render.color(0, 0, 0, 0), render.color(0, 0, 0, 0));
		render.rect_filled_multicolor(s + 1, j + 1, s, c, render.color(N, m, D, 255 * H), render.color(N, m, D, 255 * H), render.color(0, 0, 0, 0), render.color(0, 0, 0, 0));
	end
end;
function accumulate_fps()
	return math.ceil(1 / global_vars.frametime);
end
function get_tick()
	if not engine.is_in_game() then
		return;
	end
	return math.floor(1 / global_vars.interval_per_tick);
end
local PU, dU = render.get_screen_size();
local tU = {{text="SAFE",path="rage>aimbot>aimbot>Force Extra Safety"},{text="DA",path="rage>aimbot>aimbot>Target Dormant"},{text="FD",path="misc>movement>fake duck"},{text="Damage",path="rage>aimbot>ssg08>scout>override"},{text="DT",path="rage>aimbot>aimbot>double tap"},{text="HIDESHOTS",path="rage>aimbot>aimbot>hide shot"},{text="FREESTAND",path="rage>anti-aim>angles>freestand"},{text="HEAD",path="rage>aimbot>aimbot>headshot only"},{text="LEAN",path="rage>anti-aim>desync>ensure lean"}};
local VU = function()
	local k = entities.get_entity(engine.get_local_player());
	local j = k:get_prop("m_vecVelocity[0]");
	local s = k:get_prop("m_vecVelocity[1]");
	return math.sqrt((j * j) + (s * s));
end;
local eU = function()
	local k = {};
	for j, s in pairs(tU) do
		if (gui.get_config_item(s.path)):get_bool() then
			table.insert(k, s.text);
		end
	end
	return k;
end;
local pU = math.vec3(render.get_screen_size());
local JU = function(k, j, s)
	return math.floor(k + ((j - k) * s));
end;
local GU = {0,0,0,0,0};
local iU = render.create_font("calibrib.ttf", 23, render.font_flag_shadow);
function skeetind()
	if fU:get_bool() then
		local k = entities.get_entity(engine.get_local_player());
		if not k then
			return;
		end
		add_y = 0;
		if info.fatality.can_fastfire then
			GU[1] = JU(GU[1], 255, global_vars.frametime * 11);
			add_y = add_y + 7;
		else
			if (GU[1] > 0) then
				add_y = add_y + 7;
			end
			GU[1] = JU(GU[1], 0, global_vars.frametime * 11);
		end
		local s = j.anim_new("m_bIsScoped add dbbx2", (info.fatality.can_fastfire and 1) or 0.01);
		local c = gui.get_config_item("rage>anti-aim>desync>lean amount");
		local N = (c:get_int() / 100) * 2;
		local m = (info.fatality.can_fastfire and render.color(255, 255, 255, GU[1])) or render.color(225, 225, 225, 255);
		for k, c in pairs(eU()) do
			local D = {x=10,y=((pU.y / 2) + 98 + (35 * (k - 1)))};
			local H = utils.random_int(15, 100) / 100;
			local v = j.anim_new("aainverted1xq34", (fU:get_bool() and (utils.random_int(15, 100) / 100)) or 0);
			local l = render.color(150, 200, 30);
			if (c == "HEAD") then
				l = render.color(225, 225, 225);
			end
			if (c == "SAFE") then
				l = render.color(136, 207, 52);
			end
			if (c == "DA") then
				l = render.color(136, 207, 52);
			end
			if (c == "Damage") then
				l = render.color(225, 225, 225);
			end
			if (c == "FREESTAND") then
				l = render.color(225, 225, 225);
			end
			if (c == "DT") then
				l = render.color(225, 255, 255);
			end
			if (c == "HIDESHOTS") then
				if not info.fatality.can_onshot then
					l = render.color(225, 225, 225);
				end
			end
			if (c == "HIDESHOTS") then
				if not info.fatality.can_onshot then
					l = render.color(225, 225, 225);
				end
			end
			if (c == "LEAN") then
				l = render.color(225, 225, 2251);
			end
			local U = math.floor(math.abs(math.sin(global_vars.realtime) * 2) * 255);
			if (c == "ANTERRA EXPENSE") then
				l = render.color((M:get_color()).r, (M:get_color()).g, (M:get_color()).b, U);
			end
			local Y = math.vec3(render.get_text_size(iU, c));
			for k = 1, 10, 1 do
				render.rect_filled_rounded((D.x + 4) - k, D.y - k, D.x + Y.x + 8 + k, ((D.y + Y.y) - 3) + k, render.color(l.r, l.g, l.b, (20 - (2 * k)) * 0.35), 10);
			end
			render.text(iU, D.x + 8, D.y, c, l);
		end
	end
end
local kC = {render.get_screen_size()};
function animate(k, j, s, c, N, m)
	c = c * global_vars.frametime * 20;
	if (N == false) then
		if j then
			k = k + c;
		else
			k = k - c;
		end
	elseif j then
		k = k + ((s - k) * (c / 100));
	else
		k = k - ((0 + k) * (c / 100));
	end
	if m then
		if (k > s) then
			k = s;
		elseif (k < 0) then
			k = 0;
		end
	end
	return k;
end
function drag(k, j, s, c)
	local N, m = input.get_cursor_pos();
	local D = false;
	if input.is_key_down(1) then
		if ((N > k:get_int()) and (m > j:get_int()) and (N < (k:get_int() + s)) and (m < (j:get_int() + c))) then
			D = true;
		end
	else
		D = false;
	end
	if D then
		k:set_int(N - (s / 2));
		j:set_int(m - (c / 2));
	end
end
local showIndicators, showImprovments = menuAMCombo("Main selection", "Misc>Various", {"Show-Indicators","Show Resolver"});
local damageIndicator, antiaimIndicator, aimbotEnable, hideshotEnable, fakeduckEnable, doubletapEnable, hsonlyEnable, safepointEnable, dormantEnable = menuAMCombo("Indicator Selection", "Misc>Various", {"Damage Indicator","AntiAim Indicator","Aimbot Indicator","Hideshot Indicator","Fakeduck Indicator","Doubletap Indicator","HSonly Indicator","Force Safepoint Indicator","Dormant Indicator"});
local showPing, showFps, showServer, showTick, showSpeed = menuAMCombo("Advanced Indicators", "Misc>Various", {"Show Ping","Show FPS","Show Server","Show Tick","Show Speed"});
local stuffy = {activateColor=menuACheck("Lua indicator mark", "Misc>Various"),dormantBind=menuACheck("Dormant on Key", "Misc>Various"),dormantKey=menuABind("Misc>Various>Dormant on Key"),autoRevolverOnAimbot=menuACheck("Turn on Autorevolver on Aimbot", "Misc>Various"),revolverOffFakelag=menuACombo("Fakelag Off on Revolver", "Misc>Various", {"Never","Always","Only on Aimbot active"}),restoreFakelagMode=menuACombo("Restore Fakelag if not Revolver", "Misc>Various", {"None","Always On","Adaptive"})};
local disableJitterOnManualAA, disablerOnDoubletap, disablerOnHideshot = menuAMCombo("Disablers", "Misc>Various", {"Disable Jitter on Manual AA","Disable FL on DT","Disable FL on HS"});
local refs = {antiAimInd=menuFind("Rage>Anti-Aim>Angles>Anti-aim"),aimbotInd=menuFind("Rage>Aimbot>Aimbot>Aimbot"),hideshotsInd=menuFind("Rage>Aimbot>Aimbot>Hide shot"),doubletapInd=menuFind("Rage>Aimbot>Aimbot>Double tap"),hsonlyInd=menuFind("Rage>Aimbot>Aimbot>Headshot only"),safepointInd=menuFind("Rage>Aimbot>Aimbot>Force extra safety"),fakeduckInd=menuFind("Misc>Movement>Fake duck"),revolverik=menuFind("rage>aimbot>heavy_pistol>extra>autorevolver"),fakelagMenu=menuFind("Rage>Anti-Aim>Fakelag>Mode"),fakelagMenu=menuFind("Rage>Anti-Aim>Fakelag>Mode"),fakelagAmmount=menuFind("Rage>Anti-Aim>Fakelag>Limit"),dormantOnKey=menuFind("Rage>Aimbot>Aimbot>Target Dormant")};
local colors = {damageColor=menuACPicker("Misc>Various>Lua indicator mark", true),otherColor=menuACPicker("Misc>Various>Lua indicator mark", true, render.color(245, 161, 39, 255)),luaColor=menuACPicker("Misc>Various>Lua indicator mark", true, render.color(39, 106, 245, 255))};
function accumulate_fps()
	return math.ceil(1 / global_vars.frametime);
end
function get_tickrate()
	if not engine.is_in_game() then
		return;
	end
	return math.floor(1 / global_vars.interval_per_tick);
end
function get_ping()
	if not engine.is_in_game() then
		return;
	end
	return math.ceil(utils.get_rtt() * 1000);
end
function get_local_speed()
	local local_player = entities.get_entity(engine.get_local_player());
	if (local_player == nil) then
		return;
	end
	local velocity_x = local_player:get_prop("m_vecVelocity[0]");
	local velocity_y = local_player:get_prop("m_vecVelocity[1]");
	local velocity_z = local_player:get_prop("m_vecVelocity[2]");
	local velocity = math.vec3(velocity_x, velocity_y, velocity_z);
	local speed = math.ceil(velocity:length2d());
	if (speed < 10) then
		return 0;
	else
		return speed;
	end
end
function updateColorPing()
	if (get_ping() > 100) then
		newColor = "#ff3c50";
	elseif ((get_ping() > 40) and (get_ping() < 100)) then
		newColor = "#ffde00";
	elseif (get_ping() < 40) then
		newColor = "#9fca2b";
	end
	return render.color(newColor);
end
function updateColorFps()
	if (accumulate_fps() > 150) then
		newColor3 = "#9fca2b";
	elseif ((accumulate_fps() > 100) and (accumulate_fps() < 150)) then
		newColor3 = "#ffde00";
	elseif (accumulate_fps() < 100) then
		newColor3 = "#ff3c50";
	end
	return render.color(newColor3);
end
function updateColorTick()
	if (get_tickrate() < 65) then
		newColor2 = "#ff3c50";
	elseif (accumulate_fps() > 65) then
		newColor2 = "#9fca2b";
	end
	return render.color(newColor2);
end
function updateColorSpeed()
	if (get_local_speed() > 250) then
		newColor4 = "#9fca2b";
	elseif ((get_local_speed() > 100) and (get_local_speed() < 250)) then
		newColor4 = "#ffde00";
	elseif (get_local_speed() < 100) then
		newColor4 = "#ff3c50";
	end
	return render.color(newColor4);
end
function getWeapon()
	local local_player = entities.get_entity(engine.get_local_player());
	if not local_player then
		return;
	end
	local weapon = local_player:get_weapon();
	if not weapon then
		return;
	end
	local m_iItemDefinitionIndex = weapon:get_prop("m_iItemDefinitionIndex");
	if (local_player:get_prop("m_iHealth") > 0) then
		if ((m_iItemDefinitionIndex == 11) or (m_iItemDefinitionIndex == 38)) then
			return "Auto";
		elseif (m_iItemDefinitionIndex == 1) then
			return "Deagle";
		elseif (m_iItemDefinitionIndex == 64) then
			return "Heavy pistols";
		elseif ((m_iItemDefinitionIndex == 2) or (m_iItemDefinitionIndex == 3) or (m_iItemDefinitionIndex == 4) or (m_iItemDefinitionIndex == 30) or (m_iItemDefinitionIndex == 32) or (m_iItemDefinitionIndex == 36) or (m_iItemDefinitionIndex == 61) or (m_iItemDefinitionIndex == 63)) then
			return "Pistols";
		elseif (m_iItemDefinitionIndex == 40) then
			return "Scout";
		elseif (m_iItemDefinitionIndex == 9) then
			return "AWP";
		elseif ((m_iItemDefinitionIndex == 7) or (m_iItemDefinitionIndex == 8) or (m_iItemDefinitionIndex == 10) or (m_iItemDefinitionIndex == 39) or (m_iItemDefinitionIndex == 14) or (m_iItemDefinitionIndex == 13) or (m_iItemDefinitionIndex == 16) or (m_iItemDefinitionIndex == 17) or (m_iItemDefinitionIndex == 19) or (m_iItemDefinitionIndex == 23) or (m_iItemDefinitionIndex == 24) or (m_iItemDefinitionIndex == 25) or (m_iItemDefinitionIndex == 26) or (m_iItemDefinitionIndex == 27) or (m_iItemDefinitionIndex == 28) or (m_iItemDefinitionIndex == 29) or (m_iItemDefinitionIndex == 33) or (m_iItemDefinitionIndex == 34) or (m_iItemDefinitionIndex == 35) or (m_iItemDefinitionIndex == 60)) then
			return "Other";
		else
			return "kokocina";
		end
	end
	return m_iItemDefinitionIndex;
end
function pizdablat()
	local xY, yX = render.get_screen_size();
	local x = xY * 0.5;
	local y = yX * 0.5;
	local pridajY = 20;
	local pridajX = 100;
	local odoberX = 100;
	local local_player = entities.get_entity(engine.get_local_player());
	local is_valve = game_rules.is_valve_server;
	local valveSize = render.get_text_size(font, "Valve");
	local shitSize = render.get_text_size(font, "Host");
	if not local_player then
		return;
	end
	if not local_player:is_alive() then
		return;
	end
	if not engine.is_in_game() then
		return;
	end
	if showIndicators:get_bool() then
		if showServer:get_bool() then
			if is_valve then
				render.text(font, x, y + 525, "Valve", render.color("#9fca2b"), render.align_center, render.align_center);
			else
				render.text(font, x, y + 525, "Host", render.color("#ff3c50"), render.align_center, render.align_center);
			end
		end
		if showFps:get_bool() then
			odoberX = odoberX + 100;
			render.text(font, x - odoberX, y + 525, accumulate_fps() .. " Fps", updateColorFps(), render.align_bottom, render.align_center);
		end
		if showPing:get_bool() then
			odoberX = odoberX + 100;
			render.text(font, x - odoberX, y + 525, get_ping() .. " Ping", updateColorPing(), render.align_bottom, render.align_center);
		end
		if showTick:get_bool() then
			pridajX = pridajX + 100;
			render.text(font, x + pridajX, y + 525, get_tickrate() .. " Tick", updateColorTick(), render.align_bottom, render.align_center);
		end
		if showSpeed:get_bool() then
			pridajX = pridajX + 100;
			render.text(font, x + pridajX, y + 525, get_local_speed() .. " Speed", updateColorSpeed(), render.align_bottom, render.align_center);
		end
	end
	if showIndicators:get_bool() then
		if stuffy.activateColor:get_bool() then
			local picovina = "WhyNot.codes";
			pridajY = pridajY + 25;
			render.text(font2, x, y + pridajY, picovina, colors.luaColor:get_color(), render.align_center, render.align_center);
		end
	end
	if showIndicators:get_bool() then
		if (refs.antiAimInd:get_bool() and antiaimIndicator:get_bool()) then
			local picovina = "ANTIAIM";
			pridajY = pridajY + 15;
			render.text(font, x, y + pridajY, picovina, colors.otherColor:get_color(), render.align_center, render.align_center);
		end
		if (aimbotEnable:get_bool() and refs.aimbotInd:get_bool()) then
			local picovina = "AIMBOT";
			pridajY = pridajY + 15;
			render.text(font, x, y + pridajY, picovina, colors.otherColor:get_color(), render.align_center, render.align_center);
		end
		if (hideshotEnable:get_bool() and refs.hideshotsInd:get_bool()) then
			local picovina = "HIDESHOT";
			pridajY = pridajY + 15;
			render.text(font, x, y + pridajY, picovina, colors.otherColor:get_color(), render.align_center, render.align_center);
		end
		if (doubletapEnable:get_bool() and refs.doubletapInd:get_bool()) then
			local picovina = "DOUBLETAP";
			pridajY = pridajY + 15;
			render.text(font, x, y + pridajY, picovina, colors.otherColor:get_color(), render.align_center, render.align_center);
		end
		if (fakeduckEnable:get_bool() and refs.fakeduckInd:get_bool()) then
			local picovina = "FAKEDUCK";
			pridajY = pridajY + 15;
			render.text(font, x, y + pridajY, picovina, colors.otherColor:get_color(), render.align_center, render.align_center);
		end
		if (hsonlyEnable:get_bool() and refs.hsonlyInd:get_bool()) then
			local picovina = "HEADSHOT";
			pridajY = pridajY + 15;
			render.text(font, x, y + pridajY, picovina, colors.otherColor:get_color(), render.align_center, render.align_center);
		end
		if (safepointEnable:get_bool() and refs.safepointInd:get_bool()) then
			local picovina = "SAFE";
			pridajY = pridajY + 15;
			render.text(font, x, y + pridajY, picovina, colors.otherColor:get_color(), render.align_center, render.align_center);
		end
		if (dormantEnable:get_bool() and refs.dormantOnKey:get_bool()) then
			local picovina = "DORMANT";
			pridajY = pridajY + 15;
			render.text(font, x, y + pridajY, picovina, colors.otherColor:get_color(), render.align_center, render.align_center);
		end
		if damageIndicator:get_bool() then
			if (getWeapon() == "Auto") then
				damagerMin = gui.get_config_item("Rage>Aimbot>autosniper>Auto>Min-damage");
				damagerOver = gui.get_config_item("Rage>Aimbot>autosniper>Auto>Override");
				damagerOverMin = gui.get_config_item("Rage>Aimbot>autosniper>Auto>Min-damage override");
			elseif ((getWeapon() == "Heavy pistols") or (getWeapon() == "Deagle")) then
				damagerMin = gui.get_config_item("Rage>Aimbot>heavy_pistol>Heavy Pistols>Min-damage");
				damagerOver = gui.get_config_item("Rage>Aimbot>heavy_pistol>Heavy Pistols>Override");
				damagerOverMin = gui.get_config_item("Rage>Aimbot>heavy_pistol>Heavy Pistols>Min-damage override");
			elseif (getWeapon() == "Pistols") then
				damagerMin = gui.get_config_item("Rage>Aimbot>Pistol>Pistols>Min-damage");
				damagerOver = gui.get_config_item("Rage>Aimbot>Pistol>Pistols>Override");
				damagerOverMin = gui.get_config_item("Rage>Aimbot>Pistol>Pistols>Min-damage override");
			elseif (getWeapon() == "Scout") then
				damagerMin = gui.get_config_item("Rage>Aimbot>ssg08>Scout>Min-damage");
				damagerOver = gui.get_config_item("Rage>Aimbot>ssg08>Scout>Override");
				damagerOverMin = gui.get_config_item("Rage>Aimbot>ssg08>Scout>Min-damage override");
			elseif (getWeapon() == "AWP") then
				damagerMin = gui.get_config_item("Rage>Aimbot>AWP>AWP>Min-damage");
				damagerOver = gui.get_config_item("Rage>Aimbot>AWP>AWP>Override");
				damagerOverMin = gui.get_config_item("Rage>Aimbot>AWP>AWP>Min-damage override");
			elseif (getWeapon() == "Other") then
				damagerMin = gui.get_config_item("Rage>Aimbot>Other>Other>Min-damage");
				damagerOver = gui.get_config_item("Rage>Aimbot>Other>Other>Override");
				damagerOverMin = gui.get_config_item("Rage>Aimbot>Other>Other>Min-damage override");
			else
				return;
			end
			if damagerOver:get_bool() then
				render.text(font, x + 20, y - 15, damagerOverMin:get_int(), colors.damageColor:get_color(), render.align_center, render.align_center);
			else
				render.text(font, x + 20, y - 15, damagerMin:get_int(), colors.damageColor:get_color(), render.align_center, render.align_center);
			end
		end
	end
end
function enchanceStuff()
	if (stuffy.revolverOffFakelag:get_int() == 1) then
		if (getWeapon() == "Heavy pistols") then
			if (refs.fakelagMenu:get_int() ~= 0) then
				refs.fakelagMenu:set_int(0);
			end
		elseif (stuffy.restoreFakelagMode:get_int() == 0) then
			refs.fakelagMenu:set_int(0);
		elseif (stuffy.restoreFakelagMode:get_int() == 1) then
			refs.fakelagMenu:set_int(1);
		elseif (stuffy.restoreFakelagMode:get_int() == 2) then
			refs.fakelagMenu:set_int(2);
		end
	elseif (stuffy.revolverOffFakelag:get_int() == 2) then
		if (getWeapon() == "Heavy pistols") then
			if (refs.fakelagMenu:get_int() ~= 0) then
				if refs.aimbotInd:get_bool() then
					refs.fakelagMenu:set_int(0);
				end
			elseif not refs.aimbotInd:get_bool() then
				if (stuffy.restoreFakelagMode:get_int() == 0) then
					refs.fakelagMenu:set_int(0);
				elseif (stuffy.restoreFakelagMode:get_int() == 1) then
					refs.fakelagMenu:set_int(1);
				elseif (stuffy.restoreFakelagMode:get_int() == 2) then
					refs.fakelagMenu:set_int(2);
				end
			end
		end
	end
	if stuffy.autoRevolverOnAimbot:get_bool() then
		if refs.aimbotInd:get_bool() then
			refs.revolverik:set_bool(true);
		else
			refs.revolverik:set_bool(false);
		end
	end
	if stuffy.dormantBind:get_bool() then
		refs.dormantOnKey:set_bool(true);
	else
		refs.dormantOnKey:set_bool(false);
	end
end
function antiaimEnchance()
	if showDisablers:get_bool() then
		if (disablerOnDoubletap:get_bool() and not disablerOnHideshot:get_bool()) then
			if refs.doubletapInd:get_bool() then
				refs.fakelagAmmount:set_int(1);
				saved.exploits = true;
			elseif saved.exploits then
				refs.fakelagAmmount:set_int(saved.fakeLagValue);
				saved.exploits = false;
			else
				saved.fakeLagValue = refs.fakelagAmmount:get_int();
			end
		elseif (not disablerOnDoubletap:get_bool() and disablerOnHideshot:get_bool()) then
			if refs.hideshotsInd:get_bool() then
				refs.fakelagAmmount:set_int(1);
				saved.exploits = true;
			elseif saved.exploits then
				refs.fakelagAmmount:set_int(saved.fakeLagValue);
				saved.exploits = false;
			else
				saved.fakeLagValue = refs.fakelagAmmount:get_int();
			end
		elseif (disablerOnDoubletap:get_bool() and disablerOnHideshot:get_bool()) then
			if (refs.hideshotsInd:get_bool() or refs.doubletapInd:get_bool()) then
				refs.fakelagAmmount:set_int(1);
				saved.exploits = true;
			elseif saved.exploits then
				refs.fakelagAmmount:set_int(saved.fakeLagValue);
				saved.exploits = false;
			else
				saved.fakeLagValue = refs.fakelagAmmount:get_int();
			end
		end
	end
end
function on_create_move()
	enchanceStuff();
end
function on_paint()
	if (slowwalk_box:get_bool() == true) then
		gui.set_visible("Misc>Various>Speed", true);
		local is_down = input.is_key_down(16);
		if not is_down then
			set_speed(450);
		else
			local final_val = (250 * slowwalk_slider:get_float()) / 100;
			set_speed(final_val);
		end
	else
		gui.set_visible("Misc>Various>Speed", false);
	end
	if skybox_bool_checkbox:get_bool() then
		cvar.sv_skyname:set_string(skybox_value_textbox:get_string());
		skybox_bool_checkbox:set_bool(false);
	end
	CT();
	if Muted:get_bool() then
		chat:set_int(0);
		voice_chat:set_int(0);
	else
		chat:set_int(63);
		voice_chat:set_int(1);
	end
	local showManual, showFreestand, showIndi, showAdvInd, showImprovment, showRestoreFakelag, showDisablersFL = showIndicators:get_bool(), showImprovments:get_bool(), stuffy.revolverOffFakelag:get_int() > 0, sVis("Misc>Various>Lua indicator mark", showIndicators:get_bool());
	sVis("Misc>Various>Indicator Selection", showIndicators:get_bool());
	sVis("Misc>Various>Advanced Indicators", showIndicators:get_bool());
	sVis("Misc>Various>Dormant on Key", showImprovments:get_bool());
	sVis("Misc>Various>Turn on Autorevolver on Aimbot", showImprovments:get_bool());
	sVis("Misc>Various>Fakelag Off on Revolver", showImprovments:get_bool());
	sVis("Misc>Various>Disablers", showImprovments:get_bool());
	sVis("Misc>Various>Restore Fakelag if not Revolver", showImprovments:get_bool());
	if not engine.is_in_game() then
		return;
	end
	skeetind();
	keybinds.handle();
	watermark.handle();
	enchanceStuff();
	pizdablat();
end
MN611 = gui.add_listbox("             ", "Misc>Various", 1, false, {"Comands"});
_DEBUG = true;
local stats = {"Follow Players Movement","All Freeze","All Crouching","Not firing","Ignore Players"};
local function practice()
	engine.exec("sv_cheats 1; mp_limitteams 0; mp_autoteambalance 0; mp_roundtime 60; mp_roundtime_defuse 60; mp_maxmoney 60000; mp_startmoney 60000; mp_freezetime 0; mp_buytime 9999; mp_buy_anywhere 1; sv_infinite_ammo 1; ammo_grenade_limit_total 5; bot_kick; bot_stop 1; mp_warmup_end; mp_restartgame 1; mp_respawn_on_death_ct 1; mp_respawn_on_death_t 1; sv_airaccelerate 500;");
end
local function setup()
	engine.exec("sv_cheats 1;Impulse 101;sv_airaccelerate 9999;bot_stop all;mp_roundtime_defuse 60;sv_infinite_ammo 1;mp_limitteams 0;mp_autoteambalance 0;mp_buytime 100000;mp_freezetime 1;mp_ignore_round_win_conditions 1;");
end
local function setup2()
	engine.exec("mp_restartgame 1");
end
local function setup3()
	engine.exec("impulse 101");
end
local function setup4()
	engine.exec("bot_add;bot_add;bot_add;bot_add;bot_add;bot_add;bot_add;bot_add;bot_add;");
end
local function setup8()
	engine.exec("bot_kick");
end
local function setup7()
	engine.exec("give weapon_ssg08;give weapon_scar20;give weapon_awp;give weapon_deagle");
end
local function setup9()
	engine.exec("give weapon_hegrenade;give weapon_incgrenade;give weapon_smokegrenade;give weapon_flashbang");
end
local function re_active()
	engine.exec("mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0");
end
local function setup10()
	engine.exec("mp_respawn_on_death_ct 1;mp_respawn_on_death_t 1");
	utils.run_delayed(5000, function()
		re_active();
	end);
end
local antiaim = gui.get_config_item("rage>anti-aim>angles>anti-aim");
local function setup11()
	antiaim:set_bool(false);
	utils.run_delayed(30, function()
		engine.exec("bot_place");
	end);
	utils.run_delayed(30, function()
		antiaim:set_bool(true);
	end);
end
local function setup14()
	engine.exec("bot_add_t");
end
local function setup15()
	engine.exec("bot_add_ct");
end
local function rethrow()
	engine.exec("sv_rethrow_last_grenade");
end
gui.add_button("		Exec Practice CFG		", "Misc>Various", practice);
gui.add_button("		Load Warmup Config		", "Misc>Various", setup);
gui.add_button("		Restart Game		", "Misc>Various", setup2);
gui.add_button("		Gain Money		", "Misc>Various", setup3);
gui.add_button("		Kick All bots		", "Misc>Various", setup8);
gui.add_button("		Fill Server with bots		", "Misc>Various", setup4);
gui.add_button("		Give All Sniper Rifles		", "Misc>Various", setup7);
gui.add_button("		Give All nades		", "Misc>Various", setup9);
gui.add_button("		Respawn All bots		", "Misc>Various", setup10);
gui.add_button("		Place a bot		", "Misc>Various", setup11);
gui.add_button("      Rethrow last grenade", "Misc>Various", rethrow);
local follow, freeze, crouch, firing, ignore = gui.add_multi_combo("Bot Status", "Misc>Various", stats);
local function setup13()
	if freeze:get_bool() then
		engine.exec("bot_stop 1;");
	else
		engine.exec("bot_stop 0;");
	end
	if crouch:get_bool() then
		engine.exec("bot_crouch 1;");
	else
		engine.exec("bot_crouch 0;");
	end
	if follow:get_bool() then
		engine.exec("bot_mimic 1;");
	else
		engine.exec("bot_mimic 0;");
	end
	if firing:get_bool() then
		engine.exec("bot_dont_shoot 1;");
	else
		engine.exec("bot_dont_shoot 0;");
	end
	if ignore:get_bool() then
		engine.exec("bot_ignore_players 1 1;");
	else
		engine.exec("bot_ignore_players 0 0;");
	end
end
gui.add_button("Update Bot Status", "Misc>Various", setup13);
gui.add_button("       Add bot to T       ", "Misc>Various", setup14);
gui.add_button("       Add bot to CT      ", "Misc>Various", setup15);
function on_player_death(event)
	if not tt:get_bool() then
		return;
	end
	local lp = engine.get_local_player();
	local attacker = engine.get_player_for_user_id(event:get_int("attacker"));
	local userid = engine.get_player_for_user_id(event:get_int("userid"));
	if ((attacker == lp) and (userid ~= lp)) then
		engine.exec(string.format('say \"%s\"', first[utils.random_int(1, #first)]));
	end
end
fakelaglim = gui.get_config_item("Rage>Anti-Aim>Fakelag>Limit");
aaYaw = gui.get_config_item("Rage>Anti-Aim>Angles>Yaw");
aaYawadd = gui.get_config_item("Rage>Anti-Aim>Angles>Yaw add");
Pitch = gui.get_config_item("rage>anti-aim>angles>pitch");
Yaw = gui.get_config_item("rage>anti-aim>angles>yaw");
YawAdd = gui.get_config_item("rage>anti-aim>angles>yaw add");
YawAddValue1 = gui.get_config_item("rage>anti-aim>angles>add");
YawAddValue = gui.get_config_item("rage>anti-aim>angles>add");
Fake = gui.get_config_item("rage>anti-aim>desync>Fake");
FakeAmount = gui.get_config_item("rage>anti-aim>desync>Fake amount");
CompensateAngle = gui.get_config_item("rage>anti-aim>desync>Compensate angle");
Spin = gui.get_config_item("rage>anti-aim>angles>spin");
SpinRange = gui.get_config_item("rage>anti-aim>angles>spin range");
SpinSpeed = gui.get_config_item("rage>anti-aim>angles>spin speed");
Jitter = gui.get_config_item("rage>anti-aim>angles>jitter");
RandomJitter = gui.get_config_item("rage>anti-aim>angles>random");
JitterRange = gui.get_config_item("rage>anti-aim>angles>jitter range");
AntiAimOverride = gui.get_config_item("rage>anti-aim>angles>antiaim override");
dt = gui.get_config_item("rage>aimbot>aimbot>Double Tap");
hs = gui.get_config_item("rage>aimbot>aimbot>Hide shot");
fake_lag_mod = dd("Mod-Fake-Lag", "Rage>Anti-Aim>Fakelag", {"Off","Fucture","Minimal","Masiv"});
local fake_lag_fuct = utils.new_timer(5, function()
	if (fake_lag_mod:get_int() == 1) then
		fakelaglim:set_float(2);
	end
end);
fake_lag_fuct:start();
local fake_lag_fuct1 = utils.new_timer(10, function()
	if (fake_lag_mod:get_int() == 1) then
		fakelaglim:set_float(4);
	end
end);
fake_lag_fuct1:start();
local fake_lag_fuct2 = utils.new_timer(15, function()
	if (fake_lag_mod:get_int() == 1) then
		fakelaglim:set_float(6);
	end
end);
fake_lag_fuct2:start();
local fake_lag_fuct3 = utils.new_timer(20, function()
	if (fake_lag_mod:get_int() == 1) then
		fakelaglim:set_float(12);
	end
end);
fake_lag_fuct3:start();
local fake_lag_fuct4 = utils.new_timer(25, function()
	if (fake_lag_mod:get_int() == 1) then
		fakelaglim:set_float(14);
	end
end);
fake_lag_fuct4:start();
local fake_lag_minimal = utils.new_timer(5, function()
	if (fake_lag_mod:get_int() == 2) then
		fakelaglim:set_float(1);
	end
end);
fake_lag_fuct:start();
local fake_lag_minimal1 = utils.new_timer(10, function()
	if (fake_lag_mod:get_int() == 2) then
		fakelaglim:set_float(2);
	end
end);
fake_lag_minimal1:start();
local fake_lag_minimal2 = utils.new_timer(15, function()
	if (fake_lag_mod:get_int() == 2) then
		fakelaglim:set_float(3);
	end
end);
fake_lag_minimal2:start();
local fake_lag_minimal3 = utils.new_timer(20, function()
	if (fake_lag_mod:get_int() == 2) then
		fakelaglim:set_float(4);
	end
end);
fake_lag_minimal3:start();
local fake_lag_minimal4 = utils.new_timer(25, function()
	if (fake_lag_mod:get_int() == 2) then
		fakelaglim:set_float(6);
	end
end);
fake_lag_minimal4:start();
local fake_lag_masiv = utils.new_timer(5, function()
	if (fake_lag_mod:get_int() == 3) then
		fakelaglim:set_float(16);
	end
end);
fake_lag_fuct:start();
local fake_lag_masiv1 = utils.new_timer(10, function()
	if (fake_lag_mod:get_int() == 3) then
		fakelaglim:set_float(40);
	end
end);
fake_lag_masiv1:start();
local fake_lag_masiv2 = utils.new_timer(15, function()
	if (fake_lag_mod:get_int() == 3) then
		fakelaglim:set_float(60);
	end
end);
fake_lag_masiv2:start();
local fake_lag_masiv3 = utils.new_timer(20, function()
	if (fake_lag_mod:get_int() == 3) then
		fakelaglim:set_float(120);
	end
end);
fake_lag_masiv3:start();
local fake_lag_masiv4 = utils.new_timer(25, function()
	if (fake_lag_mod:get_int() == 3) then
		fakelaglim:set_float(180);
	end
end);
fake_lag_masiv4:start();
local lerp = function(precenteges, start, destination)
	return start + ((destination - start) * precenteges);
end;
function get_velocity()
	if not engine.is_in_game() then
		return;
	end
	local first_velocity = entities.get_entity(engine.get_local_player()):get_prop("m_vecVelocity[0]");
	local second_velocity = entities.get_entity(engine.get_local_player()):get_prop("m_vecVelocity[1]");
	local speed = math.floor(math.sqrt((first_velocity * first_velocity) + (second_velocity * second_velocity)));
	return speed;
end
function get_state(speed)
	if not engine.is_in_game() then
		return;
	end
	if not entities.get_entity(engine.get_local_player()):is_alive() then
		return;
	end
	local flags = entities.get_entity(engine.get_local_player()):get_prop("m_fFlags");
	if (bit.band(flags, 1) == 1) then
		if ((bit.band(flags, 4) == 4) or info.fatality.in_fakeduck) then
			return 4;
		elseif (speed <= 3) then
			return 1;
		elseif info.fatality.in_slowwalk then
			return 3;
		else
			return 2;
		end
	elseif (bit.band(flags, 1) == 0) then
		if (bit.band(flags, 4) == 4) then
			return 5;
		else
			return 6;
		end
	end
end
local enabled, onairrrr = gui.add_multi_combo("DF-AA", "Rage>Anti-Aim>Desync", {"defensive on peek","defensive enable"});
local enabled, crch = gui.add_multi_combo("DF-ON", "Rage>Anti-Aim>Desync", {"defensive on air","defensive on crouch"});
local dt = gui.get_config_item("rage>aimbot>aimbot>Double Tap");
local hs = gui.get_config_item("rage>aimbot>aimbot>Hide shot");
local fl_frozen = bit.lshift(1, 6);
local in_attack = bit.lshift(1, 0);
local in_attack2 = bit.lshift(1, 11);
local checker = 0;
local defensive = false;
function on_create_move(cmd)
	local me = entities.get_entity(engine.get_local_player());
	if (not me or not me:is_valid()) then
		return;
	end
	local tickbase = me:get_prop("m_nTickBase");
	defensive = math.abs(tickbase - checker) >= 2;
	checker = math.max(tickbase, checker or 0);
end
function on_player_spawn(event)
	if (engine.get_player_for_user_id(event:get_int("userid")) == engine.get_local_player()) then
		checker = 0;
	end
end
function on_run_command(cmd)
	local view_angles = cmd:get_view_angles();
	local state = get_state(get_velocity());
	if (not enabled:get_bool() or (not dt:get_bool() and not hs:get_bool())) then
		return;
	end
	local buttons = cmd:get_buttons();
	if ((bit.band(buttons, in_attack) == in_attack) or (bit.band(buttons, in_attack2) == in_attack2)) then
		return;
	end
	local me = entities.get_entity(engine.get_local_player());
	if (not me or not me:is_valid()) then
		return;
	end
	local flags = me:get_prop("m_fFlags");
	if (bit.band(flags, fl_frozen) == fl_frozen) then
		return;
	end
	if (info.fatality.lag_ticks > 1) then
		return;
	end
	if defensive then
		cmd:set_view_angles(utils.random_int(-78, 30), utils.random_int(360, 1), 0);
	end
	local jitterrange = gui.get_config_item("rage>anti-aim>Angles>Jitter range"):get_int();
	local view_angles = cmd:get_view_angles();
	if onairrrr:get_bool() then
		if (state == 6) then
			cmd:set_view_angles(utils.random_int(-89, 100), utils.random_int(-360, 360), 0);
		end
		local jitterrange = gui.get_config_item("rage>anti-aim>Angles>Jitter range"):get_int();
		local view_angles = cmd:get_view_angles();
		if crch:get_bool() then
			if (state == 5) then
				cmd:set_view_angles(utils.random_int(-89, 89), utils.random_int(-360, 360), 0);
			end
			if (state == 4) then
				cmd:set_view_angles(utils.random_int(-89, 100), utils.random_int(-100, 260), 0);
			end
		end
	end
end

--#credits @ensixten deobfuscating
