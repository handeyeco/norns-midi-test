pressed_notes = {}
midi_devices = {}

active_list_item = 1

in_midi_connection = nil
out_midi_connection = nil

function init()
  build_midi_device_list()

  params:add_option("midi_in_device", "midi in device", midi_devices, 1)
  params:set_action("midi_in_device", function() setup_midi_callback() end)
   
  params:add_number("midi_in_channel", "midi in channel", 1, 16, 1)
  params:set_action("midi_in_channel", function() setup_midi_callback() end)

  params:add_option("midi_out_device", "midi out device", midi_devices, 1)
  params:set_action("midi_out_device", function()  setup_midi_callback() end)

  params:add_number("midi_out_channel", "midi out channel", 1, 16, 1)
  params:set_action("midi_out_channel", function() setup_midi_callback() end)

  setup_midi_callback()
end

function build_midi_device_list()
  midi_devices = {}
  for i = 1, #midi.vports do
    local long_name = midi.vports[i].name
    local short_name = string.len(long_name) > 15 and util.acronym(long_name) or long_name
    table.insert(midi_devices, short_name)
  end
end

function midi.add()
  build_midi_device_list()
end

function midi.remove()
  clock.run(function()
    clock.sleep(0.2)
    build_midi_device_list()
  end)
end

function setup_midi_callback()
  -- clean up old connection
  if out_midi_connection ~= nil then
    stop_all_notes()
  end

  for i = 1, 16 do
    midi.vports[i].event = nil
  end

  -- make new connections
  in_midi_connection = midi.connect(params:get("midi_in_device"))
  out_midi_connection = midi.connect(params:get("midi_out_device"))

  -- listen for note on/off
  in_midi_connection.event = function(data)
    local message = midi.to_msg(data)
    tab.print(message)
    print(" ")
  
    if (message.ch == params:get("midi_in_channel")) then
      if message.type == "note_on" then
        pressed_notes[message.note] = message.note
        out_midi_connection:note_on(
          message.note,
          100,
          out_midi_channel)
      elseif message.type == "note_off" then
        pressed_notes[message.note] = nil
        out_midi_connection:note_off(
          message.note,
          100,
          params:get("midi_out_channel"))
      end
    end
  
    redraw()
  end
end

function stop_all_notes()
  for note=21,108 do
    for ch=1,16 do
      out_midi_connection:note_off(note, 100, ch)
    end
  end
  pressed_notes = {}
end

-- helper to draw selectable list item
function draw_line(yPos, leftText, rightText, active)
  local textPos = yPos + 7
  if active then
    screen.level(15)
    screen.rect(0,yPos,256,9)
    screen.fill()
    screen.level(0)
  else
    screen.level(2)
  end

  screen.move(1, textPos)
  screen.text(leftText)
  screen.move(128-1, textPos)
  screen.text_right(rightText)
end

function has_note_on()
  for _,v in pairs(pressed_notes) do
    return true
  end
  return false
end

function redraw()
  screen.clear()
  screen.fill()

  in_midi_index = params:get("midi_in_device")
  draw_line(0, "in:", in_midi_index.." "..midi_devices[in_midi_index], active_list_item==1)
  draw_line(10, "in ch:", params:get("midi_in_channel"), active_list_item==2)

  out_midi_index = params:get("midi_out_device")
  draw_line(20, "out:", out_midi_index .." "..midi_devices[out_midi_index], active_list_item==3)
  draw_line(30, "out ch:", params:get("midi_out_channel"), active_list_item==4)

  if has_note_on() then
    screen.level(15)
    screen.move(1, 60)
    screen.text("Active MIDI note!")
  else
    screen.level(2)
    screen.move(1, 60)
    screen.text("No active MIDI note")
  end

  screen.update()
end

function enc(n,d)
  if n == 2 then
    -- select which parameter to adjust
    active_list_item = util.clamp(active_list_item + d, 1, 5)
  elseif n == 3 then
    if (active_list_item == 1) then
      -- MIDI in device
      params:set("midi_in_device", params:get("midi_in_device") + d)
    elseif (active_list_item == 2) then
      -- MIDI in channel
      params:set("midi_in_channel", params:get("midi_in_channel") + d)
    elseif (active_list_item == 3) then
      -- MIDI out device
      params:set("midi_out_device", params:get("midi_out_device") + d)
    elseif (active_list_item == 4) then
      -- MIDI out channel
      params:set("midi_out_channel", params:get("midi_out_channel") + d)
    end
  end

  redraw()
end