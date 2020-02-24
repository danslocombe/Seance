pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

state = {}

updatefn = nil
drawfn = nil

function _init()
  --state = init_intro()
  state = init_talking()
end

function _update60()
  if updatefn != nil then
    updatefn(state)
  end
end

function _draw()
  if drawfn != nil then
    drawfn(state)
  end
end

------

function init_talking()
  s = {t = 0, s = 0}

  updatefn = update_talking
  drawfn = draw_talking

  return s
end

function update_talking(state)
  state.t += 1
end

function draw_talking(state)
  cls(0)
  local y = 128 * 3 / 4 - 8
  local x = 32
  palt(11, true)
  palt(0, false)

  --dump_noise(0.01)

  -- paintings
  spr(18, x + 11, y - 14)
  spr(20, x + 43, y - 14)

  -- window
  local wx = x + 22
  local wy = y - 19

  --for i=0,1 do
  --  local xx = wx+2 + rnd(12)
  --  local yy = wy+2 + rnd(12)
  --  local theta = 0.19
  --  local len = 9
  --  local x1 = min(max(wx+2, xx + len * cos(theta)), wx+12)
  --  local y1 = min(max(wy+2, yy + len * sin(theta)), wy+12)
  --  line(xx, yy, x1, y1, 7)
  --end

  spr(32, wx, wy)
  spr(33, wx+8, wy)
  spr(48, wx, wy+8)
  spr(49, wx+8, wy+8)

  -- characters
  -- get offset to sprite index
  local get_off = function(i)
    if ((state.t + i) % 128) < 64 then
      return 16
    else
      return 0
    end
  end

  spr(1+get_off(1), x, y)
  spr(5+get_off(5), x+48, y)
  spr(6+get_off(10), x+16, y)
  spr(7+get_off(7), x+32, y)

  -- floor
  for i = 0,6 do
    spr(34, x + i * 8, y + 12)
  end

  -- table
  spr(2, x+8, y)
  spr(3, x+16, y)
  spr(3, x+24, y)
  spr(3, x+32, y)
  spr(4, x+40, y)

  palt()

  spr(24 + (state.t / 16) % 4, x+7, y-2)
  spr(24 + ((state.t + 2) / 16) % 4, x+40, y-2)
end

------

function init_intro()
  s = {t = 0, s = 0, complete = 160}

  updatefn = update_intro
  drawfn = draw_intro

  return s
end

function update_intro(state)
  state.t += 1

  if (btnp(4)) then
    if state.t < state.complete then
      state.t = state.complete
    else
      state.t = 0
      state.s += 1
    end
  end

  if state.s >= 3 then
    state = init_talking()
  end
end

function draw_intro(state)
  cls(0)
  -- based on a collection of transcripts from the infamous
  -- 1998 summonings of hawthorn manor 

  if state.s == 0 then
    draw_text(state.t, "based on a collection of", 4, 32, 7)
    draw_text(state.t - 32, "transcripts from the infamous", 4, 32 + 8, 7)
    draw_text(state.t - 64, "1998 events at hawthorne manor.", 4, 32 + 16, 7)
  end

  if state.s == 1 then
    draw_text(state.t, "before publication, a team of", 4, 32, 7)
    draw_text(state.t - 32, "of paranormal reasearchers was", 4, 32 + 8, 7)
    draw_text(state.t - 64, "hired to corroborate the", 4, 32 + 16, 7)
    draw_text(state.t - 96, "presented findings.", 4, 32 + 24, 7)
  end

  if state.s == 2 then
    draw_text(state.t, "a complete list of sources", 4, 32, 7)
    draw_text(state.t - 32, "can be on our website:", 4, 32 + 8, 7)
    draw_text(state.t - 64, "http://ss.wordpress.com/ref.php", 4, 32 + 16, 7)
  end

  if state.t > state.complete then
    if (state.t % 60) < 30 then
      print("█", 110, 100, 7)
    end
  end

  -- what you are about to witness is a studio recreation
  -- on the 9th januaray 2013 a team of paranormal researchers
  -- were hired to review the footage
   
  -- now in a controled environment
  -- intern pete
  -- sprite please come forward
  -- what do you have to tell us
  --draw_text(state.t, "intern pete, prepare the stethosisphere", 32, 32, 7)
  --print("intern pete prepare the stethosisphere", 32, 32, 7)
end

function draw_text(t, text, x, y, col)
  local s = sub(text, 1, max(0, min(t, #text)))
  print(s, x, y, col)
end

function dump_noise(mag)
  local screen_start = 0x6000
  local screen_size = 8000
  for i=1,mag * 30 do
    local len = 50 + rnd(100)
    local pos = rnd(screen_size) + screen_start
    len = min(len, screen_start + screen_size - pos)
    memset(pos, rnd(64), len)
  end
end
__gfx__
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000008000000800000000800000000000000080000000080000008000
00000000bb7777bbbbbbbbbbbbbbbbbbbbbbbbbbbb1111bbbb9999bbbb4444bb0000800000080000000080000000080000008000000008000000800000080000
00700700777fffbbbbbbbbbbbbbbbbbbbbbbbbbbbbe1e11bb999999bbb4444bb0008000000008000000080000000080000000800000080000000800000080000
00077000777fffbbbbbbbbbbbbbbbbbbbbbbbbbbbb4441ebb99ff99bbbbffbbb0009000000009000000009000000090000000900000090000009000000090000
000770007b7fffbbbbbbbbbbbbbbbbbbbbbbbbbbbb444eebbb9ff9bbbb6666bb0000a0000000a0000000a0000000a0000000a0000000a0000000a0000000a000
00700700bb4444bb444444444444444444444444bbddddbbbb2222bbbb6666bb0000700000007000000070000000700000007000000070000000700000007000
00000000bb44444b444444444444444444444444bd44ddbbbbf22fbbbbfeefbb0000600000006000000060000000600000006000000060000000600000006000
00000000bb44444bb4bbbbbbbbbbbbbbbbbbbb4bbdddddbbbbddddbbbbeeeebb0000600000006000000060000000600000006000000060000000600000006000
00000000bb7777bbbbbbbbbb00000000bbbbbbbbbb1111bbbb9999bbbb4444bb0000000000000000000000000000000000000000000000000000000000000000
00000000777fffbbb444444b00000000b444444bbbe1e11bb999999bbb4444bb0000080000008000000800000000800000000000000000000000000000000000
00000000777fffbbb411714b00000000b411a14bbb4441ebb99ff99bbbbffbbb0000800000080000000080000000080000000000000000000000000000000000
000000007b7fffbbb417f14b00000000b41afa4bbb444eebbb9ff9bbbb6666bb0008900000090000000098000000090000000000000000000000000000000000
00000000bb4444bbb432234b00000000b4adda4bbbddddbbbb2222bbbb6666bb0000a0000000a0000000a0000000a00000000000000000000000000000000000
00000000bb4444bbb433224b00000000b4dd334bbbd4ddbbbb2222bbbbf66fbb0000700000007000000070000000700000000000000000000000000000000000
00000000bb44444bb444444b00000000b444444bbd4dddbbbbfddfbbbbfeefbb0000600000006000000060000000600000000000000000000000000000000000
00000000bb44444bbbbbbbbb00000000bbbbbbbbbddddbbbbbddddbbbbeeeebb0000600000006000000060000000600000000000000000000000000000000000
bbbbbbbbbbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d4d4d444444d4d4dbbbb5bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddbbbbbbdddddbbbb5bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddbbbbbbddddd5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddbbbbbbbbddddb5bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dbdbbbbbbbbbbdddb5bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddbbbbbbbbbbdddbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddbbbbbbbbbbdddbbbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddbbbbbbbbbbddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddbbbbbbbbbbddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddbbbbbbbbbbddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bddbbbbbbbbbbddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddbbbbbbbbbbddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd4444444444d4d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd4444444444ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddbbbbbbbbbbddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
