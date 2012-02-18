// this file contains the implementation for queue functions.
#include "queue.h"

uint8_t initQueue(QueueType* queue)
{
  queue->write = 0;
  queue->read = 0;
  return 0;
}

uint8_t isFull(QueueType* queue)
{
    return (((queue->write + 1) % FIFO_SIZE) == queue->read);
}

uint8_t isEmpty(QueueType* queue)
{
    return (queue->write == queue->read);
}
// This function checks for is full condition. The user of this function may
// not just use isFull before calling this. Just check the return type, you will know.
uint8_t write_packet(QueueType* queue, uint8_t* packet_ptr)
{
    uint8_t is_full = isFull(queue);
    // Dont do anything if the queue is full
    if(!is_full)
    {
        // copy the value at the pointer provided in the queue.
        memcpy(&(queue->packets[queue->write]), packet_ptr, sizeof(ECGPacket));
        if(FIFO_SIZE-1 == queue->write) {
            queue->write = 0;
        }
        else {
            queue->write ++;
        }        
    }else {
      nrk_kprintf(PSTR("ERROR: TX FIFO FULL\n\r"));
    }
    return !is_full;
}

// This function checks for is empty condition. The user of this function may
// not jusr use isEmpty before calling this. Just check the return type - you will know.
uint8_t read_packet(QueueType* queue, uint8_t* packet_ptr)
{
    uint8_t is_empty  = isEmpty(queue);
    if(!is_empty)
    {
        // Copy to the requested pointer.
        memcpy(packet_ptr, &(queue->packets[queue->read]), sizeof(ECGPacket));
        if(FIFO_SIZE -1 == queue->read) {
            queue->read = 0;
	}
	else {
	    queue->read ++;
	}        
    }
    return !is_empty;
}

void debug_queue(QueueType* queue)
{

  printf("write: %d, read: %d\n\r",queue->write,queue->read);

}
