; BIOS = Basic Input Output System
; boot sector needs to be 512 bits total
; org directive, tells assembler where we expect our code to be loaded (offset)
org 0x7C00
; bits directive tells assembler to emit 16/32/64 bit code
bits 16

; nasm macro to define new line bytes
%define ENDL 0x0D, 0x0A

msg_helloworld: db 'Hello world!', ENDL, 0

; memory segments
; cs - currently running code segment
; ds - data segment
; ss - stack segment
; es, fs, gs - extra data segments

start:
	jmp main

; prints a string to the screen
; params:
; - ds:si points to the string
puts:
	; save the registers we will use
	push si
	push ax

.loop:
	lodsb     ; loads next character in al
	or al, al ; verify if next character is null
	jz .done  ; if so jump to done

	; BIOS int 0x10, ah = 0x0e
	; prints a character to the screen in TTY mode
	; ah = 0x0e
	; al = ASCII character to write
	; bh = page number (text modes)
	; bl = foreground pixel color (graphics mode)
	mov ah, 0x0e
	mov bh, 0
	int 0x10

	jmp .loop

.done:
	; restore registers and return
	pop ax
	pop si
	ret

main:
	; setup data segments
	mov ax, 0
	mov ds, ax ; can't write to ds & es directly
	mov es, ax

	; setup stack
	mov ss, ax
	mov sp, 0x7C00 ; sp - stack pointer, stack grows downwards
	; so we put it at the start of the program so it doesn't overwrite the os program

	; move string to si and call puts function
	mov si, msg_helloworld
	call puts

	HLT ; stop CPU from executing, can be resumed by an interrupt

.halt:
	jmp .halt

; times repeat given instruction a number of times
; db stands for "define byte(s)", writes given bytes to the assembled binary file
; $ is a special nasm symbol which is equal to the memory offset of the current line
; $$ is a special nasm symbol which is equal to the memory offset of the beginning of the current section
; so it means that it fill with 0 for at most 510 bytes depending on the current size
; because BIOS expects 512 bytes boot sector
times 510-($-$$) db 0
; dw stands for "define word(s)", writes given word(s) (2 bytes, little endian) to the assembled binary file
; boot sector should finish with bytes 0xAA55
dw 0xAA55
