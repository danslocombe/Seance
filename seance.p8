pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

text_speed = 0.35
text_speed_internal = text_speed * 1.5
global_state = nil
dialogue_y = 6

action_pressed_last_frame = false

function _init()
  cls(0)
  --global_state = init_intro()
  --global_state = init_talking()
  global_state = init_dead()
end

function _update60()
  if global_state != nil then
    global_state.updatefn(global_state)
  end

  action_pressed_last_frame = btn(4)
end

function _draw()
  if global_state != nil then
    global_state.drawfn(global_state)
  end
end

------

function init_dead()
  local state = {
    t = 0,
    s = 0,
    global_t = 0,
    state_init = true,
    updatefn = update_dead,
    drawfn = draw_dead,

    filter_scene = true,
    filter_pat = 0,
    noise_mag = 0,

    text = "",
    dialogue_state = 0,
    dialogue_t = 0,
    dialogue = {},

    objects = {},

    phase_text_y = 0,
    phase_col = 0,
    phase_bg_bits = 0,

    player = make_dead_player(32, 32),
  }

  add(state.dialogue, "i beckon thee ........")
  add(state.dialogue, "feel .... ... ...  to the")
  add(state.dialogue, "vibrations ................")
  add(state.dialogue, "....... fetch the .... ....")
  add(state.dialogue, "i sense a presence amongst us")

  -- your favourite
  -- 
  -- you are reminded of something deep inside you
  -- wow a cool plant
  -- the scent brings a great melencholy
  -- your mother is laughing these flowers in her hair
  -- you cant remember this one


  add(state.objects, {spr = 16, x = 100, y = 32, text = {"you are reminded of", "something deep inside you"} })

  add(state.objects, {spr = 16, x = 40, y = 42, text = {"the scent brings a","great melencholy"} })
  add(state.objects, {spr = 16, x = 40, y = 52, text = {"wow a cool plant"} })
  add(state.objects, {spr = 16, x = 40, y = 80, text = {"what is worse,", "the pain of the remembering,", " or the pain of the smelling?", text_pause = 10}})
  --add(state.objects, {spr = 16, x = 40, y = 80, text = "the pain of remembering fills you, is this the most pain?" })
  --add(state.objects, {spr = 16, x = 60, y = 62, text = "your mother is laughing, these flowers in her hair" })
  --add(state.objects, {spr = 16, x = 60, y = 102, text = "memory waters the plant with attention" })
  add(state.objects, {spr = 16, x = 50, y = 52, text = {"you are transported back home,", "your mother smiles", text_pause = 12 }})
  add(state.objects, {spr = 16, x = 60, y = 92, text = {"actually you dont really like", "this one" }})
  --add(state.objects, {spr = 16, x = 10, y = 82, text = {"your nose births the", "disappointment anew" }})
  add(state.objects, {spr = 28, x = 30, y = 82, text = {"my soul is a vessel,", "and my nose a steam paddle", text_pause = 10} })

  add(state.objects, {spr = 16, x = 40, y = 32, text = {"the scent of roses fills you"} })
  --add(state.objects, {spr = 16, x = 100, y = 32, text = "you reminise" })
  add(state.objects, {spr = 20, x = 3, y = 100, text = {"an oil painting in front of you", "it is ugly and shouldn't be here"}})
  add(state.objects, {spr = 25, x = 90, y = 100, text = {"the smell of burning wax", "evokes...", "evokes...", text_pause = 12}})
  add(state.objects, {spr = 25, x = 90, y = 10, text = {"saint waningus\'", "garden of smells"}})

  return state
end

function make_dead_player(x, y)
  local player = {
    x = x,
    y = y,
    xvel = 0,
    yvel = 0,
    spr_t = 0,
    spr_look_right = false,
    update = function(p)
      local spd = 0.85
      local t_xvel = 0
      local t_yvel = 0
      if btn(0) then
        t_xvel = -spd
        p.spr_look_right = false
      end
      if btn(1) then
        t_xvel = spd
        p.spr_look_right = true
      end
      if btn(2) then
        t_yvel = -spd
      end
      if btn(3) then
        t_yvel = spd
      end

      local d = sqrt(sqr(t_xvel) + sqr(t_yvel))
      local a = 0.25 + atan2(-t_yvel, t_xvel)
      t_xvel = d * cos(a)
      t_yvel = d * sin(a)

      local k = 12
      local k_stop = 5
      local xk = k
      local yk = k
      if t_xvel == 0 then
        xk = k_stop
      end
      if t_yvel == 0 then
        yk = k_stop
      end

      if t_xvel == 0 and t_yvel == 0 then
        p.spr_t = 0
      end

      p.xvel = lerp(p.xvel, t_xvel, xk)
      p.yvel = lerp(p.yvel, t_yvel, yk)

      p.x += p.xvel
      p.y += p.yvel
    end,
    draw = function(p)
      --rectfill(p.x, p.y, p.x+3, p.y+3, 7)
      local d = sqr(p.xvel) + sqr(p.yvel)
      local s = 28
      if d > 0.1 then
        p.spr_t += sqrt(d)
        s = 29
        if (p.spr_t / 3) % 2 < 1 then
          s = 30
        end
      end

      palt(11, true)
      palt(0, false)
      spr(s, p.x - 4, p.y - 4, 1, 1, p.spr_look_right)
      palt()
    end,
  }

  return player
end

function update_dead(state)
  state.t += 1
  state.global_t += 1
  state.player.update(state.player)

  local dialogue_t = 0
  local text = nil
  for i,o in pairs(state.objects) do
    local d2 = sqr(o.x - state.player.x) + sqr(o.y - state.player.y)
    if d2 < 60 then
      dialogue_t = state.dialogue_t + 1
      text = o.text
    end
  end
  state.dialogue_t = dialogue_t
  state.text = text

  state.filter_scene = true
  state.filter_pat = 0b0000000000000000.1
  local speed = sqr((1 + state.dialogue_state) * 0.15)
  local is_end = (state.dialogue_state == #state.dialogue - 2 and abs(state.phase_text_y - dialogue_y) < 1)
    or state.dialogue_state == #state.dialogue - 1
  if is_end then
    state.phase_text_y = dialogue_y
    speed = 0
  end
  state.phase_text_y = (state.phase_text_y + speed) % 128
  state.face_scale = 0
  state.phase_col += 0.4 * speed
  state.phase_bg_bits += 0.3 * speed
end

function draw_dead(state)
  --cls(0)
  local pat = generate_fillp(state.t, 32, state.phase_bg_bits, false)
  fillp(pat)
  rectfill(0, 0, 128, 128, state.phase_col)
  fillp()

  palt(11, true)
  palt(0, false)
  for i, o in pairs(state.objects) do
    spr(o.spr, o.x - 4, o.y - 4)
  end
  palt()

  if state.text != nil then
    local before = 0
    local text_pause = 2
    if state.text.text_pause != nil then
      text_pause = state.text.text_pause
    end
    for i,text in pairs(state.text) do
      if type(text) == "string" and state.dialogue_t * text_speed_internal > before then
        local yy = state.phase_text_y + i * 6
        --rectfill(0, yy, 128, yy + 4, 0)
        rectfill(0, yy-1, 128, yy + 5, 0)
        draw_text(state.dialogue_t * text_speed_internal - before, text, 4, yy, 7)
        before += #text + text_pause
      end
    end
  end

  state.player.draw(state.player)
end

------

function init_talking()
  local s = {
    t = 0,
    s = 0,
    global_t = 0,
    state_init = true,
    updatefn = update_talking,
    drawfn = draw_talking,

    filter_scene = true,
    filter_pat = 0,
    noise_mag = 0,

    text = "",
    face_sprite_x = 0,
    face_sprite_y = 32,
    face_scale = 1,
    face_angle = -0.25,
    face_mod = 1,
    face_mod_d = 0,
    draw_face = false,
    dialogue_state = 0,
    dialogue_t = 0,
    dialogue = {},

    phase_text_y = 0,
    phase_col = 0,
    phase_bg_bits = 0,
  }

  return s
end

function update_talking(state)
  state.t += 1
  state.dialogue_t += 1
  state.global_t += 1

  if state.s == 0 then
    if state.state_init then
      state.dialogue = {}
      add(state.dialogue, "i beckon thee ........")
      add(state.dialogue, "feel .... ... ...  to the")
      add(state.dialogue, "vibrations ................")
      add(state.dialogue, "....... fetch the .... ....")
      add(state.dialogue, "i sense a presence amongst us")
      add(state.dialogue, "i sense a presence amongst us")
      add(state.dialogue, "come close everyone we can ...")
      add(state.dialogue, "susan please stop")
      add(state.dialogue, "class this is serious please")
      add(state.dialogue, "        stop               ")
      add(state.dialogue, "light the candles darling")
      state.draw_face = true
    end
    state.filter_scene = true
    state.filter_pat = 0b0000000000000000.1
    local speed = sqr((1 + state.dialogue_state) * 0.15)
    local is_end = (state.dialogue_state == #state.dialogue - 2 and abs(state.phase_text_y - dialogue_y) < 1)
      or state.dialogue_state == #state.dialogue - 1
    if is_end then
      state.phase_text_y = dialogue_y
      speed = 0
    end
    state.phase_text_y = (state.phase_text_y + speed) % 128
    if is_end then
      state.phase_col = 0
      state.phase_bg_bits = 0
      state.face_scale = lerp(state.face_scale, 1.15 + 0.08*sin(state.global_t / 250), 40)
      state.face_mod = 0
      state.noise_mag = 0.0125
    else
      state.face_scale = 0
      state.phase_col += 0.4 * speed
      state.phase_bg_bits += 0.3 * speed
    end
  elseif state.s == 1 then
    if state.state_init then
      state.dialogue = {}
      add(state.dialogue, "intern pete, move the gin")
      add(state.dialogue, "ahh the spirits are in motion")
      --add(state.dialogue, "ahh i can feel the spirits")
    end
  elseif state.s == 2 then
    if state.state_init then
      state.dialogue = {}
      state.face_sprite_x = 5*8
      add(state.dialogue, "hello hello")
      state.pete_x = -4
    end

    if (state.pete_x < 64) then
      state.pete_x += 0.95
    end
  end

  state.state_init = false

  if (state.s > 0) then
    state.filter_scene = true

    local fade_in = state.s == 1
    state.filter_pat = generate_fillp(state.t, 32, state.t/7, not fade_in)

    if state.s == 1 then
      state.noise_mag = 1 / state.t
    else
      state.noise_mag = 0
    end

    state.face_angle = -0.25 + 0.025 * cos(state.global_t / 300)

    -- how much to sample angle in rendering
    state.face_mod = min(1, sqr(state.t/ 60))
    -- how much to offset distance in rendering
    state.face_mod_d = sin(state.global_t / 1000) * 4 / (0.1 * state.t + 1)
    state.face_scale = 1.15 + 0.08*sin(state.global_t / 250)
  end

  if (state.dialogue_state < #state.dialogue) then
    state.text = state.dialogue[state.dialogue_state+1]
    if action_pressed() then
      if state.dialogue_t * text_speed < #state.text then
        state.dialogue_t = 1000
      else
        state.dialogue_state += 1
        state.dialogue_t = 0

        if state.dialogue_state >= #state.dialogue then
          state.dialogue_state = 0
          state.s += 1
          state.state_init = true
          state.t = 0
        end
      end
    end
  end
end

function draw_scene(state)
  local y = 128 * 3 / 4 - 8
  local x = 32
  palt(11, true)
  palt(0, false)

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

  -- pete
  if state.s == 2 then
    spr(37+get_off(12), state.pete_x, y + 7)
  end

  --candles
  spr(24 + (state.t / 16) % 4, x+7, y-2)
  spr(24 + ((state.t + 2) / 16) % 4, x+40, y-2)

  -- effects

  if (state.noise_mag > 0.01) then
    dump_noise(state.noise_mag)
    if (state.filter_scene) then
      fillp(state.filter_pat)
      rectfill(0, 0, 128, 128, 0)
      fillp()
    end
  end

  palt()


end

function draw_phasein(state)
  --local pat_speed = sqrt(state.phase_col
  if (state.noise_mag > 0) then
    cls(0)
    dump_noise(state.noise_mag)
  else
    local pat = generate_fillp(state.t, 32, state.phase_bg_bits, false)
    fillp(pat)
    rectfill(0, 0, 128, 128, state.phase_col)
    fillp()

    --rectfill(0, text_y - 2, 128, text_y + 8, 0)
    rectfill(0, state.phase_text_y, 128, state.phase_text_y + 4, 0)

  end
end

function draw_talking(state)

  local text_y = dialogue_y

  if (state.s > 0) then
    cls(0)
    draw_scene(state)
  else
    text_y = state.phase_text_y
    draw_phasein(state)
  end

  if state.text != nil then
    draw_text(state.dialogue_t * text_speed, state.text, 4, text_y, 7)
  end

  -- face
  if state.draw_face then
    local face_x = 95 - state.face_scale*12
    local face_y = 35 - state.face_scale*16
    rspr(state.face_sprite_x,state.face_sprite_y,face_x,face_y,24,32,state.face_scale,state.face_angle, state.face_mod, state.face_mod_d, 11)

    local mouth_move_mult = 0.66
    local mouth_move_rate = 28
    if state.text != nil and state.dialogue_t * text_speed * mouth_move_mult < #state.text then
      if state.s > 0 and state.t % mouth_move_rate < mouth_move_rate/2 then
        rspr(24,32,face_x + 1, face_y, 16,32, state.face_scale, state.face_angle, state.face_mod, state.face_mod_d, 11)
      end
    end
  end
end

------

function init_intro()
  s = {
    t = 0,
    s = 0,
    complete = 160,
    updatefn = update_intro,
    drawfn = draw_intro,
  }

  return s
end

function update_intro(state)
  state.t += 1

  if action_pressed() then
    if state.t < state.complete then
      state.t = state.complete
    else
      state.t = 0
      state.s += 1
    end
  end

  if state.s >= 3 then
    global_state = init_talking()
    cls(0)
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

function rspr(sx, sy, tx, ty, w, h, scale, a, modp, modd, bgcol)
  local k = scale
  local kw = k*w
  local kh = k*h

  local sx_mid = sx + w/2
  local sy_mid = sy + h/2
  local tx_mid = tx + kw/2
  local ty_mid = ty + kh/2

  --a = -0.25
  --modp = 1

  local sample_angle_min = a
  local sample_angle_max = a + modp
  local sample_angle_mid = modp / 2

  local buffer = 0
  for y=-buffer,kh-1+buffer do
    for x=-buffer,kw-1+buffer do
      local d_tx = x - kw/2
      local d_ty = y - kh/2
      local dist = modd + sqrt((d_tx * d_tx) + (d_ty * d_ty)) / k
      local angle = atan2(d_ty, d_tx)
      local sample_angle = (a + modp * angle) -- + rnd(0.005))
      sget_x = (sx_mid + dist*cos(sample_angle))
      sget_y = (sy_mid + dist*sin(sample_angle))

        if sget_x >= sx and sget_x <= sx + w and sget_y >= sy and sget_y <= sy + h then
          local col = sget(sget_x, sget_y)

          if (col != bgcol) then
            pset(tx + x, ty + y, col)
          end
        end
    end
  end
end

function sqr(x)
  return x * x
end

function generate_fillp(t, k, bits_selector, just_filter)
    local filter = 0
    if (t % k) < k/2 then
      filter = 0b1110110111101111.1
    else
      filter = 0b0111101101111011.1
    end

    if (just_filter) then
      return filter
    end

    local pat = 0b0000000000000000.1
    for i = 0,(min(k, bits_selector)) do
      local x = shl(1, i)
      pat = bor(pat, x)
    end

    return band(pat, filter)
end

function map_angle(x, a, k)
      --local sample_angle = normalize_angle((a + modp * angle + rnd(0.005)))
      --local sample_angle = (a + modp * angle + rnd(0.005))
          -- sample backwards to prevent branch cut

          --new_angle = 1-new_angle
        --new_angle = new_angle / 2
        --sget_x = flr(sx_mid + dist*cos(new_angle))
        --sget_y = flr(sy_mid + dist*sin(new_angle))
  if (x < 0.5) then
    if (x < 0.25) then
      --return 0
    end
    return a + x * k
  end
  return a + k*(1 - x)
  --return a + x
end

function normalize_angle(x)
  if (x < 0) then
    return 1 + x
  end

  return x
end

function action_pressed()
  -- dont use inbuilt btnp because it has
  -- repeating
  return btn(4) and (not action_pressed_last_frame)
end

function lerp(x, y, scale)
  return (x * (scale-1) + y) / scale
end

__gfx__
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbbb8bbbbbbbb8bbbbbbbbbbbbbbb8bbbbbbbb8bbbbbb8bbb
00000000bb7777bbbbbbbbbbbbbbbbbbbbbbbbbbbb1111bbbb9999bbbb4444bbbbbb8bbbbbb8bbbbbbbb8bbbbbbbb8bbbbbb8bbbbbbbb8bbbbbb8bbbbbb8bbbb
00700700777fffbbbbbbbbbbbbbbbbbbbbbbbbbbbbe1e11bb999999bbb4444bbbbb8bbbbbbbb8bbbbbbb8bbbbbbbb8bbbbbbb8bbbbbb8bbbbbbb8bbbbbb8bbbb
00077000777fffbbbbbbbbbbbbbbbbbbbbbbbbbbbb4441ebb99ff99bbbbffbbbbbb9bbbbbbbb9bbbbbbbb9bbbbbbb9bbbbbbb9bbbbbb9bbbbbb9bbbbbbb9bbbb
000770007b7fffbbbbbbbbbbbbbbbbbbbbbbbbbbbb444eebbb9ff9bbbb6666bbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbbbbabbb
00700700bb4444bb444444444444444444444444bbddddbbbb2222bbbb6666bbbbbb7bbbbbbb7bbbbbbb7bbbbbbb7bbbbbbb7bbbbbbb7bbbbbbb7bbbbbbb7bbb
00000000bb44444b444444444444444444444444bd44ddbbbbf22fbbbbfeefbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbb
00000000bb44444bb4bbbbbbbbbbbbbbbbbbbb4bbdddddbbbbddddbbbbeeeebbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbb
bbbbbbbbbb7777bbbbbbbbbb00000000bbbbbbbbbb1111bbbb9999bbbb4444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777bbbb7777bbbbbbbbbb
bbbb8bbb777fffbbb444444b00000000b444444bbbe1e11bb999999bbb4444bbbbbbb8bbbbbb8bbbbbb8bbbbbbbb8bbbbb7777bbbb0707bbbb0707bbbbbbbbbb
bbb888bb777fffbbb411714b00000000b411a14bbb4441ebb99ff99bbbbffbbbbbbb8bbbbbb8bbbbbbbb8bbbbbbbb8bbbb0707bbbb7777bbbb7777bbbbbbbbbb
bbb888bb7b7fffbbb417f14b00000000b41afa4bbb444eebbb9ff9bbbb6666bbbbb89bbbbbb9bbbbbbbb98bbbbbbb9bbbb7777bbbb7777bbbb7777bbbbbbbbbb
bbb3bbbbbb4444bbb432234b00000000b4adda4bbbddddbbbb2222bbbb6666bbbbbbabbbbbbbabbbbbbbabbbbbbbabbbbb7777bbbb7bb7bbbb7bb7bbbbbbbbbb
bbbb3bbbbb4444bbb433224b00000000b4dd334bbbd4ddbbbb2222bbbbf66fbbbbbb7bbbbbbb7bbbbbbb7bbbbbbb7bbbbb7bb7bbbb7bb7bbbb7bb7bbbbbbbbbb
bbbb3bbbbb44444bb444444b00000000b444444bbd4dddbbbbfddfbbbbfeefbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbb7bb7bbbb7bbbbbbbbbb7bbbbbbbbbb
bbbb3bbbbb44444bbbbbbbbb00000000bbbbbbbbbddddbbbbbddddbbbbeeeebbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb555555550000000000000000bbb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
d4d4d444444d4d4dbbbb5bbb0000000000000000bb0040bbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddddbbbbbbdddddbbbb5bbb0000000000000000bbb44bbbbbbbbbbbbbbbbbbbbbb888bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddddbbbbbbddddd555555550000000000000000bb3333bbbbbbbbbbbbbbbbbbbbb888bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ddddbbbbbbbbddddb5bbbbbb0000000000000000bb3333bbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dbdbbbbbbbbbbdddb5bbbbbb0000000000000000bb4333bbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddbbbbbbbbbbdddbbbbbbbb0000000000000000bb4555bbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddbbbbbbbbbbdddbbbbbbbb0000000000000000bb5555bbbbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddbbbbbbbbbbddd000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddbbbbbbbbbbddd000000000000000000000000bbb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddbbbbbbbbbbddd000000000000000000000000bb0040bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bddbbbbbbbbbbddd000000000000000000000000bbb44bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddbbbbbbbbbbddd000000000000000000000000bb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ddd4444444444d4d000000000000000000000000bb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ddd4444444444ddd000000000000000000000000bb4555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddbbbbbbbbbbddd000000000000000000000000bb5555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb77777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbb7777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb777770000077777777777bbbbbbbbbbbbbbbbbbbbbbbbbbb111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb7777700ffff00000077777bbbbbbbbbbbbbbbbbbbbbbb1e11e11101e1e0111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb777770ffffffffff007777bbbbbbbbbbbbbbbbbbbbb111e1101e10ee1e0111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb777700fffffffffff00777bbbbbbbbbbbbbbbbbbbbbe11e1100e101eee0111bebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b777770fffffffffffff0777bbbbbbbbbbbbbbbbbbbbb0e1eee00e101eee01e11eebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b777700aaaaffffffaaf0077bbbbbbbbbbbbbbbbbbbbe001eee000e00ee00ee11eeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b77770ffffaaaaaaaafff077ffaaaaaaaafff077bbee00eeeeeeeee4eeeeeeeeeeeeebbb0000e00ebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b77770ffffffffffffffff07ffffffffffffff07bbbee0e0000000ee0000e001eeeeebbb4440400ebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b77700f0000ffffff0000ff0000ffffff0000ff0bbbee04400004444444040011eeeebbb41111000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b7770ff444004ff400444ff044004ff400444ff0bbbee01111144444411110011eeeebbb11444400bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b7770f2222244ff4442222ff22444ff4444422ffbbbee044441144441144440e99eeebbb44222200bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b770044107444ff44410742f22244ff44422242fbbbe0422222444442222220e40eeebbb44707020bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b770f4a100aaffff4a100aff0022ffff422004ffbbee0440707444444070724040eebebb44700040bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b770fff4444ffffff4444fff444ffffff4444fffbbee0440007444444000744440eeeebb44444440bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b770ffffffffffaffffffff4bbbbbbbbbbbbbbbbbbee0044444444444444444000eebebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b77704ffffffffaffffffff4bbbbbbbbbbbbbbbbbeee0044444404444444444000eeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b777044fffff0faf0ffff444bbbbbbbbbbbbbbbbbebe0004444404440444444000eeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b777044444000faf00044420bbbbbbbbbbbbbbbbbeee0044444094440044444040eeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb702244200ff4ff0044220bbbbbbbbbbbbbbbbbeee004444904444404444400eeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb7b0222200000000222200bbbbbbbbbbbbbbbbbeeebb0444400000004444409eeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb000000f40004f000040bbbbbbbbbbbbbbbbbbbeee0444444000444444001eeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb04420ff44444ff04440bbbbbbbbbbbbbbbbbbbbeb04444444444444440beeeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb04ffff022f222ffff40fff22222222fff40bbbbbb00444022000044440bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb00fff022222220ffff0ff220000002ffff0bbbbbbb0440222222204400bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb00fff0000000ffff00fff22000022fff00bbbbbbbb04400000004440bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb0fffff444ffffff00ffff222222ffff00bbbbbbbb00444444444400bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb0fffaaaaaaff0000bfffaaaaaaff0000bbbbbbbbbb004444444000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbb000ffffffa00bbbbb00ffffffa00bbbbbbbbbbbbbbb000444000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb00000000bbbbbbbb00000000bbbbbbbbbbbbbbbbbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
