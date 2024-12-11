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
; along with flox.  If not, see <https://www.gnu.org/licenses/>.

INTERPERET_OK = 0
INTERPERET_COMPILE_ERROR = 1
INTERPERET_RUNTIME_ERROR = 2

DEBUG_TRACE = 1
STACK_MAX = 256

; VM memory format (8 bytes)
; poninter chunk (8 bytes)
; pointer ip (8 bytes)