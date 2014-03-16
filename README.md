##A XCore Driver for Adafruit NeoPixel Strips on XMOS startKIT

###Introduction
This project contains a general purpose frame buffered XMOS Module-style driver **neopixel** for controlling Adafruit NeoPixel strips.

It also includes an example application similar to the Adafruit strandtest but written in XC and able to control 8 NeoPixel strips from the startKIT.  The multiple strips are individually timed, displaying LED patterns each at their own speed.

**NOTE:**  Splitting the driver task and generator task into their own source files (module_neopixel directory and app_strandtest directory) does make the program memory larger.  This could use some research - perhaps combinable tasks are optimized when they are in the same compilation unit in a way not possible when they are linked together?

###Operation
To decouple creation of pixel color data from the precise serial output timing needed, strip-sized buffers are first filled by generator tasks (strandtest) before then being written out by driver tasks (neopixel module).  Eight copies of the generator task output to 8 copies of the strip driver task to control 8 strips.  The 8 task pairs run concurrently without synchronization on the 8 CPU cores.  Which is pretty cool!

Since this application generates complete frame buffers before displaying them on the LED strips it will run out of memory somewhere.  That "somewhere" is well past 10,000 LEDS total (that didn't get physically tested, just compiled).  An xCore project that can generate and display unbuffered NeoPixel data full-speed on-the-fly is [here.](https://github.com/teachop/xcore_neopixel_leds)

###Task Handling
In order to pair the generator/driver tasks up correctly on the 8 cores of the startKIT CPU, the task functions are marked as "combinable".  [Combinable](https://www.xmos.com/en/published/how-define-and-use-combinable-function?secure=1) is a special XMOS xC attribute that allows multiple tasks to run on a single logical core.  The par statements in main() run the tasks, combining them as needed.

###Task Communication and Driver API
The generator/driver tasks communicate via [interfaces](https://www.xmos.com/en/published/how-communicate-between-tasks-interfaces?secure=1) which define message passing transactions.  It was not required to use tasks to seperate the generation and drawing operations on the same core since they are fundamentally serial operations.  However this approach did provide an interesting and structured way to organize the code.

The particular syntax of this interface was designed to be familiar to users of the [Adafruit NeoPixel Library for Arduino](https://github.com/adafruit/Adafruit_NeoPixel).  Because this driver is in XC using the powerful multi-core XMOS XCore features it is not (and should not be) the same.
