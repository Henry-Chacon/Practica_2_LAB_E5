SYSCTL_RCGCGPIO_R    EQU 0x400FE608
GPIO_PORTB5          EQU 0x40005080
GPIO_PORTB6          EQU 0x40005100
GPIO_PORTB7          EQU 0x40005200
GPIO_PORTB_AMSEL_R   EQU 0x40005528
GPIO_PORTB_PCTL_R    EQU 0x4000552C
GPIO_PORTB_DIR_R     EQU 0x40005400
GPIO_PORTB_AFSEL_R   EQU 0x40005420
GPIO_PORTB_DEN_R     EQU 0x4000551C
CONSTANTE            EQU 6000000
DISMINUCION          EQU 500000

    AREA    codigo, CODE, READONLY,ALIGN=2
    THUMB
    EXPORT Start

Start
    ; Paso 1. Reloj en Puerto B
    LDR R1, =SYSCTL_RCGCGPIO_R
    LDR R0, [R1]
    ORR R0, R0, #0x02  ; Habilitar puerto B (0x02)
    STR R0, [R1]
    NOP 
    NOP
    ; Paso 3. Deshabilitar Funciones Analógicas en el Puerto B
    LDR R1, =GPIO_PORTB_AMSEL_R    
    LDR R0, [R1]
    BIC R0, #0xE0
    STR R0, [R1]
    ; Paso 4. Configurar como GPIO Puerto B
    LDR R1, =GPIO_PORTB_PCTL_R
    LDR R0, [R1]
    BIC R0, R0, #0xFF000000
    BIC R0, R0, #0x00FF0000
    STR R0, [R1]
    ; Paso 5. Dirección del Puerto B7 (Salida)
    LDR R1, =GPIO_PORTB_DIR_R
    LDR R0, [R1]
    ORR R0, R0, #0x80
    STR R0, [R1]
    ; Dirección Puerto B5-B6 (Entrada)
    LDR R1, =GPIO_PORTB_DIR_R
    LDR R0, [R1]
    BIC R0, R0, #0x60
    STR R0, [R1]
    ; Paso 6. Limpiar bits función alternativa puerto B
    LDR R1, =GPIO_PORTB_AFSEL_R
    LDR R0, [R1]
    BIC R0, R0, #0xE0
    STR R0, [R1]
    ; Paso 7. Habilitar como puerto digital puerto B
    LDR R1, =GPIO_PORTB_DEN_R
    LDR R0, [R1]
    ORR R0, R0, #0xE0
    STR R0, [R1]
    
    LDR R3, =CONSTANTE
    LDR R10, =DISMINUCION
    B Loop
    
Delay
    ADD R2, #1
    NOP
    NOP

    NOP
    CMP R2, R3
    BNE Delay
    BX LR

led; luz por defecto
    LDR R5, =GPIO_PORTB7
    LDR R4, [R5]
    EOR R4, R4, #0x80
    STR R4, [R5]
    LDR R2, =0
    LDR R3, =CONSTANTE
    B Loop

Menos; ira disminuyendo el tiempo
    LDR R5, =GPIO_PORTB7
    LDR R4, [R5]
    EOR R4, R4, #0x80
    STR R4, [R5]
    LDR R2, =0
    SUB R3, R10
    B Loop

Mas; incrementará el tiempo
    LDR R5, =GPIO_PORTB7
    LDR R4, [R5]
    EOR R4, R4, #0x80
    STR R4, [R5]
    LDR R2, =0
    ADD R3, R10
    B Loop

Push1; Botón de Menos
    LDR R1, =GPIO_PORTB5
    LDR R0, [R1] ;
    BX LR

Push2; Botón de Mas
    LDR R1, =GPIO_PORTB6
    LDR R0, [R1] ;
    BX LR

Loop
    BL Push1
    LDR R2, =0
    BL Delay
    CMP R0, #0x20
    BEQ Menos
    BL Push2
    LDR R2, =0
    BL Delay
    CMP R0, #0x40
    BEQ Mas
    CMP R0, #0x00    
    BEQ led
    CMP R0, #0x00    
    B Loop

    ALIGN
    END
