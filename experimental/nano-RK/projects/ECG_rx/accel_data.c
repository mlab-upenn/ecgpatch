#include "accel_data.h"

static AccelData accelDataPort;

// This function returns the last witen data in the accel data port.
void readAccelData(AccelReading *data)
{
    int8_t index = accelDataPort.index; // this is necessary so that we dont get a dirty read.
    data->zValue = accelDataPort.data[index].zValue;
    data->yValue = accelDataPort.data[index].yValue;
    data->xValue = accelDataPort.data[index].xValue;
}

// ths functio write the the data in the last w
void writeAccelData(AccelReading *data)
{
    // you should write on the index that is not being currently read.
    int8_t index = accelDataPort.index ^ 1;
    accelDataPort.data[index].zValue = data->zValue;
    accelDataPort.data[index].yValue = data->yValue;
    accelDataPort.data[index].xValue = data->xValue;

    // now toggle the index.
    accelDataPort.index ^= 1;
}

