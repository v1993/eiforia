-- Добавляем поддержку numlock

room = stead.inherit(room, function(v)
	v.kbd = stead.hook(v.kbd, function(f, s, down, key)
		if key == '[0]' or key == 'keypad 0' then
			key = '0';
		elseif key == '[1]' or key == 'keypad 1' then
			key = '1';
		elseif key == '[2]' or key == 'keypad 2' then
			key = '2';
		elseif key == '[3]' or key == 'keypad 3' then
			key = '3';
		elseif key == '[4]' or key == 'keypad 4' then
			key = '4';
		elseif key == '[5]' or key == 'keypad 5' then
			key = '5';
		elseif key == '[6]' or key == 'keypad 6' then
			key = '6';
		elseif key == '[7]' or key == 'keypad 7' then
			key = '7';
		elseif key == '[8]' or key == 'keypad 8' then
			key = '8';
		elseif key == '[9]' or key == 'keypad 9' then
			key = '9';
		elseif key == "enter" or key == "keypad enter" then
			key = 'return';
		elseif key == "f1" and here() ~= help and here() ~= settings then
			walkin (help);
			click();
			return;
		elseif key == "f2" and here() ~= settings and here() ~= help then
			walkin (settings);
			click();
			return;
		elseif key == "f1" and here() == help then
			walkout();
			click();
			return;
		elseif key == "f2" and here() == settings then
			walkout();
			click();
			return;
		end
		return f(s, down, key);
	end)
	return v;
end)

vobj = function(nam, dsc)
	local v = obj
	{
		nam = nam;
		dsc = dsc;
		act = function(s) return stead.call(where(s), 'act', stead.nameof(s)) end;
		save = function(self, name, h, need)
			-- self - текущий объект
			-- name -- полное имя переменной
			-- h - файловый дескриптор файла сохранения
			-- need - признак того, что это создание объекта, 
			-- файл сохранения должен создать объект 
			-- при загрузке
			local dsc;
			print(self.nam);
			if stead.type(self.dsc) == 'string' then
				dsc = self.dsc;
			else
				dsc = string.dump(self.dsc);
			end;
			print(dsc);
			if need then 
				-- в случае создания, запишем строку 
				-- с вызовом конструктора
				h:write(stead.string.format(
				"%s  = vobj(%s, %s);\n",
				name,
				-- формирование строк
				stead.tostring(self.nam),                                     
				stead.tostring(dsc)));
			end
			stead.savemembers(h, self, name, true); -- сохраним все 
			-- остальные переменные объекта
			-- например, состояние включен/выключен
			-- итд
			-- false в последней позиции означает что будет 
			-- передано в save-методы вложенных объектов в 
			-- качестве параметра need
			end;
		};
	return v;
end;
