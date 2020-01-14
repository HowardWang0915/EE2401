//
// Smpl_GPIO_Keypad : scan keypad 3x3 (1~9) to control GPB0~8
//
// 4-port Relay
// VCC : to 3.3V
// IN1 : to GPB0 (press 1 will output 3.3V, else output 0V)
// IN2 : to GPB1 (press 2 will output 3.3V, else output 0V)
// IN3 : to GPB2 (press 3 will output 3.3V, else output 0V)
// IN4 : to GPB3 (press 4 will output 3.3V, else output 0V)
// GND : to GND

#include "stdio.h"																											 
#include "NUC1xx.h"
#include "GPIO.h"
#include "SYS.h"
#include "Seven_Segment.h"
#include "Scankey.h"
#include "LCD.h"

void Init_LED();					// Initialize the LED
void Buzz(int number);				// buzz fuction 
/*----------------------------------------------------------------------------
  MAIN function
  ----------------------------------------------------------------------------*/
int32_t main (void)
{
	int delay_cnt;							// counting for delay time
	int16_t i = 12;							// counting LED
	int8_t number, key_pressed = 0;			// for getting the data from keypad
	char TEXT[14];							// LCD displaying

	UNLOCKREG();
	DrvSYS_Open(50000000);			// set System Clock to run at 48MHz, 12MHz crystal input, PLL output 48MHz
	SYSCLK->PWRCON.XTL12M_EN = 1; 	//Enable 12Mhz and set HCLK->12Mhz
	SYSCLK->CLKSEL0.HCLK_S = 0;
	LOCKREG();

	Init_LED();
	init_LCD();
	clear_LCD();
	OpenKeyPad();
	DrvGPIO_Open(E_GPB, 11, E_IO_OUTPUT); // initial GPIO pin GPB11 for controlling Buzzer

	while(1) {
		number = ScanKey();
		// keep cheching if input changed
		if (number != 0) {
			i = 12;							// refresh LED count
			DrvGPIO_SetBit(E_GPC, 12);		// output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 13); 		// GPC13 pin output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 14); 		// GPC14 pin output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 15); 		// GPC15 pin output Hi to turn off LED	
			close_seven_segment();			// turn off ssd
			clear_LCD();					// clear LCD
			key_pressed = number;			// refresh number
		}
		// check what is the key_pressed
		if(key_pressed == 1) {			
			DrvGPIO_ClrBit(E_GPC, 12); 	// output Low to turn on LED
			show_seven_segment(0, key_pressed);			// show ssd
			sprintf(TEXT, "Key%d pressed", key_pressed);	
			print_Line(0, TEXT);			// print LCD
			Buzz(1);
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}							// Buzz, then delay for next buzz
		}
		else if(key_pressed == 2) {
			DrvGPIO_ClrBit(E_GPC, 13);
			show_seven_segment(0, key_pressed);
			sprintf(TEXT, "Key%d pressed", key_pressed);
			print_Line(0, TEXT);
			Buzz(2);
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}							// Buzz, then delay for next buzz
		}
		else if(key_pressed == 3) {
			DrvGPIO_ClrBit(E_GPC, 14);
			show_seven_segment(0, key_pressed);
			sprintf(TEXT, "Key%d pressed", key_pressed);
			print_Line(0, TEXT);
			Buzz(3);
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}							// Buzz, then delay for next buzz
		}
		else if(key_pressed == 4) {
			DrvGPIO_ClrBit(E_GPC, 15);
			show_seven_segment(0, key_pressed);
			sprintf(TEXT, "Key%d pressed", key_pressed);
			print_Line(0, TEXT);
			Buzz(4);
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}							// Buzz, then delay for next buzz
		}
		else if(key_pressed == 5) {
			show_seven_segment(0, key_pressed);
			sprintf(TEXT, "Key%d pressed", key_pressed);
			print_Line(0, TEXT);
			DrvGPIO_ClrBit(E_GPC, i); 		// output Low to turn on LED
			for (delay_cnt = 400; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			Buzz(5);
			for (delay_cnt = 200; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}							// Buzz, then delay for next buzz
			DrvGPIO_SetBit(E_GPC, i);
			(i == 15) ? (i = 12) : (i++);		// light up in one at all time
		}
		else if(key_pressed == 6) {
			show_seven_segment(0, key_pressed);
			sprintf(TEXT, "Key%d pressed", key_pressed);
			print_Line(0, TEXT);
			print_Line(1, "107061112");
			DrvGPIO_ClrBit(E_GPC, 12); // output Low to turn on LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			DrvGPIO_SetBit(E_GPC, 12);
			DrvGPIO_ClrBit(E_GPC, 13); // output Low to turn on LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			DrvGPIO_SetBit(E_GPC, 13);
			DrvGPIO_ClrBit(E_GPC, 14); // output Low to turn on LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			DrvGPIO_SetBit(E_GPC, 14);
			DrvGPIO_ClrBit(E_GPC, 15); // output Low to turn on LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			// all lightened up, now turn off
			DrvGPIO_SetBit(E_GPC, 12);		// output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 13); 		// GPC13 pin output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 14); 		// GPC14 pin output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 15); 		// GPC15 pin output Hi to turn off LED
			DrvGPIO_ClrBit(E_GPC, 15); // output Low to turn on LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			DrvGPIO_SetBit(E_GPC, 15);
			DrvGPIO_ClrBit(E_GPC, 14); // output Low to turn on LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			DrvGPIO_SetBit(E_GPC, 14);
			DrvGPIO_ClrBit(E_GPC, 13); // output Low to turn on LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			DrvGPIO_SetBit(E_GPC, 13);
			DrvGPIO_ClrBit(E_GPC, 12); // output Low to turn on LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			// all lightened up, now turn off
			DrvGPIO_SetBit(E_GPC, 12);		// output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 13); 		// GPC13 pin output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 14); 		// GPC14 pin output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 15); 		// GPC15 pin output Hi to turn off LED
		}
		else if(key_pressed == 7) {
			show_seven_segment(0, key_pressed);
			sprintf(TEXT, "Key%d pressed", key_pressed);
			print_Line(0, TEXT);
			print_Line(1, "Howard");
			DrvGPIO_ClrBit(E_GPC, i); 		// output Low to turn on LED
			DrvGPIO_ClrBit(E_GPC, i + 1); 	// output Low to turn on LED, alternating
	  		for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			DrvGPIO_SetBit(E_GPC, i); 		// output Low to turn off LED
			DrvGPIO_SetBit(E_GPC, i + 1); 	// output Low to turn off LED, alternating
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			(i == 14) ? (i = 12) : (i += 2);		// control the LED count
		}
		else if(key_pressed == 8) {
			show_seven_segment(0, key_pressed);
			print_Line(0, "107061112");
			DrvGPIO_ClrBit(E_GPC, i); 		// output Low to turn on LED
			DrvGPIO_ClrBit(E_GPC, i + 2); 	// output Low to turn on LED, alternating
	  		for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			DrvGPIO_SetBit(E_GPC, i); 		// output Low to turn off LED
			DrvGPIO_SetBit(E_GPC, i + 2); 	// output Low to turn off LED, alternating
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			(i == 13) ? (i = 12) : (i++);		// control the LED count
		}
		else if(key_pressed == 9) {
			show_seven_segment(0, key_pressed);
			sprintf(TEXT, "Key%d pressed", key_pressed);
			print_Line(0, TEXT);
			print_Line(1, "Happy New Year");
			DrvGPIO_ClrBit(E_GPC, 12); // output Low to turn on LED
	  		DrvGPIO_ClrBit(E_GPC, 13); // output Low to turn on LED
	  		DrvGPIO_ClrBit(E_GPC, 14); // output Low to turn on LED 
	  		DrvGPIO_ClrBit(E_GPC, 15); // output Low to turn on LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
			DrvGPIO_SetBit(E_GPC, 12); // output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 13); // output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 14); // output Hi to turn off LED
			DrvGPIO_SetBit(E_GPC, 15); // output Hi to turn off LED
			for (delay_cnt = 500; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
				DrvSYS_Delay(1);
			}
		}
	}
}
/****************************************************************************
 * Initialize the LED
 * *************************************************************************/
void Init_LED() {
	// initialize GPIO pins
	DrvGPIO_Open(E_GPC, 12, E_IO_OUTPUT); // GPC12 pin set to output mode
	DrvGPIO_Open(E_GPC, 13, E_IO_OUTPUT); // GPC13 pin set to output mode
	DrvGPIO_Open(E_GPC, 14, E_IO_OUTPUT); // GPC14 pin set to output mode
	DrvGPIO_Open(E_GPC, 15, E_IO_OUTPUT); // GPC15 pin set to output mode
	// set GPIO pins to output Low
	DrvGPIO_SetBit(E_GPC, 12); // GPC12 pin output Hi to turn off LED
	DrvGPIO_SetBit(E_GPC, 13); // GPC13 pin output Hi to turn off LED
	DrvGPIO_SetBit(E_GPC, 14); // GPC14 pin output Hi to turn off LED
	DrvGPIO_SetBit(E_GPC, 15); // GPC15 pin output Hi to turn off LED
}
// Function: input the number of buzz
void Buzz(int number)
{
	int i, delay_cnt;			// loop index and count for delay
	for (i=0; i<number; i++) {
	  	DrvGPIO_ClrBit(E_GPB,11); // GPB11 = 0 to turn on Buzzer
	  	for (delay_cnt = 50; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
			DrvSYS_Delay(1);
		}
	 	DrvGPIO_SetBit(E_GPB,11); // GPB11 = 1 to turn off Buzzer	
	  	for (delay_cnt = 50; (delay_cnt >= 0) && (ScanKey() == 0); delay_cnt--) {
			DrvSYS_Delay(1);
		} 
	}
}