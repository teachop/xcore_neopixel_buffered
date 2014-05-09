####Notes Pondering Calculation of Total Strip Current

Total milliamps will be the sum of all individual LED currents, 3 per pixel.  A full on LED is Xf milliamps.  The color data (PWM factor) for each LED is assumed to cause current to scale in a linear way, resulting in pwm * Xf milliamps.

It has been observed in testing that the 3 colors all draw the same Xf full on milliamp value.  For example with 5V applied to an Adafruit 60 pixel 1 meter strip, full on all-red all-green all-blue were found to have equal total miliamp values of 1.07 A.

Although the LEDs regulate current, voltage droop does change the actual value.  This may explain why full on all white current for the 60 pixel strip is considerably lower than the expected 3 * 1.07 value.

####Measurements

If the actual strip current value is low due to distributed resistance, it will be possible to adjust the calculation for this effect.  Collect the following data to determine what is happening:

- With 5.0V applied, confirm the actual Xf value.
- Vary the PWM setting and tabulate current to determine if this is linear.
- Vary voltage on the LED to determine if the actual current is a function of droop, and if so what the relationship is (LED current as a function of voltage).
- With 5.0V applied, measure voltage droop at the strip end for various current settings.

Each LED will have a source voltage equal to the previous LED voltage, applied through a source resistance Rs, a function of the strip construction.
```
LED_voltage[n] = LED_voltage[n-1] - Rs * Xdownstream;
// or
LED_voltage[n-1] = LED_voltage[n] + Rs * Xdownstream;
```
The downstream current is the sum of the LED current and all the rest on down the strip.

To be continued...

