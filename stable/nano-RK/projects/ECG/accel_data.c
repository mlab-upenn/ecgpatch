#include "accel_data.h"

#define ACCEL_CHANEL_Z 1
#define ACCEL_CHANEL_Y 2
#define ACCEL_CHANEL_X 5

static AccelData accelDataPort;


static int8_t accelHandle;
static int g_lock;

int8_t initAccel()
{
    // initialize the accelerometer.
    accelHandle = nrk_open(ADC_DEV_MANAGER,INIT);
    if(NRK_ERROR == accelHandle)
    {
        nrk_kprintf(PSTR("Failed to open ADC driver\n\r"));
    }

    // Open ADC device as read
    accelHandle = nrk_open(ADC_DEV_MANAGER,READ);
    if(NRK_ERROR == accelHandle)
    {
        nrk_kprintf( PSTR("Failed to open ADC driver in READ mode\r\n"));
    }
    return accelHandle;
}


int8_t readAndStoreAccelData()
{
    int8_t status = 0;

    // TODO: This is not thread safe. Make it so.

    // Starting to read.. lock !!
    g_lock = 1;

    // Set the ADC status to channel 1.
    status = nrk_set_status(accelHandle, ADC_CHAN, ACCEL_CHANEL_Z);
    if(NRK_ERROR == status)
    {
        nrk_kprintf( PSTR("Failed to set ADC status for Channel 1\r\n" ));
    }
    // Now read the ADC value.
    status = nrk_read(accelHandle, &(accelDataPort.data.zValue), sizeof(int16_t));


    // Set the ADC status to channel 2.
    status = nrk_set_status(accelHandle, ADC_CHAN, ACCEL_CHANEL_X);
    if(NRK_ERROR == status)
    {
        nrk_kprintf( PSTR("Failed to set ADC status for Channel 2\r\n" ));
    }
    // Now read the ADC value.
    status = nrk_read(accelHandle, &(accelDataPort.data.yValue), sizeof(int16_t)) & status;

    // Set the ADC status to channel 1.
    status = nrk_set_status(accelHandle, ADC_CHAN, ACCEL_CHANEL_X);
    if(NRK_ERROR == status)
    {
        nrk_kprintf( PSTR("Failed to set ADC status for Channel 5\r\n" ));
    }
    // Now read the ADC value.
    status = nrk_read(accelHandle, &(accelDataPort.data.xValue), sizeof(int16_t)) & status;

    // the data is now fresh.
    accelDataPort.fresh = 1;
    // unlock the lock.
    g_lock = 0;

}

// This function returns the accel read data from
int8_t readAccelData(AccelReading *data, int8_t *freshness)
{
    int8_t returnVal = 0;
    *freshness = 0;
    // find out if you can read the data or not.
    if(!g_lock)
    {
        // read and return.
        data->zValue = accelDataPort.data.zValue;
        data->yValue = accelDataPort.data.yValue;
        data->xValue = accelDataPort.data.xValue;
        *freshness = accelDataPort.fresh;
        returnVal = 1;
    }
    return returnVal;
}

