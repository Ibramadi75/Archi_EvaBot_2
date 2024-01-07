		AREA    |.text|, CODE, READONLY
		
GPIO_PORTF_BASE		EQU		0x40025000
GPIO_O_DIR   		EQU 	0x00000400
GPIO_O_DR2R   		EQU 	0x00000500
GPIO_O_DEN   		EQU 	0x0000051C

PIN4				EQU		0x10
PIN5				EQU		0x20
PIN4_5				EQU		0x30
		
		ENTRY
		EXPORT LEDs_INIT
		EXPORT LEDs_ON
		EXPORT LEDs_OFF
		EXPORT LED_GAUCHE_ON
		EXPORT LED_GAUCHE_OFF
		EXPORT LED_DROITE_ON
		EXPORT LED_DROITE_OFF

;; init both right and left led
LEDs_INIT
		LDR r6, = GPIO_PORTF_BASE + GPIO_O_DIR
	        LDR r0, = PIN4_5 	
	        STR r0, [r6]
			
	        LDR r6, = GPIO_PORTF_BASE + GPIO_O_DEN
	        LDR r0, = PIN4_5 		
	        STR r0, [r6]
	 
		LDR r6, = GPIO_PORTF_BASE + GPIO_O_DR2R
	        LDR r0, = PIN4_5		
	        STR r0, [r6]
		
		MOV r2, #0
		
		BX LR

;; put LEDs ON
LEDs_ON
		MOV r3, #PIN4_5
		LDR r6, = GPIO_PORTF_BASE + (PIN4_5<<2)
		STR r3, [r6]
		
		BX LR

;; put LEDs OFF
LEDs_OFF
		LDR r6, = GPIO_PORTF_BASE + (PIN4_5<<2)
		MOV r2, #0
		STR r2, [r6]
		
		BX LR
		
;; put right LED ON
LED_DROITE_ON
		PUSH {LR}
		MOV r3, #PIN4
		LDR r6, = GPIO_PORTF_BASE + (PIN4<<2)
		STR r3, [r6]
		POP {LR}
		
		BX LR
		
;; put right LED OFF
LED_DROITE_OFF
		PUSH {LR}
		LDR r6, = GPIO_PORTF_BASE + (PIN4<<2)
		STR r2, [r6]
		POP {LR}
		
		BX LR
		
;; put left LED ON
LED_GAUCHE_ON
		PUSH {LR}
		MOV r3, #PIN5
		LDR r6, = GPIO_PORTF_BASE + (PIN5<<2)
		STR r3, [r6]
		POP {LR}
		
		BX LR
		
;; put left LEDs OFF
LED_GAUCHE_OFF
		PUSH {LR}
		LDR r6, = GPIO_PORTF_BASE + (PIN5<<2)
		STR r2, [r6]
		POP {LR}
		
		BX LR
		
		END
