    lxi b, lc0
    lxi d, lc1

start
    mvi a, 0

add_1
    adi 1
    out 3
    jc inc_lc0
    jmp add_1

inc_lc0
    ldax b
    adi 1
    stax b
    jc inc_lc1
    jmp start

inc_lc1
    ldax d
    adi 1
    stax d
    out 2
    jmp start

lc0
    db 0
lc1
    db 0