#ifndef EXT_ADC_DRIVER_H
#define EXT_ADC_DRIVER_H

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
void ADC_write(char cData);
void ADC_read(char* data_ptr, int num_bytes);
void ADC_read_data(char* data_ptr, int num_bytes);
uint8_t ADC_nDRDY();
void ADC_init();



#endif //EXT_ADC_DRIVER
