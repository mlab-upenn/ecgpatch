#include <nrk.h>
#include <include.h>
#include <ulib.h>
#include <stdio.h>
#include <avr/sleep.h>
#include <hal.h>
#include <nrk_error.h>
#include <nrk_timer.h>

#include "adc_driver.h"


void ADC_reset()
{
    // reset the ADC here. We need to connect the ADC pin with
    // some pin of the micro controller.
}

void SPI_initialize()
{
    // Set MOSI and SCK output, all others input
//    DDR_SPI = (1<<DD_MOSI) | (1<<DD_SCK);

    // Enable SPI, Master, set clock rate fck/16
//    SPCR = (1 << SPE)|(1 << MSTR)|(1 << SPR0);
}

void SPI_write_to_register(char cData)
{
    //    int q;

    // Set MOSI and SCK output, all others input
    //  DDR_SPI = (1<<DD_MOSI)|(1<<DD_SCK);

    //    // Enable SPI, Master, set clock rate fck/16
    //    SPCR = (1 << SPE)|(1 << MSTR)|(1 << SPR0);

    //    q = SPSR;
    //    q = SPDR;

    // Enable the Chip select.
    PORT_ADC_CS &= ~(1 << PIN_ADC_CS);

    // Start transmission
    SPDR = cData;

    // Wait for transmission complete
    while(!(SPSR & (1<<SPIF)));

    // Disable the chip select.
    PORT_ADC_CS |= 1 << PIN_ADC_CS;
}

void ADC_read(char* dataptr, int num_bytes)
{
    int q;
    int index = 0;

    // Set MOSI and SCK output, all others input
    //    DDR_SPI = (1<<DD_MOSI) | (1<< DD_MISO) | (1<<DD_SCK);

    // Enable the Chip select.
    PORT_ADC_CS &= ~(1 << PIN_ADC_CS);
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

    // Disable the chip select.
    PORT_ADC_CS |= 1 << PIN_ADC_CS;
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

    // Enable SPI, Master, set clock rate fck/16
    SPCR = (1 << SPE)|(1 << MSTR)|(1 << SPR0);

    // Now set the chip select line to low.
    PORT_ADC_CS &= ~(1 << PIN_ADC_CS);
    // The next few lines are as instructed by AD7705 document page 33.
    SPI_write_to_register(0x20);
    SPI_write_to_register(0x1D);
    SPI_write_to_register(0x10);
    SPI_write_to_register(0x00);

    PORT_ADC_CS |= 1 << PIN_ADC_CS;

    // Wait for DRDY to go low.
    // while (PORT_ADC_CS & (1 << PIN_ADC_DREADY));

}


