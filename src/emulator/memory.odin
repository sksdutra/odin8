package emulator

Memory :: struct {
    chunks: [4096]u8
}

write_byte :: proc(m: ^Memory, address: u16, value: u8) {
    m.chunks[address] = value
}

read_byte :: proc(m: ^Memory, address: u16) -> u8 {
    return m.chunks[address]
}

read_word :: proc(m: ^Memory, address: u16) -> u16 {
    return (u16(m.chunks[address]) << 8) | u16(m.chunks[address + 1])
}

load_font_set :: proc(m: ^Memory) {
    for b, i in font_set {
        m.chunks[FONT_SET_START_ADDRESS + i] = b
    }
}