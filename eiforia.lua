-- Имена ресурсов в игре: mo(ney) go(ld) la(nd) ze(reno) kr(est) gu(ard)

start_game = function()
	cur_money=money;
	cur_gold=gold;
	cur_land=land;
	cur_zerno=zerno;
	cur_krest=krest;
	cur_guard=guard;
	triggers_reset();
	if rnd(100) < 25 then
		fl_block = 1;
	else
		fl_block = 0;
	end;
	return nextstep();
end;

-- Сброс переменных

vars_reset = function()
	-- текущее состояние ресурсов
	cur_money=0;cur_gold=0;cur_land=0;cur_zerno=0;cur_krest=0;cur_guard=0;
	build_xram=0;
	ochki=0;
	for_xram=0;
	fl_r=0;
	fl_mar_war=0;
	why_mar_war=0;
	fl_mal_war=0;
	why_mal_war=0;
	fl_kar=0;
	fl_marry=0;
	fl_end=0;
	fl_lec=0;
	god=1;
	-- Доп. переменные, юзаются где попало
	-- Королева
	year_marry = 0; -- На всякий случай
	-- Контроль цикла
	cstate = 0;
	ecstate = 0;
end;

triggers_reset = function()
	god_checker:on(1);
	ill_checker:on(2);
	rev_checker:on(3);
	end_checker:on(4);
end;

-- Очки
make_ochki = function(t)
	local p1=round(cur_money/1000);
	local p2=round(cur_gold*2);
	local p3=round(cur_land/5);
	local p4=round(cur_zerno/100);
	local p5=round(cur_krest/20);
	local p6=round(cur_guard/10);
	local p7=round(build_xram*200);
	local p8=round(god*10);
	if t then
		ochki=(p1+p2+p3+p4+p5+p6+p7+p8);
	else
		return p1, p2, p3, p4, p5, p6, nil, 'Очков дано', nil, nil, nil, false;
	end;
end;

-- Спец. функция обработки шагов

nextstep = function()
	local chtype = 0; retry = false;
	if cstate == 0 then
		make_price();
		walk "startyear";
	elseif cstate == 1 then
		if ecstate == 0 and fl_kar == 0 and rnd(100) < 25 then
			walk "snaradkar";
			chtype = 1;
		elseif ecstate == 0 then
			chtype = 1;
			retry = true;
		elseif ecstate == 1 and fl_kar > 0 and rnd(100) < 20 then
			walk "grabegkar";
			chtype = 1;
		elseif ecstate == 1 then
			chtype = 1;
			retry = true;
		elseif ecstate == 2 and rnd(100) < 20 then
			walk "mitropolit";
			chtype = 1;
		elseif ecstate == 2 then
			chtype = 1;
			retry = true;
		elseif ecstate == 3 and fl_mar_war == 1 then
			why_mar_war = 1;
			walk "war1";
			chtype = 1;
		elseif ecstate == 3 then
			chtype = 1;
			retry = true;
		elseif ecstate == 4 and rnd(100) > cur_guard then
			fl_mar_war=(why_mar_war==1 and 0);
			why_mar_war = 0;
			fl_mal_war = 1;
			why_mal_war = 1;
			walk "war1";
			chtype = 1;
		elseif ecstate == 4 and rnd(100) < 30 then
			fl_mar_war=(why_mar_war==1 and 0);
			why_mar_war = 0;
			walk "prewar";
			chtype = 1;
		elseif ecstate == 4 then
			fl_mar_war=(why_mar_war==1 and 0);
			why_mar_war = 0;
			chtype = 1;
			retry = true;
		elseif ecstate == 5 and fl_vis == 1 and rnd(100) < 15 then
			fl_mal_war=0;
			why_mal_war=0;
			walk "poimali_visir";
			chtype = 1;
		elseif ecstate == 5 then
			fl_mal_war=0;
			why_mal_war=0;
			chtype = 1;
			retry = true;
		elseif ecstate == 6 and rnd(100) < 10 then
			walk "nasledstvo";
			chtype = 1;
		elseif ecstate == 6 then
			chtype = 1;
			retry = true;
		elseif ecstate == 7 and rnd(100) < fl_marry*10 then
			walk "rodilsa_sin";
			chtype = 1;
		elseif ecstate == 7 then
			chtype = 1;
			retry = true;
		elseif ecstate == 8 and fl_marry < prefs.maxwife and rnd(100) < 15 then
			walk "svadba";
			chtype = 1;
		elseif ecstate == 8 then
			chtype = 1;
			retry = true;
		elseif ecstate == 9 and fl_marry > 0 and (year_marry == 0 or fl_marry > 1) and rnd(100) < 10 then
			walk "wife_dead1";
			chtype = 1;
		elseif ecstate == 9 then
			chtype = 1;
			retry = true;
		else
			ecstate = 0;
			retry = true;
		end;
	elseif cstate == 2 then
		if ecstate == 0 and fl_marry > 0 then
			walk "koroleva_prosit1";
			chtype = 1;
		elseif ecstate == 0 then -- На всякий случай
			chtype = 1;
			retry = true;
		elseif ecstate == 1 and rnd(100)<(god)*2 then
			walk "ill";
			chtype = 1;
		elseif ecstate == 1 then
			chtype = 1;
			retry = true;
		else
			ecstate = 0;
			retry = true;
		end;
	elseif cstate == 3 then
		walk "choicezerno1";
	elseif cstate == 4 then
		walk "isend";
	elseif cstate == 5 then
		walk "newyear";
	elseif cstate == 6 then
		make_turn();
		god = god + 1;
		walk "yeartoyear";
	else
		cstate = -1;
		retry = true;
	end;
	if chtype == 0 then
		cstate = cstate + 1;
	else
		ecstate = ecstate + 1;
	end;
	if retry then
		nextstep();
	end;
	return true;
end

function _nextstep()
  return function()
    return nextstep();
  end
end

-- Обработка года
make_turn = function()
	local a, b;
	-- Урожай
	fl_urog = rnd(5)-1;
	a = math.min(cur_land, cur_krest);
	b = math.min(a, for_posev);
	add_zerno = (fl_urog*2+3)*b;
	cur_zerno = add_zerno + cur_zerno;
	-- Крысы
	if rnd(100)<20 then
		eat_rat = round((rnd(20)*cur_zerno)/100);
		cur_zerno = cur_zerno - eat_rat;
	else
		eat_rat = 0;
	end;
	-- Обработка земля - крестьяне
	if cur_krest > cur_land then
		run_krest = rnd(cur_krest-cur_land);
		cur_krest = cur_krest - run_krest;
	else
		run_krest = 0;
	end;
	add_krest = round((cur_krest*(rnd(10)+6))/100);
	cur_krest = cur_krest + add_krest;
	-- Обработка гвардия - деньги
	abs_sod_guard = (cur_guard+1)*sod_guard;
	if abs_sod_guard > cur_money then
		run_guard = round((cur_guard*(rnd(10)+6))/100);
		cur_guard = cur_guard - run_guard;
		abs_sod_guard = (cur_guard+1)*sod_guard;
		abs_sod_guard = (abs_sod_guard <= cur_money) and abs_sod_guard or cur_money;
	else
		run_guard = 0;
	end;
	cur_money = cur_money - abs_sod_guard;
	-- Обработка похищения золота
	if cur_gold > 0 and rnd(100)<20 then
		grab_gold = round((rnd(25)*cur_gold)/100);
		grab_gold2 = grab_gold;
		cur_gold = cur_gold - grab_gold;
	else
		grab_gold = 0;
	end;
	if cur_money > 0 and rnd(100)<10 and fl_vis == 0 then
		grab_money = round((rnd(25)*cur_money)/100);
		grab_money2 = grab_money;
		cur_money = cur_money - grab_money
		fl_vis = 1;
	else
		grab_money = 0;
	end;
	make_price();
	if rnd(100) < 25 then
		fl_block = 1;
	else
		fl_block = 0;
	end;
	-- Обработка каравана
	if fl_kar > 0 then
		fl_kar = fl_kar + 1;
	end;
	if fl_kar == 6 then
		fl_kar = 0;
		kar_pribil = round(for_kar*6);
		cur_money=cur_money+kar_pribil;
	else
		kar_pribil = 0;
	end;
	-- Обработка королевы
	year_marry = 0;
	return true;
end;

-- люди склоняются
mannam = function(num)
	return sklon(num, "человек", "человека");
end

rubnam = function(num)
	return sklon2(num, "рубль", "рубля", "рублей");
end
sodnam = function(num)
	return sklon(num, "солдат", "солдата")
end

krestnam = function(num)
	return sklon2(num, "крестьянин", "крестьянина", "крестьян");
end

-- 1.2
sklon = function(num, t1, t2)
	local num1=tonumber(string.sub(tostring(num), -1));
	local num2=tonumber(string.sub(tostring(num), -2));
	if num2 > 10 and num2 < 20 then
		return t1
	elseif num1 == 0 or num1 == 1 or num1 == 5 or num1 == 6 or num1 == 7 or num1 == 8 or num1 == 9 then
		return t1
	else
		return t2
	end
end
-- 1.2.0
sklon2 = function(num, t1, t2, t3)
	local num1=tonumber(string.sub(tostring(num), -1));
	local num2=tonumber(string.sub(tostring(num), -2));
	if num2 > 10 and num2 < 20 then
		return t3
	elseif num1 == 0 or num1 == 5 or num1 == 6 or num1 == 7 or num1 == 8 or num1 == 9 then
		return t3
	elseif num1 == 1 then
		return t1
	else
		return t2
	end
end;
-- 1.2
sklon3 = function(num, t1, t2)
	return sklon2(num, t1, t2, t2)
end;

-- 1.2
sklon4 = function(num, t1, t2)
	return sklon2(num, t1, t1, t2)
end;

nextstep_xact = xact('nextstep_xact', code [[return nextstep()]]);

deftable = function(mo, go, la, ze, kr, gu, firl, secl, startprint, endprint, hat, typeprint)
	if mo == nil and go == nil and la == nil and ze == nil and kr == nil and gu == nil then
		return true
	end
	if startprint then
		p "^";
	end;
	if typeprint == nil then typeprint = true; end;
	if hat == true or hat == nil then
		p (txttab '0%');
		p (firl or 'Название');
		p (txttab '35%');
		p (secl or 'Запасы');
	end;
	if mo ~= nil then
		p "^"
		p (txttab '0%');
		p (typeprint and 'Деньги, рублей' or 'Деньги');
		p (txttab '35%');
		p (mo);
	end;
	if go ~= nil then
		p "^"
		p (txttab '0%');
		p (typeprint and 'Золото, кг' or 'Золото');
		p (txttab '35%');
		p (go);
	end;
	if la ~= nil then
		p "^"
		p (txttab '0%');
		p (typeprint and 'Земля, га' or 'Земля');
		p (txttab '35%');
		p (la);
	end;
	if ze ~= nil then
		p "^"
		p (txttab '0%');
		p (typeprint and 'Зерно, тонн' or 'Зерно');
		p (txttab '35%');
		p (ze);
	end;
	if kr ~= nil then
		p "^"
		p (txttab '0%');
		p (typeprint and 'Крестьяне, душ' or 'Крестьяне');
		p (txttab '35%');
		p (kr);
	end;
	if gu ~= nil then
		p "^"
		p (txttab '0%');
		p (typeprint and 'Гвардия, человек' or 'Гвардия');
		p (txttab '35%');
		p (gu);
	end;
	if endprint then
		p "^";
	end;
end
moneytable = function(extramode, startprint)
	if startprint == true or startprint == nil then
		p "^";
	end;
	if not extramode then
		if deftable(cur_money, cur_gold, cur_land, cur_zerno, cur_krest, cur_guard) ~= nil then
			return (deftable(cur_money, cur_gold, cur_land, cur_zerno, cur_krest, cur_guard).."^");
		else
			return "^";
		end;
	else
		p (txttab '0%');
		p 'Название';
		p (txttab '35%');
		p 'Запасы';
		p (txttab '70%');
		p 'Текущая цена';
		p "^";
		p (txttab '0%');
		p 'Деньги, рублей';
		p (txttab '35%');
		p (cur_money);
		p (txttab '70%');
		p '1';
		p "^";
		p (txttab '0%');
		p 'Золото, кг';
		p (txttab '35%');
		p (cur_gold);
		p (txttab '70%');
		p (cur_pr_gold);
		p "^";
		p (txttab '0%');
		p 'Земля, га';
		p (txttab '35%');
		p (cur_land);
		p (txttab '70%');
		p (cur_pr_land);
		p "^";
		p (txttab '0%');
		p 'Зерно, тонн';
		p (txttab '35%');
		p (cur_zerno);
		p (txttab '70%');
		p (cur_pr_zerno);
		p "^";
		p (txttab '0%');
		p 'Крестьяне, душ';
		p (txttab '35%');
		p (cur_krest);
		p (txttab '70%');
		p (cur_pr_krest);
		p "^";
		p (txttab '0%');
		p 'Гвардия, человек';
		p (txttab '35%');
		p (cur_guard);
		p (txttab '70%');
		p (cur_pr_guard);
		p "^";
	end
end
make_price = function()
	cur_pr_gold = ((pr_gold*75)/100) + (rnd(50)*pr_gold/100);
	cur_pr_land = ((pr_land*75)/100) + (rnd(50)*pr_land/100);
	cur_pr_zerno = ((pr_zerno*75)/100) + (rnd(50)*pr_zerno/100);
	cur_pr_krest = ((pr_krest*75)/100) + (rnd(50)*pr_krest/100);
	cur_pr_guard = ((pr_guard*75)/100) + (rnd(50)*pr_guard/100);
	cur_pr_gold = round(cur_pr_gold, 0);
	cur_pr_land = round(cur_pr_land, 0);
	cur_pr_zerno = round(cur_pr_zerno, 0);
	cur_pr_krest = round(cur_pr_krest, 0);
	cur_pr_guard = round(cur_pr_guard, 0);

end
-- Биржа
ask1 = obj {
	nam = 'ask1';
	var {state='select'};
	dsc = function(s)
		p "Выберите тип операций с";
		pr (s:goodstext());
		pn ":";
		pn "1. {buy_s|покупать}";
		pn "2. {sell_s|продавать}";
	end;
	kbd = function(s, down, key)
		if s.state == 'select' then
			if key == '1' or key == '2' then
				click();
				return s:selected(key);
			end
		else
			return stead.call(ask2, 'kbd', down, key);
		end
	end;
	obj = {
	xact('buy_s', code [[return stead.call(ask1, 'selected', '1')]]),
	xact('sell_s', code [[return stead.call(ask1, 'selected', '2')]])
	};
	goodstext = function(s)
		local goods = here().goods;
		if      goods == 1 then return 'золотом'
		elseif  goods == 2 then return 'землёй'
		elseif  goods == 3 then return 'зерном'
		elseif  goods == 4 then return 'крестьянами'
		elseif  goods == 5 then return 'гвардией'
		end;
	end;
	selected = function(s, optype)
		here().optype = tonumber (optype);
		s.state = 'selected'
		s:disable();
		ask2:enable();
		return true;
	end;
}

-- Дополнительный конструктор. Во как!

ask2const = function()
	local v = numberinputbase();
	stead.add_var(v, { text = "" });
	stead.add_var(v, { extradsc = "" });
	v.nam = "ask2";
	v.ok = function(s)
		s:disable();

		ask1.state = 'select';
		here().state = 'select';
		s.extradsc = "";
		return true
	end
	v.reaction = function(s, text)
		inputl = tonumber(text);
		local goods = here().goods;
		local optype = here().optype;
		local errl = false;
		if optype == 1 then
			if      goods == 1 and (inputl*cur_pr_gold) > cur_money then errl = true;
			elseif  goods == 2 and (inputl*cur_pr_land) > cur_money then errl = true;
			elseif  goods == 3 and (inputl*cur_pr_zerno) > cur_money then errl = true;
			elseif  goods == 4 and (inputl*cur_pr_krest) > cur_money then errl = true;
			elseif  goods == 5 and (inputl*cur_pr_guard) > cur_money then errl = true;
			end
		elseif optype == 2 then
			if      goods == 1 and cur_gold < inputl then errl = true;
			elseif  goods == 2 and cur_land < inputl then errl = true;
			elseif  goods == 3 and cur_zerno < inputl then errl = true;
			elseif  goods == 4 and cur_krest < inputl then errl = true;
			elseif  goods == 5 and cur_guard < inputl then errl = true;
			end
		end
		if errl then
			return s:failenter(optype)
		end
		if optype == 1 then
			if      goods == 1 then cur_gold=(inputl+cur_gold); cur_money=(cur_money-(inputl*cur_pr_gold));
			elseif  goods == 2 then cur_land=(inputl+cur_land); cur_money=(cur_money-(inputl*cur_pr_land));
			elseif  goods == 3 then cur_zerno=(inputl+cur_zerno); cur_money=(cur_money-(inputl*cur_pr_zerno));
			elseif  goods == 4 then cur_krest=(inputl+cur_krest); cur_money=(cur_money-(inputl*cur_pr_krest));
			elseif  goods == 5 then cur_guard=(inputl+cur_guard); cur_money=(cur_money-(inputl*cur_pr_guard));
			end
		elseif optype == 2 then
			if      goods == 1 then cur_gold=(cur_gold-inputl); cur_money=(cur_money+(inputl*cur_pr_gold));
			elseif  goods == 2 then cur_land=(cur_land-inputl); cur_money=(cur_money+(inputl*cur_pr_land));
			elseif  goods == 3 then cur_zerno=(cur_zerno-inputl); cur_money=(cur_money+(inputl*cur_pr_zerno));
			elseif  goods == 4 then cur_krest=(cur_krest-inputl); cur_money=(cur_money+(inputl*cur_pr_krest));
			elseif  goods == 5 then cur_guard=(cur_guard-inputl); cur_money=(cur_money+(inputl*cur_pr_guard));
			end
		end
		return s:ok();
	end
	v.failenter = function(s, ft)
		if ft == 1 then
			s.extradsc = 'У вас не хватает денег, чтобы оплатить покупку!'
		elseif ft == 2 then
			s.extradsc = 'У Вас столько нету. Повторите ввод.'
		end;
		return true
	end
	v.msg = function(s)
		local goods = here().goods;
		local optype = here().optype;
		local goodsstr = "";
		local optypestr = "";
		if          goods == 1 then goodsstr = 'килограммов золота';
			elseif  goods == 2 then goodsstr = 'гектаров земли';
			elseif  goods == 3 then goodsstr = 'тонн зерна';
			elseif  goods == 4 then goodsstr = 'душ крестьян';
			elseif  goods == 5 then goodsstr = 'гвардейцев';
		end
		if optype == 1 then
			if goods == 5 then
				optypestr = 'нанять';
			else
				optypestr = 'купить';
			end
		elseif optype == 2 then
			if goods == 5 then
				optypestr = 'продать'; -- Нужно заменить, а то неправильно как-то...
			else
				optypestr = 'продать';
			end
		end
	return stead.call (s, 'msgfunc', goodsstr, optypestr);
	end;
	v.msgfunc = function(s, goodsstr, optypestr)
		return ("Сколько " ..goodsstr.." желаете "..optypestr..": ")
	end;
	return obj(v);
end

ask2 = ask2const();

torgovla = room {
	nam = "Биржа";
	pic = "gfx/money.png";
	entered = code [[hook_all()]];
	exit = code [[unhook_all()]];
	selected = function(s, goods)
		s.state = 'selected';
		s.goods = tonumber (goods);
		ask1:enable();
		return true;
	end;
	kbd = function(s, down, key)
		if not down then
			return;
		end;
		if s.state == 'select' then
			if key == '1' or key == '2' or key == '3' or key == '4' or key == '5' then
				click();
				return s:selected(key);
			elseif key == '6' then
				click();
				return nextstep();
			end
		else
			return stead.call (ask1, 'kbd', down, key);
		end
	end;
	var {state='select', goods=false, optype=false};
	dsc = function(s)
		moneytable(true, false);
		p "^";
		if s.state == 'select' then
			pn "Выберите товар, с которым проводить операции:";
			pn '1. {gold_s|Золото}';
			pn '2. {land_s|Земля}';
			pn '3. {zerno_s|Зерно}';
			pn '4. {krest_s|Крестьяне}';
			pn '5. {guard_s|Гвардия}';
			pn '6. {nextstep_xact|Выход с биржи}'
		end;
	end;
	obj = {
	xact('gold_s', code [[return stead.call(here(), 'selected', '1')]]),
	xact('land_s', code [[return stead.call(here(), 'selected', '2')]]),
	xact('zerno_s', code [[return stead.call(here(), 'selected', '3')]]),
	xact('krest_s', code [[return stead.call(here(), 'selected', '4')]]),
	xact('guard_s', code [[return stead.call(here(), 'selected', '5')]]),
	ask1:disable(), ask2:disable()
	};
}

-- Война

prewar = yesnoroom {
	nam = "Война";
	pic = "gfx/war.png";
	question = "Есть возможность объявить войну одному из соседей. Объявляете?";
	yes = code [[return walk "war1";]];
	no = code [[nextstep();]];
};

war1 = yesnoroom {
	enter = function(s)
		hook_all();
		your_men_krest = 0;
		your_men_extra = 0;
		your_men_guard = cur_guard;
		enemy_men_guard = round(rnd(cur_guard*2));
		enemy_men_krest = round(rnd(cur_krest*2));
		ras_guard = round(enemy_men_guard - (50 * enemy_men_guard / 100) + rnd(enemy_men_guard));
		ras_krest = round(enemy_men_krest - (35 * enemy_men_krest / 100) + rnd(enemy_men_krest));
	end;
	nam = "Война";
	pic = "gfx/war.png";
	question = function(s)
		if why_mar_war == 1 then
			pn "Разозленный отказом жениться на его дочке, соседний король начал ВОЙНУ!";
		elseif why_mal_war == 1 then
			pn "Соседние короли, видя малочисленность Ваших войск, объявили Вам ВОЙНУ!";
		end;
		pn ("Разведка доносит о предполагаемой численности войск врага: "..ras_guard.." "..sodnam(ras_guard).." и "..ras_krest.." "..krestnam(ras_krest)..".");
		p ("Ваши силы: "..your_men_guard.." "..sodnam(your_men_guard)..". Объявляете мобилизацию крестьян?");
	end;
	yes = function(s)
		your_men_krest = round((rnd(50)+50)*cur_krest/100);
		walk "war12";
	end;
	no = code [[walk(war2);]];
};

war12 = cutscene {
	nam = "Информация";
	pic = "gfx/war.png";
	dsc = function(s)
		local str = (sklon3(your_men_krest, "Мобилизован ", "Мобилизовано ")..your_men_krest.." "..mannam(your_men_krest)..".^В народе растет недовольство!");
		for c in str:gmatch"." do
			pr (c.."{fading 1}");
		end;
		p "{pause 6000}{walk war2}";
	end;
};

war2const = function(v)
	stead.add_var(v, { selected = false });
	v.entered = code [[hook_yesno();]];
	v.exit = code [[unhook_yesno();]];
	v.kbd = function(s, down, key)
		if down and not selected  and key == "y" or key == "n" then
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
		else
			if seen(warenter) then
				return stead.call(warenter, 'kbd', down, key);
			end
		end;
	end;
	if v.yes == nil or v.no == nil then
		error "yesnoroom -- yes or no attrs not found.";
	end;
	if v.question == nil then
		error "yesnoroom -- question attr not found.";
	end;
	v.dsc = function(s)
		if not seen(warenter) then
			pn (stead.call (s, "question"));
			pn ("{yesselect|"..yimg.."}/{noselect|"..nimg.."}");
		end;
	end;
	if v.pic == nil then
		v.pic = "gfx/question.png";
	end;
	return room(v);
end;

war2 = war2const {
	nam = "Война";
	pic = "gfx/war.png";
	question = function(s)
		pn "Есть возможность завербовать наемников на время этой войны.";
		p "Один наемник стоит 100 рублей. Будете вербовать?"
	end;
	yes = function(s)
		objs():add(warenter);
		return true;
	end;
	no = code [[walk(war3);]];
	exit = code [[unhook_all()]];
};

warenter = checkinput(
	function(s, text)
		cur_money = cur_money-(tonumber(text)*100);
		your_men_extra = tonumber(text);
		objs():del(s);
		walk(war3);
	end,
	function(s)
		p ("Сколько наёмников хотите нанять (в казне - "..cur_money.." "..rubnam(cur_money).."):")
	end,
	'cur_money', 100, "warenter"
);

war3 = enterroom {
	nam = "Война";
	pic = "gfx/war.png";
	enter = code [[hook_enter()]];
	exit = code [[unhook_enter()]];
	dsc = function(s)
		pn ("Перед битвой выяснилось точное число войск противника: "..enemy_men_guard.." "..sodnam(enemy_men_guard).." и "..enemy_men_krest.." "..krestnam(enemy_men_krest)..".");
		pr ("Ваши войска составляют "..your_men_guard.." "..sodnam(your_men_guard));
		if your_men_krest > 0 and your_men_extra > 0 then
			pr (", "..your_men_krest.." "..krestnam(your_men_krest).." и "..your_men_extra.." "..sklon2(your_men_extra, "наёмник", "наёмника", "наёмников"));
		elseif your_men_krest > 0 then
			pr (" и "..your_men_krest.." "..krestnam(your_men_krest));
		elseif your_men_extra > 0 then
			pr (" и "..your_men_extra.." "..sklon2(your_men_extra, "наёмник", "наёмника", "наёмников"));
		end;
		pn "."
		p ("Нажмите "..make_enter("warpress").." для начала сражения...");
	end;
	obj = {xact('warpress', code [[return stead.call(here(), 'press')]])};
	press = function(s)
		local victory=false;
		local n;
		local your_mark;
		local enemy_mark;
		your_mark = round(your_men_guard*rndfr(7, 8, 5)+your_men_extra*rndfr(5, 8, 5)+your_men_krest*rndfr(2, 4, 5));
		enemy_mark = round(enemy_men_guard*rndfr(7, 8, 5)+enemy_men_krest*rndfr(2, 4, 5));
		n=rnd(enemy_mark+your_mark*2);
		if (n<=your_mark*2) then
			victory=true;
		end;
		click();
		if victory then
			n=rnd(90)+10; ch_money=round(cur_money*n/100); cur_money=cur_money+ch_money;
			n=rnd(90)+10; ch_gold=round(cur_gold*n/100); cur_gold=cur_gold+ch_gold;
			n=rnd(90)+10; ch_land=round(cur_land*n/100); cur_land=cur_land+ch_land;
			n=rnd(90)+10; ch_zerno=round(cur_zerno*n/100); cur_zerno=cur_zerno+ch_zerno;
			n=rnd(90)+10; ch_krest=round(cur_krest*n/100); cur_krest=cur_krest+ch_krest;
			walk(warvictory);
		else
			n=rnd(90)+10; ch_money=round(cur_money*n/100); cur_money=cur_money-ch_money;
			n=rnd(90)+10; ch_gold=round(cur_gold*n/100); cur_gold=cur_gold-ch_gold;
			n=rnd(90)+10; ch_land=round(cur_land*n/100); cur_land=cur_land-ch_land;
			n=rnd(90)+10; ch_zerno=round(cur_zerno*n/100); cur_zerno=cur_zerno-ch_zerno;
			n=rnd(90)+10; ch_krest=round(cur_krest*n/100); cur_krest=cur_krest-ch_krest;
			n=rnd(90)+10; ch_guard=round(cur_guard*n/100); cur_guard=cur_guard-ch_guard;
			walk(warloss);
		end
	end;
};

warvictory = xenterroom {
	nam = code [[return (andale:txt ("Победа!!!", 'green', 5));]];
	pic = "gfx/warvictory.png";
	dsc = function(s)
		p (andale:txt ("Вы победили!", 'green'));
		p "Ваша армия захватила трофеи:";
		deftable(ch_money, ch_gold, ch_land, ch_zerno, ch_krest, nil, nil, nil, nil, false, false);
--		p "^^";
	end;
	xdsc = nextbutton;
	press = code [[return nextstep()]];
}

warloss = xenterroom {
	nam = code [[return (andale:txt ("Поражение...", 'red', 5));]];
	pic = "gfx/warloss.png";
	dsc = function(s)
		p (andale:txt ("Вы проиграли...", 'red'));
		p " Ваши потери в этой войне:";
		deftable(ch_money, ch_gold, ch_land, ch_zerno, ch_krest, ch_guard, nil, nil, nil, false, false);
--		p "^^";
	end;
	xdsc = nextbutton;
	press = code [[nextstep()]];
}

-- Караван

-- Отправка каравана
snaradkarconst = function(v)
	stead.add_var(v, { selected = false });
	v.entered = code [[hook_all();]];
	v.exit = code [[unhook_all();]];
	v.kbd = function(s, down, key)
		if down and not selected  and key == "y" or key == "n" then
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
		else
			if seen(snaradkarenter) then
				return stead.call(snaradkarenter, 'kbd', down, key);
			end
		end;
	end;
	if v.yes == nil or v.no == nil then
		error "yesnoroom -- yes or no attrs not found.";
	end;
	if v.question == nil then
		error "yesnoroom -- question attr not found.";
	end;
	v.dsc = function(s)
		if not seen(snaradkarenter) then
			pn (stead.call (s, "question"));
			pn ("{yesselect|"..yimg.."}/{noselect|"..nimg.."}");
		end;
	end;
	if v.pic == nil then
		v.pic = "gfx/question.png";
	end;
	return room(v);
end;

snaradkar = snaradkarconst {
	nam = "Снаряжение каравана";
	pic = "gfx/snaradkar.png";
	question = function(s)
		p "Заморский купец предлагает снарядить караван. Вы согласны?";
	end;
	yes = function(s)
		objs():add(snaradkarenter);
		return true;
	end;
	no = code [[return nextstep();]];
	exit = code [[unhook_all()]];
};

snaradkarenter = moneyinput(
	function(s, text)
		objs():del(s);
		if tonumber(text) > 0 then
			cur_money = cur_money-(tonumber(text));
			for_kar = tonumber(text);
			fl_kar = 1;
			walk "snaradkar1";
		else
			nextstep();
		end;
	end,
	function(s)
		p ("В казне - "..cur_money.." "..rubnam(cur_money)..", сколько на караван:")
	end,
	"snaradkarenter"
);

snaradkar1 = cutscene {
	nam = "В пустыню...";
	pic = "gfx/kar.png";
	dsc = function(s)
		local str = "Караван отправился за тридевять земель...";
		for c in str:gmatch"." do
			pr (c.."{pause 30}{fading 1}");
		end;
		pn "{pause 6000}";
		pn "{walk tmproom}";
	end;
};

-- Грабёж!!!

grabegkar = xenterroom {
	nam = _warn("ЧП!!!");
	enter = function(s)
		local n = rnd(100);
		if n < 5 then
			grabkar_type = "full";
			fl_kar = 0;
			for_kar = 0;
		else
			n=rnd(40);
			grabkar_type = null;
			grabkar=round((for_kar*n)/100);
			n=rnd(40);
			if n < 10 then
				for_kar=round(for_kar-grabkar);
			else
				for_kar=round(for_kar-(grabkar/6));
			end;
		end;
	end;
	dsc = function(s)
		local str
		if grabkar_type == "full"  then
			str = "Произошло ЧП! Ваш караван полностью разграблен бандитами!!!";
		else
			str = "Внимание, ЧП! Ваш караван ограблен бандитами на сумму "..grabkar.." "..rubnam(grabkar).."!!!"
		end
		return warnfnt(str);
	end;
	xdsc = nextbutton;
	press = code [[return nextstep();]];
}

-- Болезнь

ill = yesnoroom {
	nam = "Болезнь";
	enter = function(s)
		lekar_deneg = round((rnd(30)+1)*cur_money/100);
	end;
	pic = "gfx/temperature.png";
	question = function(s)
		pn ("Вы заболели! За лечение лекарь просит "..lekar_deneg.." "..rubnam(lekar_deneg)..".");
		pn "Вы можете выздороветь сами, но можете и не выздороветь...";
		p "Будете лечиться?"
	end;
	yes = function(s)
		cur_money = cur_money-lekar_deneg;
		local n=rnd(100);
		if n < 5 then
			illend = 3;
		else
			illend = 1;
		end;
		return walk "ill2";
	end;
	no = function(s)
		if rnd(100)<(god) then
			illend = 2;
		else
			illend = 0;
		end;
		return walk "ill2";
	end;
};

ill2 = cutscene {
	nam = "Болезнь";
	dsc = function(s)
		local str, str2;
		if illend == 0 then
			str = "Вы благополучно исцелились сами...";
			str2 = "{fading 1}{pause 4000}{walk tmproom}";
		elseif illend == 1 then
			str = "Лечение помогло, Вы благополучно выздоровели...";
			str2 = "{fading 1}{pause 4000}{walk tmproom}";
		elseif illend == 2 then
			str = "Я же Вас предупреждал! Болезнь обострилась, Вы при смерти!";
			str2 = "{fading 1}{pause 4000}{walk shaman}";
		else
			str = "Лечение не дало результатов. Вы при смерти...";
			str2 = "{fading 1}{pause 4000}{walk shaman}"
		end;
		for c in str:gmatch"." do
			pr (c.."{fading 1}{pause 20}");
		end;
		p (str2);
	end;
};

-- Шаман

shaman = yesnoroom {
	nam = "Шаман";
	enter = function(s)
		lekar_deneg = round((rnd(40)+1)*cur_money/100);
	end;
	question = function(s)
		pn "Местный шаман берется вылечить Вас (с вероятностью 20%...)";
		pn ("Но за это он требует половину Вашего золота и "..lekar_deneg.." "..rubnam(lekar_deneg)..".");
		p "Вы согласны?"
	end;
	yes = function(s)
		cur_money = cur_money-lekar_deneg;
		cur_gold = round(cur_gold/2);
		local n=rnd(100);
		if n<20 then
			illend = 0;
			walk "shaman2";
		else
			fl_lec = 2;
			return true;
		end;
	end;
	no = function(s)
		local n=rnd(100);
		if n<5 then
			illend = 1;
			walk "shaman2";
		else
			fl_lec = 1;
			return true;
		end;
	end;
};

shaman2 = cutscene {
	nam = "Вы выздоровели!";
	dsc = function(s)
		local str;
		if illend == 0 then
			str = "Колдовство шамана помогло! Вы выздоровели!";
		else
			str = "Случилось ЧУДО! Вы победили болезнь и встали со смертного одра!";
		end;
		for c in str:gmatch"." do
			pr (c.."{fading 1}{pause 10}");
		end;
		p "{fading 1}{pause 3000}{walk tmproom}";
	end;
};

svadba = yesnoroom {
	nam = "Свадьба";
	enter = function(s)
		ch_money = round(cur_money*(rnd(90)+10)/100);
		ch_gold = round(cur_gold*(rnd(90)+10)/100);
		ch_land = round(cur_land*(rnd(90)+10)/100);
		ch_zerno = round(cur_zerno*(rnd(90)+10)/100);
		ch_krest = round(cur_krest*(rnd(90)+10)/100);
		ch_guard = round(cur_guard*(rnd(90)+10)/100);
	end;
	question = function(s)
		pn "Соседний король сватает за Вас свою дочку.";
		pn "В приданое он предлагает:";
		deftable(ch_money, ch_gold, ch_land, ch_zerno, ch_krest, ch_guard, nil, "Количество", false, true, false);
		p "Вы согласны?"
	end;
	yes = function(s)
		cur_money = cur_money+ch_money;
		cur_gold = cur_gold+ch_gold;
		cur_land = cur_land+ch_land;
		cur_zerno = cur_zerno+ch_zerno;
		cur_krest = cur_krest+ch_krest;
		cur_guard = cur_guard+ch_guard;
		year_marry = 1;
		walk "svadba1";
	end;
	no = function(s)
		walk "svadba2";
	end;
};

svadba1 = cutscene {
	nam = "Информация";
	enter = function(s)
		wife_deneg = round((rnd(40)+20)*cur_money/100);
		fl_marry=fl_marry+1;
	end;
	dsc = function(s)
		local str = ("Поздравляю. На свадебный пир потрачено "..wife_deneg.." "..rubnam(wife_deneg)..".");
		for c in str:gmatch"." do
			pr (c.."{pause 30}{fading 1}");
		end
		pn "{pause 4000}";
		pn "{walk tmproom}";
	end;
};

svadba2 = cutscene {
	nam = "Информация";
	enter = function(s)
		fl_mar_war=1;
	end;
	dsc = function(s)
		local str = "Ах так?!! Вы пренебрегаете моим предложением??! Готовьтесь к ВОЙНЕ!";
		for c in str:gmatch"." do
			pr (c.."{fading 1}{pause 25}");
		end
		pn "{pause 6000}";
		pn "{walk tmproom}";
	end;
};

nasledstvo = xenterroom {
	nam = "Умер дальний родственник";
	enter = function(s)
		ch_money = round(cur_money*(rnd(90)+10)/100);
		ch_gold = round(cur_gold*(rnd(90)+10)/100);
		ch_land = round(cur_land*(rnd(90)+10)/100);
		ch_zerno = round(cur_zerno*(rnd(90)+10)/100);
		ch_krest = round(cur_krest*(rnd(90)+10)/100);
		ch_guard = round(cur_guard*(rnd(90)+10)/100);
		cur_money = cur_money + ch_money;
		cur_gold = cur_gold + ch_gold;
		cur_land = cur_land + ch_land;
		cur_zerno = cur_zerno + ch_zerno;
		cur_krest = cur_krest + ch_krest;
		cur_guard = cur_guard + ch_guard;
	end;
	dsc = function(s)
		p "Умер Ваш дальний родственник. Вы получили наследство в размере:";
		deftable(ch_money, ch_gold, ch_land, ch_zerno, ch_krest, ch_guard, nil, "Количество", true, true, false);
--		p "^^";
	end;
	press = code [[return nextstep();]];
	xdsc = nextbutton;
};

koroleva_prosit1 = yesnoroom {
	nam = "Прибыл гонец";
	question = [[Прибыл гонец от королевы. Впустить?]];
	yes = code [[walk "koroleva_prosit2"]];
	no = code [[return nextstep()]];
};

koroleva_prosit2 = yesnoroom {
	nam = "Королева просит";
	enter = function(s)
		if rnd(100) < 15 then
			prosit_mode = 0;
		else
			prosit_mode = 1;
		end;
		wife_deneg = round((rnd(30)+1)*cur_money/100);
	end;
	question = function(s)
		if prosit_mode == 0 then
			p ("Королева просит "..wife_deneg.." "..rubnam(wife_deneg).." на новое платье. Выделить средства?")
		else
			p ("Королева просит "..wife_deneg.." "..rubnam(wife_deneg)..", чтобы устроить бал. Выделить средства?")
		end;
	end;
	yes = function(s)
		if prosit_mode == 0 then
			prosit_end = 0;
		else
			prosit_end = 1;
		end;
		cur_money = cur_money - wife_deneg
		walk "koroleva_prosit3";
	end;
	no = function(s)
		if prosit_mode == 0 then
			prosit_end = 2;
		else
			prosit_end = 3;
		end;
		walk "koroleva_prosit3";
	end;
};

koroleva_prosit3 = cutscene {
	nam = "Королева просит";
	dsc = function(s)
		local str
		if prosit_end == 0 or prosit_end == 1 then
			str = "Королева благодарит Вас /лично и ОЧЕНЬ горячо...";
		elseif prosit_end == 2 then
			str = "Королева ЖУТКО на Вас обиделась... Видеть Вас больше не желает...";
		else
			str = "Королева на Вас обиделась... Хоть и не очень сильно, но все таки...";
		end;
		for c in str:gmatch"." do
			pr (c.."{fading 1}{pause 50}");
		end;
		p "{fading}";
		p "{pause 4000}";
		p "{walk tmproom}";
	end;
};

wife_dead1 = yesnoroom {
	nam = "Прибыл гонец";
	question = [[Прибыл гонец от королевы. Впустить?]];
	yes = function(s)
		dead_prinal = 1;
		walk "wife_dead2";
	end;
	no = function(s)
		dead_prinal = 0;
		walk "wife_dead2";
	end;
};

wife_dead2 = cutscene {
	nam = "Великое несчастье!";
	enter = code[[wife_deneg=round((rnd(40)+20)*cur_money/100);cur_money=cur_money-wife_deneg;fl_marry=fl_marry-0;]];
	dsc = function(s)
		if dead_prinal == 0 then
			pn "Хоть Вы и не приняли гонца, но печальная весть все равно дошла до Вас.";
			p "{fading}{pause 500}";
		end;
		local str = "Великое несчастье! Умерла королева! Овдовевший монарх безутешен!";
		for c in str:gmatch"." do
			pr (c.."{fading 1}{pause 50}");
		end;
		p "^{fading}{pause 2000}";
		pn ("На похороны королевы потрачено "..wife_deneg.." "..rubnam(wife_deneg)..".");
		pn "{fading}";
		pn "{pause 5000}";
		pn "{walk tmproom}";
	end;
};

rodilsa_sin = cutscene {
	nam = "Поздравляю!";
	enter = code[[wife_deneg=round((rnd(40)+20)*cur_money/100);cur_money=cur_money-wife_deneg;]];
	dsc = function(s)
		local str = "У Вас родился сын! Поздравляю! Ваша династия не угаснет в веках!";
		for c in str:gmatch"." do
			pr (c.."{fading 1}{pause 10}");
		end;
		pr "^{pause 2000}";
		pr ("На праздничный банкет по случаю рождения сына потрачено "..wife_deneg.." "..rubnam(wife_deneg)..".");
		pr "{fading 1}";
		pr "{pause 6000}";
		pr "{walk tmproom}";
	end;
};

mitropolit = room {
	entered = code [[hook_all()]];
	exit = code [[unhook_all()]];
	kbd = function(s, ...) return stead.call (mitropolitenter, 'kbd', ...); end;
	nam = "Митрополит";
	dsc = function(s)
		p "Митрополит Вашего государства просит денег на новый храм.";
	end;
	obj = {'mitropolitenter'};
};

mitropolitenter = moneyinput(
	function(s, text)
		mitropolit_deneg = tonumber(text);
		for_xram = for_xram + mitropolit_deneg;
		xram_new = math.floor(for_xram/100000);
		build_xram = build_xram + xram_new;
		for_xram = for_xram - xram_new * 100000;
		cur_money = cur_money - mitropolit_deneg;
		walk(mitropolit1);
	end,
	function(s)
		p ("Сколько выделяете (в казне "..cur_money.." "..rubnam(cur_money).."):")
	end,
	"mitropolitenter"
);

mitropolit1 = cutscene {
	nam = "Митрополит";
	dsc = function(s)
		local str = "", str2, strfull;
		if cur_money == 0 then
			str = "Молись усерднее, сын мой, да и воздастся тебе за веру твою.";
		else
			local procentum = mitropolit_deneg/cur_money*100;
			if procentum < 1 then
				str = "Ты что, насмехаешься?! Скряга!!! За твою жадность ты сгоришь в аду!";
			elseif procentum < 10 then
				str = "Опомнись, сын мой! Нельзя же быть таким жадным, это смертный грех!";
			elseif procentum < 20 then
				str = "Не слишком-то щедры твои приношения, сын мой. Можно было дать и побольше.";
			elseif procentum < 30 then
				str = "Что ж, спасибо и на этом. Ваши приношения пойдут на богоугодное дело.";
			elseif procentum < 50 then
				str = "Благодарю тебя, сын мой. Твоя щедрость будет оценена по достоинству.";
			else
				str = "Во всех храмах страны поют молитвы во славу мудрого и щедрого короля!";
			end;
			if xram_new > 0 then
				if xram_new == 1 then
					str2 = "Воздвигнут новый храм.";
				else
					str2 = (sklon3(xram_new, "Воздвигнут ", "Воздвигнуто ")..xram_new.." "..sklon3(xram_new, "новый", "новых").." "..sklon2(xram_new, "храм", "храма",  "храмов")..".");
				end;
			end;
		end;
		if str2 ~= nil then
			strfull = (str.." "..str2);
		else
			strfull = str;
		end;
		for c in strfull:gmatch"." do
			pr (c.."{fading 1}{pause 20}");
		end;
		p "{fading 1}{pause 4000}{walk tmproom}"
	end;
};

choicezerno1 = yesnoroom {
	nam = "Распределение зерна";
	pic = 'gfx/zerno.png';
	question = "Желаете сами распределить расход зерна?";
	enter = function(s)
		if cur_krest == 0 and cur_guard == 0 then
			return nextstep();
		elseif (cur_krest > 0 or cur_guard > 0) and cur_zerno == 0 then
			for_eat=0;
			for_posev=0;
			zerno_end = 5;
			return walk "choicezerno3";
		end;
	end;
	entered = code [[hook_all()]];
	exit = code [[unhook_all()]];
	yes = code [[return walk "choicezerno2"]];
	no = function(s)
		for_eat=(cur_krest+cur_guard)*ed_eat;
		for_posev=math.min(cur_land,cur_krest)*ed_posev;
		if ((for_eat+for_posev)<=cur_zerno) then
			zerno_nemog = 0;
			cur_zerno = cur_zerno-(for_eat+for_posev);
			return walk(choicezerno3);
		else
			zerno_nemog = 1;
			return walk(choicezerno2);
		end;
	end;
};

choicezerno2 = room {
	var {state = 0};
	nam = "Распределение зерна";
	pic = 'gfx/zerno.png';
	entered = code [[hook_all()]];
	exit = code [[unhook_all()]];
	enter = code [[choicezerno2.state = 0;choicezernoenter1:enable();choicezernoenter2:disable()]];
	left = code [[choicezerno2.state = 0;choicezernoenter1:enable();choicezernoenter2:disable()]];
	kbd = function(s, down, key)
		if s.state == 0 then
			return stead.call(choicezernoenter1,'kbd', down, key);
		elseif s.state == 1 then
			return stead.call(choicezernoenter2,'kbd', down, key);
		else
			if down then
				click();
				return walk "choicezerno3";
			end;
		end;
	end;
	dsc = function(s)
		if zerno_nemog == 1 then
			pn "Не могу самостоятельно распределить зерно.^Не хватает зерна на посев и еду по полной норме.^Пожалуйста, распределите зерно лично.";
		end;
		if s.state < 2 then
			pn "Напоминаю, Ваше состояние сейчас составляет:";
			pn ("Земля - "..cur_land.." га, крестьяне - "..cur_krest.." "..sklon2(cur_krest, "душа", "души", "душ")..", гвардия - "..cur_guard.." "..mannam(cur_guard).." чел.");
			pn ("Запас зерна в амбарах - "..cur_zerno.." "..sklon2(cur_zerno, "тонна", "тонны", "тонн")..".");
			p ("В идеале: на еду -- "..(cur_krest+cur_guard)*ed_eat.." "..sklon2((cur_krest+cur_guard)*ed_eat, "тонна", "тонны", "тонн")..", на посев -- "..math.min(cur_land,cur_krest)*ed_posev.." "..sklon2(math.min(cur_land,cur_krest)*ed_posev, "тонна", "тонны", "тонн")..".");
		end;
		if s.state > 0 then
			p ("^На еду выделено "..for_eat.." "..sklon2(for_eat, "тонна", "тонны", "тонн").." зерна.");
		end;
		if s.state > 1 then
			pn ("^На посев выделено "..for_posev.." "..sklon2(for_posev, "тонна", "тонны", "тонн").." зерна.");
			pn ("Оставшийся запас в амбарах: "..cur_zerno.." "..sklon2(cur_zerno, "тонна", "тонны", "тонн")..".");
			p (make_enter('zerno_enter1'));
		end;
	end;
	obj = {'choicezernoenter1', 'choicezernoenter2', xact('zerno_enter1', code [[walk "choicezerno3"]])};
};

choicezerno3 = room {
	nam = "Распределение зерна";
	entered = code [[hook_enter();]];
	exit = code [[unhook_enter();]];
	pic = 'gfx/zerno.png';
	kbd = function(s, down, key)
		if down and key == 'return' then
			if zerno_end < 3 then
				click();
				return nextstep();
			else
				click();
				fl_r = 1;
			end;
		end;
	end;
	enter = function(s)
		local getted;
		if (cur_krest + cur_guard) > 0 then
			getted = (for_eat/ed_eat)/(cur_krest+cur_guard);
		else
			error "Это невозможная ситуация! Сообщите об ошибке, если она возникла при естественном ходе игры. А игру перезапустите.";
		end;
		zerno_norma = math.floor(getted*100);
		if zerno_norma >= 100 then
			zerno_end = 0;
		elseif zerno_norma >= 70 then
			zerno_end = 1;
		elseif zerno_norma >= 40 then
			if (rnd(100)<100-zerno_norma) then
				zerno_end = 3;
			else
				zerno_end = 2;
			end;
		else
			zerno_end = 4; -- Ну и изверг!!!
		end;
	end;
	dsc = function(s)
		pn ("Норма продуктов на год на 1 человека составляет "..zerno_norma.." "..sklon2(zerno_norma, "процент", "процента", "процентов").." от необходимой.");
		if zerno_end == 0 then
			pn "Народ доволен таким щедрым правителем.";
			p (make_enter('zerno_good'));
		elseif zerno_end == 1 then
			pn "Кормите народ получше, не то получите РЕВОЛЮЦИЮ...";
			p (make_enter('zerno_good'));
		elseif zerno_end == 2 then
			pn "Недовольство вами резко возросло. Вы сильно рискуете...";
			pn "Только случай спас Вас в этот раз от РЕВОЛЮЦИИ...";
			p (make_enter('zerno_good'));
		elseif zerno_end == 3 then
			pn "Вы доигрались... Народ не стал терпеть такие унижения и сверг Вас!!!";
			pn "Не доводите больше свой народ до РЕВОЛЮЦИИ!!!";
			p (make_enter('zerno_bad'));
		elseif zerno_end == 4 then -- Ну всё, хана тебе, правитель!!!
			pn "Да Вы что, издеваетесь?!! Так морить голодом свой народ!..";
			pn "Продали бы лишних крестьян, изверг, если прокормить не можете...";
			pn "Естественно, умирающий от голода народ сверг такого тирана...";
			pn "Получите РЕВОЛЮЦИЮ!!!";
			p (make_enter('zerno_bad'));
		else
			pn "Куда вы дели зерно?!! И что по вашему люди есть будут?!";
			pn "Естественно, умирающий от голода народ сверг такого тирана...";
			pn "Получите РЕВОЛЮЦИЮ!!!";
			p (make_enter('zerno_bad'));
		end;
	end;
	obj = {xact('zerno_good', code [[return nextstep();]]), xact('zerno_bad', code [[fl_r = 1; return true;]])};
};

choicezernoenter1 = checkinput(
	function(s, text)
		for_eat = tonumber(text);
		cur_zerno = cur_zerno - for_eat;
		choicezerno2.state = 1;
		s:disable();
		choicezernoenter2:enable()
		return true;
	end,
	function(s)
		p ("Укажите расход зерна на еду:")
	end,
	'cur_zerno', 1, "choicezernoenter1"
);

choicezernoenter2 = checkinput(
	function(s, text)
		for_posev = tonumber(text);
		cur_zerno = cur_zerno - for_posev;
		choicezerno2.state = 2;
		s:disable();
		unhook_all();
		hook_enter();
		return true;
	end,
	function(s)
		p ("Укажите расход зерна на посев:")
	end,
	'cur_zerno', 1, "choicezernoenter2"
);

poimali_visir = xenterroom {
	nam = "Поймали визиря";
	enter = code [[grab_money2 = round((rnd(50)+50)*grab_money2/100); cur_money = cur_money+grab_money2; fl_vis = 0;]];
	dsc = function(s)
		pn "Ваша полиция поймала сбежавшего визиря!";
		pn "У него конфисковано все имущество, а его самого посадили на кол!";
		if grab_money2 > 0 then
			pn ("В казну возвращено "..grab_money2.." "..rubnam(grab_money2)..".");
		end;
	end;
	xdsc = nextbutton;
	press = code [[return nextstep();]];
};

newyearconst = function(v)
	stead.add_var(v, { selected = false });
	v.entered = code [[hook_all();]];
	v.exit = code [[unhook_all();]];
	v.kbd = function(s, down, key)
		if down and not selected  and key == "y" or key == "n" then
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
		else
			if seen(newyearenter) then
				return stead.call(newyearenter, 'kbd', down, key);
			end
		end;
	end;
	if v.yes == nil or v.no == nil then
		error "yesnoroom -- yes or no attrs not found.";
	end;
	if v.question == nil then
		error "yesnoroom -- question attr not found.";
	end;
	v.dsc = function(s)
		if not seen(newyearenter) then
			pn (stead.call (s, "question"));
			pn ("{yesselect|"..yimg.."}/{noselect|"..nimg.."}");
		end;
	end;
	if v.pic == nil then
		v.pic = "gfx/question.png";
	end;
	return room(v);
end;

isend = yesnoroom {
	nam = " ";
	question = "Будете править в следующем году?";
	yes = code [[return nextstep()]];
	no = code [[fl_end = true; return true]];
};

newyear = newyearconst {
	nam = "Новогодний бал";
	question = "Будете устраивать новогодний бал?";
	yes = function(s)
		objs():add(newyearenter);
		return true;
	end;
	no = code [[return nextstep();]];
	exit = code [[unhook_all()]];
};

newyearenter = moneyinput(
	function(s, text)
		objs():del(s);
		if tonumber(text) > 0 then
			cur_money = cur_money-(tonumber(text));
			walk "newyear1";
		else
			nextstep();
		end;
	end,
	function(s)
		p ("Сколько даете на бал (в казне - "..cur_money.." "..rubnam(cur_money).."):")
	end,
	"newyearenter"
);

newyear1 = cutscene {
	nam = "Новогодний бал";
	dsc = function(s)
		local str;
		if fl_marry > 0 then
			str = "Королева благодарит Вас.";
		else
			str = "Придворные благодарят Вас.";
		end;
		for c in str:gmatch"." do
			pr (c.."{pause 20}{fading 1}");
		end;
		pn "{pause 6000}";
		pn "{walk tmproom}";
	end;
};

yeartoyear = cutscene {
	nam = "Прошёл год";
	enter = function(s) s.kbduse = false; hook_enter(); sound.play(turning_snd, 2, 1); end;
	exit = function(s) s.kbduse = false; unhook_enter(); end;
	var {kbduse = false};
	kbd = function(s, down, key)
		if s.kbduse and down then
			click();
			walk "tmproom";
			return true;
		end;
	end;
	dsc = function(s)
		pn "Прошёл год...{pic gfx/visir.png}{fading}{pause 1500}^Ваше Величество, прибыл Главный Визирь с докладом.{fading}{pause 1000}^Визирь сообщает:{fading}{pause 1000}";
		pn ("Жалованье гвардии за прошлый год составило "..abs_sod_guard.." "..rubnam(abs_sod_guard)..".{pic gfx/money2.png}{fading}{pause 1000}");
		if fl_urog == 0 then
			pn "Страшная засуха поразила посевы. Очень неурожайный год."
			pn ("Собрано всего "..add_zerno.." "..sklon2(add_zerno, "тонна", "тонны", "тонн").." зерна.");
		elseif fl_urog == 1 then
			pn ("Урожайность была низкая. Собрано "..add_zerno.." "..sklon2(add_zerno, "тонна", "тонны", "тонн").." зерна.");
		elseif fl_urog == 2 then
			pn "Средний по урожайности год."
			pn ("Наши крестьяне собрали "..add_zerno.." "..sklon2(add_zerno, "тонна", "тонны", "тонн").." зерна.");
		elseif fl_urog == 3 then
			pn ("Урожайный год. Собрано "..add_zerno.." "..sklon2(add_zerno, "тонна", "тонны", "тонн").." зерна.");
		else
			pn "Пролившиеся вовремя дожди обеспечили невиданно высокий урожай.";
			pn ("Амбары ломятся от зерна - собрано "..add_zerno.." "..sklon2(add_zerno, "тонна", "тонны", "тонн").." !");
		end;
		pr "{pic gfx/zerno2.png}{fading}{pause 2000}"
		if eat_rat > 0 then
			pn ("Преступная халатность! Крысы сожрали "..eat_rat.." "..sklon2(eat_rat, "тонна", "тонны", "тонн").." зерна!{pic gfx/rats.png}{fading}{pause 2000}");
		end;
		if add_krest > 0 then
			pn ("Число Ваших подданных увеличилось. "..sklon3(add_krest, "Родился", "Родилось").." "..add_krest.." "..sklon2(add_krest, "ребёнок", "ребёнка", "детей")..".{pic gfx/child.png}{fading}{pause 2000}");
		end;
		if run_krest > 0 then
			pn ("Вашим крестьянам не хватает земли. "..sklon3(run_krest, "Сбежал", "Сбежало").." "..run_krest.." "..mannam(run_krest)..".{fading}{pause 2000}{pic gfx/run_krest.png}");
		end;
		if run_guard > 0 then
			pn "Не хватило денег на выплату денежного довольствия Вашей гвардии.";
			pn (sklon3(run_guard, "Дезертировал", "Дезертировало").." "..run_guard.." "..sodnam(run_guard)..".{pic gfx/run_guard.png}{fading}{pause 2000}");
		end;
		if grab_gold > 0 then
			pn ("Скандал! Из сокровищницы "..sklon3(grab_gold, "похищен", "похищено").." "..grab_gold.." "..sklon2(grab_gold, "килограмм", "килограмма", "килограммов").." золота.{pic gfx/grab_gold.png}{fading}{pause 2000}");
		end;
		if grab_money > 0 then
			pn ("Кража! Визирь похитил "..grab_money.." "..rubnam(grab_money).." и скрылся!{pic gfx/visir_deneg.png}{fading}{pause 2000}");
		end;
		if kar_pribil > 0 then
			pn ("Вернулся Ваш караван! Получено прибыли на сумму "..kar_pribil.." "..rubnam(kar_pribil).."!{pic gfx/pribil_kar.png}{fading}{pause 2000}")
		end;
		pr ("{code yeartoyear.kbduse=true}{cut "..enterimg.."}{walk tmproom}");
	end;
};

startyear = room {
	nam = "Состояние";
	entered = code [[hook_all();]];
	exit = code [[unhook_all();]];
	yes  = code [[return walk "torgovla";]];
	no = code [[return nextstep();]];
	kbd = function(s, down, key)
		if down and (((key == "y" or key == "n") and fl_block == 0) or (key == "return" and fl_block == 1)) then
			click();
			if key == "y" then
				return stead.call(s, "yes");
			elseif key == "n" then
				return stead.call(s, "no");
			else
				return nextstep();
			end;
		end;
	end;
	dsc = function(s)
		p ("Состояние Ваших дел на "..god.."-й год правления:");
		moneytable();
		pr "^^";
		if fl_block == 1 then
			pn "Международный кризис! Торговля невозможна!";
			pn "Вашему государству объявлена экономическая блокада!";
			p (nextbutton);
		else
			pn "Желаете торговать на бирже?";
			p ("{yesselect|"..yimg.."}/{noselect|"..nimg.."}")
		end;
	end;
};

tmproom = room {
	nam = "tmproom";
	enter = code [[return nextstep();]];
};

gameend = xenterroom {
	nam = "Итого...";
	enter = code [[make_ochki(true)]];
	dsc = function(s)
		if fl_lec == 1 then
			pn "Болезнь победила Вас... Король УМЕР!!!^";
		elseif fl_lec == 2 then
			pn "Шаман ничем не смог помочь Вам... Король УМЕР!!!^";
		end;
		if not fl_r == 0 then
			pn "Голодающий народ ВОССТАЛ и сверг нерадивого правителя!!!";
			pn "Поздравляю Вас, батенька, с РЕВОЛЮЦИЕЙ, ха-ха...^";
		else
			pn "Ваше правление завершилось...^";
		end;
		p (times:txt ("В настоящий момент ваше состояние равняется:", nil, 3));
		moneytable();
		pr "^"
		p (txttab '0%');
		p 'Воздвигнуто храмов';
		p (txttab '35%');
		pn (build_xram);
		p (txttab '0%');
		p 'Время правления, лет';
		p (txttab '35%');
		pn (god);
		pn (times:txt ("За ваше состояние Вам даётся следующее количество очков:", nil, 3));
		deftable(make_ochki());
		p "^";
		p (txttab '0%');
		p 'Храмы';
		p (txttab '35%');
		pn (round(build_xram*200));
		p (txttab '0%');
		p 'Время правления';
		p (txttab '35%');
		pn (round((god)*10));
		pn ("Итого: "..tostring(ochki).." "..sklon2(ochki, "очко", "очка", "очков")..".");
		pn "Ну что ж... Поздравляю с успешным (?) окончанием игры.";
		p "P.S."
		if ochki<=100 then
			andalefnt "Вам бы лучше гусей пасти... Вместо Ваших крестьян...";
		elseif ochki<=300 then
			andalefnt "Для новичка - сойдет... Хотя, конечно, неважно...";
		elseif ochki<=500 then
			andalefnt "Ну, это уже кое-что... Худо-бедно, да ладно...";
		elseif ochki<=1000 then
			andalefnt "Ну вот, кое-что уже получается. Старайтесь дальше...";
		elseif ochki<=3000 then
			andalefnt "Неплохо, весьма неплохо... Уважаю...";
		elseif ochki<=5000 then
			andalefnt "Что ж, видно, играть Вы умеете... Весьма недурственно...";
		elseif ochki<=10000 then
			andalefnt "Круто, что говорить... Да Вы, батенька, профессионал...";
		elseif ochki<=100000 then
			andalefnt "Прости их, Господи... Ну Вы, блин, даете!!!";
		else
			timesfnt "NO pity, NO mercy, NO REGRET!!!!!!!!!!";
		end;
	end;
	obj = {xact('restart_x', code [[return stead.restart()]])};
	xdsc = make_enter("restart_x");
	press = function() vars_reset(); click();walk "main"; return true; end;
};

god_checker = trigger(code [[ walk 'gameend'; return true ]], [[ god > 50 ]]):on(1);
ill_checker = trigger(code [[ walk 'gameend'; return true ]], [[ fl_lec ~= 0 ]]):on(2);
rev_checker = trigger(code [[ walk 'gameend'; return true ]], [[ fl_r ~= 0 ]]):on(3);
end_checker = trigger(code [[ walk 'gameend'; return true ]], [[ fl_end ~= 0 or fl_r ~= 0 ]]):on(4);

-- eiforia -- главный объект после game (а по факту -- почти что фигня)
eiforia = obj {
	nam = "eiforia";
	global {
		-- описание возможных ресурсов и их начальные значения
		money=10000;
		gold=0;
		land=100;
		zerno=1000;
		krest=100;
--		krest=125;
		guard=100;
--		cattle=25;
		-- текущее состояние ресурсов
		cur_money=0;cur_gold=0;cur_land=0;cur_zerno=0;cur_krest=0;cur_guard=0;
		build_xram=0;
		ochki=0;
		-- средние цены
		pr_gold=1000;
		pr_land=200;
		pr_zerno=10;
		pr_krest=50;
		pr_guard=100;
		sod_guard=10;
		-- текущие цены
		cur_pr_gold=0;
		cur_pr_land=0;
		cur_pr_zerno=0;
		cur_pr_krest=0;
		cur_pr_guard=0;
		for_kar=0;
		for_xram=0;
		abs_sod_guard=0;
		run_krest=0;
		add_krest=0;
		run_guard=0;
		eat_rat=0;
		grab_money=0;
		grab_money2=0;
		grab_gold=0;
		ed_posev=1;
		ed_eat=3;
		for_posev=0;
		for_eat=0;
		add_zerno=0;
		urog=7;
		fl_urog=0;
		fl_r=0;
		fl_kar=0;
		kar_pribil=0;
		fl_marry=0;
		fl_end=0;
		fl_vis=0;
		fl_mar_war=0;
		why_mar_war=0;
		fl_mal_war=0;
		why_mal_war=0;
		fl_block=0;
		fl_lec=0;
		illend=0;
		god=1;
		-- Новое (не реализованно)
		-- Скот (cattle)
		--cur_cattle=0;
		--ch_cattle=0;
		--cur_pr_cattle=0;
		--pr_cattle=100;
		--for_cattle=0; -- На еду скоту
		--cattle_run=0; -- Скота сбежало
		--max_cattle_krest=2; -- Макс. животных на крестьянина
		--cattle_zerno=3; -- Зерна на скотину в год
		--add_cattle=0; -- Родилось скота
		--cattle_dead=0; -- Умерло скота
		---- Мясо (meat)
		--cur_meat=0;
		--ch_meat=0;
		--cur_pr_meat=0;
		--pr_meat=100;
		--meat_broken=0; -- Мяса испортилось
		---- Едобаллы (eats)
		--eats_need=0;
		--eats_gave=0;
		--eats_one_man=0;
		-- Доп. переменные, юзаются где попало
		-- Война и не только
		your_men_guard=0;
		your_men_krest=0;
		your_men_extra=0;
		enemy_men_guard=0;
		enemy_men_krest=0;
		ras_guard=0;
		ras_krest=0;
--		mobil=0;
		ch_money=0;
		ch_gold=0;
		ch_land=0;
		ch_zerno=0;
		ch_krest=0;
		ch_guard=0;
		-- Караван
		grabkar_type=0;
		grabkar=0;
		lekar_deneg = 0;
		wife_deneg = 0;
		mitropolit_deneg = 0;
		-- Королева
		prosit_mode = 0;
		prosit_end = 0;
		year_marry = 0;
		dead_prinal = 0;
		-- Митрополит
		xram_new = 0;
		-- Зерно
		zerno_nemog = 0;
		zerno_norma = 0;
		zerno_end = 0;
		-- Контроль цикла
		cstate = 0;
		ecstate = 0;
	}
}
