/******************************************************************************
*  Nano-RK, a real-time operating system for sensor networks.
*  Copyright (C) 2007, Real-Time and Multimedia Lab, Carnegie Mellon University
*  All rights reserved.
*
*  This is the Open Source Version of Nano-RK included as part of a Dual
*  Licensing Model. If you are unsure which license to use please refer to:
*  http://www.nanork.org/nano-RK/wiki/Licensing
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, version 2.0 of the License.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*******************************************************************************/
#include "queue.h"
#include "ext_adc_driver.h"
#include "accel_data.h"
#include "int_adc_driver.h"

#include <nrk.h>
#include <ulib.h>
#include <stdio.h>
#include <avr/sleep.h>
#include <hal.h>
#include <nrk_error.h>
#include <nrk_timer.h>
#include <nrk_stack_check.h>
#include <bmac.h>
#include <nrk_driver.h>
#include <nrk_driver_list.h>
#include <adc_driver.h>


#define MAC_ADDR	0x0003
#define CSMA_CHECK_PERIOD 25
#define ADC_PERIOD      10
#define TIMING_BUFFER   2
#define NUM_RETRIES     3

nrk_task_type RX_TASK;
NRK_STK rx_task_stack[NRK_APP_STACKSIZE];
void rx_task (void);

uint8_t tx_buf[RF_MAX_PAYLOAD_SIZE];
QueueType tx_queue;
ECGPacket tx_packet;
uint8_t rx_buf[RF_MAX_PAYLOAD_SIZE];

NRK_STK Stack1[NRK_APP_STACKSIZE];
nrk_task_type TaskOne;
void Task1(void);

void nrk_create_taskset();
void add_to_time(nrk_time_t old_time,nrk_time_t *new_time, uint32_t ms_to_add);
uint32_t time_diff_ns(nrk_time_t time1,nrk_time_t time2);
// Don't put the MMC buffer in a task or it will go onto the stack!
char ADC_data[10];



int main ()
{
    uint16_t div;
    nrk_setup_ports();
    nrk_setup_uart(UART_BAUDRATE_115K2);

    nrk_init();
    initQueue(&tx_queue);

    nrk_led_clr(0);
    nrk_led_clr(1);
    nrk_led_clr(2);
    nrk_led_clr(3);

    nrk_time_set(0,0);
    nrk_create_taskset ();

    bmac_task_config ();

    nrk_start();
    return 0;
}


void Task1()
{
    uint16_t cnt;
    int val;
    int index = 0;
    uint8_t i = 0;
    int adc_value = 0;
    uint8_t retries = 0; //important initial condition.
    AccelReading accelReading;

    nrk_time_t check_period;
    nrk_time_t next_time;
    nrk_time_t current_time;

    printf( "Task1 PID=%d\r\n",nrk_get_pid());

    // init bmac on channel 20
    bmac_init (20);

    // wait for bmac to start.
    while (!bmac_started ())
        nrk_wait_until_next_period ();

    //we're sending data at least 4x per second, so set a small check period
    check_period.secs=0;
    check_period.nano_secs=CSMA_CHECK_PERIOD*NANOS_PER_MS;
    val=bmac_set_rx_check_rate(check_period);

    //set up auto-ack
    bmac_addr_decode_set_my_mac(MAC_ADDR);
    bmac_addr_decode_enable();
    bmac_auto_ack_enable();
    bmac_addr_decode_dest_mac(1);

    // wait for some more time [testing]
    nrk_wait_until_next_period ();
    nrk_wait_until_next_period ();

    initOnChipADC();
    nrk_wait_until_next_period();
    nrk_wait_until_next_period();

    ADC_init();

    while (cnt < 2)
    {
        // give ADC enough time.
        nrk_wait_until_next_period();
        cnt ++;
    }

    //this is intended to initialize the value of next_time
    //wait for drdy to go low
    while (ADC_nDRDY()); //PORT_ADC_CS & (1 << PIN_ADC_DREADY));
    nrk_time_get(&current_time); //this is the time of the DRDY transition
    //wait for a little bit less than the ADC period
    add_to_time(current_time,&next_time,(uint32_t)(ADC_PERIOD - TIMING_BUFFER));
    nrk_wait_until(next_time);
    //bmac_rx_pkt_set_buffer (tx_buf, RF_MAX_PAYLOAD_SIZE);

    cnt = 0;
    index = 0;
    tx_packet.address = MAC_ADDR;
    while(1)
    {
        //wait for drdy to go low
        while (ADC_nDRDY()); //PORT_ADC_CS & (1 << PIN_ADC_DREADY));

	//record the time of the DRDY transition
	//this could be misleading if we were preempted by bmac
	//during the above while loop.  that case is handled below
        nrk_time_get(&current_time); 

        //read data from ADC
        ADC_data[0] = ADC_data[1] = 0;
        ADC_read_data(ADC_data, 2);
        adc_value =  (ADC_data[0] << 8) | ADC_data[1];
	//ugly hack...
	if(adc_value < 0) adc_value = -32768 - adc_value;
	else adc_value = 32768 - adc_value;

//        readAccelData(&accelReading);
//        printf("%d ACCEL:%d,%d,%d\n\r", adc_value, accelReading.xValue, accelReading.yValue, accelReading.zValue);


	// copy the data into the tx buffer 
	tx_packet.data[index] = ADC_data[0];
	index++;
	tx_packet.data[index] = ADC_data[1];
	index++;
	cnt++;

	//write a new packet every 25 samples
	if(25 == cnt)
        {
            readAccelData(&accelReading);
            tx_packet.accelReading.xValue = accelReading.xValue;
            tx_packet.accelReading.yValue = accelReading.yValue;
            tx_packet.accelReading.zValue = accelReading.zValue;

            write_packet(&tx_queue,(uint8_t *)&tx_packet);
	    for(i=0; i<DATA_PACKET_SIZE; i++)
                tx_packet.data[i] = 0;
	    cnt = 0;
	    index = 0;

            //  nrk_kprintf(PSTR("added packet to queue\n\r"));
        }
	//if the last packet is done and we didn't get an ack
	//and we have some retries left, re-send
	if(!bmac_tx_busy() && !bmac_got_ack() && retries > 0)
        {
	    //resend packet
            val=bmac_tx_pkt_nonblocking(tx_buf, DATA_PACKET_SIZE + 1 + sizeof(accelReading));
            //    printf("retry %d\n\r",4-retries);
	    retries--;

            //normal packet sending
        }
        else if(!isEmpty(&tx_queue) && !bmac_tx_busy())
        {
	    //we're sending a new packet, so reset retries
	    retries = NUM_RETRIES;
	    //get the packet from the queue
	    val = read_packet(&tx_queue,&tx_buf);
	    if(val == 0) nrk_kprintf(PSTR("ERROR: tx queue empty\n\r"));

	    //	printf(" transmitting:");
            //for(int i = 0; i<50; i ++)
            //{
            //	printf("0x%x", tx_buf[i]);
            //}
            //	printf("\n\r");
	    
            val=bmac_tx_pkt_nonblocking(tx_buf, DATA_PACKET_SIZE + 1 + sizeof(accelReading));
            //    nrk_kprintf(PSTR("sending packet\n\r"));
	    //	if(val==NRK_OK) printf("PASSED\n\r");
	    //	     else nrk_kprintf( PSTR( "NO ack or Reserve Violated!\r\n" ));
        }

	//check if time diff makes sense (task could have been preempted)
	if(time_diff_ns(next_time,current_time) < (3 * NANOS_PER_MS)) //this is ok
            add_to_time(current_time,&next_time,ADC_PERIOD - TIMING_BUFFER);
	else //probably preempted.  don't trust current_time.  
            //just wait ADC_PERIOD ms from the last next_time
            add_to_time(next_time,&next_time,(uint32_t)ADC_PERIOD);


	//scheduler doesn't like being told to wait until a
	//time in the past (what, no time machine??!!??)
	//if we've already passed next_time, ask to come back
	//5ms after the current time.
	nrk_time_get(&current_time);
	if(current_time.secs > next_time.secs || 
                current_time.nano_secs > next_time.nano_secs) {            
            add_to_time(current_time,&next_time,(uint32_t)5);
	}

        nrk_wait_until(next_time);
        //nrk_wait_until_next_period();

    }
}

void nrk_create_taskset()
{
    nrk_task_set_entry_function( &TaskOne, Task1);
    nrk_task_set_stk( &TaskOne, Stack1, NRK_APP_STACKSIZE);
    TaskOne.prio = 3;
    TaskOne.FirstActivation = TRUE;
    TaskOne.Type = BASIC_TASK;
    TaskOne.SchType = PREEMPTIVE;
    TaskOne.period.secs = 0;
    TaskOne.period.nano_secs = 100* NANOS_PER_MS;
    TaskOne.cpu_reserve.secs = 0;
    TaskOne.cpu_reserve.nano_secs =  70 * NANOS_PER_MS;
    TaskOne.offset.secs = 0;
    TaskOne.offset.nano_secs= 0;
    nrk_activate_task (&TaskOne);

    printf ("Create done\r\n");
}

void add_to_time(nrk_time_t old_time,nrk_time_t *new_time, uint32_t ms_to_add)
{
    if(old_time.nano_secs > ((1000 - ms_to_add)*NANOS_PER_MS))
    {
	new_time->secs = old_time.secs + (uint32_t)1;
	new_time->nano_secs = (old_time.nano_secs + (ms_to_add*NANOS_PER_MS)) - 1000*NANOS_PER_MS;
    }else {
	new_time->secs = old_time.secs;
	new_time->nano_secs = old_time.nano_secs + ms_to_add*NANOS_PER_MS;
    }
}

uint32_t time_diff_ns(nrk_time_t time1,nrk_time_t time2)
{
    if(time2.nano_secs < time1.nano_secs) //nanosecs has probably wrapped
    {
        return (time2.nano_secs + 1000*NANOS_PER_MS - time1.nano_secs);
    }else {
        return (time2.nano_secs - time1.nano_secs);
    }

}
