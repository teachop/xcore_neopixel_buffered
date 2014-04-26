//---------------------------------------------------------
// Buffered NeoPixel driver
// by teachop
//

#include <xs1.h>
#include <stdint.h>
#include "neopixel.h"


// ---------------------------------------------------------
// neopixel_task - output driver for one neopixel strip
//
[[combinable]]
void neopixel_task(port neo, static const uint32_t buf_size,
                   interface neopixel_if server dvr) {
    const uint32_t length = buf_size/3;
    uint8_t colors[buf_size];
    const uint32_t delay_first  = NEO_P1;
    const uint32_t delay_second = NEO_P2;
    const uint32_t delay_third  = NEO_P3;
    uint8_t brightness=0;
    for ( uint32_t loop=0; loop<(buf_size); ++loop ) {
        colors[loop] = 0;
    }

    while( 1 ) {
        select {
        case dvr.Color(uint8_t r, uint8_t g, uint8_t b) -> uint32_t return_val:
            return_val = ((uint32_t)r << 16) | ((uint32_t)g <<  8) | b;
            break;
        case dvr.numPixels() -> uint32_t return_val:
            return_val = length;
            break;
        case dvr.setBrightness(uint8_t bright):
            brightness = bright+1;
            break;
        case dvr.getPixelColor(uint32_t pixel) -> uint32_t return_val:
            if ( length > pixel ) {
                uint32_t index = 3*pixel;
                return_val = ((uint32_t)colors[index+1] << 16) | ((uint32_t)colors[index] <<  8) | colors[index+2];
            } else {
                return_val = 0;
            }
            break;
        case dvr.setPixelColor(uint32_t pixel, uint32_t color):
            if ( length > pixel ) {
                uint32_t index = 3*pixel;
                colors[index++] = color>>8;//g
                colors[index++] = color>>16;//r
                colors[index]   = color;//b
            }
            break;
        case dvr.setPixelColorRGB(uint32_t pixel, uint8_t r, uint8_t g, uint8_t b):
            if ( length > pixel ) {
                uint32_t index = 3*pixel;
                colors[index++] = g;
                colors[index++] = r;
                colors[index]   = b;
            }
            break;
        case dvr.show():
            // beginning of strip, sync counter
            uint32_t delay_count, bit;
            neo <: 0 @ delay_count;
            #pragma unsafe arrays
            for (uint32_t index=0; index<buf_size; ++index) {
                uint32_t color_shift = colors[index];
                uint32_t bit_count = 8;
                while (bit_count--) {
                    // output low->high transition
                    delay_count += delay_third;
                    neo @ delay_count <: 1;
                    // output high->data transition
                    if ( brightness && (7==bit_count) ) {
                        color_shift = (brightness*color_shift)>>8;
                    }
                    bit = (color_shift & 0x80)? 1 : 0;
                    color_shift <<=1;
                    delay_count += delay_first;
                    neo @ delay_count <: bit;
                    // output data->low transition
                    delay_count += delay_second;
                    neo @ delay_count <: 0;
                }
            }
            break;
        }
    }

}
