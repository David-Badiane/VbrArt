# VbrArt

<p align ="center" > <img width ="450" height ="280" src = "/readme_images/first.png"> </p>

## Introduction

VbrArt is an interactive artistic installation created by David Badiane, Marco Donzelli and Miriam Papagno. It brings together four different worlds all linked to the ondulatory world of acoustics. The aim of this installation is to enhance the curiosity related to Music and its 'physicality' everywhere around us. 

## General structure
The user can choose between four different worlds, each of which represent an acoustic feature. 
Processing, Supercollider and Python frameworks are used to develop this project, they can be thought as blocks performing given tasks that commuincate one another using OSC protocol.
<p align ="center" > <img width ="600" height ="280" src = "/readme_images/blockDiagram.PNG"> </p>
The graphic part and the user interaction (Leap Motion, Arduino Uno, mouse) are managed by <u>Processing<u>; you can find any part of the code related to graphics in the folder 'Processing'. 
<u>Supercollider<u> handles the music framework of the entire project, you can find it in MusicFrameworkVibrart.scd .
In the last world proposed, Sunset, also <u>Python<u> is used to develop a Markov chain able to generate chord sequences accordingly to a given harmony. 
The Python code introduces more intelligence in the musical side of the project, giving it a more natural footprint; you can find the main program main.py and the Data folder in the Python folder.

## Inside the scene
The four scenerios consist of four different backgrounds. 
The design is strictly exploratory, the scenes are designed so that the user becomes curious about them and starts playing with them, leaving a mark into the scene and evolving the artwork in an individual way.
In every background a physic representation of acoustic is depicted: 
* the 1st background simulates the Chladni patterns formation process  on a rectangular plate  - **vibratingPlate**; 
 <p align ="right" > <img width ="270" height ="160" src = "/readme_images/vibratingPlate.png"> </p>
 
* the 2nd background consists of the simulation of a water drop - **vibratingWater**;
 <p align ="right" > <img width ="270" height ="160" src = "/readme_images/vibratingWater.png"> </p>
 
* the 3rd background represents a five strings acoustic instrument - **vibratingStrings**;
  <p align ="right" > <img width ="270" height ="160" src = "/readme_images/vibratingStrings.png"> </p>
  
* the 4th background depicts a sunset and relates its elements to the spectrum of a sound, creating a deeper, thoughtful environment - **vibratingSunset**.
 <p align ="right" > <img width ="270" height ="160" src = "/readme_images/vibratingSunset.png"> </p>
 
The user can play with one background at a time, giving vent to his creativity.
Interaction happens through Leap Motion tracking or MousePositions tracking.

### vibratingPlate
The simulation of chladni patterns is reality based:
* Particles system where eigenmodes configurations are based on toxiclibs attractors and repulsors;
* The user controls the frequency of the sinusoidal signal that stimulates vibrations in the virtual plate;
* The attractive/repulsive forces are inversey proportional to the distance of the control frequency from the plate resonance frequencies;
* The eigenmode configuration is selected based on the distance of the control frequency from the plate resonance frequencies;
* If the distance of the control frequency from the plate resonance frequencies is major than a given threshold, based on the distance between subsequent modes, the particles will move randomly;

### vibratingWater
The simulation of water spherical wave propagation is based on:
* A matrix that represents our domain;
* The finite difference equation that governs spherical waves propagation;
* The application of point loads (stimulus);
* A color gradient of watery colors;
* Damping modeling - in order to recreate water texture we set the damping of the wave propagation to be way less if the energy in the given cell is less than a given threshold, this will make the wave fade away more slowly and create a watery texture;
* The musical background, which is in turn based on granular synthesis;
* The correspondance between application of the stimulus and a sound signal from an scl Synth;

### vibratingStrings
The simulation of string vibration is more musical, its characteristics are:
* Strings simulated by the connection of verletSprings characterised by high tension at the extrema;
* String plucking mechanism simulation;
* Particles generation when the string is plucked;
* Musical background based on an autogenerative melody in Lydian scale;
* String plucking triggers a tuned string sound, the tonality of the melodic line is changed accordingly to the particular string note; 
 
### vibratingSunset
This scene is more like a picture that wants to make the user think and enjoy a digital dynamic painting characterised by:
* The sun - a 2D cycle Cellular Automata (CA) based on five rules of life, set on a fire-like color gradient;
* The sun CA is based on a matrix, rules of life, matrix initial fillage and the color gradient can be variated;
* The sea - a dynamic rectangle based on a color gradient where FFTLines grow;
* FFTLines - lines that depict the sound spectrum at the given instant simulating waves (inspired by Unknown Pleasures - Joy Division);
* The stars - sky objects that sparkle when certain Bins of the sound spectrum are filled;
* The musical background is here more complicated, we have two melodies and chords;
* Both melodies and chords follow a reference mode, accordingly to the sun's rules of life; 

## General Controls
**Switching between backgrounds** :
* Arduino Uno buttons;
* Up and Down arrows of the keyboard;

**Pointer position**:
* Leap Motion;
* Mouse;

**Pointer activation**:
* Leap Motion - distance from Leap Motion less than a given threshold;
* Mouse - mouse clicked;
 
## Background related Controls:
**vibratingPlate**:
1. Arduino Uno - the potentiometer value regulates the frequency of the simulation;
2. the frequency of the simulation can be also variated by pressing the mouse;

**vibratingWater**:
1. the Leap Motion cursor, when activated, excitates the water;
2. when the mouse is pressed at a given position, it provides a stimulus; 

**vibratingStrings**:
1. Leap Motion cursor:
  * when activated around a string, it plucks it; 
  * it releases the string when deactivated;
2. Mouse:
  * when the mouse left button is pressed near the string, it plucks; 
  * it releases the string when the mouse left button is released;

**vibratingSunset**:
1. Leap Motion cursor:
  * when activated inside the sun, it changes it's modality of the sun's burning and the reference mode for music (**changeMode**); 
  * when deactivated inside the sun, it changes the color map colors and refills the sun matrix (**scrumble**);
2. Mouse: when the mouse left button is pressed - **changeMode**;
3. Keyboard: when left arrow of the keyboard is pressed - **scrumble**;

## Arduino Uno setup
**What is needed for the complete setup?**
* Arduino Uno;
* Arduino Breadboard;
* 4 Button Switches;
* 4 Leds;
* 1 Potentiometer;
* Resistances;
* Jumpers;
* The Arduino sketch that you can find in the repository;

With those elements it's possible to build the circuit depicted below:

The final implementation should look like this:
<p align ="center" > <img width ="600" height ="280" src = "/readme_images/arduino_real.jpg"> </p>

## Booting the Project

Further informations can be found in the 'Presentation' pdf.
Enjoy your play!
