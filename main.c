#include "N76E003.h"

#define TIMER_RELOAD_VALUE (65536 - 1334)

void msdelay(unsigned long count) {
  while (count != 0) {
    TH0 = TIMER_RELOAD_VALUE >> 8;
    TL0 = TIMER_RELOAD_VALUE & 0xFF;

    TF0 = 0;
    TR0 = 1;

    while (TF0 != 1)
      ;

    TR0 = 0;
    count--;
  }
}

void main(void) {
  // just clock things
  CKCON &= ~0x08;
  TMOD &= 0xF0;
  TMOD |= 0x01;

  // push pull mode
  P1M1 &= ~(1 << 2);
  P1M2 |= (1 << 2);

  while (1) {
    P12 = !P12;
    msdelay(1000);
  }
}
