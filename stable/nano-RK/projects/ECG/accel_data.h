// This file includes the fuctions one needs to read and the accerometer
// data and puts into a thread safe data structure.

#ifndef ACCEL_DATA_H
#define ACCEL_DATA_H

#include <nrk.h>
#include <include.h>
#include <ulib.h>
#include <stdio.h>
#include <avr/sleep.h>
#include <hal.h>
#include <nrk_error.h>
#include <nrk_timer.h>
#include <nrk_driver_list.h>
#include <nrk_driver.h>
#include <adc_driver.h>

typedef struct
{
    int16_t xValue;
    int16_t yValue;
    int16_t zValue;
}AccelReading;


// This is a datastructure rads the data when available.
typedef struct
{
    int fresh;
    AccelReading data;
}AccelData;


//  This function initializes the accelerometer data
int8_t initAccel();

// The function reads the data from the accelerameter and puts the data for
// consumption from the main thread.
int8_t readAndStoreAccelData();

// this function gets you the acceleration data.
 int8_t readAccelData(AccelReading *data, int8_t *freshness);

#endif //ACCEL_DATA_H
