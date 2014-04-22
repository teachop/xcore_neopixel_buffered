##XCore Driver for Adafruit NeoPixel Strips

###Introduction
This project provides a general purpose frame buffered XCore driver **module_neopixel** for controlling [Adafruit NeoPixel](http://www.adafruit.com/category/37_168) strips.

It also includes an example application similar to the Adafruit strandtest but written in xC.  This program is able to control 8 NeoPixel strips from an XMOS startKIT.  The multiple strips are individually timed, displaying LED patterns each at their own speed.

###Driver API
An application task communicates with the driver by using its [interface](https://www.xmos.com/en/published/how-communicate-between-tasks-interfaces?secure=1), which defines these transactions:

- **setPixelColor(pixel, color)** Write a pixel in the driver internal buffer with packed RGB 8:8:8 value.  Use show() to actually update the LEDs.

- **setPixelColorRGB(pixel, r, g, b)** Write a pixel to driver internal buffer using individual 8 bit RGB values.  Use show() to actually update the LEDs.

- **show()** Update LED strip by clocking out serial data from the driver internal buffer.

- **setBrightness(bright)** Set scaling factor when buffer is displayed, 255 is full.  This is non-destructive, it does not change the buffer contents.

- **getPixelColor(pixel)** Get from the driver buffer the RGB 8:8:8 packed color for a given pixel.

- **Color(r, g, b)** Utility function to generate packed value from individual 8 bit RGB.

- **numPixels()** Get length of strip in pixels.

###Driver Operation
Strip-sized color data is drawn by application tasks (see example in strandtest) into driver buffers using the setPixelColor functions before then being sent to the LEDs using show().  Calling show() causes the driver to spool out to the strip contents of the frame buffer using precise serial timing needed by the NeoPixels (see note on timing below).

The driver is implemented as a task (see the neopixel module).  In the example given, eight copies of an application task output to 8 copies of the driver task to control 8 strips.  These 8 application/driver task pairs run concurrently on the 8 CPU cores.

This driver provides in memory a frame buffer, allowing the application to build and modify a complete image of the strip before displaying it on the LED strips.  An xCore project that can generate and display unbuffered (in other words without needing the large RAM frame buffers) NeoPixel data full-speed on-the-fly is [here.](https://github.com/teachop/xcore_neopixel_leds)

###Driver Task Handling
In order to allow the option of pairing up of application/driver tasks up on cores of the startKIT CPU, the task functions are marked as **combinable**.  [Combinable](https://www.xmos.com/en/published/how-define-and-use-combinable-function?secure=1) is an XMOS xC function attribute that allows multiple tasks to run on a single logical core.  In the example the **par()** statements in **main()** start the 16 tasks, combining them in pairs to execute together on each of the cores.  Use of combine is optional.

###Notes
**API** The driver interface API was designed to be familiar to users of the [Adafruit NeoPixel Library for Arduino](https://github.com/adafruit/Adafruit_NeoPixel).  Because this driver is written in xC, using the powerful multi-core XMOS XCore features, it is not exactly the same.  The interface is given in the neopixel.h file.

**Timing** There are different integrated circuits at the heart of various NeoPixel brand LED products.  These include WS2811, WS2812, WS2812B, and maybe more.  Timings are not identical for the different parts.  This driver is optimized for the WS2812B, and has been observed to "work" on the others.  If it is required to adjust  timing, three pulse phase constants can be modified in strip_config.h.

**More Code** There is another example project using this NeoPixel driver together with an ultrasonic range finder driver for XCore located [here](https://github.com/teachop/xcore_ping).

For additional information on the NeoPixel LED strips see [here](http://learn.adafruit.com/adafruit-neopixel-uberguide/overview).

Development and testing of the driver was done on the low cost [XMOS startKIT](http://www.xmos.com/en/startkit).
