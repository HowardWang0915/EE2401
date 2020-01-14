 //
// Smpl_PWM_Music : use PWM to generate musical notes
//
// Output : PWM0 (GPA12)

#include <stdio.h>
#include <math.h>

#include "NUC1xx.h"
#include "GPIO.h"
#include "SYS.h"
#include "PWM.h"
#include "LCD.h"
#include "Note_Freq.h"
#include "Seven_Segment.h"
#include "Scankey.h"

int32_t main (void)
{
	int delay_cnt;				// for delay count
  	int i;
		int j;
  	uint32_t Clock;	
  	uint32_t Frequency;
  	uint8_t  PreScaler;
  	uint8_t  ClockDivider;
  	uint8_t  DutyCycle;
	uint16_t number;			// for scankey
  	uint16_t CNR, CMR;
  
	uint16_t NTHU_DELAY[77] = {
		3, 1, 4, 2, 1, 1, 4,
		4, 1, 1, 2, 2, 1, 1, 2, 2,
		5, 1, 2, 2, 2, 1, 1, 2,
		2, 3, 1, 2, 4, 1, 1, 2,
		4, 2, 2, 3, 1, 4,
		4, 2, 2, 3, 1, 4,
		6, 2, 2, 1, 1, 4, 
		4, 2, 2, 3, 1, 4, 
		6, 2, 6, 2, 
		4, 2, 2, 2, 2, 4,
		6, 2, 6, 2, 
		4, 2, 2, 2, 1, 1, 4
	};
  	uint16_t NTHU_ANTH[77] = {
		D5u, G5, A5u, C6, D6u, C6, A5u,
		G5, A5u, G5, D5u, C5, D5u, F5, A5u, 0,
		C6, D6u, A5u, G5, F5, G5, F5, D5u,
		F5, A5u, G5u, A5u, C6, D6, C6, A5u,
		D6u, C6, D6u, A5u, C6, A5u,
		C6, A5u, G5, F5, G5, A5u, 
		D5u, G5, F5, G5, F5, D5u,
		C6, A5u, G5, F5, G5, D5u,
		D6u, 0, C6, 0, 
		A5u, C6, A5u, F5, G5, A5u,
		D6u, 0, C7, 0,
		A5u, C6, A5u, F5, G5, F5, D5u
	};
	uint16_t sineA[100] ={
		53, 56, 59, 62, 65,
		68, 71, 74, 77, 79, 
		82, 84, 86, 89, 90,
		92, 94, 95, 96, 98, 
		98, 99, 100, 100, 100,
		100, 100, 99, 98, 98, 
		96, 95, 94, 92, 90, 
		89, 86, 84, 82, 79, 
		77, 74, 71, 68, 65, 
		62, 59, 56, 53, 50, 
		47, 44, 41, 38, 35, 
		32, 29, 26, 23, 21,
		18, 16, 14, 12, 10, 
		8, 6, 5, 4, 2, 
		2, 1, 0, 0, 0, 
		0, 0, 1, 2, 2, 
		4, 5, 6, 8, 10, 
		12, 14, 16, 18, 21, 
		23, 26, 29, 32, 35, 
		38, 41, 44, 47, 50
	};

	//Enable 12Mhz and set HCLK->12Mhz

	UNLOCKREG();
	SYSCLK->PWRCON.XTL12M_EN = 1;
	SYSCLK->CLKSEL0.HCLK_S = 0;
	LOCKREG();

	init_LCD();	
	clear_LCD();   	
	OpenKeyPad();
	
// PWM_No = PWM channel number
// PWM_CLKSRC_SEL   = 0: 12M, 1:32K, 2:HCLK, 3:22M
// PWM_PreScaler    : PWM clock is divided by (PreScaler + 1)
// PWM_ClockDivider = 0: 1/2, 1: 1/4, 2: 1/8, 3: 1/16, 4: 1
	init_PWM(0, 0, 119, 4);
	init_PWM(1, 0, 119, 4);
	init_PWM(2, 0, 119, 4);
	init_PWM(3, 0, 119, 4); // initialize PWM0(GPA12) to output 1MHz square wave
	Clock = 12000000;
	PreScaler = 119;
	ClockDivider = 1;
	DutyCycle = 50;

	while(1)
	{
		number = ScanKey();
		if (number == 1) {
			clear_LCD();
			DutyCycle = 50;
			PWM_Stop(0);
			PWM_Stop(1);
			PWM_Stop(2);
			show_seven_segment(0, number);			// show ssd
			print_Line(0, "Now playing the");
			print_Line(1, "NTHU University");
			print_Line(2, "anthem");
			print_Line(3, "107061112 Howard");
	  		for (i = 0; i < 77 && ScanKey() == 0; i++) {
				Frequency = NTHU_ANTH[i];
				//PWM_FreqOut = PWM_Clock / (PWM_PreScaler + 1) / PWM_ClockDivider / (PWM_CNR + 1)
				CNR = Clock / Frequency / (PreScaler + 1) / ClockDivider - 1;
    			// Duty Cycle = (CMR0+1) / (CNR0+1)
     			CMR = (CNR + 1) * DutyCycle /100  - 1;			
			
	   			PWM_Out(3, CNR, CMR);
				if (Frequency == 0) 
					PWM_Stop(3);

	    		for (delay_cnt = 250 * NTHU_DELAY[i]; (delay_cnt >= 0) && ScanKey() == 0; delay_cnt--) {	// for delaying
					DrvSYS_Delay(1);
				}				
	  		}
		}

		else if (number == 2) {
			clear_LCD();
			PWM_Stop(0);
			PWM_Stop(1);
			PWM_Stop(2);
			show_seven_segment(0, number);			// show ssd
			print_Line(0, "Now playing");
			print_Line(1, "My choice of");
			print_Line(2, "the single tone");
			print_Line(3, "107061112 Howard");
			Frequency = 250;
			CNR = Clock / Frequency / (PreScaler + 1) / ClockDivider - 1;
			for (j = 0; j < 15 && ScanKey() == 0; j++) {
				for (i = 0; i < 100 && ScanKey() == 0; i++) {
					PWM_Out(3, CNR, sineA[i]);
					for (delay_cnt = 10; (delay_cnt >= 0) && ScanKey() == 0; delay_cnt--) {	// for delaying
						DrvSYS_Delay(1);
					}
				}
			}
		}
		else {
			clear_LCD();
			close_seven_segment();
			show_seven_segment(0, 0);			// show ssd
			print_Line(0, "Prepare to play");
			print_Line(1, "music");
			PWM_Stop(3);
			for (DutyCycle = 100; DutyCycle > 60; DutyCycle--) {
				//PWM_FreqOut = PWM_Clock / (PWM_PreScaler + 1) / PWM_ClockDivider / (PWM_CNR + 1)
				CNR = Clock / Frequency / (PreScaler + 1) / ClockDivider - 1;
    			// Duty Cycle = (CMR0+1) / (CNR0+1)
     			CMR = (CNR + 1) * DutyCycle /100  - 1;	
				PWM_Out(0, CNR, CMR);
				CMR = (CNR + 1) * (DutyCycle - 30)/100  - 1;	
				PWM_Out(1, CNR, CMR);
				CMR = (CNR + 1) * (DutyCycle - 60)/100  - 1;	
				PWM_Out(2, CNR, CMR);
				for (delay_cnt = 40; (delay_cnt >= 0) && ScanKey() == 0; delay_cnt--) {	// for delaying
					DrvSYS_Delay(1);
				}		
			}
			for (DutyCycle = 100; DutyCycle > 60; DutyCycle--) {
				//PWM_FreqOut = PWM_Clock / (PWM_PreScaler + 1) / PWM_ClockDivider / (PWM_CNR + 1)
				CNR = Clock / Frequency / (PreScaler + 1) / ClockDivider - 1;
    		// Duty Cycle = (CMR0+1) / (CNR0+1)
     		CMR = (CNR + 1) * DutyCycle /100  - 1;	
				PWM_Out(2, CNR, CMR);
				CMR = (CNR + 1) * (DutyCycle - 30)/100  - 1;	
				PWM_Out(1, CNR, CMR);
				CMR = (CNR + 1) * (DutyCycle - 60)/100  - 1;	
				PWM_Out(0, CNR, CMR);
				for (delay_cnt = 40; (delay_cnt >= 0) && ScanKey() == 0; delay_cnt--) {	// for delaying
					DrvSYS_Delay(1);
				}		
			}
		}
	}
}

