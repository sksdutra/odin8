package emulator

Registers :: struct {
    v: [16]u8,
    i: u16,
    delay_timer: u8,
    sound_timer: u8,
    pc: u16,
    sp: u8,
    stack: [16]u16,
}

get_v_registers :: proc(r: Registers, register: u8) -> u8 {
    return r.v[register]
}

set_v_registers :: proc(r: ^Registers, register: u8, value: u8) {
    r.v[register] = value
}

get_i_register :: proc(r: Registers) -> u16 {
    return r.i
}

set_i_register :: proc(r: ^Registers, value: u16) {
    r.i = value
}

get_delay_timer :: proc(r: Registers) -> u8 {
    return r.delay_timer
}

set_delay_timer :: proc(r: ^Registers, value: u8) {
    r.delay_timer = value
}

get_sound_timer :: proc(r: Registers) -> u8 {
    return r.sound_timer
}

set_sound_timer :: proc(r: ^Registers, value: u8) {
    r.sound_timer = value
}

set_pc :: proc(r: ^Registers, value: u16) {
    r.pc = value
}

get_sp :: proc(r: Registers) -> u8 {
    return r.sp
}

set_sp :: proc(r: ^Registers, value: u8) {
    r.sp = value
}

push_stack :: proc(r: ^Registers, value: u16) {
    r.stack[r.sp] = value
    r.sp += 1
}

pop_stack :: proc(r: ^Registers) -> u16 {
    r.sp -= 1
    return r.stack[r.sp]
}