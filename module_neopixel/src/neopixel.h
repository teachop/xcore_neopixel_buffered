//---------------------------------------------------------
// Buffered NeoPixel driver header
// by teachop
//

#ifndef __NEOPIXEL_H__
#define __NEOPIXEL_H__

#include "strip_config.h"

// neopixel driver interface, Adafruit library-like
interface neopixel_if {
    void show(void);
    void setPixelColor(uint32_t pixel, uint32_t color);
    void setPixelColorRGB(uint32_t pixel, uint8_t r, uint8_t g, uint8_t b);
    void setBrightness(uint8_t bright);
    uint32_t getPixelColor(uint32_t pixel);
    uint32_t Color(uint8_t r, uint8_t g, uint8_t b);
    uint32_t numPixels(void);
};

[[combinable]] void neopixel_task(port neo, interface neopixel_if server dvr);


#endif // __NEOPIXEL_H__
