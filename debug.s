; Copyright (C) 2024 Devin Rockwell
; 
; This file is part of flox.
; 
; flox is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
; 
; flox is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with flox.  If not, see <http://www.gnu.org/licenses/>.

format ELF64

extrn printf
extrn printValue

section ".text"
    public disassembleChunk
disassembleChunk: ; (Chunk *chunk, const char *name)
    push rbp
    mov rbp, rsp

    push rdi
    push rsi
    mov rdi, nameFormat
    xor rax, rax
    call plt printf
    pop rsi
    pop rdi

    xor rsi, rsi
for:
    cmp esi, dword [rdi]
    jge endloop
    call disassembleInstruction
    mov rsi, rax
    jmp for
endloop:

    mov rsp, rbp
    pop rbp
    ret

    public disassembleInstruction
disassembleInstruction: ; (Chunk *chunk, int offset)
    push rbp
    mov rbp, rsp

    xor rax, rax
    push rsi
    push rdi
    mov rdi, offsetFormat
    call printf
    pop rdi
    pop rsi

    cmp rsi, 0
    mov rdx, [rdi+16]
    mov edx, [rdx+rsi*4]
    jle els
    mov rcx, [rdi+16]
    mov ecx, [rcx+rsi*4-4]
    cmp ecx, edx
    jne els
    push rdi
    push rsi
    mov rdi, lineContFormat
    xor rax, rax
    call printf
    pop rsi
    pop rdi
    jmp endif
els:
    push rdi
    push rsi
    xor rax, rax
    mov rdi, lineNumFormat
    mov esi, edx
    call printf
    pop rsi
    pop rdi
endif:

    mov rcx, [rdi + 8]
    xor rdx, rdx
    mov dl, byte [rcx + rsi]
    cmp rdx, 2 ; number of cases
    jge default
    lea rax, [jump_table + rdx*8]
    jmp qword [rax]

op_constant:
    push rdi
    mov rdx, rdi
    mov rdi, op_constantFormat
    call constantInstruction
    pop rdi
    jmp endSwitch

op_return:
    push rdi
    mov rdi, op_returnFormat
    call simpleInstruction
    pop rdi
    jmp endSwitch

default:
    push rsi
    push rdi
    xor rax, rax
    mov rdi, unkownOpcodeFormat
    mov rsi, rdx
    call printf
    pop rdi
    pop rsi
    mov rax, rsi
    add rax, 1
endSwitch:
    mov rsp, rbp
    pop rbp
    ret

simpleInstruction:
    push rbp
    mov rbp, rsp

    push rsi
    mov rsi, rdi
    mov rdi, simpleInstructionFormat
    xor rax, rax
    call printf
    pop rsi
    mov rax, rsi
    add rax, 1

    mov rsp, rbp
    pop rbp
    ret

public constantInstruction
constantInstruction: ; (const char *name, int offset, Chunk* chunk)
    push rbp
    mov rbp, rsp

    mov r8, [rdx + 8]
    add r8, 1
    xor rcx, rcx
    mov cl, byte [r8]

    push rdx
    push rsi
    mov rsi, rdi
    xor rdx, rdx
    mov dl, cl
    mov rdi, constantFormat
    xor rax, rax
    call printf
    pop rsi
    pop rdx

    push rsi
    push rdx
    mov rdi, [rdx + 32]
    add rdi, r10
    movq xmm0, [rdi]
    call printValue
    pop rdx
    pop rsi

    push rsi
    push rbx
    mov rdi, constantEndFormat
    xor rax, rax
    call printf
    pop rbx
    pop rsi

    mov rax, rsi
    add rax, 2

    mov rsp, rbp
    pop rbp
    ret

section ".rodata"
nameFormat: db "== %s ==", 10, 0
offsetFormat: db "%04d ", 0
unkownOpcodeFormat: db "Unkown opcode %d", 10, 0
op_returnFormat: db "OP_RETURN", 0
op_constantFormat: db "OP_CONSTANT", 0
simpleInstructionFormat: db "%s", 10, 0
jump_table: dq op_constant, op_return
constantFormat: db "%-16s %4d '", 0
constantEndFormat: db "'", 10, 0
lineNumFormat: db "%4d ", 0
lineContFormat: db "   | ", 0