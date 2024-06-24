# norns-midi-test

Test script to ask a question about Norns MIDI

I'm using an "Arturia KeyStep 32", but I imagine any USB MIDI controller would work.

[Question link](https://llllllll.co/t/two-scripts-nts-1-ripchord-and-a-question/67721)

## Steps to repro:

1. Go to `SYSTEM > DEVICES > MIDI`
2. Set all slots to `none`
3. Load the `midi-test.lua` script
4. Use k2 and k3 to set the input device to `2 Arturia KeyStep 32`
5. Play notes on your keyboard, note the app still says `No active MIDI notes`
   - **In the script, `midi.devices` has `Arturia KeyStep 32` at index 2, but calling `midi.connect(2)` doesn't seem to set it up correctly**
6. Go to `SYSTEM > DEVICES > MIDI`
7. Set slot 1 to `1. Arturia KeyStep 32`
8. Go back to the `midi-test.lua` script
9. Use k2 and k3 to set the input device to `2 Arturia KeyStep 32`
10. Play notes on your keyboard, note the app still says `No active MIDI notes`
    - **Even though we set the USB keyboard up, it's still not right**
11. Use k2 and k3 to set the input device to `1 virtual`
12. Play notes on your keyboard, note the app says `Active MIDI note!`
    - **Even though the entry in `midi.devices` is listed as `1 virtual` it's actually the `Arturia KeyStep 32`**

## Expected behavior:

- There should be a list of connected MIDI devices
- I should be able to use `midi.connect` to connect to a specific device
- The names of the listed devices should reflect what those devices actually are
