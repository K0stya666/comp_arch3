    .data
input_addr:  .word 0x80
output_addr: .word 0x84


    .text

_start:
    @p input_addr a! @          \ читаем a
    @p input_addr a! @          \ читаем b

    dup                         \ (a b) <- b
    a!                          \ b -> A


    over                        \ (a b) -> (b a)
    dup                         \ (b a) <- a 
    a                           \ (b a a) <- b

    inv                         \ (b a a ~b)
    lit 1                       \ (b a a ~b 1)
    +                           \ (b a a -b)
    +                           \ (b a diff)


    a!                          \ diff -> A 
    over                        \ (b a) -> (a b)
    a                           \ (a b) <- diff


    -if loop                    \ если diff >= 0, то меняем местами a и b
    switch

loop:

    dup                         \ (a b) -> (a b b)
    if end                      \ if (b == 0) { завершить }

    \ mod
    
    \ (a b)
    dup                         \ (a b) <- b
    inv                         \ (a b ~b)
    lit 1                       \ (a b ~b 1)
    +                           \ (a b -b)

    a!                          \ -b -> A
    over                        \ (a b) -> (b a)
    a                           \ (b a) <- -b
    +                           \ (b diff)

    dup                          \ (b diff diff)
    -if subber                   \ if (diff >= 0)
    +                            \ (b + diff)
    
end:
    drop
    @p output_addr a! !         \ записываем результат
    halt
    


\================= ФУНКЦИ ==================

\ функция, которая меняет аргументы местами
switch:
    over
    ;


\ нахождение остатка
subber:
    \ (b diff)
    over                        \ (diff b)
    dup                         \ (diff b) <- b
    inv                         \ (diff b ~b)
    lit 1                       \ (diff b ~b 1)
    +                           \ (diff b -b)
    a!                          \ ~b -> A

    over                        \ (diff b) -> (b diff)
    a                           \ (b diff) <- -b
    +                           \ (b {diff - b})



    dup 
    -if subber                   \ if ({diff - b} >= 0)


back:
    \ (b diff)
    over                        \ (diff b)
    dup                         \ (diff b) <- b 
    a!                          \ b -> A
    over                        \ (b diff)
    a                           \ (b diff) <- b
    +                           \ (b old_diff)


    dup                         
    if end                      \ если old_diff = 0, то на end

    dup                         
    -if loop                    \ если old_diff >  0, то на loop
