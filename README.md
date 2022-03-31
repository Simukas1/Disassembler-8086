# Disassembler-8086

Version: 1.0<br>
Author: Simonas Jarukaitis<br>
E-mail: simasjarukaitis@gmail.com<br>

<h2>Introduction</h3>
A disassembler is software, that converts machine language instructions into assembly language instructions.<br>
This disassembler for 8086/8088 processor. It converts .com program instructions to assembly language. For example, 04 17 means add al, 17.<br>
It should work with all commands, presented at file instr86.pdf.<br>

If Disassembler does not understand command, it will return "db xx" (xx - byte).<br>

Template for disassembler was provided by my professor, Irus Grinis. it had simple 1 byte instructions, function to open, read, close files.<br>
Grinis also provided libraries "yasmlib.asm" and "yasmmac.inc".<br>

<h2>Usage</h2>

First, we will need these files:
<ul>
  <li>DOSBOX emulator (https://www.dosbox.com/download.php?main=1)</li>
  <li>dsmnulis.asm file</li>
  <li>YASM.exe file (to compile .com file)</li>
  <li>yasmliv.asm and yasmmac.inc files</li>
  <li>DEBUG.com file, used for creating .com files</li>
</ul>

Then, launch DEBUG.com, and write these instructions:
<ul>
  <li>mount c: 'folder with dsmnulis.asm file'.</li>
  <li>c:</li>
  <li>yasm dsmnulis.asm -fbin -o dsmnulis.com OR cl dsmnulis, if you have cl.bat file</li>
  <li>debug</li>
  <li>a100</li>
  <li>Now write assembly commands</li>
  <li>When you are done writing, press enter and write r cx</li>
  <li>enter how many bytes you used (You can see them on the left, behind the assembly commands)</li>
  <li>n 'file_name.com'</li>
  <li>w</li>
  <li>q</li>
  <li>dsmnulis 'file_name'</li>
</ul>

Copyright (C) 2021 Simonas Jarukaitis, Vilnius University.
