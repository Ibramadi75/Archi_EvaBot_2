		AREA    |.text|, CODE, READONLY

SYSCTL_PERIPH_GPIO		EQU		0x400FE108

		ENTRY
		EXPORT __main
		
		;; Imports for interaction handling and time-related
		IMPORT HANDLE_BUMPERS_INTERACTIONS
		IMPORT HANDLE_SWITCHES_INTERACTIONS
		IMPORT INTERACTIONS_TO_DISTANCE
		IMPORT WAIT_ASKED_TIME_IN_CYCLE
		IMPORT DISTANCE_TO_TIME_IN_CYCLE
		IMPORT TRAVEL_TIME_IN_CYCLE

		;; Imports for initialization
		IMPORT LEDs_INIT
		IMPORT MOTEUR_INIT
		IMPORT BUMPERS_INIT
		IMPORT SWITCHES_INIT
		
		IMPORT MOTORS_ON
		IMPORT MOTORS_OFF
		IMPORT FORWARD_MOTION

		IMPORT LEDs_ON
		IMPORT LEDs_OFF
			
		IMPORT SECOND_SWITCH_ST_ADR ;; store the state of the switch one
		IMPORT FIRST_SWITCH_ST_ADR ;; store the state of the switch two
			
		IMPORT INIT_UTIL_address
__main
		ldr r6, = SYSCTL_PERIPH_GPIO
		mov r0, #0x38 ;; (0x38 == 0b111000)
		; ;; 			 (GPIO :    FEDCBA)
		str r0, [r6]
		
		nop
		nop
		nop
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^PERIPHERAL INITIALIZATIONS FOR "PHASE 1: SETUP"
		BL BUMPERS_INIT
		BL LEDs_INIT
		BL SWITCHES_INIT
		
		BL INIT_UTIL_address
		
SETUP	;; Start of the SETUP phase
		BL LEDs_ON
		
		BL HANDLE_BUMPERS_INTERACTIONS
		BL HANDLE_SWITCHES_INTERACTIONS
		
		;; Check if swith 1 is pressed
		LDR r1, =SECOND_SWITCH_ST_ADR
		LDR r1, [r1]
		CMP r1, #1
		BEQ MEASURE  ;; if switch 1 is pressed, start MEASURE step, else : stay in setup step
		
        b SETUP

MEASURE	;; Start of the measurement phase
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^PERIPHERAL INITIALIZATIONS FOR "PHASE 2: MEASUREMENT ACTION"
		BL MOTEUR_INIT
		
		;; Turn off LEDs to indicate that configuration is no longer possible
		BL LEDs_OFF

		BL INTERACTIONS_TO_DISTANCE ;; Convert user interactions into distance		
		BL DISTANCE_TO_TIME_IN_CYCLE ;; Convert requested distance into execution cycles and store it in the dedicated address (label "TRAVEL_TIME_IN_CYCLE")

		;; Move the distance
		BL MOTORS_ON		;; TURN ON MOTORS
		BL FORWARD_MOTION	;; MOVE FORWARD
		
		;; Countdown based on the value of the dedicated address (label "TRAVEL_TIME_IN_CYCLE") 
		BL WAIT_ASKED_TIME_IN_CYCLE

		;; End of the journey
		BL MOTORS_OFF	;; turn off motors

		BL LEDs_OFF	;; turn off LEDs
		b __main

END_PROG
		nop
		END
