		AREA    |.text|, CODE, READONLY
			
GPIO_PORTE_BASE		EQU		0x40024000
GPIO_O_DIR  		EQU 	0x00000400
GPIO_O_DR2R   		EQU 	0x00000500
GPIO_O_DEN   		EQU 	0x0000051C
GPIO_I_PUR   		EQU 	0x00000510

BROCHE0				EQU		0x01
BROCHE1				EQU		0x02
BROCHE0_1			EQU		0x03
	
BUMPERS_DATA_BASE      EQU     0x20000000
BUMPER_SW_OFFSET       EQU     0x00 ;; Is on/off option
BUMPER_CT_OFFSET       EQU     0x05 ;; Counter option
NEXT_BUMPER_OFFSET     EQU     0x10 ;; right, left

LEFT_BUMPER_BASE       EQU     BUMPERS_DATA_BASE 
LEFT_BUMPER_ST_ADR     EQU     LEFT_BUMPER_BASE + BUMPER_SW_OFFSET
LEFT_BUMPER_CT_ADR     EQU     LEFT_BUMPER_BASE + BUMPER_CT_OFFSET

RIGHT_BUMPER_BASE      EQU     BUMPERS_DATA_BASE + NEXT_BUMPER_OFFSET 
RIGHT_BUMPER_ST_ADR    EQU     RIGHT_BUMPER_BASE + BUMPER_SW_OFFSET
RIGHT_BUMPER_CT_ADR    EQU     RIGHT_BUMPER_BASE + BUMPER_CT_OFFSET

		ENTRY
		EXPORT BUMPER_DROIT_READSTATE
		EXPORT BUMPER_GAUCHE_READSTATE
			
		EXPORT LEFT_BUMPER_ST_ADR
		EXPORT RIGHT_BUMPER_ST_ADR

		EXPORT LEFT_BUMPER_CT_ADR
		EXPORT RIGHT_BUMPER_CT_ADR
			
		EXPORT INCR_RIGHT_BUMPER_COUNTER
		EXPORT INCR_LEFT_BUMPER_COUNTER
			
		EXPORT HANDLE_BUMPERS_INTERACTIONS
			
		EXPORT BUMPERS_INIT
			
		EXPORT INIT_BUMPERS_ADRESS
			
		IMPORT LED_GAUCHE_ON
		IMPORT LED_GAUCHE_OFF
		IMPORT LED_DROITE_ON
		IMPORT LED_DROITE_OFF
		
		IMPORT WAIT_R5_SECONDS
		IMPORT DISTANCE_TO_TIME_IN_CYCLE
		IMPORT WAIT_ASKED_TIME_IN_CYCLE
			
		IMPORT INCR_VAL_STORED_IN_R1_ADR

;; Put to 0 values of bumper's dedicated adress
INIT_BUMPERS_ADRESS
		MOV r0, #0
		; Charger l'adresse de LEFT_BUMPER_ST_ADR et stocker 0
		LDR r1, =LEFT_BUMPER_ST_ADR
		STR r0, [r1]

		; Charger l'adresse de RIGHT_BUMPER_ST_ADR et stocker 0
		LDR r1, =RIGHT_BUMPER_ST_ADR
		STR r0, [r1]

		; Charger l'adresse de LEFT_BUMPER_CT_ADR et stocker 0
		LDR r1, =LEFT_BUMPER_CT_ADR
		STR r0, [r1]

		; Charger l'adresse de RIGHT_BUMPER_CT_ADR et stocker 0
		LDR r1, =RIGHT_BUMPER_CT_ADR
		STR r0, [r1]
		
		BX LR

;; Init bumpers and their adress
BUMPERS_INIT
		LDR r7, = GPIO_PORTE_BASE + GPIO_I_PUR
		
		; Initialize BROCHE0_1 (BROCHE0 and BROCHE1)
		LDR r0, = BROCHE0_1
        STR r0, [r7]
		
		LDR r7, = GPIO_PORTE_BASE + GPIO_O_DEN
		
		; Enable BROCHE0_1 (BROCHE0 and BROCHE1)
		LDR r0, = BROCHE0_1
        STR r0, [r7]  

		PUSH {LR}
		BL INIT_BUMPERS_ADRESS
		POP {LR}
		
		BX LR
		
;; check bumpers states and store 
HANDLE_BUMPERS_INTERACTIONS
		PUSH {LR}
		BL BUMPER_DROIT_READSTATE
		
		LDR r1, =RIGHT_BUMPER_ST_ADR    ; Load RIGHT_BUMPER_ST_ADR in r1
		LDR r2, [r1]    
		
		CMP r2, #1
		BNE CHECK_NEXT_BUMPER
		
		;; put led of to indicate user can't configure
		BL LED_DROITE_OFF;

  		;; increment right bumper counter
		BL INCR_RIGHT_BUMPER_COUNTER
			
		;; security delay to prevent spam
		MOV r5, #1
		BL WAIT_R5_SECONDS
		
		;; put led on to indicate user can now continue to configure
		BL LED_DROITE_ON;
		
CHECK_NEXT_BUMPER
		BL BUMPER_GAUCHE_READSTATE
		
		LDR r1, =LEFT_BUMPER_ST_ADR    ; Load LEFT_BUMPER_ST_ADR in r1
		LDR r2, [r1] 
		
		CMP r2, #1
		BNE LEFT_BUMPER_NOT_PRESSED
		
		;; put led of to indicate user can't configure
 		BL LED_GAUCHE_OFF;

  		;; increment left bumper counter
		BL INCR_LEFT_BUMPER_COUNTER

		;; security delay to prevent spam
		MOV r5, #1
		BL WAIT_R5_SECONDS
		
		BL LED_GAUCHE_ON;
		
LEFT_BUMPER_NOT_PRESSED
		POP {LR}
		
		BX LR

;; Lis l'état du bumper de gauche
BUMPER_GAUCHE_READSTATE
		LDR r2, =LEFT_BUMPER_ST_ADR ;; load adress dedicated to left bumper's state
		LDR r1, =GPIO_PORTE_BASE + (BROCHE1<<2)
		
		PUSH {LR}
		BL DEFINE_STATE
		POP {LR}
		
		BX LR

;; Lis l'état du bumper de droite
BUMPER_DROIT_READSTATE
		LDR r2, =RIGHT_BUMPER_ST_ADR ;; load adress dedicated to right bumper's state
		LDR r1, =GPIO_PORTE_BASE + (BROCHE0<<2)

DEFINE_STATE
		MOV r3, #0
		LDR r1, [r1]
		CMP r1, #0
		
		BNE leave1
		MOV r3, #1
leave1
		STR r3, [r2]
		
		BX LR

;; Increment of 1 the right bumper counter value stored in RIGHT_BUMPER_CT_ADR
INCR_RIGHT_BUMPER_COUNTER
		LDR r1, =RIGHT_BUMPER_CT_ADR
		
		PUSH{LR}
		BL INCR_VAL_STORED_IN_R1_ADR
		POP{LR}
		
		BX LR

;; Increment of 1 the left bumper counter value stored in RIGHT_BUMPER_CT_ADR
INCR_LEFT_BUMPER_COUNTER
		LDR r1, =LEFT_BUMPER_CT_ADR
		PUSH{LR}
		BL INCR_VAL_STORED_IN_R1_ADR
		POP{LR}
		
		BX LR
		
		END
