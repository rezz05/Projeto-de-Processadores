#include <stdio.h>
#define SIZE    10

/* Shared variables */
int buffer[SIZE];
int begin = 0;              // Index to insert data into queue 
int end = 0;                // Index to remove data from queue
int count = 0;              // Number of elements currently stored

void producer1() {
    int i;
    
    while(1) {
        /* Begin of critical section */
        if (count < SIZE) {
            buffer[end] = 1;            // Insert data 
            end++;
            count++;
        }    
        /* End of critical section */
        
        for(i=0; i<255; i++);           // Time delay
    }  
}

void producer2() {
    int i;
    
    while(1) {
        /* Begin of critical section */
        if (count < SIZE) {
            buffer[end] = 2;            // Insert data 
            end++;
            count++;
        }       
        /* End of critical section */
        
        for(i=0; i<255; i++);           // Time delay
    }  
}

void consumer() {
    int i,data;
    
    while(1) {
        /* Begin of critical section */
        if (count > 0) {
            buffer[begin] = -1;       // Remove data
            begin++;
            count--;
        }
        /* End of critical section */
        
        for(i=0; i<255; i++);           // Time delay
    }
}
