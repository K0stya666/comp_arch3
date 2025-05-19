
    .data

input_addr:  .word 0x80
output_addr: .word 0x84

    .text

_start:

    ; чтение указателя на входное значение
    lui   t0, %hi(input_addr)               ; t0 <- 0x00000080 & 0xFFFFF000 = 0x00000000
    addi  t0, t0, %lo(input_addr)           ; t0 <- 0x00000000 + 0x00000080 = 0x00000080
    lw    t0, 0(t0)                         ; t0 ← M[t0]  (фактический указатель на число)

    ; чтение самого 32битного числа
    lw    t1, 0(t0)                         ; t1 ← *(uint32_t*)t0

    ; подготовка констант
    addi  t2, zero, 24                      ; сдвиг на 24 бита
    addi  t3, zero, 16                      ; сдвиг на 16 бит
    addi  t4, zero, 8                       ; сдвиг на  8 бит
    addi  t5, zero, 255                     ; маска 0xFF

    ; извлечение отдельных байтов
    srl   a0, t1, t2                        ; сдвигаем на t2 бит t1 и записывем в a0
    srl   a1, t1, t3                        ; 
    and   a1, a1, t5                        ; 
    srl   a2, t1, t4                        ; 
    and   a2, a2, t5                        ; 
    and   a3, t1, t5                        ; 

    ; перемещение их наоборот
    sll   a3, a3, t2                        ; сдвигаем влево
    sll   a2, a2, t3                        ; 
    sll   a1, a1, t4                        ; 

    ; склейка результата
    mv    a4, a3                            ; a4 = старший байт
    or    a4, a4, a2                        ; добавляем следующий
    or    a4, a4, a1                      
    or    a4, a4, a0                        ; итог: a4 = 0x11223344

    ; запись результата
    lui   t0, %hi(output_addr)              ; t0 ← адрес метки 0x84
    addi  t0, t0, %lo(output_addr)         
    lw    t0, 0(t0)                         ; t0 ← указатель куда сохранять
    sw    a4, 0(t0)                         ; *t0 = a4

    halt