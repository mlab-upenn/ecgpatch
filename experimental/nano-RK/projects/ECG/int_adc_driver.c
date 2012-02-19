#include "int_adc_driver.h"
#include "accel_data.h"

#include <nrk_driver_list.h>
#include <nrk_driver.h>
#include <adc_driver.h>
#include <include.h>
#include <stdio.h>
#include <ulib.h>
#include <nrk_error.h>
#include <nrk.h>
#include <stdint.h>

#define ADC_SETUP_DELAY  500
#define ACCEL_CHANEL_Z 1
#define ACCEL_CHANEL_Y 2
#define ACCEL_CHANEL_X 5

#define ADC_SET_CHANNEL(channel) do { ADMUX = (ADMUX & ~0x1F) | (channel); } while (0)

typedef enum
{
    Z_VALUE = 0,
    Y_VALUE = 1,
    X_VALUE = 2

}LastWrittenValue;
static LastWrittenValue lastWrittenValue = Z_VALUE;
AccelReading acclReading = {0};

// Enables/disables the ADC
#define ADC_ENABLE() ADCSRA |= BM(ADEN)
#define ADC_DISABLE() ADCSRA &= ~BM(ADEN)


// This function  used to initialize the onchip ADC for interrupt mode.
void initOnChipADC()
{
    ADCSRA = BM(ADPS0) | BM(ADPS1) | BM(ADIE); // Enabling the interrupt as well.
    ADMUX = BM(REFS0);  // we are setting the channel to zero initially.

    // enable the ADC now.
    ADC_ENABLE();

    // Delay.
    nrk_spin_wait_us(ADC_SETUP_DELAY);

    ADC_SET_CHANNEL(ACCEL_CHANEL_Z);

    // start the ADC conversion;
    ADCSRA |= BM(ADSC);
}

// ADC interrupt.
// This routine remembers which value (out of x, y, z) did he read the last time.
ISR(ADC_vect)
{
    int16_t value = 0;
    value = ((uint8_t) ADCL) >> 2;
    value |= ((int8_t) ADCH) << 6;

    if(lastWrittenValue == Z_VALUE) {
        acclReading.zValue = value;
//        printf("%d ", value);
        // chnage the cannel now.
        ADC_SET_CHANNEL(ACCEL_CHANEL_Y);
        lastWrittenValue = Y_VALUE;
    }
    else if(lastWrittenValue == Y_VALUE) {
        acclReading.yValue = value;
//        printf("%d ", value);
        // change the channel now.
        ADC_SET_CHANNEL(ACCEL_CHANEL_X);
        lastWrittenValue = X_VALUE;
    }
    else {
        acclReading.xValue = value;
//        printf("%d \n\r", value);

        // change the channel now.
        ADC_SET_CHANNEL(ACCEL_CHANEL_Z);
        lastWrittenValue = Z_VALUE;

        // Now you have the data ready. So write in in the data port.
        writeAccelData(&acclReading);
    }

}


