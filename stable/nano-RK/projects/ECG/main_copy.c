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
#include <nrk.h>
#include <include.h>
#include <ulib.h>
#include <stdio.h>
#include <avr/sleep.h>
#include <hal.h>
#include <nrk_error.h>
#include <nrk_timer.h>
#include <nrk_stack_check.h>
#include "adc_driver.h"
#include <bmac.h>

#define MAC_ADDR	0x0001

nrk_task_type RX_TASK;
NRK_STK rx_task_stack[NRK_APP_STACKSIZE];
void rx_task (void);

uint8_t tx_buf[RF_MAX_PAYLOAD_SIZE];
uint8_t rx_buf[RF_MAX_PAYLOAD_SIZE];

NRK_STK Stack1[NRK_APP_STACKSIZE];
nrk_task_type TaskOne;
void Task1(void);

void nrk_create_taskset();
// Don't put the MMC buffer in a task or it will go onto the stack!
char ADC_data[10];



int main ()
{
    uint16_t div;
    nrk_setup_ports();
    nrk_setup_uart(UART_BAUDRATE_115K2);

    printf( "Starting up...\r\n" );

    nrk_init();


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

    printf( "Task1 PID=%d\r\n",nrk_get_pid());


   // init bmac on channel 25 
   bmac_init (15);

  // wait for bmac to start.
  while (!bmac_started ())
    nrk_wait_until_next_period ();

   // wait for some more time [testing] 
      nrk_wait_until_next_period ();
    nrk_wait_until_next_period ();


    ADC_init();

    while (cnt < 20)
    {
        // give ADC enough time.
        nrk_wait_until_next_period();
        cnt ++;
    }


	bmac_rx_pkt_set_buffer (tx_buf, RF_MAX_PAYLOAD_SIZE);

	cnt = 0;
    while(1)
    {
      //wait for drdy to go low
        while (PORT_ADC_CS & (1 << PIN_ADC_DREADY));

        ADC_data[0] = ADC_data[1] = 0;
        ADC_read_data(ADC_data, 2);
        val =  (ADC_data[0] << 8) | ADC_data[1];
        printf("ADC: 0x%x 0x%x \n\r", ADC_data[0], ADC_data[1]);

	   // copy the data into the tx buffer 
		tx_buf[index] = ADC_data[0];
		tx_buf[index ++] = ADC_data[1];
		cnt++;

		if(20 == cnt)
		{ 
			printf(" transmitting:");
			for(int i = 0; i<40; i ++)
			{				
				printf("0x%x", tx_buf[i]);
			}
			printf("\n\r");

			val=bmac_tx_pkt_nonblocking(tx_buf, 40);
			//	if(val==NRK_OK) printf("PASSED\n\r");
			//	     else nrk_kprintf( PSTR( "NO ack or Reserve Violated!\r\n" ));
			cnt = 0;
			index = 0;
		}

        nrk_wait_until_next_period();
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
    TaskOne.period.nano_secs = 20* NANOS_PER_MS;
    TaskOne.cpu_reserve.secs = 0;
    TaskOne.cpu_reserve.nano_secs =  18 * NANOS_PER_MS;
    TaskOne.offset.secs = 0;
    TaskOne.offset.nano_secs= 0;
    nrk_activate_task (&TaskOne);

    printf ("Create done\r\n");
}
