//---------------------------------------------------------
// Buffered NeoPixel driver
// by teachop
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>


// length of the strip(s)
#define LEDS 60

// microseconds it takes to write to the strip
#define LED_WRITE_TIME (30*LEDS + (LEDS>>2) + 51)

// neopixel driver interface sort of like Adafruit library
interface neopixel_if {
    void show(void);
    void setPixelColor(uint32_t pixel, uint32_t color);
    void setPixelColorRGB(uint32_t pixel, uint8_t red, uint8_t green, uint8_t blue);
    void setBrightness(uint8_t bright);
};


// ---------------------------------------------------------
// neopixel_led_task - output driver for one neopixel strip
//
[[combinable]]
void neopixel_led_task(port neo, interface neopixel_if server dvr) {
    uint8_t colors[LEDS*3];
    const uint32_t delay_third = 42;
    uint8_t brightness=0;

    while( 1 ) {
        select {
        case dvr.setBrightness(uint8_t bright):
            brightness = bright;
            break;
        case dvr.setPixelColor(uint32_t pixel, uint32_t color):
            if ( LEDS > pixel ) {
                uint32_t index = 3*pixel;
                colors[index++] = color>>8;//g
                colors[index++] = color>>16;//r
                colors[index]   = color;//b
            }
            break;
        case dvr.setPixelColorRGB(uint32_t pixel, uint8_t r, uint8_t g, uint8_t b):
            if ( LEDS > pixel ) {
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
            for (uint32_t index=0; index<sizeof(colors); ++index) {
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
                    delay_count += delay_third;
                    neo @ delay_count <: bit;
                    // output data->low transition
                    delay_count += delay_third;
                    neo @ delay_count <: 0;
                }
            }
            break;
        }
    }

}


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
// blinky_task - rainbow cycle pattern from adafruit strip test
//
[[combinable]]
void blinky_task(uint32_t strip, interface neopixel_if client dvr) {
    uint8_t outer = 0;
    uint8_t r,g,b;
    timer tick;
    uint32_t next_pass;
    tick :> next_pass;

    while (1) {
        select {
        case tick when timerafter(next_pass) :> void:
            next_pass += (LED_WRITE_TIME + strip*1000)*100;
            // cycle of all colors on wheel
            for ( uint32_t pixel=0; pixel<LEDS; ++pixel) {
                {r,g,b} = wheel(( (pixel*256/LEDS) + outer++) & 255);
                dvr.setPixelColorRGB(pixel, r,g,b);
            }
            // write to the strip
            dvr.show();
            break;
        }
    }
}


// ---------------------------------------------------------
// main - xCore startKIT NeoPixel blinky test
//
port out_pin[8] = {
    // j7.1, j7.2, j7.3, j7.4, j7.23, j7.21, j7.20, j7.19
    XS1_PORT_1F, XS1_PORT_1H, XS1_PORT_1G, XS1_PORT_1E,
    XS1_PORT_1P, XS1_PORT_1O, XS1_PORT_1I, XS1_PORT_1L
};
int main() {
    interface neopixel_if neo_driver[8];

    par {
        // 16 tasks, 8 cores, drive 8 led strips with differing patterns
        [[combine]] par {
            neopixel_led_task(out_pin[0], neo_driver[0]);
            blinky_task(0, neo_driver[0] );
        }
        [[combine]] par {
            neopixel_led_task(out_pin[1], neo_driver[1]);
            blinky_task(1, neo_driver[1] );
        }
        [[combine]] par {
            neopixel_led_task(out_pin[2], neo_driver[2]);
            blinky_task(2, neo_driver[2] );
        }
        [[combine]] par {
            neopixel_led_task(out_pin[3], neo_driver[3]);
            blinky_task(3, neo_driver[3] );
        }
        [[combine]] par {
            neopixel_led_task(out_pin[4], neo_driver[4]);
            blinky_task(4, neo_driver[4] );
        }
        [[combine]] par {
            neopixel_led_task(out_pin[5], neo_driver[5]);
            blinky_task(5, neo_driver[5] );
        }
        [[combine]] par {
            neopixel_led_task(out_pin[6], neo_driver[6]);
            blinky_task(6, neo_driver[6] );
        }
        [[combine]] par {
            neopixel_led_task(out_pin[7], neo_driver[7]);
            blinky_task(7, neo_driver[7] );
        }
    }

    return 0;
}

