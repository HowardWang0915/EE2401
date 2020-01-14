//
// Smpl_ADC_VR1 : use ADC7 to read Variable Resistor (on-board)
//
#include <stdio.h>																											 
#include "NUC1xx.h"
#include "SYS.h"
#include "LCD.h"
#include "PWM.h"
#include "GPIO.h"
#include "ADC.h"
#include "math.h"

void InitADC(void)
{
	/* Step 1. GPIO initial */ 
	GPIOA->OFFD|=0x00800000; 	//Disable digital input path
	SYS->GPAMFP.ADC7_SS21_AD6=1; 		//Set ADC function 
				
	/* Step 2. Enable and Select ADC clock source, and then enable ADC module */          
	SYSCLK->CLKSEL1.ADC_S = 2;	//Select 22Mhz for ADC
	SYSCLK->CLKDIV.ADC_N = 1;	//ADC clock source = 22Mhz/2 =11Mhz;
	SYSCLK->APBCLK.ADC_EN = 1;	//Enable clock source
	ADC->ADCR.ADEN = 1;			//Enable ADC module

	/* Step 3. Select Operation mode */
	ADC->ADCR.DIFFEN = 0;     	//single end input
	ADC->ADCR.ADMD   = 0;     	//single mode
		
	/* Step 4. Select ADC channel */
	ADC->ADCHER.CHEN = 0x80;
	DrvADC_ConfigADCChannel7(0);
	/* Step 5. Enable ADC interrupt */
	ADC->ADSR.ADF =1;     		//clear the A/D interrupt flags for safe 
	ADC->ADCR.ADIE = 1;
//	NVIC_EnableIRQ(ADC_IRQn);
	
	/* Step 6. Enable WDT module */
	ADC->ADCR.ADST=1;
}

int32_t main (void)
{
	uint32_t Clock;	
  	uint32_t Frequency;
  	uint8_t  PreScaler;
  	uint8_t  ClockDivider;
  	uint8_t  DutyCycle;
	uint16_t CNR, CMR;
	char TEXT1[16]="ADC Value:      ";	
	char TEXT2[15] = "DC Value:      ";

	Clock = 12000000;
	PreScaler = 119;
	ClockDivider = 1;
	DutyCycle = 0;
	Frequency = 500;
	UNLOCKREG();
	SYSCLK->PWRCON.XTL12M_EN = 1; // enable external clock (12MHz)
	SYSCLK->CLKSEL0.HCLK_S = 0;	  // select external clock (12MHz)
	LOCKREG();

	InitADC();		    // initialize ADC
	init_PWM(0, 0, 119, 4);
	init_PWM(1, 0, 119, 4);
	init_PWM(2, 0, 119, 4);
	init_LCD();  // initialize LCD pannel
	clear_LCD();  // clear LCD panel 
	print_Line(0, "Smpl_ADC_VR1");
							 					 
	while(1)
	{
		while(ADC->ADSR.ADF==0); // wait till conversion flag = 1, conversion is done
		ADC->ADSR.ADF=1;		     // write 1 to clear the flag
		//PWM_FreqOut = PWM_Clock / (PWM_PreScaler + 1) / PWM_ClockDivider / (PWM_CNR + 1)
		DutyCycle = ADC->ADDR[7].RSLT * 100 / 4095;
		sprintf(TEXT2+9, "%4d", DutyCycle);
		print_Line(2, TEXT2);
		CNR = Clock / Frequency / (PreScaler + 1) / ClockDivider - 1;
    // Duty Cycle = (CMR0+1) / (CNR0+1)
    CMR = (CNR + 1) * (10*sqrt((100 - DutyCycle)))/ 100  - 1;	
		PWM_Out(0, CNR, CMR);
		CMR = (CNR + 1) * (10*sqrt((DutyCycle / 2 + 50)))/ 100  - 1;	
		PWM_Out(1, CNR, CMR);
		CMR = (CNR + 1) * (10*sqrt(((100 - DutyCycle) / 2))) / 100  - 1;	
		PWM_Out(2, CNR, CMR);
		sprintf(TEXT1+10,"%4d",ADC->ADDR[7].RSLT); // convert ADC7 value into text
		print_Line(1, TEXT1);	   // output TEXT to LCD
		DrvSYS_Delay(20000);	   // delay
		ADC->ADCR.ADST=1;		     // restart ADC sample
	}
}

