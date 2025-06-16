
    
    .data


input_addr:     .word  0x80
output_addr:    .word  0x84
stack_top:      .word  0x1000

                
    .text

_start:
    movea.l  stack_top, A7          ; устанавливаем стек
    movea.l  (A7), A7

    movea.l  input_addr, A0
    movea.l  (A0), A0

    move.l   (A0), D0               ; a
    move.l   (A0),  D1              ; b

    movea.l  output_addr, A1
    movea.l  (A1), A1

    jsr      gcd

    move.l   D0, (A1)               ; записываем НОД
    halt


gcd:

    ; если b > a, то меняем их местами и теперь a это b, а b это a
    cmp.l    D1, D0
    bpl      gcd_loop
    jsr      swap

gcd_loop:

    cmp.l   0, D1               ; пока b != 0
    beq     end

    move.l  D0, D3
    div.l   D1, D3              ; D3 = a / b 

    mul.l   D1, D3              ; D3 = (a / b) * b

    move.l  D0, D4              ; D4 = a
    sub.l   D3, D4              ; D4 = a % b


    move.l  D1, D0              ; a = b
    move.l  D4, D1              ; b = a % b

    jmp     gcd_loop

end:
    rts



;======================= ФУНКЦИИ =======================

; функция, которая меняет аргументы местами
swap:
    move.l   D0, D2
    move.l   D1, D0
    move.l   D2, D1
    rts

; функция, которая вычитает из a b
subber:
    move.l   D0, D2             ; D2 = a
    move.l   D1, D3             ; D3 = b

subber_loop:

    sub.l    D3, D2             ; D2 = diff = a - b
    bpl      subber_loop        ; если diff >= 0, то продолжаем вычитать

    add.l    D3, D2             ; делаем шаг назад
    move.l   D2, D0
    rts