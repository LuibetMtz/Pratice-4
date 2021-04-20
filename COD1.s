.data
clock: .long 0x1600
vPCR_B18_19: .long 0x100
vPDDRBo: .long 0xC0000
vPDDRAi: .long 0x0
vPCR_GPIO: .long 0x100
vPDDRDo: .long 0x3
Ron1: .long 0x80000
Ron2: .long 0x2
Gon1: .long 0x40000
Gon2: .long 0x2
Bon1: .long 0xC0000
Bon2: .long 0x0
Eon1: .long 0xC0000
Eon2: .long 0x3
Ton1: .long 0x0
Ton2: .long 0x1
Toff1: .long 0xC0000
Toff2: .long 0x2
RGon1: .long 0x0
RGon2: .long 0x2
RGBon1: .long 0x0
RGBon2: .long 0x0
GBEon1: .long 0x40000
GBEon2: .long 0x1
BEon1: .long 0xC0000
BEon2: .long 0x1
Button: .long 0x2000
vDelay: .long 0x3D0900//4M

.text
.global COD1
.type COD1 function

COD1:
	LDR R5, =0x40048038		// Direccion del Clock
	LDR R0, =clock			// Valor necesario para prender el clock del puerto A, B, D
	LDR R0, [R0]
	STR R0,[R5] 		// Configurar clock para A, B y D

	LDR R0, =0x40049034	//Usar A13 como pin para el boton
	LDR R1, =vPCR_GPIO //
	LDR R1, [R1]
	STR R1, [R0]		//Configurar A13 como GPIO
	LDR R0, =0x400FF014		//direccion PDDR puerto A
	LDR R1, =vPDDRAi		//0
	LDR R1, [R1]
	STR R1, [R0]		//Configurar A13 como input



	LDR R0, =0x4004A048	//PCR B18 ROJO
	LDR R5, =vPCR_B18_19
	LDR R5, [R5]
	STR R5, [R0] 		//Configurar B18 como GPIO
	LDR R1, =0x4004A04C	// PCR B19 VERDE
	STR R5, [R1] 		//Configurar B19 como GPIO
	LDR R2, =0x400FF054	// PDDR B
	LDR R0, =vPDDRBo
	LDR R0, [R0]
	STR R0, [R2] 		//Configurar B18 y B19 (Red,Green) como outputs



	LDR R3, =0x4004C004		//PCR D1 AZUL
	LDR R0, =vPCR_GPIO
	LDR R0, [R0]
	STR R0, [R3]			//Configurar D1 como GPIO

	LDR R4, =0x4004C000		//PCR D0 EXTRA
	STR R0, [R4]			//Configurar D0 como GPIO

	LDR R6, =0x400FF0D4 	// PDDR D
	LDR R0, =vPDDRDo
	LDR R0, [R0]
	STR R0, [R6]			//Configurar D0 y D1 como outputs

	LDR R5, =0x400FF010		//Direccionar  PDIR  Puerto A  A13
	LDR R6, =0x400FF040		// Direccionar PDOR B18 Rojo, Verde b19
	LDR R7, =0x400FF0C0		// Direccionar PDOR D1 Azul y Extra D0


	LDR R5, [R5]
	LDR R0, =Toff1
	LDR R0, [R0]
	STR R0, [R6]		//apagar leds rojo y verde
	LDR R0, =Toff2
	LDR R0, [R0]
	STR R0, [R7]		// apagar led azul

	LDR R1, =Button //mascara para tener 1 en la posicion A13 00010000000000000
	LDR R1, [R1]


	B ONEHOT_S0



ONEHOT_S0:
	LDR R0, =Ron1			//Cargar en R0 la direccion Ron1(rojo 0, verde 1)
	LDR R0, [R0]			//Cargar en R0 el valor de la direccion
	STR R0, [R6]			// almacenar el valor de R1 en puerto B (R6)
	LDR R0, =Ron2			//Cargar en R0 la direccion Ron2 (Azul 1 extra 0)
	LDR R0, [R0]			//cargar el valor de la direccion de R0 en R0
	STR R0, [R7]			//almacena el valor de r0 en puerto D (7)

	LDR R0, =vDelay			//carga la direccion del numero que determinara el delay
	LDR R0, [R0]			//carga el valor de R0 en R0
	B DelayOH0

DelayOH0:
	CMP R0, #0				//comparar delay con 0
	BNE RESTAROH0			//ir al restador
	LDR R5, =0x400FF010		//carga en r5 la direccion del puerto A
	LDR R5, [R5]			//carga eb R5 el valor que hay en la direccion A
	AND R5, R5, R1			//And nivel bit a bit para ver si hay un 1 en la posicion A13
	CMP R5, R1				//Comparacion
	BEQ JOHNSON_S0			//Si se cumple, boton presionado
	B ONEHOT_S1				//boton NO presionado, saltar a siguiente estado

RESTAROH0:
	SUB R0, R0, #1			//restar 1 al gran numero
	B DelayOH0				// regreso a la coomparacion

ONEHOT_S1:
	LDR R0, =Gon1		//apagar Rojo encender Verde
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Gon2		// apagar azul y Extra
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayOH1

DelayOH1:
	CMP R0, #0
	BNE RESTAROH1
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ JOHNSON_S0
	B ONEHOT_S2

RESTAROH1:
	SUB R0, R0, #1
	B DelayOH1

ONEHOT_S2:
	LDR R0, =Bon1		//apagar verde y rojo
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Bon2		//encender  Azul Apagar extra
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayOH2

DelayOH2:
	CMP R0, #0
	BNE RESTAROH2
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ JOHNSON_S0
	B ONEHOT_S3

RESTAROH2:
	SUB R0, R0, #1
	B DelayOH2

ONEHOT_S3:
	LDR R0, =Eon1			// Apagar rojo y verde
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Eon2			//apagar Azul Encender Extra
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayOH3

DelayOH3:
	CMP R0, #0
	BNE RESTAROH3
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ JOHNSON_S0
	B ONEHOT_S0

RESTAROH3:
	SUB R0, R0, #1
	B DelayOH3

JOHNSON_S0:
	LDR R0, =Toff1			//apagar rojo apagar verde
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Toff2			//apagar extra apagar azul
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayJ0

DelayJ0:
	CMP R0, #0
	BNE RESTARJ0
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ BOUNCE_S01
	B JOHNSON_S1

RESTARJ0:
	SUB R0, R0, #1
	B DelayJ0

JOHNSON_S1:
	LDR R0, =Ron1		//encender Rojo apagar Verde
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Ron2		// apagar extra apagar azul
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayJ1

DelayJ1:
	CMP R0, #0
	BNE RESTARJ1
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ BOUNCE_S0
	B JOHNSON_S2

RESTARJ1:
	SUB R0, R0, #1
	B DelayJ1

JOHNSON_S2:
	LDR R0, =RGon1			//rojo y verde encendido
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =RGon2			//azul y extra apagado
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayJ2

DelayJ2:
	CMP R0, #0
	BNE RESTARJ2
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ BOUNCE_S0
	B JOHNSON_S3

RESTARJ2:
	SUB R0, R0, #1
	B DelayJ2

JOHNSON_S3:
	LDR R0, =RGBon1			//rojo y verde encendido
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =RGBon2			//azul encendido extra apagado
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayJ3

DelayJ3:
	CMP R0, #0
	BNE RESTARJ3
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ BOUNCE_S0
	B JOHNSON_S4

RESTARJ3:
	SUB R0, R0, #1
	B DelayJ3

JOHNSON_S4:
	LDR R0, =Ton1			//encender rojo y vede
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Ton2			//encender azul y extra
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayJ4

DelayJ4:
	CMP R0, #0
	BNE RESTARJ4
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ BOUNCE_S0
	B JOHNSON_S5

RESTARJ4:
	SUB R0, R0, #1
	B DelayJ4


BOUNCE_S01:
	B BOUNCE_S0
JOHNSON_S01:
	B JOHNSON_S0

JOHNSON_S5:
	LDR R0, =GBEon1		//apagar rojo verde encendido
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =GBEon2		//azul y extra encendido
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayJ5

DelayJ5:
	CMP R0, #0
	BNE RESTARJ5
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ BOUNCE_S0
	B JOHNSON_S6

RESTARJ5:
	SUB R0, R0, #1
	B DelayJ5

JOHNSON_S6:
	LDR R0, =BEon1			//apagar rojo y verde
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =BEon2			// azul y extra encendido
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayJ6

DelayJ6:
	CMP R0, #0
	BNE RESTARJ6
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ BOUNCE_S0
	B JOHNSON_S7

RESTARJ6:
	SUB R0, R0, #1
	B DelayJ6



JOHNSON_S7:
	LDR R0, =Eon1			// rojo y verde apagado
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Eon2			//extra encendido azul apagado
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayJ7

DelayJ7:
	CMP R0, #0
	BNE RESTARJ7
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ BOUNCE_S0
	B JOHNSON_S01

RESTARJ7:
	SUB R0, R0, #1
	B DelayJ7

ONEHOT_S01: //retorno  a one hot S0
	B ONEHOT_S0

BOUNCE_S0:
	LDR R0, =Eon1		//rojo y verde apagados
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Eon2		// extra encendido azul apagado
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayB0

DelayB0:
	CMP R0, #0
	BNE RESTARB0
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ ONEHOT_S01
	B BOUNCE_S1

RESTARB0:
	SUB R0, R0, #1
	B DelayB0

BOUNCE_S1:
	LDR R0, =Bon1			//rojo y verde apagado
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Bon2			//extra apagado azul encendido
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayB1

DelayB1:
	CMP R0, #0
	BNE RESTARB1
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ ONEHOT_S01
	B BOUNCE_S2

RESTARB1:
	SUB R0, R0, #1
	B DelayB1
BOUNCE_S012:
	B BOUNCE_S01
ONEHOT_S012:
	B ONEHOT_S01//retornando de Bounce s6
BOUNCE_S2:
	LDR R0, =Gon1		//rojo apagado verde encendido
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Gon2		//extra y azul apagado
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayB2

DelayB2:
	CMP R0, #0
	BNE RESTARB2
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ ONEHOT_S01
	B BOUNCE_S3

RESTARB2:
	SUB R0, R0, #1
	B DelayB2

BOUNCE_S3:
	LDR R0, =Ron1			// rojo encendido verde apagado
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Ron2			// extra y azul apagado
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayB3

DelayB3:
	CMP R0, #0
	BNE RESTARB3
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ ONEHOT_S01
	B BOUNCE_S4

RESTARB3:
	SUB R0, R0, #1
	B DelayB3

BOUNCE_S4:
	LDR R0, =Gon1			//verde encendido rojo apagado
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Gon2			// extra y azul apagado
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayB4

DelayB4:
	CMP R0, #0
	BNE RESTARB4
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ ONEHOT_S01
	B BOUNCE_S5

RESTARB4:
	SUB R0, R0, #1
	B DelayB4

BOUNCE_S5:
	LDR R0, =Bon1				//rojo y verde apagado
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Bon2				// azul encendido extra apagado
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayB5

DelayB5:
	CMP R0, #0
	BNE RESTARB5
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ ONEHOT_S01
	B BOUNCE_S6

RESTARB5:
	SUB R0, R0, #1
	B DelayB5

BOUNCE_S6:
	LDR R0, =Eon1				// rojo y verde apagado
	LDR R0, [R0]
	STR R0, [R6]
	LDR R0, =Eon2				//azul apagado extra encendido
	LDR R0, [R0]
	STR R0, [R7]


	LDR R0, =vDelay
	LDR R0, [R0]
	B DelayB6

DelayB6:
	CMP R0, #0
	BNE RESTARB6
	LDR R5, =0x400FF010
	LDR R5, [R5]
	AND R5, R5, R1
	CMP R5, R1
	BEQ ONEHOT_S012  //Branch no alcazna a regresar al inicio el archico, mini branches creados para poder regresar
	B BOUNCE_S012

RESTARB6:
	SUB R0, R0, #1
	B DelayB6

