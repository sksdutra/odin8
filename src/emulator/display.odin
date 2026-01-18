package emulator

Display :: struct {
    pixels: [64 * 32]u8,
}

// Draws a byte on screen and check for collison
draw_byte :: proc(d: ^Display, x: u8, y: u8, byte: u8) -> bool {
    collision := false
    for i in 0..<8 {
        // Verify each bit of the byte (from most significant to least)
        if (byte >> (7 - u8(i))) & 1 != 0 {
            px := u16(x) + u16(i)
            py := u16(y)

            // Clipping: ignore pixels outside the screen
            if px >= 64 || py >= 32 {
                continue
            }

            idx := py * 64 + px
            is_on := d.pixels[idx] == 1
            d.pixels[idx] ~= 1 // XOR
            
            if is_on && d.pixels[idx] == 0 {
                collision = true
            }
        }
    }
    return collision
}

clear_display :: proc(d: ^Display) {
    for i in 0..<len(d.pixels) {
        d.pixels[i] = 0
    }
}
