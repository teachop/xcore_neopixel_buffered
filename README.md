##A Buffered Driver for 8 NeoPixel Strips on XMOS startKIT

This test/learning project controls Adafruit NeoPixel strips of fairly arbitrary length with a rolling rainbow pattern.  The multiple strips are individually timed, displaying LED patterns each at their own speed.  (The point is to learn about xCore moreso than make LED patterns).

**NOTE:**  Putting the driver and application (driver task / generator task) into their own source files makes program memory larger.  Need to research - perhaps combinable tasks are optimized when they are in the same compilation unit in a way not possible when they are linked together?

To decouple creation of pixel color data from the precise serial output timing needed, strip-sized buffers are first filled by generator tasks before then being written out by driver tasks.  Eight copies of the generator task output to 8 copies of the strip driver task to control 8 strips.  The 8 task pairs run concurrently without synchronization on the 8 CPU cores.  Which is pretty cool.

In order to pair the generator/driver tasks up correctly on the 8 cores of the startKIT CPU, the task functions are marked as "combinable".  [Combinable](https://www.xmos.com/en/published/how-define-and-use-combinable-function?secure=1) is a special XMOS xC attribute that allows multiple tasks to run on a single logical core.  The par statements in main() run the tasks, combining them as needed.

Since this application generates complete frame buffers before displaying them on the LED strips it will run out of memory somewhere.  That "somewhere" is well past 10,000 LEDS total (that didn't get physically tested, just compiled).  An xCore project that can generate and display unbuffered NeoPixel data full-speed on-the-fly is [here.](https://github.com/teachop/xcore_neopixel_leds)

The generator/driver tasks communicate via [interfaces](https://www.xmos.com/en/published/how-communicate-between-tasks-interfaces?secure=1) which define message passing transactions.  It was not required to use tasks to seperate the generation and drawing operations on the same core since they are fundamentally serial operations.  However this approach did provide an interesting and structured way to organize the code.

The particular syntax of this interface was designed to be similar to the Adafruit NeoPixel Library for Arduino.  More development work will be going in this direction next...

One last point - there is (for fun) use in the generator task of a multiple return function. This feature in xC provides for multiple return values as an alternative to single return or return by reference (which xC also supports).
