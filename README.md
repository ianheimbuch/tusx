![TUSX Logo](assets/tusxLogo.png)

# TUSX

A toolbox for acoustic simulations of transcranial ultrasound

TUSX (Transcranial Ultrasound Simulation Toolbox) is an open-source MATLAB toolbox to perform acoustic simulations using subject-specific medical images for transcranial ultrasound experiments. TUSX consists of an integrated processing pipeline that takes in structural MRI (magnetic resonance) or CT (computed tomography) head images, processes them for accurate simulation, and runs the simulations using [k-Wave](http://k-wave.org), an existing open-source acoustics toolbox for MATLAB and C++.

- **Who will use TUSX?**
  - Presumably researchers peforming transcranial ultrasound experiments. TUSX was written specifically with transcranial ultrasound stimulation (TUS) researchers in mind (i.e. those who use ultrasound as a non-invasive brain stimulation technique). However, TUSX should be useful for anyone who want to simulate the propagation of ultrasonic waves through the skull and brain.
- **What is the goal of TUSX?**
  - To make performing accurate accoustic simulations of transcranial ultrasound easier.

## k-Wave
[**k-Wave**](http://k-wave.org) is a powerful open-source toolbox to perform computationally efficient acoustic simulations in MATLAB and C++ developed by Bradley Treeby and Ben Cox (University College London) and Jiri Jaros (Brno University of Technology). TUSX uses k-Wave to run accoustic simulations, so one must install k-Wave and add it to the MATLAB search path to use TUSX. k-Wave can be downloaded for free on their [website](http://k-wave.org). **Please cite k-Wave** if you perform acoustic simulations with the help of TUSX.

## Miscellaneous
- **How do you pronounce TUSX?**
  - I pronounce TUSX as "tusks" (note the elephant motif in the 'T' of the TUSX logo). But whatever works for you.

## Citing TUSX
If you use TUSX, please cite both TUSX and k-Wave:
### TUSX
* Ian S Heimbuch, Guido C Faas, Marco Iacoboni, Andrew C Charles, "TUSX: an accessible toolbox for transcranial ultrasound simulation," bioRxiv 2021.06.03.446963; doi: https://doi.org/10.1101/2021.06.03.446963
### k-Wave
* B. E. Treeby and B. T. Cox, "k-Wave: MATLAB toolbox for the simulation and reconstruction of photoacoustic wave-fields," J. Biomed. Opt., vol. 15, no. 2, p. 021314, 2010.
* *(Additional k-Wave citation details available on the [k-Wave website](http://www.k-wave.org/license.php)*)

## Credits
TUSX was created by Ian Heimbuch (@ianheimbuch) at the University of California, Los Angeles