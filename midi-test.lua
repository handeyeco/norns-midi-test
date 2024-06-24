pressed_notes = {}

active_list_item = 1

in_midi_index = 1
in_midi_channel = 1
in_midi_connection = nil
out_midi_index = 1
out_midi_channel = 1
out_midi_connection = nil

function init()
  setup_midi_callback()
end

function setup_midi_callback()
  -- clean up old connection
  if out_midi_connection ~= nil then
    stop_all_notes()
  end
  midi.cleanup()

  -- make new connections
  in_midi_connection = midi.connect(in_midi_index)
  out_midi_connection = midi.connect(out_midi_index)

  -- listen for note on/off
  in_midi_connection.event = function(data)
    local message = midi.to_msg(data)
    tab.print(message)
    print(" ")
  
    if (message.ch == in_midi_channel) then
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
          out_midi_channel)
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

  draw_line(0, "in:", in_midi_index.." "..midi.devices[in_midi_index].name, active_list_item==1)
  draw_line(10, "in ch:", in_midi_channel, active_list_item==2)
  draw_line(20, "out:", out_midi_index .." "..midi.devices[out_midi_index].name, active_list_item==3)
  draw_line(30, "out ch:", out_midi_channel, active_list_item==4)

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
      in_midi_index = util.clamp(in_midi_index + d, 1, #midi.devices)
    elseif (active_list_item == 2) then
      -- MIDI in channel
      in_midi_channel = util.clamp(in_midi_channel + d, 1, 16)
    elseif (active_list_item == 3) then
      -- MIDI out device
      out_midi_index = util.clamp(out_midi_index + d, 1, #midi.devices)
    elseif (active_list_item == 4) then
      -- MIDI out channel
      out_midi_channel = util.clamp(out_midi_channel + d, 1, 16)
    end

    setup_midi_callback()
  end

  redraw()
end