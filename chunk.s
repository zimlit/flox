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
include 'memory.inc'

extrn reallocate
extrn initValueArray
extrn freeValueArray
extrn writeValueArray

    section ".text"
    public initChunk ; void (Chunk *chunk)
initChunk:
    push rbp
    mov rbp, rsp

    mov dword [rdi], 0 ; count = 0
    mov dword [rdi + 4], 0 ; capacity = 0
    mov qword [rdi + 8], 0 ; code = NULL
    mov qword [rdi + 16], 0 ; lines = NULL

    push rdi
    add rdi, 24
    call initValueArray
    pop rdi

    mov rsp, rbp
    pop rbp
    ret

    public writeChunk ; void (Chunk *chunk, uint8_t byte, int line)
writeChunk:
    push rbp
    mov rbp, rsp

    mov eax, dword [rdi] ; rax = count
    add eax, 1 ; rax++
    cmp dword [rdi + 4], eax
    jge endif ; capacity is sufficient
    mov ecx, dword [rdi + 4] ; rcx = capacity
    push rcx
    push rax
    push rdx
    GROW_CAPACITY ecx
    pop rdx
    mov [rdi + 4], ecx
    ;call reallocate
    pop rcx
    push rdi
    push rsi
    push rdx ; alignment
    mov rsi, rcx ; rsi = oldCapacity
    mov rdx, [rdi + 4] ; rdx = newCapacity
    mov rdi, [rdi + 8] ; rdi = code
    call reallocate
    pop rdx
    pop rsi
    pop rdi
    mov qword [rdi + 8], rax ; code = rax
    push rdi
    push rsi
    push rdx
    mov rsi, rcx ; rsi = oldCapacity
    mov rdx, [rdi + 4] ; rdx = newCapacity
    mov rdi, [rdi + 16] ; rdi = lines
    call reallocate
    pop rdx
    pop rsi
    pop rdi
    mov qword [rdi + 16], rax ; code = rax
    pop rax

endif:
    mov rax, [rdi + 8] ; rax = code
    mov r8, [rdi+16] ; r8 = lines
    mov ecx, dword [rdi] ; rdx = count
    mov byte [rcx + rax], sil ; code[count] = sil
    mov dword [rcx*4 + r8], edx
    add dword [rdi], 1 ; count++

    mov rsp, rbp
    pop rbp
    ret

    public freeChunk
freeChunk:
    push rbp
    mov rbp, rsp

    mov rsi, [rdi + 4] ; rsi = capacity
    xor rdx, rdx
    push rdi
    mov rdi, [rdi + 8] ; rdi = code
    call reallocate
    pop rdi

    mov rsi, [rdi + 4]
    xor rdx, rdx
    push rdi
    mov rdi, [rdi + 16] ; rdi = lines
    call reallocate
    pop rdi

    add rdi, 8
    call initValueArray
    sub rdi, 8

    call initChunk

    mov rsp, rbp
    pop rbp
    ret

    public addConstant ; int (Chunk *chunk, Value value)
addConstant:
    push rbp
    mov rbp, rsp
    
    add rdi, 24
    call writeValueArray
    mov eax, dword [rdi]
    sub rax, 1

    mov rsp, rbp
    pop rbp
    ret