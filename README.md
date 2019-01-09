* assmebler for sun architecture in c
* dependencies <br>
 flex, yacc, gcc, make
* how to compile <br>
 make all
* how to use <br>
 ./sunasm < sample.s | tee sample.bin

* add support for directive
 ex.)
 .segment text 
 .byte
 .word
 
