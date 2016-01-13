require "kbd"
require "xact"
require "timer"

function evalvar(n)
        local f = stead.eval('return '..n);
        if f then
                return f()
        end
end

stead.module_init(function()
	global {underlinenow = "_"; };
	hook_keys('f1', 'f2');
	return true
end);

function _walk(where)
  return function()
    return walk(where);
  end
end;

function round(num, idp)
  return math.ceil(num)
end


-- Хукаем цифры, кейпад и управление

hook_numbers = function()
	return hook_keys('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
end

unhook_numbers = function()
	return unhook_keys('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
end

hook_keypad = function()
	return hook_keys('[0]', '[1]', '[2]', '[3]', '[4]', '[5]', '[5]', '[6]', '[7]', '[8]', '[9]', 'keypad 0', 'keypad 1', 'keypad 2', 'keypad 3', 'keypad 4', 'keypad 5', 'keypad 6', 'keypad 7', 'keypad 8', 'keypad 9')
end

unhook_keypad = function()
	return unhook_keys('[0]', '[1]', '[2]', '[3]', '[4]', '[5]', '[5]', '[6]', '[7]', '[8]', '[9]', 'keypad 0', 'keypad 1', 'keypad 2', 'keypad 3', 'keypad 4', 'keypad 5', 'keypad 6', 'keypad 7', 'keypad 8', 'keypad 9')
end

hook_controls = function()
	return hook_keys("enter", "keypad enter", 'backspace', 'return')
end

hook_enter = function()
	return hook_keys("enter", "keypad enter", 'return');
end;

unhook_controls = function()
	return unhook_keys("enter", "keypad enter", 'backspace', 'return')
end

hook_yesno = function()
	return hook_keys("y", "n")
end

unhook_yesno = function()
	return unhook_keys("y", "n")
end

unhook_enter = function()
	return unhook_keys("enter", "keypad enter", 'return');
end;

hook_all = function()
	hook_numbers();
	hook_keypad();
	hook_yesno();
	return hook_controls();
end

unhook_all = function()
	unhook_numbers();
	unhook_keypad();
	unhook_yesno();
	return unhook_controls();
end

game.timer = function()
	if underlinenow ~= "" then
		underlinenow = ""
	else
		underlinenow = prefs.underline
	end
	return true;
end

setunderline = function(delay)
	timer:stop();
	if prefs.underline ~= nil and delay ~= nil then
		timer:set(delay)
	end
end

numberinputcancelxact = xact('numberinputcancelxact', function(s, w) return stead.call(stead.ref(w), 'reaction', 0); end);
numberinputbase = function(v)
	local v = v or {};
	if v.nam == nil then
		v.nam = "numberinputentry";
	end
	v.act = function(s)
		return stead.call(s, 'kbd', true, 'return');
	end;
	--if v.msg == nil then
		--v.msg = "Введите число:";
	--end
	v.kbd = function(s, down, key)
		if not down then
			return true
		end;
		if s.extradsc ~= nil then
			s.extradsc = "";
		end
		if key == 'return' then
			if s.text == "" then
				return true;
			else
				local text = s.text;
				s.text = "";
				return stead.call(s, 'reaction', text);
			end;
		end;
		if key == 'backspace' then
			if s.text == "" then
				return true
			else
				s.text = s.text:sub(1, s.text:len() - 1);
				return true
			end;
		end;
		if key == '0' or key == '1' or key == '2' or key == '3' or key == '4' or key == '5' or key == '6' or key == '7' or key == '8' or key == '9' then
			s.text = s.text..key;
			return true;
		end;
	end;
	v.dsc = function(s)
		local msg = "";
		msg = tostring (stead.call(s, 'msg'));
		if s.extradsc ~= nil then
			p (txtem(s.extradsc));
			p "^";
		end
		if underlinenow ~= nil then
			pn (msg..s.text..underlinenow);
		else
			pn (msg..s.text.."_"); -- Такого не должно быть!
		end;
		pn ("{"..enterimg.."}");
		pr "{numberinputcancelxact(";
		pr (stead.deref(s));
		pr "|Отмена}";
		return true
	end;
	return obj(v);
end;
numberinput = function(reaction, msg, nam)
	local v = numberinputbase({});
	stead.add_var(v, { text = "" });
	stead.add_var(v, { extradsc = "" });
	stead.add_var(v, { msg = msg });
	if not nam then
		nam = "numberinputentry";
	end
	if not msg then
		v.msg = "Введите число:";
	end
	v.reaction = reaction or "ERROR";
	--hook_keys('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '[0]', '[1]', '[2]', '[3]', '[4]', '[5]', '[5]', '[6]', '[7]', '[8]', '[9]', 'backspace', 'return');
	return obj(v);
end
enterroom = function(v)
	v.entered = code [[hook_enter()]];
	v.exit = code [[unhook_enter()]];
	v.kbd = function(s, down, key)
		if down and key == "return" then
			return stead.call(s, 'press');
		end
	end;
	if v.press == nil then
		error "enterroom -- press attr not found.";
	end
	return room(v);
end;

xenterroom = function(v)
	v.entered = code [[hook_enter()]];
	v.exit = code [[unhook_enter()]];
	v.kbd = function(s, down, key)
		if down and key == "return" then
			click();
			return stead.call(s, 'press');
		end
	end;
	if v.press == nil then
		error "xenterroom -- press attr not found.";
	end
	return xroom(v);
end;

yesselect = xact("yesselect", code [[return stead.call(here(), 'yes')]]);
noselect = xact("noselect", code [[return stead.call(here(), 'no')]]);

yesnoroom = function(v)
	stead.add_var(v, { selected = false });
	v.entered = v.entered or code [[hook_yesno()]];
	v.exit = v.exit or code [[unhook_yesno()]];
	v.kbd = function(s, down, key)
		if down and not selected and key == "y" or key == "n" then
			if down and key == "y" then
				r,v = stead.call(s, 'yes');
				if v ~= nil then
					s.selected = v;
				end;
				click();
				return r,v;
			end;
			if down and key == "n" then
				r,v = stead.call(s, 'no');
				if v ~= nil then
					s.selected = v;
				end;
				click();
				return r,v;
			end;
		end;
	end;
	if v.yes == nil or v.no == nil then
		error "yesnoroom -- yes or no attrs not found.";
	end;
	if v.question == nil then
		error "yesnoroom -- question attr not found.";
	end;
	v.dsc = function(s)
		pn (stead.call (s, "question"));
		pn ("{yesselect|"..yimg.."}/{noselect|"..nimg.."}");
	end;
	if v.pic == nil then
		v.pic = "gfx/question.png";
	end;
	return room(v);
end;
xyesnoroom = function(v)
	stead.add_var(v, { selected = false });
	v.entered = v.entered or code [[hook_yesno()]];
	v.exit = v.exit or code [[unhook_yesno()]];
	v.kbd = function(s, down, key)
		if down and not selected and key == "y" or key == "n" then
			if down and key == "y" then
				r,v = stead.call(s, 'yes');
				if v ~= nil then
					s.selected = v;
				end;
				click();
				return r,v;
			end;
			if down and key == "n" then
				r,v = stead.call(s, 'no');
				if v ~= nil then
					s.selected = v;
				end;
				click();
				return r,v;
			end;
		end;
	end;
	if v.yes == nil or v.no == nil then
		error "yesnoroom -- yes or no attrs not found.";
	end;
	if v.question == nil then
		error "yesnoroom -- question attr not found.";
	end;
	v.dsc = function(s)
		pn (stead.call (s, "question"));
		pn ("{yesselect|"..yimg.."}/{noselect|"..nimg.."}");
	end;
	if v.pic == nil then
		v.pic = "gfx/question.png";
	end;
	return xroom(v);
end;
checkinput = function(reaction, msg, comp, coff, nam)
	local v = numberinputbase({});
	stead.add_var(v, { text = "" });
	stead.add_var(v, { extradsc = "" });
	stead.add_var(v, { msg = msg });
	stead.add_var(v, { comp = stead.deref(comp) or 1 });
	stead.add_var(v, { coff = stead.deref(coff) or 1 });
	if not nam then
		nam = "numberinputentry";
	end
	if not msg then
		v.msg = "Введите число:";
	end
	reaction = stead.hook(reaction, function(f, s, text)
		local coff, comp;
		if stead.type(s.coff) == 'number' then
--			print "coff = s.coff";
			coff = s.coff;
		else
--			print "coff = evalvar(s.coff)"
			coff = evalvar(s.coff);
		end;
		if stead.type(s.comp) == 'number' then
--			print "comp = s.comp";
			comp = s.comp;
		else
--			print "comp = evalvar(s.comp)";
			comp = evalvar(s.comp);
		end;
--		print (coff);
--		print (comp);
--		print (stead.type(s.comp));
--		print (stead.type(comp));
		if tonumber(text)*coff > tonumber(comp) then
			s.msg = "Повторите ввод: ";
			s.extradsc = "У вас столько нет.";
			return true;
		end;
		return f(s, text)
	end)
	v.reaction = reaction or "ERROR";
	return obj(v);
end;
moneyinput = function(reaction, msg, nam)
	return checkinput (reaction, msg, 'cur_money', 1, nam)
end

--num1 = moneyinput(function(s, text) return text end);
--test = room {
	--dsc = "test";
	--nam = "test";
	--entered = code [[hook_all()]];
	--kbd = function (s, ...) return stead.call(warenter, 'kbd', ...) end;
	--obj = {warenter};
--}
