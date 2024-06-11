# Header 1
## Header 2
### Header 3
#### Header 4
##### Header 5
###### Header 6
---

*This text will be italic*
_This will also be italic_

**This text will be bold**
__This will also be bold__

_You **can** combine them_
---


# Q Measurement
This code contains two files: 

    1. Cao.m: This file defines the method to fit the data and do the fitting
    
    2. Q_Measurement.mlapp: This file defines the UI interface, will call Cao.m to do computation, and it is responsible for the connection to the oscilloscope to acquire data for fitting.
---
To use it, simply double click the Q_Measurement.mlapp, and make sure **Cao.m and Q_Measurement.mlapp are under the same folder!!!**

---
I am using DSOX1204G oscilloscope. If you are using a different type of oscilloscope, you must adapt the code in Q_Measurement.mlapp, to make sure that you can provide two arrays: 
1. array for mzi
2. array for trans

---

![UI Image](pictures\UI.png)

Above is the UI interface. I will explain how to use it step by step. 

## Step 0: Specify output folder
You need to enter a main address, which is the long horizontal line above. Sub1 and Sub2 are up user define. Overall, they will create: **\Main Path\sub1\sub2**

where sub1 and sub2 are two folders. 

If you leave them blank, then it would skip it. e.g. sub1 = blank, sub2 =A

**\Main Path\A**

You could also leave all of them blank, but you must enter a path for the main path. 

The data of the measurement will be automatically saved as: 

1. A single plot containing the Lorentzian fit and Q value for the highest Q at **\Main Path\A**. the plot name will dynamically change according to the MZI freq, and the Q measured.
2. One plot with Q for all peaks detected and one plot with Q-statistics at **\Main Path\A\B**
3. Regardless of your choice of A and B, a folder called "data_mzi" containing all of the raw oscilloscope data and numerical fitting result in .matlabdata form will be created at **\Main Path\A\B\data_mzi**

## Step 1: Choose the Channel

For the quality of Q measurement, please always use **CH2 for transmission(Trans)**, **CH3 for MZI**, and disable other channels! Because for DSOX1204G: 

**"Half-channel operation on a 4-channel model refers to two-channel operation when using channel-1 or channel-2 AND channel-3 or channel-4. Example: If viewing just channel-1 and channel-3, maximum sample rate is 2 GSa/s and maximum memory is 2 M points. But if viewing channel-1 and channel-2, maximum sample rate is 1 GSa/s and maximum memory is 1 M points."**

## Step 1.5: FFT

This is optional. You could use it to filter your data if your oscilloscope is too garbage or the measured signal is too garbage. 

## Step 2: Enter the FSR of your MZI

As the name suggested, enter the FSR of your MZI

## Step 3: Enter the wavelength of your laser

## Step 4: Threshold

This is used to filtered some peaks. Peaks does not meet the threshold value will not be considered for fitting. 0.95 means that if the transmission of the peak is less than (1-0.95) then it will be discarded for fitting. 

To include more shallower peak, increae the threshold from 0.95 to 0.98 would greatly increase the number of peak considered. 

## Step 5 Correction Type 

### No correction: 
    As the name suggested, no correction would apply. This is not recommended. 
### fano resonance correction: FANO or FANOMZI
This type of resonance is the result of two coupled oscillator. In the common Lorentzian case, we can think of it as a single oscillator and your driving frequency matches the oscillator natrual frequency. 
![Fano Image](pictures\fano.png)

Fano resonance happens as there are two modes coupling to each other. The plot above shows you the solution and also if you plot x1 v.s. w, thats what you got. The shape in green is called the fano resonance. On the oscilloscope, in the context of ring resonator, it look likes: 
![Fano Image](pictures\fano_osc.png)

If you see this shape, please use FANO or FANOMZI. I recommend FANOMZI.

### MZI

This correction is the most general one. Since we are using MZI as the frequency ruler, always use MZI as the correction. Only when you see a fano shape, you should switch to it. 

## Cutoff frequency 
is the cutoff frequency used in 'osc' and  'oscmzi'. Sine components with less than cutoff_freq periods will be  removed. If not specified the code attempts to find a frequency by  analyzing the Q trace.