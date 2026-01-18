package emulator

Keypad :: struct {
    keys: [16]bool
}

get_key_state :: proc(k: Keypad, key: u8) -> bool {
    return k.keys[key]
}