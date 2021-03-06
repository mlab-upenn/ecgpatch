// The function declares the functions needed for Queue.
#ifndef QUEUE_H
#define QUEUE_H

#include <include.h>
#include <stdio.h>

//#include <nrk_defs.h>

#define FIFO_SIZE 10
#define DATA_PACKET_SIZE 51

typedef struct
{
  uint8_t address;
    uint8_t data[DATA_PACKET_SIZE];
}ECGPacket;

typedef struct 
{
    ECGPacket packets[FIFO_SIZE];
    uint8_t write;
    uint8_t read;
}QueueType;

uint8_t initQueue(QueueType* queue);
uint8_t isFull(QueueType* queue);
uint8_t isEmpty(QueueType* queue);
uint8_t write_packet(QueueType* queue, uint8_t* packet_ptr);
uint8_t read_packet(QueueType* queue, uint8_t* packet_ptr);    
void debug_queue(QueueType* queue);

#endif //QUEUE_H
