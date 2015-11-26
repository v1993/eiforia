stead.module_init(function()
	click_snd = sound.load('snd/click.ogg');
	andale = font('fonts/Andale_Mono.ttf', 16);
	times = font('fonts/Times_New_Roman.ttf', 16);
	return true
end);


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
	sound.play(click_snd, "0", "1");
end
jump = xact('jump', code [[ walk(arg1) ]]);
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
