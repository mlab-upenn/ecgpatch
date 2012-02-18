#ifndef ADC_DRIVER_H
#define ADC_DRIVER_H

#define PORT_SPI PORTB
#define DDR_SPI DDRB
#define PIN_SPI	PINB
#define SCLK PB1
#define MOSI PB2
#define MISO PB3

#define DD_SCK 0x01
#define DD_MOSI 0x02
#define DD_MISO 0x03

#define PORT_ADC_CS PORTE
#define DDR_ADC DDRE

#define PIN_ADC_CS 5
#define PIN_ADC_DREADY 4

void ADC_reset();
void SPI_initialize();
void SPI_write_to_register(char cData);
void ADC_read(char* data_ptr, int num_bytes);
void ADC_init();


#endif
