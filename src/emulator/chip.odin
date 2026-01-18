package emulator
import "core:math/rand"
import "core:os"

Chip :: struct {
    registers: Registers,
    memory: Memory,
    keypad: Keypad,
    display: Display,
}

// Initialize the Chip-8 emulator
init :: proc(chip: ^Chip) {
    set_pc(&chip.registers, 0x200)
    load_font_set(&chip.memory)
}

// Load a ROM into the Chip-8 emulator
load_rom :: proc(chip: ^Chip, filename: string) -> bool {
    data, ok := os.read_entire_file(filename)
    if !ok {
        return false
    }
    defer delete(data)

    for b, i in data {
        if 0x200 + i < len(chip.memory.chunks) {
            write_byte(&chip.memory, u16(0x200 + i), b)
        }
    }
    return true
}

// Update the timers
update_timers :: proc(chip: ^Chip) {
    dt := get_delay_timer(chip.registers)
    if dt > 0 {
        set_delay_timer(&chip.registers, dt - 1)
    }
    st := get_sound_timer(chip.registers)
    if st > 0 {
        set_sound_timer(&chip.registers, st - 1)
    }
}

// Verifica se o timer de som está ativo (maior que zero)
should_play_sound :: proc(chip: ^Chip) -> bool {
    return get_sound_timer(chip.registers) > 0
}

// Get the first 4 bits of the opcode
get_opcode_type :: proc(opcode: u16) -> u8 {
    return u8(opcode >> 12)
}

// Get the second 4 bits of the opcode
get_x :: proc(opcode: u16) -> u8 {
    return u8(opcode >> 8 & 0xf)
}

// Get the third 4 bits of the opcode
get_y :: proc(opcode: u16) -> u8 {
    return u8(opcode >> 4 & 0xf)
}

// Get the last 4 bits of the opcode
get_n :: proc(opcode: u16) -> u8 {
    return u8(opcode & 0xf)
}

// Get the last 8 bits of the opcode
get_nn :: proc(opcode: u16) -> u8 {
    return u8(opcode & 0xff)
}

// Get the last 12 bits of the opcode
get_nnn :: proc(opcode: u16) -> u16 {
    return opcode & 0xfff
}

// Fetch, decode and execute the next instruction
step :: proc(chip: ^Chip) {
    instruction := read_word(&chip.memory, chip.registers.pc)
    chip.registers.pc += 2
    opcode := get_opcode_type(instruction)

    switch opcode {
        case 0x0:
            switch instruction {
                case 0x00E0:
                    clear_display(&chip.display)
                case 0x00EE:
                    set_pc(&chip.registers, pop_stack(&chip.registers))
            }
        case 0x1:
            nnn := get_nnn(instruction)
            set_pc(&chip.registers, nnn)
        case 0x2:
            nnn := get_nnn(instruction)
            push_stack(&chip.registers, chip.registers.pc)
            set_pc(&chip.registers, nnn)
        case 0x3:
            x := get_x(instruction)
            nn := get_nn(instruction)
            if get_v_registers(chip.registers, x) == nn {
                chip.registers.pc += 2
            }
        case 0x4:
            x := get_x(instruction)
            nn := get_nn(instruction)
            if get_v_registers(chip.registers, x) != nn {
                chip.registers.pc += 2
            }
        case 0x5:
            x := get_x(instruction)
            y := get_y(instruction)
            if get_v_registers(chip.registers, x) == get_v_registers(chip.registers, y) {
                chip.registers.pc += 2
            }
        case 0x6:
            x := get_x(instruction)
            nn := get_nn(instruction)
            set_v_registers(&chip.registers, x, nn)
        case 0x7:
            x := get_x(instruction)
            nn := get_nn(instruction)
            set_v_registers(&chip.registers, x, u8(int(get_v_registers(chip.registers, x)) + int(nn)))
        case 0x8:
            n := get_n(instruction)
            x := get_x(instruction)
            y := get_y(instruction)
            switch n {
                case 0:
                    set_v_registers(&chip.registers, x, get_v_registers(chip.registers, y))
                case 1:
                    vx := get_v_registers(chip.registers, x)
                    vy := get_v_registers(chip.registers, y)
                    set_v_registers(&chip.registers, x, vx | vy)
                case 2:
                    vx := get_v_registers(chip.registers, x)
                    vy := get_v_registers(chip.registers, y)
                    set_v_registers(&chip.registers, x, vx & vy)
                case 3:
                    vx := get_v_registers(chip.registers, x)
                    vy := get_v_registers(chip.registers, y)
                    set_v_registers(&chip.registers, x, vx ~ vy)
                case 4:
                    vx := get_v_registers(chip.registers, x)
                    vy := get_v_registers(chip.registers, y)
                    sum := u16(vx) + u16(vy)
                    set_v_registers(&chip.registers, x, u8(sum))
                    set_v_registers(&chip.registers, 0xf, u8(sum > 0xff))
                case 5:
                    vx := get_v_registers(chip.registers, x)
                    vy := get_v_registers(chip.registers, y)
                    not_borrow := vx >= vy
                    set_v_registers(&chip.registers, x, u8(int(vx) - int(vy)))
                    set_v_registers(&chip.registers, 0xf, u8(not_borrow))
                case 6:
                    vx := get_v_registers(chip.registers, x)
                    lsb := vx & 1
                    set_v_registers(&chip.registers, x, vx >> 1)
                    set_v_registers(&chip.registers, 0xf, lsb)
                case 7:
                    vx := get_v_registers(chip.registers, x)
                    vy := get_v_registers(chip.registers, y)
                    not_borrow := vy >= vx
                    set_v_registers(&chip.registers, x, u8(int(vy) - int(vx)))
                    set_v_registers(&chip.registers, 0xf, u8(not_borrow))
                case 0xe:
                    vx := get_v_registers(chip.registers, x)
                    msb := vx >> 7
                    set_v_registers(&chip.registers, x, vx << 1)
                    set_v_registers(&chip.registers, 0xf, msb)
            }
        case 0x9:
            x := get_x(instruction)
            y := get_y(instruction)
            if get_v_registers(chip.registers, x) != get_v_registers(chip.registers, y) {
                chip.registers.pc += 2
            }
        case 0xa:
            nnn := get_nnn(instruction)
            set_i_register(&chip.registers, nnn)
        case 0xb:
            nnn := get_nnn(instruction)
            chip.registers.pc = nnn + u16(get_v_registers(chip.registers, 0))
        case 0xc:
            x := get_x(instruction)
            nn := get_nn(instruction)
            set_v_registers(&chip.registers, x, u8(rand.uint32()) & nn)

        case 0xd:
            x := get_x(instruction)
            y := get_y(instruction)
            n := get_n(instruction)

            vx := get_v_registers(chip.registers, x)
            vy := get_v_registers(chip.registers, y)
            set_v_registers(&chip.registers, 0xf, 0)

            for row in 0..<n {
                sprite_byte := read_byte(&chip.memory, get_i_register(chip.registers) + u16(row))
                if draw_byte(&chip.display, vx % 64, (vy % 32) + u8(row), sprite_byte) {
                    set_v_registers(&chip.registers, 0xf, 1)
                }
            }
        
        case 0xe:
            x := get_x(instruction)
            nn := get_nn(instruction)
            switch nn {
                case 0x9e:
                    if get_key_state(chip.keypad, get_v_registers(chip.registers, x) & 0xf) {
                        chip.registers.pc += 2
                    }
                case 0xa1:
                    if !get_key_state(chip.keypad, get_v_registers(chip.registers, x) & 0xf) {
                        chip.registers.pc += 2
                    }
            }
        case 0xf:
            x := get_x(instruction)
            nn := get_nn(instruction)
            switch nn {
                case 0x07:
                    set_v_registers(&chip.registers, x, get_delay_timer(chip.registers))
                case 0x0a:
                    pressed := false
                    for i in 0..<16 {
                        if get_key_state(chip.keypad, u8(i)) {
                            set_v_registers(&chip.registers, x, u8(i))
                            pressed = true
                            break
                        }
                    }
                    if !pressed {
                        chip.registers.pc -= 2
                    }
                case 0x15:
                    set_delay_timer(&chip.registers, get_v_registers(chip.registers, x))
                case 0x18:
                    set_sound_timer(&chip.registers, get_v_registers(chip.registers, x))
                case 0x1e:
                    set_i_register(&chip.registers, u16(int(get_i_register(chip.registers)) + int(get_v_registers(chip.registers, x))))
                case 0x29:
                    set_i_register(&chip.registers, FONT_SET_START_ADDRESS + u16(get_v_registers(chip.registers, x) & 0xf) * 5)
                case 0x33:
                    vx := get_v_registers(chip.registers, x)
                    i := get_i_register(chip.registers)
                    write_byte(&chip.memory, i, vx / 100)
                    write_byte(&chip.memory, i + 1, (vx / 10) % 10)
                    write_byte(&chip.memory, i + 2, vx % 10)
                case 0x55:
                    i := get_i_register(chip.registers)
                    for idx in 0..=x {
                        write_byte(&chip.memory, i + u16(idx), get_v_registers(chip.registers, u8(idx)))
                    }
                case 0x65:
                    i := get_i_register(chip.registers)
                    for idx in 0..=x {
                        set_v_registers(&chip.registers, u8(idx), read_byte(&chip.memory, i + u16(idx)))
                    }
            }
    }
}