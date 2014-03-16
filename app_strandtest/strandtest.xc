//-----------------------------------------------------------
// XCore Driver for Adafruit NeoPixel - test application
// by teachop
//
// On 8 NeoPixel strips display independent strand test patterns
//
// Note:  The neopixel module API is intended to be familiar
// to Adafruit NeoPixel Library users.
// (https://github.com/adafruit/Adafruit_NeoPixel)
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include "neopixel.h"


// ---------------------------------------------------------
// wheel - input a value 0 to 255 to get a color value.
//         The colors are a transition r - g - b - back to r
//
{uint8_t, uint8_t, uint8_t} wheel(uint8_t wheelPos) {
    if ( wheelPos < 85 ) {
        return {wheelPos*3, 255-wheelPos*3, 0};
    } else if ( wheelPos < 170 ) {
        wheelPos -= 85;
        return {255-wheelPos*3, 0, wheelPos*3};
    } else {
        wheelPos -= 170;
        return {0, wheelPos*3, 255-wheelPos*3};
    }
}


// ---------------------------------------------------------------
// blinky_task - cycle through patterns from adafruit strip test
//
[[combinable]]
void blinky_task(uint32_t taskID, interface neopixel_if client strip) {
    const uint32_t wipe[4] = {0xff0000,0x00ff00,0x0000ff,0xffffff};
    uint8_t outer = 0;
    uint8_t inner = 0;
    uint8_t r,g,b;
    uint32_t pattern_counter = 0;
    uint32_t length = strip.numPixels();
    uint32_t speed = ((30*length + (length>>2) + 51) + taskID*500)*100;
    timer tick;
    uint32_t next_pass;
    tick :> next_pass;

    while (1) {
        select {
        case tick when timerafter(next_pass) :> void:
            if ( 5 > pattern_counter ) {
                next_pass += speed;
                // ------- rainbow cycle --------
                outer++;
                for ( uint32_t pixel=0; pixel<length; ++pixel) {
                    {r,g,b} = wheel(( (pixel*256/length) + outer) & 255);
                    strip.setPixelColorRGB(pixel, r,g,b);
                }
                if ( !outer ) {
                    pattern_counter++;
                }
            } else if ( 16 > pattern_counter ) {
                next_pass += speed;
                // ------- color wipe --------
                strip.setPixelColor((pattern_counter&1)?outer:(length-1-outer), wipe[3&pattern_counter]);
                if ( ++outer >= length ) {
                    inner = outer = 0;
                    pattern_counter++;
                }
            } else if ( 18 > pattern_counter ) {
                next_pass += speed;
                // ------- brightness --------
                strip.setBrightness((pattern_counter&1)?outer:(255-outer));
                if ( !++outer ) {
                    pattern_counter++;
                }
            } else {
                next_pass += speed*12;
                // ------- theater chase --------
                for (uint32_t pixel=0; pixel<(length-2); pixel+=3) {
                  {r,g,b} = wheel( ((pixel+outer)<<1) & 255);
                  strip.setPixelColorRGB(pixel+inner, r,g,b);
                  strip.setPixelColor(inner?(pixel+inner-1):(pixel+2), 0);
                }
                inner = (2>inner)? inner+1 : 0;
                if ( !++outer ) {
                    pattern_counter = 0;
                }
            }
            // write to the strip
            strip.show();
            break;
        }
    }
}


// ---------------------------------------------------------
// main - xCore startKIT NeoPixel strand test
//
port out_pin[8] = {
    // j7.1, j7.2, j7.3, j7.4, j7.23, j7.21, j7.20, j7.19
    XS1_PORT_1F, XS1_PORT_1H, XS1_PORT_1G, XS1_PORT_1E,
    XS1_PORT_1P, XS1_PORT_1O, XS1_PORT_1I, XS1_PORT_1L
};
int main() {
    interface neopixel_if neopixel_strip[8];

    par {
        // 16 tasks, 8 cores, drive 8 led strips with differing patterns
        [[combine]] par {
            neopixel_task(out_pin[0], neopixel_strip[0]);
            blinky_task(0, neopixel_strip[0] );
        }
        [[combine]] par {
            neopixel_task(out_pin[1], neopixel_strip[1]);
            blinky_task(1, neopixel_strip[1] );
        }
        [[combine]] par {
            neopixel_task(out_pin[2], neopixel_strip[2]);
            blinky_task(2, neopixel_strip[2] );
        }
        [[combine]] par {
            neopixel_task(out_pin[3], neopixel_strip[3]);
            blinky_task(3, neopixel_strip[3] );
        }
        [[combine]] par {
            neopixel_task(out_pin[4], neopixel_strip[4]);
            blinky_task(4, neopixel_strip[4] );
        }
        [[combine]] par {
            neopixel_task(out_pin[5], neopixel_strip[5]);
            blinky_task(5, neopixel_strip[5] );
        }
        [[combine]] par {
            neopixel_task(out_pin[6], neopixel_strip[6]);
            blinky_task(6, neopixel_strip[6] );
        }
        [[combine]] par {
            neopixel_task(out_pin[7], neopixel_strip[7]);
            blinky_task(7, neopixel_strip[7] );
        }
    }

    return 0;
}

