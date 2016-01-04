-- $Name: Королевство Эйфория$
-- $Version: 0.2.4$
-- $Author: Очинский Валерий$
instead_version "2.1.0"
game.forcedsc = true;
stead.scene_delim = '^'
--require "dbg"
require "prefs"
require "para"
require "dash"
require "quotes"
require "kbd"
require "preload"
require "xact"
require "sound"
require "timer"
require "lib/trigger"
require "lib/fonts"
require "lib/cutscene"
require "funcs"
require "lib/iolib"
dofile "eiforia.lua"
game.enable_save = false
function init()
	lifeon(mplayer);
	setunderline(500);
	if prefs.music == nil then
		prefs.music = true;
	end;
	if prefs.maxwife == nil then
		prefs.maxwife = 1;
	end;
--	take (hookobj);
--	take (unhookobj);
end;

function start()
	if prefs.music then
		if here().menuroom and sound.playing(1) ~= main_snd then
			sound.stop(1);
			sound.play(main_snd, 1)
		elseif not here().menuroom and sound.playing(1) ~= game_snd then
			sound.stop(1);
			sound.play(game_snd, 1)
		end;
	end;
end;
--hookobj = menu { nam = "hookobj"; disp = "hook_all"; menu = code [[return hook_all();]]}
--unhookobj = menu { nam = "unhookobj"; disp = "unhook_all"; menu = code [[return unhook_all();]]}

main = room {
	nam = "Главное меню";
	menuroom = true;
	pic = "gfx/main.png";
	entered = code [[hook_all()]];
--	exit = code [[unhook_all()]];
	kbd = function(s, down, key)
		if down then
			if key == "1" then
				click();
				return start_game();
			elseif key == "2" then
				click();
				return walk(help);
			elseif key == "3" then
				click();
				return walk(settings);
			elseif key == "4" then
				click();
				stead.menu_toggle('quit');
			end
		end
	end;
	dsc = [[Добо пожаловать в игру "Королевство Эйфория", версия 0.2.4. Если вы играете впервые, рекомендуется прочесть раздел "Помощь".^^
1. {newgame|Начать игру}^
2. {tohelp|Помощь}^
3. {sets|Настройки}^
4. {exit|Выход}
]];
	obj = {
	xact('newgame', code [[start_game()]]),
	xact('tohelp', code [[walk (help)]]),
	xact('sets', code [[walk (settings)]]),
	xact('exit', code [[stead.menu_toggle('quit')]])};
};
help = xenterroom {
	nam = "Помощь";
	menuroom = true;
	press = function(s) click(); walkout(); end;
	dsc = _andale ([[
      Нехитрые правила игры.^^
      Для вызова справки в любое время нажмите F1.^
      Для вызова меню параметров нажмите F2.^^
   Первое. Вашим подданным нужно кушать. На каждого человека - крестьянина или
гвардейца - нужно в год 3 тонны зерна (стандартная норма). Если дадите меньше,
то могут быть такие последствия: 1) дадите от 70% до 99%. Вас немного пожурят
и напомнят, что народ нужно кормить. 2) дадите от 40% до 69%. С вероятностью,
обратно пропорциональной выделенной норме, может произойти революция, и
Вас свергнут. А может и не произойти. 3) дадите < 40%. Гарантированно произойдет
революция, и Вас свергнут.^^
   Так что перед тем, как купить огромную армию крестьян или солдат, посмотрите -
а сможете ли Вы ее прокормить.^^
   Второе. Солдатам нужно ежегодно платить жалование. По 10 рублей за год каждому
солдату. Плюс еще 10 рублей начальнику стражи, который всегда на службе, даже если
под его началом - ни одного гвардейца. Если в казне не хватает денег на выплату
жалованья, то Ваша верная гвардия может просто-напросто дезертировать...^^
   Третье. Крестьянам для работы нужна земля. Если земли больше, чем крестьян,
то крестьяне обрабатывают ровно столько гектар земли, сколько их самих. Если крестьян
больше, чем земли, то они обрабатывают всю землю, а «лишние», те, которым земли
не хватило, могут сбежать от Вас. Сбегает обычно часть «лишних» крестьян.^^
   Учтите, что урожай может быть получен только с обрабатываемых земель. Каждый
гектар пашни требует для посева 1 тонну зерна. Дадите меньше, чем обрабатывается
земли, следовательно, засеете не всю возможную площадь, и часть обрабатываемой
земли простоит год впустую. Выделите лишнее зерно - просто
потратите его зря, так как будет посеяно все равно только необходимое количество
зерна, а остальное, выделенное для посева, пропадет впустую. Так что мой
Вам совет - выделяйте на посев именно столько зерна, сколько нужно.^^
   Описывать работу с биржей и всякую дипломатию не имеет смысла - там все элементарно.
Два слова можно сказать о караванах.^^
   Караван  -  достаточно редкая возможность быстро разбогатеть, если Вы готовы
рискнуть. Вложенные в караван деньги приносят шестикратную прибыль. Но не радуйтесь раньше
времени  -  не все так просто. Ваш караван могут запросто ограбить бандиты,
отняв у Вас изрядный кусок прибыли. А могут и не просто ограбить, а разграбить
полностью. И тогда плакали Ваши денежки...^^
   Не жадничайте, давайте на храм  митрополиту - ведь это богоугодное дело. Глядишь,
и действительно новый храм отгрохают.^^
   Да, и народу на Новый год выделяйте иногда - пусть повеселится.^^
   Пара слов насчет войны. Разведка сообщает не точную информацию о численности
противника, а приблизительную, с ошибкой ±25%. Учитывайте это.^^
   Кроме того, не все воюющие качественно обучены. Гвардеццы воюют, как правило, довольно хорошо.
Наёмники подбираются в спешке, поэтому могут воевать хуже, чем гвардейцы. А крестьяне,
конечно же, не обучены, и воители из них, прямо скажем, как из начинающего игрока правитель. 
   Война может возникнуть в трёх случаях: 1) Вы объявили войну соседям. Но уж если Вы объявили
войну, то потом отказаться уже не сможете. 2) У Вас мало солдат. Чем меньше у Вас солдат,
тем чаще будут нападать нахальные соседи. 3) Вы оскорбили какого-либо соседа
отказом жениться на его дочке. Оскорбленный сосед обязательно покатит на Вас бочку (то бишь
пойдет войной). Хотя, с другой стороны, согласившись на брак, Вы потратите кучу денег на
свадебный пир, а там еще, может быть, и на день рождения сына. Решайте сами, что Вам выгодней...
Успехов в управлении королевством.^^
Оригинальная версия на C++: Ponpa Dmitriy, 41PDM., версия на INSTEAD: Очинский Валерий, 2015. ^
Движок текстовых игр INSTEAD: Пётр Косых.^
Также использованы изображения и шрифты из открытых источников, в т. ч. с commons.wikimedia.org и pixbay.com.^
Музыка (скачано с Jamendo):
Thomass Eccard - Fairytail Kingdom: 2Invenions^
Kingdom: Antonio Torres Ruiz^
Звук клика взят из поставки INSTEAD.^
Тема оформления «Свиток (без инвентаря)»: excelenter.^
Благодарности:^
Всем, кто (как минимум) не мешал. :}
]]);
xdsc = make_enter("jumpout");
};

mplayer = obj {
	nam = 'mplayer';
	life = function(s)
		if sound.playing(1) and not prefs.music then
			sound.stop(1);
			return;
		end;
		if prefs.music then
			if here().menuroom and sound.playing(1) ~= main_snd then
				sound.stop(1);
				sound.play(main_snd, 1)
			elseif not here().menuroom and sound.playing(1) ~= game_snd then
				sound.stop(1);
				sound.play(game_snd, 1)
			end;
		end;
	end;
}

--[[
	Настройки:
	Меняет prefs переменные настройки.
	Синтаксис:
	Переключатель:
	{'Имя', 'boolean', 'вкл. состояние', 'выкл. состояние', 'prefs.имя'}
	Пример:
	{'Музыка', 'boolean', 'включена', 'выключена', 'music'}
	Число:
	{'Имя', 'number', минимальное число (nil -- 0), максимальное число (nil или 0 -- неограничено), шаг (nil -- 1), 'prefs.имя'}
	Пример:
	{'Максимальное кол-во жён', 'number', 1, 5, 1, 'maxwife'}
	Список:
	{'Имя', 'list', {{'в переменную 1', 'показать 1'}, {'в переменную 2', 'показать 2', и т. д.}}, 'prefs.имя'}
	Пример:
	{'Язык', 'list', {{'ru', 'русский'}, {'en', 'english'}}, 'lang'}
]]--
settings = xenterroom {
	nam = "Настройки игры";
	press = function(s) click(); walkout(); end;
	sets = {{'Музыка', 'boolean', 'включена', 'выключена', 'music'}, {'Максимальное кол-во жён', 'number', 1, 5, 1, 'maxwife'}};
	menuroom = true;
	switch = function(nam)
		if nam == 'out' then
			walkout();
			return;
		end;
		local i, n, t;
		for i in pairs(here().sets) do
			i = here().sets[i];
			if i[#i] == nam and i[2] == 'boolean' then
				local c = stead.eval('prefs.'..i[#i]..' = not prefs.'..i[#i]);
				c();
				prefs:save();
			elseif i[#i] == nam and i[2] == 'list' then
				local cur = evalvar('prefs.'..i[#i]);
				local pre = false;
				for n in pairs(i[3]) do
					t = i[3][n];
					if pre then
						pre = false;
						local c = stead.eval('prefs.'..i[#i]..' = "'..t[1]..'"');
--						print (evalvar('prefs.'..i[#i]));
						c();
--						print (evalvar('prefs.'..i[#i]));
						break;
					end;
					if t[1] == cur then
						pre = true;
					end;
				end;
				if pre then
					local c = stead.eval('prefs.'..i[#i]..' = "'..i[3][1][1]..'"');
					c();
				end;
				prefs:save();
			end;
		end;
	end;
	enter = function(s)
		s.obj:zap();
		local i;
		for i in pairs(s.sets) do
			i = s.sets[i];
			if i[2] == 'boolean' then
				local c = ('if prefs.'..i[5]..' then v="'..i[3]..'" else v="'..i[4]..'" end pn("'..i[1]..': {" .. v .. "}")');
				put (vobj (i[5], code (c)))
			elseif i[2] == 'number' then
				local plus = (i[#i]..'plus');
				local minus = (i[#i]..'minus');
				local mini = i[3] or 0;
				local maxi = i[4] > 0 and i[4] or nil;
				local step = i[5] or 1;
				local c = ('pn ("'..i[1]..': {'..minus..'|-} "..tostring(prefs.'..i[#i]..').." {'..plus..'|+}")');
				local plusc;
				if maxi then
					plusc = ('if prefs.'..i[#i]..'+'..tostring(step)..' <= '..tostring(maxi)..' then prefs.'..i[#i]..'=prefs.'..i[#i]..'+'..tostring(step)..'; prefs:save(); return true; end');
				else
					plusc = ('prefs.'..i[#i]..'=prefs.'..i[#i]..'+'..tostring(step)..'; prefs:save(); return true');
				end;
--				print(plusc);
				local minusc = ('if prefs.'..i[#i]..'-'..tostring(step)..' >= '..tostring(mini)..' then prefs.'..i[#i]..'=prefs.'..i[#i]..'-'..tostring(step)..'; prefs:save(); return true end');
--				print(minusc);
				put (vobj (i[#i], code (c)));
				put (xact(plus, code (plusc)));
				put (xact(minus, code (minusc)));
			elseif i[2] == 'list' then
				local c = ([[
					local i, n;
					for i in pairs(]]..stead.deref(s)..[[.sets) do
						i = ]]..stead.deref(s)..[[.sets[i];
						if i[2] == 'list' and i[4] == ']]..i[4]..[[' then
							for n in pairs(i[3]) do
								n = i[3][n];
								if prefs.]]..i[4]..[[ == n[1] then
									pn (']]..i[1]..[[: {'..n[2]..'}');
								end;
							end;
						end;
					end;]]
				);
				put (vobj (i[4], code (c)));
			end;
		end;
		put (vobj ('out', code [[return make_enter('jumpout')]]));
	end;
	act = function (s, w)
		s.switch (w)
		return true
	end
};
