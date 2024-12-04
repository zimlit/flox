# Copyright (C) 2024 Devin Rockwell
# 
# This file is part of flox.
# 
# flox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# flox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with flox.  If not, see <http://www.gnu.org/licenses/>.

flox: main.o chunk.o memory.o debug.o value.o
	gcc -no-pie debug.o main.o chunk.o memory.o value.o -o flox

main.o: main.s chunk.inc
	fasm main.s

chunk.o: chunk.s chunk.inc memory.inc
	fasm chunk.s

memory.o: memory.s memory.inc
	fasm memory.s

debug.o: debug.s
	fasm debug.s

value.o: value.s
	fasm value.s