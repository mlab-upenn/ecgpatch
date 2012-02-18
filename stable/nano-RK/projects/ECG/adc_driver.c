#include <nrk.h>
#include <include.h>
#include <ulib.h>
#include <stdio.h>
#include <avr/sleep.h>
#include <hal.h>
#include <nrk_error.h>
#include <nrk_timer.h>

#include "adc_driver.h"

void enable_adc();
void disable_adc();

void ADC_reset()
{
    // reset the ADC here. We need to connect the ADC pin with
    // some pin of the micro controller.
}

void ADC_write(char cData)
{
  enable_adc();

    // Start transmission
    SPDR = cData;

    // Wait for transmission complete
    while(!(SPSR & (1<<SPIF)));

    disable_adc();
}

void ADC_read(char* dataptr, int num_bytes)
{
    int q;
    int index = 0;

     enable_adc();

    // Read all the bits
    for(index = 0; index < num_bytes; index ++)
    {
        SPDR = 0xFF;

        // Wait for transmission complete
        while(!(SPSR & (1<<SPIF)));

        // receive data from the SPI data register.
        //ADC_data[index] = SPDR;
        dataptr[index] = SPDR;
    }
    disable_adc();
}

void ADC_read_data(char* dataptr, int num_bytes)
{
    int q;
    int index = 0;

     enable_adc();

     //next action is read of data register
     SPDR = 0x38;
     // Wait for transmission complete
     while(!(SPSR & (1<<SPIF)));

    // Read all the bits
    for(index = 0; index < num_bytes; index ++)
    {
        SPDR = 0x00;

        // Wait for transmission complete
        while(!(SPSR & (1<<SPIF)));

        // receive data from the SPI data register.
        //ADC_data[index] = SPDR;
        dataptr[index] = SPDR;
    }
    disable_adc();
}

uint8_t ADC_nDRDY()
{
    int q;
    int index = 0;
    uint8_t reg_val = 0;
     enable_adc();

     //next action is read of communications register
     SPDR = 0x08;
     // Wait for transmission complete
     while(!(SPSR & (1<<SPIF)));

    // Read the value
     //SPDR = 0xFF;
     SPDR = 0x00;

     // Wait for transmission complete
     while(!(SPSR & (1<<SPIF)));

     // receive data from the ADC.
     reg_val = SPDR;
     //printf("0x%x, 0x%x\n\r",reg_val,(reg_val & 0x80));
    disable_adc();

    //nDRDY is the MSB of the returned value
    if((reg_val & 0x80) == 0x80) return 1;
    else return 0;

}

void ADC_init()
{
    // First Initialize the SPI
    PORT_SPI &= ~((1 << SCLK) | (1 << MOSI));	// low bits
    PORT_SPI |= (1 << MISO);			// high bits

    // Set MOSI and SCK output, all others input
    DDR_SPI = (1<<DD_MOSI) | (1<<DD_SCK);

    // make the Chip select high.
    PORT_ADC_CS = 1 << PIN_ADC_CS; // Check if i will have to use |= instead of assignment.
    // Set the data direction of ADC DATA rady pin to in which is 0.
    DDRE |= (1 << PIN_ADC_CS);
    DDRE &= ~(1 << PIN_ADC_DREADY);

    //setup spi, cs, disable interrupts
    enable_adc();

    // The next few lines are as instructed by AD7705 document page 33.
    ADC_write(0x20); //write to clk register
    //ADC_write(0x04); //clk 1 (2.4MHz), FS = 0 (50Hz)
    ADC_write(0x0A); //clk divide, clk 0 (1MHz), FS = 2 (100Hz)
    ADC_write(0x10); //write to setup register
    ADC_write(0x40); //start internal calibration, gain = 1, bipolar inputs, unbuffered.
    //ADC_write(0x44); //start internal calibration, gain = 1, unipolar inputs, unbuffered.

    //put back spi as it was, diable cs, reenable interrupts
    disable_adc();

    // Wait for DRDY to go low.
    // while (PORT_ADC_CS & (1 << PIN_ADC_DREADY));

}


void enable_adc()
{
  // disbable the interrupts
  nrk_int_disable();
  // enable additional CPOL and CPHA bits.
  SPCR = (1<<SPE)|(1<<MSTR)|(1 << SPR0)|(1<<CPOL)|(1<<CPHA);
  // select the chip select.
  PORT_ADC_CS &= ~(1 << PIN_ADC_CS);
}

void disable_adc()
{
    // Disable the chip select.
    PORT_ADC_CS |= 1 << PIN_ADC_CS;
    // put the SPI back the way it was.
   SPCR = (1<<SPE)|(1<<MSTR)|(1 << SPR0);
   // enable the interrupt back.
    nrk_int_enable();
}
