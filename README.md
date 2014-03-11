#Buffered Driver for 8 NeoPixel Strips

This project drives Adafruit NeoPixel strips of fairly arbitrary length with a nice rolling rainbow effect.  Multiple strips are independent, running patterns each at their own speed.  (The point is to learn about xCore more than make LED patterns)

The color data is fully generated into buffers by generator tasks before being written out by driver tasks.  Eight copies of the generator task output to 8 copies of the strip driver task to control 8 strips.

Since this version generates complete buffers before displaying LEDS, it will run out of memory somewhere.  That "somewhere" is well past 10,000 LEDS total (that didn't get physically tested, just compiled).

In this program there are 16 tasks on 8 cores, combinable functions, multiple return functions, and communication interfaces, making this an interesting if quirky version.

An xCore project that generates and displays unbuffered NeoPixel data on the fly is here:
https://github.com/teachop/xcore_neopixel_leds
