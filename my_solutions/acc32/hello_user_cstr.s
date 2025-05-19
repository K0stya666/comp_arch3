

    .data


i:                   .word 0
ptr:                 .word 0           ; указатель на текущую исходную строку
ptr_g:               .word 0

buf:                 .byte 'What is your name?\n\0'
name_buf:            .byte '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0'


greet_prefix:        .byte 'Hello, \0\0\0\0\0\0\0\0\0'
greet_suffix:        .byte '!\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0'

input_addr:          .word 0x80        ; адрес ввода символов
output_addr:         .word 0x84        ; адрес вывода символов
greet_addr:          .word 0x00
trash_addr:          .word 0x50

const_FF:            .word 0xFF
const_1:             .word 1           ; константа "1" для инкремента
const_NL:            .word 0x0A        ; символ '\n'
const_0:             .word 0x00
const_last:          .word 0x22
const_24:            .word 24
const_null:          .word 0xCCCCCCCC
const_term:          .word '\0'

trash:               .word 0x5f
counter:             .word 0

.org 0x90

    .text

_start:

    load_imm    buf
    store       ptr             ; ptr <- адрес buf

; вывести вопрос
print_buf:
    load_ind     ptr            ; while (*ptr != 0) {
    beqz         read_input

    and          const_FF       
    store_ind    output_addr    ;       *output_addr <- *ptr & const_FF

    load         ptr
    add          const_1        ;       ptr++
    store        ptr

    jmp          print_buf      ; }




; считать имя в name_buf
read_input:

    load_imm    name_buf
    store       ptr             ; ptr <- адрес name_buf

read_loop:

    load        counter
    add         const_1
    store       counter

    sub         const_24
    beqz        format2

    load_ind    input_addr
    and         const_FF
    store_ind   ptr

    load_ind    ptr
    sub         const_NL
    beqz        finish_input    ; if (байт == '\n') break

    ; load_ind    ptr
    ; sub         const_0
    ; beqz        free_ram

    load        ptr
    add         const_1
    store       ptr

    jmp         read_loop     


; =================== СБОРКА ПРИВЕТСТВИЯ ====================
finish_input:

    load_imm    greet_prefix
    store       ptr

; записать префикс
prefix_loop:
    load_ind    ptr             ; while (*ptr != 0) {
    beqz        name

    and         const_FF
    store_ind   greet_addr      ;       *greet_addr <- *ptr & const_FF

    load        greet_addr
    add         const_1         ;       greet_addr++
    store       greet_addr

    load        ptr
    add         const_1         ;       ptr++
    store       ptr

    jmp         prefix_loop     ; }


; записать имя
name:

    load_imm    name_buf
    store       ptr

name_loop:
    load_ind    ptr
    sub         const_NL
    beqz        suffix          ; while (*ptr != '\n') {

    load_ind    ptr
    and         const_FF
    sub         const_0
    beqz        suffix

    load_ind    ptr
    and         const_FF
    store_ind   greet_addr      ;       *greet_addr <- *ptr & const_FF

    load        greet_addr
    add         const_1         ;       greet_addr++
    store       greet_addr

    load        ptr
    add         const_1         ;       ptr++
    store       ptr

    jmp         name_loop       ; }


; записать суффикс
suffix:

    load_imm    greet_suffix
    store       ptr

suffix_loop:
    load_ind    ptr
    beqz        print_greet_buf  ; while (*ptr != 0) {

    and         const_FF
    store_ind   greet_addr      ;       *greet_addr <- *ptr & const_FF

    load        greet_addr
    add         const_1         ;       greet_addr++
    store       greet_addr

    load        ptr 
    add         const_1         ;       ptr++
    store       ptr

    jmp         suffix_loop     ; }


; напечатать приветствие 
print_greet_buf:
    
print_greet_buf_loop:
    load_ind    ptr_g                       ; while (*ptr != 0) {
    beqz        write_term

    and         const_FF
    store_ind   output_addr                 ;       *output_addr <- *ptr_g & const_FF

    load        ptr_g
    add         const_1                     ;       ptr_g++
    store       ptr_g 

    jmp         print_greet_buf_loop        ; }


write_term:

    load        const_0
    and         const_FF
    store_ind   ptr_g

    load        ptr_g
    add         const_1
    store       ptr_g       


format:
    load        ptr_g
    sub         const_last
    beqz        end 

    load        trash
    and         const_FF
    store_ind   ptr_g

    load        ptr_g
    add         const_1
    store       ptr_g

    jmp         format


format2:
    load        const_null
    store_ind   output_addr

    
end:
    halt
