#define F_CPU 1000000UL

#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	DDRD = 0x00;
	PORTD= 0xFF;
	DDRA = 0x00;
	PORTA= 0xFF;

    DDRB = 0x00;
	PORTB = 0x00;
    OCR0=0x0D;
    //TCCR0|=((1<<WGM01)|(1<<COM00)|(1<<CS00));
    TCCR0=0b00011001;

	while(1)
	{
		if (bit_is_clear(PINA,1))	//3
           	{
                    DDRB =0XFF;        
			_delay_ms(10);
	            DDRB =0X00;        
			_delay_ms(10); 		//start bit
	            DDRB =0XFF;        
			_delay_ms(10);		//msg1
        	    DDRB =0X00;        
			_delay_ms(10);		
        	    DDRB =0XFF;        
			_delay_ms(10);		//msg2
	            DDRB =0X00;        
			_delay_ms(1000);	//stop bit		
		}
	}
return(0);
}
