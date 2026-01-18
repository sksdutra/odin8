package ui

import rl "vendor:raylib"

import emu "../emulator"

run :: proc(c: ^emu.Chip, rom_path: string) {
    rl.SetTraceLogLevel(.WARNING)
    screen_width  : i32 = 800
    screen_height : i32 = 450
    rl.InitWindow(screen_width, screen_height, "Odin8: The CHIP-8 Emulator")
    defer rl.CloseWindow()

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    rl.SetTargetFPS(60)

    emu.init(c)
    if !emu.load_rom(c, rom_path) {
        return
    }

    sample_rate : u32 = 44100
    frequency   : u32 = 440
    volume      : i16 = 3000

    samples := make([]i16, int(sample_rate))
    defer delete(samples)

    period := int(sample_rate / frequency)
    half_period := period / 2

    for i in 0..<int(sample_rate) {
        samples[i] = ((i / half_period) % 2 == 0) ? volume : -volume
    }

    wave := rl.Wave{
        frameCount = sample_rate,
        sampleRate = sample_rate,
        sampleSize = 16,
        channels   = 1,
        data       = raw_data(samples),
    }

    beep := rl.LoadSoundFromWave(wave)
    defer rl.UnloadSound(beep)

    for !rl.WindowShouldClose() {
        for i in 0..<10 {
            emu.step(c)
        }
        emu.update_timers(c)

        if emu.should_play_sound(c) {
            if !rl.IsSoundPlaying(beep) do rl.PlaySound(beep)
        } else {
            if rl.IsSoundPlaying(beep) do rl.StopSound(beep)
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        scale_x := screen_width / 64
        scale_y := screen_height / 32

        for y in 0..<32 {
            for x in 0..<64 {
                if c.display.pixels[y * 64 + x] != 0 {
                    rl.DrawRectangle(i32(x) * scale_x, i32(y) * scale_y, scale_x, scale_y, rl.WHITE)
                }
            }
        }

        key_map := [16]rl.KeyboardKey{
            .X, .ONE, .TWO, .THREE,
            .Q, .W, .E, .A,
            .S, .D, .Z, .C,
            .FOUR, .R, .F, .V,
        }

        for key, i in key_map {
            is_pressed := rl.IsKeyDown(key)
            c.keypad.keys[i] = is_pressed
        }

        rl.EndDrawing()
    }
}