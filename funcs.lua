-- Пояснение: канал 0 -- клик, 1 -- музыка, 2 -- эффекты
stead.module_init(function()
	stead.busy(true);
	click_snd = sound.load('snd/click.ogg');
	turning_snd = sound.load('snd/turning.ogg');
	main_snd = sound.load('snd/main.ogg');
	game_snd = sound.load('snd/game.ogg');
	andale = font('fonts/Andale_Mono.ttf', 16);
	times = font('fonts/Times_New_Roman.ttf', 16);
	stead.busy(false);
	return true
end);

-- m -- нижний предел, n -- верхний, a -- кол-во знаков после запятой
rndfr = function(m, n, a)
	m = m or 0;
	n = n or 1;
	a = a or 0;
	a = 10 ^ a;
	m = m * a;
	n = n * a;
	local b = math.random(m, n);
	return b/a;
end;

rnd = stead.hook(rnd, function(f, m)
	if m < 1 then
		return 0;
	end;
	return f(m)
end)

make_enter = function(name)
	return ("{"..name.."|"..enterimg.."}")
end

enterimg = img('gfx/enter.png');
nextbutton = make_enter("nextstep_xact");
yimg = img('gfx/Y.png');
nimg = img('gfx/N.png');

function click()
	sound.stop("0");
	sound.play(click_snd, 0, 1);
end
jump = xact('jump', code [[ walk(arg1) ]]);
jumpout = xact('jumpout', code [[ walkout() ]]);
jumpsnd = xact('jumpsnd', code [[ click(); walk(arg1) ]]);
function _andale(text)
  return function()
    return p (andale:txt (text));
  end
end
function andalefnt(text)
    return p (andale:txt (text));
end
function _times(text)
  return function()
    return p (times:txt (text));
  end
end
function timesfnt(text)
    return p (times:txt (text));
end
function _warn(text)
  return function()
    return p (andale:txt (text, 'red', 1));
  end
end
function warnfnt(text)
    return p (andale:txt (text, 'red', 1));
end
