

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

![UI Image](pictures/UI.png)

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

### No Correction: 
As the name suggested, no correction would apply. This is not recommended. 

### Fano Resonance: FANO or FANOMZI
This type of resonance is the result of two coupled oscillators. For a detailed math, I recommend this paper: 

    Fano resonances in a multimode waveguide coupled to a high-Q silicon nitride ring resonator Dapeng Ding, Michiel J. A. de Dood, Jared F. Bauters, Martijn J. R. Heck, John E. Bowers, and Dirk Bouwmeester 
    https://opg.optica.org/oe/fulltext.cfm?uri=oe-22-6-6778&id=281922  

For an understanding at a storyteller level, I recommend my story. 

In the common Lorentzian case, we can think of it as a single oscillator and your driving frequency matches the oscillator's natural frequency, which will result in a Lorentzian dip. This dip is symmetric around the resonance. 

In the fano resonance case, we can think of it as two coupled driven harmonic oscillators and your pump laser is the driving field.

![Fano Image](pictures/fano.png)

Above is the plot of x1(w), a diagram of the setting for the coupled oscillators, and a system of differential equations solving this classical problem. For a 2 by 2 matrix, there are two eigenmodes, shown as two peaks on the plot of x1(t). The shaded green peak is anti-symmetric around the resonance. We call this shape fano resonance. 

On the oscilloscope, I have experimentally observed this shape(If you see this shape, please use FANO or FANOMZI. I recommend FANOMZI.):

![Fano Image](pictures/fano_osc.png)

In the context of a ring resonator, there is a tapered fiber delivering energy, and a ring resonator receives and sends back the energy. Light, when confined in a tapered fiber, could have many eigenmodes, and this is a continuous basis. Light, when confined in a ring resonator, could have many discrete eigenmodes, and this is a discrete basis. These two types of vector spaces or the modes that exists in these two types of vector space could interfere with each other and result in the fano resonance shape, whose resonance mathematical structure is similar to a classical system of driven harmonic resonators.

** Below is my fantasy and this might be incorrect **

Fano resonance can be understood as a finite representations coupled to an infinite representations. In the finite representation of the Lorentz group, it is always attached to space-time, which is considered as an infinite vector space. When there is a spacetime transformation \( \Lambda \) on space time, it would modify the field\( \Phi \) in two ways: 1. The field itself \( \Phi \) by \(  U(\Lambda) \) 2. The space time by \( \Lambda x \). 


## Mode Splitting
Mode splitting results from the interference of clockwise and counter clockerwise interference of the light in the ring resonator. The back scattering will cause the light to reflect its direction inside the ring resonator, which could result in an opposite light propagate in the ring. When there is defect in the ring, this will result in back scattering and result in the mode splitting. 

A picture of mode splitting(theoretical plot) is below: 

![Fano Image](pictures/split.png)

## Cutoff frequency 
is the cutoff frequency used in 'osc' and  'oscmzi'. Sine components with less than cutoff_freq periods will be  removed. If not specified the code attempts to find a frequency by  analyzing the Q trace.
