package main

import "core:fmt"
import "core:os"
import "ui"
import emu "emulator"

main :: proc() {
	if len(os.args) < 2 {
		fmt.println("Usage: odin8 <rom_path>")
		return
	}
	rom_path := os.args[1]
	chip := emu.Chip{}
	ui.run(&chip, rom_path)
}