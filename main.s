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

include 'chunk.inc'

extrn initChunk
extrn writeChunk
extrn freeChunk
extrn disassembleChunk
extrn addConstant

section ".text"

    public main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 8

    sub rsp, 32
    
    mov rdi, rsp
    call initChunk

    mov rdi, rsp
    movq xmm0, [constant]
    call addConstant
    mov ebx, eax
    
    mov rdi, rsp
    mov rsi, OP_CONSTANT
    mov rdx, 123
    call writeChunk

    mov rdi, rsp
    mov rsi, rbx
    mov rdx, 123
    call writeChunk

    mov rdi, rsp
    mov rsi, OP_RETURN
    mov rdx, 123
    call writeChunk
    
    mov rdi, rsp
    mov rsi, chunkName
    call disassembleChunk
    
    call freeChunk

    mov rsp, rbp
    pop rbp
    xor rax, rax
    ret

section ".data"
chunkName db "test chunk", 0
constant dq 1.2