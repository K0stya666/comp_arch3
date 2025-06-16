
    
    .data


input_addr:     .word  0x80
output_addr:    .word  0x84
stack_top:      .word  0x1000

                
    .text


_start:
    movea.l  stack_top, A7      ; устанавливаем стек
    movea.l  (A7), A7

    movea.l  input_addr, A0
    movea.l  (A0), A0

    movea.l  output_addr, A1
    movea.l  (A1), A1


    move.l   (A0)+, D0           ; a
    move.l   (A0),  D1           ; b

    
    jsr      gcd

    move.l   D0, (A1)            ; записываем НОД
    halt


gcd:

    cmp.l    0, D0               ; флаги по a
    bpl      abs_a_ok
    not.l    D0
    add.l    1, D0

abs_a_ok:
    cmp.l    0, D1               ; флаги по b
    bpl      abs_b_ok
    not.l    D1
    add.l    1, D1

abs_b_ok:
    cmp.l    0, D0               ; если a==0 -> gcd=b
    beq      return_b
    cmp.l    0, D1               ; если b==0 -> gcd=a
    beq      return_a

gcd_loop:
    cmp.l    D1, D0
    beq      gcd_done

    bgt      a_gt_b

    sub.l    D0, D1              ; b = b − a
    jmp      gcd_loop

a_gt_b:
    sub.l    D1, D0              ; a = a − b
    jmp      gcd_loop

return_b:
    move.l   D1, D0
    rts

return_a:
    rts

gcd_done:
    rts
