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
  global_state = init_dead()
  --global_state = init_talking()
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

    text = nil,
    interupt_text = nil,
    interupt_text_t = 0,
    dialogue_state = 1,
    dialogue_t = 0,
    dialogue = {},

    objects = {},
    drawables = {},

    phase_text_y = 0,
    phase_col = 0,
    phase_bg_bits = 0,

    player = make_dead_player(64, 22),

    smelled_serious = 0,
    smelled_funny = 0,
  }

  add(state.drawables, state.player)

  music(2, 8000)

  add(state.dialogue, "i beckon thee ........")
  add(state.dialogue, "feel .... ... ...  to the")
  add(state.dialogue, "vibrations ................")
  add(state.dialogue, "....... fetch the .... ....")
  add(state.dialogue, "i sense a presence amongst us")
  add(state.dialogue, "come close everyone we can ...")
  add(state.dialogue, "susan please stop")
  add(state.dialogue, "please everone sit down an be ")
  add(state.dialogue, "quiet class is in progress")
  add(state.dialogue, "everyone this is serious please")
  add(state.dialogue, "the spirit is nearing us quick!")
  add(state.dialogue, "            stop           ")
  add(state.dialogue, "light the candles darling")

  local add_talker = function(s, x, y, text, funny)
    local obj = {
      s = s,
      x = x,
      y = y,
      text = text,
      funny = funny,
      draw = function(o, state)
        palt(11, true)
        palt(0, false)
        spr(o.s, o.x - 4, o.y - 4)
        palt()
      end
    }

    add(state.objects, obj)
    add(state.drawables, obj)
  end

  -- you cant remember this one
  --add_talker(16, 100, 32)
  add_talker(16, 100, 32, {"you are reminded of", "something deep inside you"})
  add_talker(16, 46, 26, {"the scent of roses fills you"})
  add_talker(16, 40, 48, {"the scent brings a","great melencholy"})

  add_talker(16, 12, 59, {"wow a cool plant"}, true)
  add_talker(16, 40, 80, {"what is worse,", "the pain of the remembering,", " or the pain of the smelling?", text_pause = 10}, true)
  add_talker(16, 70, 52, {"you are transported back home,", "your mother smiles", text_pause = 12 })
  add_talker(16, 98, 89, {"actually you dont really like", "this one" }, true)
  add_talker(19, 90, 10, {"saint waningus\'", "garden of smells"})

  add_talker(20, 23, 100, {"an oil painting in front", "of you, it is ugly and ", "shouldn't be here", text_pause = 2}, true)
  add_talker(25, 76, 115, {"the smell of burning wax", "evokes...", "evokes...", text_pause = 12})

  add_talker(28, 67, 78, {"\"my soul is a vessel,", "and my nose the steam paddle\"", text_pause = 10}, true)

  --add(state.objects, {16, x = 10, y = 82, text = {"your nose births the", "disappointment anew" }})
  --add(state.objects, {16, x = 40, y = 80, text = "the pain of remembering fills you, is this the most pain?" })
  --add(state.objects, {16, x = 60, y = 62, text = "your mother is laughing, these flowers in her hair" })
  --add(state.objects, {16, x = 60, y = 102, text = "memory waters the plant with attention" })

  --add(state.objects, {16, x = 100, y = 32, text = "you reminise" })
  --add(state.objects, {28, x = 84, y = 82, text = {"ah i could smell you coming", "i was reminded of my dog", text_pause = 12} })
  --add(state.objects, {28, x = 84, y = 82, text = {"i prefer the feeling den", "i was reminded of my dog", text_pause = 12} })

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
    footstep_t = 0,
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

      --local d = sqrt(sqr(t_xvel) + sqr(t_yvel))
      if t_xvel != 0 or t_yvel != 0 then
        local a = 0.25 + atan2(-t_yvel, t_xvel)
        t_xvel = spd * cos(a)
        t_yvel = spd * sin(a)
      end

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

      local p_spd = sqrt(sqr(p.xvel) + sqr(p.yvel))
      p.spr_t += p_spd

      if (p_spd > 0.0001) then
        p.footstep_t -= p_spd
        if (p.footstep_t < 0) then
          p.footstep_t = 5
          sfx(4)
        end
      else
        p.footstep_t = 0
      end

      p.x += p.xvel
      p.y += p.yvel
    end,
    draw = function(p, state)
      --rectfill(p.x, p.y, p.x+3, p.y+3, 7)
      circfill(p.x, p.y, rnd(state.dialogue_state * 2), 0)
      --if state.dialogue_state > 4 then
        --circfill(p.x, p.y, 3 + rnd(8), 7)
      --end
      local d = sqr(p.xvel) + sqr(p.yvel)
      local s = 28
      if d > 0.1 then
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
      if state.dialogue_t == 0 then
        if o.funny then
          state.smelled_funny += 1
        else
          state.smelled_serious += 1
        end
      end
    end
  end

  state.dialogue_t = dialogue_t
  state.text = text

  state.filter_scene = true
  state.filter_pat = 0b0000000000000000.1

  local speed = 0

  if state.smelled_serious < 1 or state.smelled_funny < 1 then
  else
    speed = sqr((state.dialogue_state) * 0.15)

    if state.smelled_serious >= 4
      and state.smelled_funny >= 4
      and state.dialogue_state <= #state.dialogue then

      --if state.interupt_text_t == 0 and (state.dialogue_state + 1) % 2 == 0 then
      --end
      
      if state.interupt_text_t == 0 and state.dialogue_state == 1 then
        music(-1)
      end

      if (stat(24) == -1) then
        local spd = 26-2*state.dialogue_state
        set_speed(6, spd)
        set_speed(7, spd)
        music(1)
      end

      state.interupt_text_t += 1
      state.interupt_text = state.dialogue[state.dialogue_state]
      if state.interupt_text_t * text_speed * 0.25 * sqrt(state.dialogue_state) > #state.interupt_text then
        state.interupt_text_t = 0
        state.dialogue_state += 1
      end
    end
  end

  local is_end = (state.dialogue_state == #state.dialogue - 1 and abs(state.phase_text_y - dialogue_y) < 1)
    or state.dialogue_state >= #state.dialogue
  if is_end then
    global_state = init_talking()
    --state.phase_text_y = dialogue_y
    --speed = 0
  end

  state.phase_text_y = (state.phase_text_y + 2 * speed) % 128
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

  insertion_sort(state.drawables, function(list, i) return list[i].y end)

  for i,o in pairs(state.drawables) do
    o.draw(o, state)
  end

  if state.interupt_text != nil then
    local yy = state.phase_text_y
    rectfill(0, yy, 128, yy + 4, 0)
    --rectfill(0, yy-1, 128, yy + 5, 0)
    draw_text(state.interupt_text_t * text_speed_internal, state.interupt_text, 4, yy, 6, 5)
  end

  if state.text != nil then
    local before = 0
    local text_pause = 2
    if state.text.text_pause != nil then
      text_pause = state.text.text_pause
    end
    for i,text in pairs(state.text) do
      if type(text) == "string" and state.dialogue_t * text_speed_internal > before then
        --local yy = state.phase_text_y + i * 6
        local yy = 100 + i * 6
        --rectfill(0, yy, 128, yy + 4, 0)
        rectfill(0, yy-1, 128, yy + 5, 0)
        draw_text(state.dialogue_t * text_speed_internal - before, text, 4, yy, 7, 0)
        before += #text + text_pause
      end
    end
  end
end

------

function init_talking()
  music(-1)
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
      --add(state.dialogue, "i beckon thee ........")
      --add(state.dialogue, "feel .... ... ...  to the")
      --add(state.dialogue, "vibrations ................")
      --add(state.dialogue, "....... fetch the .... ....")
      --add(state.dialogue, "i sense a presence amongst us")
      --add(state.dialogue, "i sense a presence amongst us")
      --add(state.dialogue, "come close everyone we can ...")
      --add(state.dialogue, "susan please stop")
      --add(state.dialogue, "class this is serious please")
      add(state.dialogue, "           stop            ")
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
      music(0)
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
    draw_text(state.dialogue_t * text_speed, state.text, 4, text_y, 7, 5)
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

function draw_text(t, text, x, y, col, sfx_id)
  if sfx_id != nil and t < #text then
    sfx(sfx_id)
  end
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

function insertion_sort(list, f)
  local i = 2
  while i <= #list do
    local j = i
    while j > 1 and f(list, j-1) > f(list, j) do 
      local tmp = list[j]
      list[j] = list[j-1]
      list[j-1] = tmp
      j -= 1
    end
    i += 1
  end
end

function set_speed(sfx, speed)
  poke(0x3200 + 68*sfx + 65, speed)
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
bbbbbbbbbb7777bbbbbbbbbb44444444bbbbbbbbbb1111bbbb9999bbbb4444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777bbbb7777bbbbbbbbbb
bbbb8bbb777fffbbb444444b4ffffff4b444444bbbe1e11bb999999bbb4444bbbbbbb8bbbbbb8bbbbbb8bbbbbbbb8bbbbb7777bbbb0707bbbb0707bbbbbbbbbb
bbb888bb777fffbbb411714b4ffffff4b411a14bbb4441ebb99ff99bbbbffbbbbbbb8bbbbbb8bbbbbbbb8bbbbbbbb8bbbb0707bbb777777bb777777bbbbbbbbb
bbb888bb7b7fffbbb417f14b4ffffff4b41afa4bbb444eebbb9ff9bbbb6666bbbbb89bbbbbb9bbbbbbbb98bbbbbbb9bbbb7777bbbb7777bbbb7777bbbbbbbbbb
bbb3bbbbbb4444bbb432234b44444444b4adda4bbbddddbbbb2222bbbb6666bbbbbbabbbbbbbabbbbbbbabbbbbbbabbbb777777bbb7bb7bbbb7bb7bbbbbbbbbb
bbbb3bbbbb4444bbb433224bbb4bb4bbb4dd334bbbd4ddbbbb2222bbbbf66fbbbbbb7bbbbbbb7bbbbbbb7bbbbbbb7bbbbb7bb7bbbb7bbbbbbbbbb7bbbbbbbbbb
bbbb3bbbbb44444bb444444bbb4bb4bbb444444bbd4dddbbbbfddfbbbbfeefbbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbb7bb7bbbb7bbbbbbbbbb7bbbbbbbbbb
bbbb3bbbbb44444bbbbbbbbbbb4bb4bbbbbbbbbbbddddbbbbbddddbbbbeeeebbbbbb6bbbbbbb6bbbbbbb6bbbbbbb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
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
__sfx__
0101000023050230502305032050320503205031000160002300022000210001f0001e0001b000170001600000000000000000000000000000000000000000000000000000000000000000000000000000000000
018300000c214182140c214184140c214182140c214184140a214162140a214164140521411214052141141400004000000000000000000000000000000000000000000000000000000000000000000000000000
011800000c0100c0200c0300c0400c0400c0300c0200c0100c0100c0200c0300c0400c0300c0200c0100c0100c0100c0200c0300c0300c0200c0100c0100c0100c0100c0200c0300c0400c0500c0400c0300c020
0110000000000000000000000000000001a0101a0501a010000000000021010210502101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000017030170300b03002030020300203031000160002300022000210001f0001e0001b000170001600000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001773017731171311a1311a0311a0310e03002030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a0000021511a0111a05126111321113e71102221023311a0211a0211a0211a0211a0211a0211a0241a02421011210512d11139111217110922109321090311d0201d0211d0211c0211c0211c0211c0211c021
011800000e2101a2101a11026214263101a51026114261110e2101a2101a110262141a3101a51026114261112121021210211102d21421310215102d1142d1111c2101c2101c110282141c3101c5102811428111
011000000061102611046210562107621056210462102621006210262104621056210762104621026210062100621026210462105621046210262100621026210e6210c621026210462104621056210462102621
011500000504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040050400504005040
011500000204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040020400204002040
01150000157541575017754177501c7541c7521775417750157541575017754177501c7541c7521773117755157541575017754177501c7541c75217754177501575415750177541775010754107501375413750
0115000011754117501575415750187541875015754157501175411750157541575018754187521d7311d75511754117501575415750187541875215754157501175411750157541575018754187501175411750
01100000000001500015000170501704017050170401703017020170101701017010170100c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a000014155141051415514005115550000008511085211455114552141551410000000161550000000000200500000020050000001d0500000000000000000000000000000000000000000000000000000000
__music__
03 02034344
04 06074344
01 094a0b4c
02 0a4a0c4c

