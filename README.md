# VbrArt

<p align ="center" > <img width ="450" height ="280" src = "/readme_images/first.png"> </p>

<p align ="center" > youtube demonstrative video (click on the image below) </p>
<div align="center">
   <a href="https://www.youtube.com/watch?v=pIHimDycQJk" target="_blank"><img src="http://img.youtube.com/vi/pIHimDycQJk/0.jpg" 
                                                                            alt="youtube video" width="240" height="180" border="10" ></img>
   </a>
</div>

[Processing standalone app for Linux](https://drive.google.com/file/d/1GwGIbqAN3qZ7Avxk31g-MEXY-Wsa2J_d/view?usp=sharing)

[Processing standalone app for Windows](https://drive.google.com/file/d/11BVhGNGqTv0VDtXeEzXLKhSFNHP13A8x/view?usp=sharing)


## Introduction

VbrArt is an interactive artistic installation created by David Badiane, Marco Donzelli and Miriam Papagno. It brings together four different worlds all linked to the ondulatory world of acoustics. The aim of this installation is to enhance the curiosity related to Music and its 'physicality' everywhere around us. 

## General structure
The user can choose between four different worlds, each of which represent an acoustic feature. 
Processing, Supercollider and Python frameworks are used to develop this project, they can be thought as blocks performing given tasks that commuincate one another using OSC protocol.
<p align ="center" > <img width ="600" height ="280" src = "/readme_images/blockDiagram.PNG"> </p>
The graphic part and the user interaction (Leap Motion, Arduino Uno, mouse) are managed by <u>Processing<u>; you can find any part of the code related to graphics in the folder 'Processing'. 
   
**Supercollider** handles the music framework of the entire project, you can find it in MusicFrameworkVibrart.scd .
In the last world proposed, Sunset, also <u>Python<u> is used to develop a Markov chain able to generate chord sequences accordingly to a given harmony. 
The **Python** code introduces more intelligence in the musical side of the project, giving it a more natural footprint; you can find the main program main.py and the Data folder in the Python folder.
   
Coming back to Processing code, it consists of one main program plus thirteen classes, which hierarchy is the subsequent:

- Main = **Vibrart**  --> **Calls Scenery.update()**, global objects, timing, high level control of Leap Motion, choice of the background, mouse and keyboards interaction, provides OSC send and receive functions;
- **Scenery** - Handler class --> In its update() function it handles selection and control of four Vibrating Elements (VE) calling also **currentVE.update()** accordingly to a global variable value;
- **(VE)** - 4 Classes (Plate, WaterDrops, VibString, Sunset)  --> In their update() function they control the evolution of their objects, such as **Strings, Cellular Automata, Particles, Attractors, etc.**;
   - Each VE has a die(), create() that allow to optimise runtime memory in switching between backgrounds;
- All Processing code is properly commented and easily readable;
   

## Inside the scene
The four scenerios consist of four different background. 
The design is strictly exploratory, the scenes are designed so that the user becomes curious about them and starts playing with them, leaving a mark into the scene and evolving the artwork in an individual way.
In every background a physic representation of acoustic is depicted: 
* the 1st background simulates the Chladni patterns formation process  on a rectangular plate  - **vibratingPlate**; 
 <p align ="right" > <img width ="270" height ="160" src = "/readme_images/vibratingPlate.png"> </p>
 
* the 2nd background consists in the simulation of a water drop - **vibratingWater**;
 <p align ="right" > <img width ="270" height ="160" src = "/readme_images/vibratingWater.png"> </p>
 
* the 3rd background represents a five strings acoustic instrument - **vibratingStrings**;
  <p align ="right" > <img width ="270" height ="160" src = "/readme_images/vibratingStrings.png"> </p>
  
* the 4th background depicts a sunset and relates its elements to the spectrum of a sound, creating a deeper, thoughtful environment - **vibratingSunset**.
 <p align ="right" > <img width ="270" height ="160" src = "/readme_images/vibratingSunset.png"> </p>
 
The user can play with one background at a time, giving vent to his creativity.
Interaction happens through Leap Motion tracking or MousePositions tracking.

### vibratingPlate
The simulation of Chladni patterns is reality based:
* **Particles system** where eigenmodes configurations are based on toxiclibs attractors and repulsors, notable members are;
   * map of Attractors/repulsors position and force for each eigenMode configuration;
   * eigenfrequencies;
* The user controls the frequency of the sinusoidal signal that stimulates vibrations in the virtual plate;
* The attractive/repulsive forces are inversely proportional to the distance of the control frequency from the plate resonance frequencies;
* The eigenmode configuration is selected based on the distance of the control frequency from the plate resonance frequencies;
* If the distance of the control frequency from the plate resonance frequencies is major than a given threshold, based on the distance between control frequency and adjacent modes, the particles will move randomly;

### vibratingWater
The simulation of water spherical wave propagation is based on:
* A matrix that represents our domain;
* The finite difference equation that governs spherical waves propagation;
* The application of point loads (stimulus);
* A color gradient of watery colors;
* Damping modeling -  piecewise constant damping :
   *  **5% loss if** the matrix cell value is major than a treshold **(Element_i,j >= 3)**, **else 1.3% loss (Element_i,j < 3)** - this enables a more permanent watery texture;
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
* The sun CA is based on a matrix. Rules of life, matrix initial fillage and the color gradient can be variated;
* The sea - a dynamic rectangle based on a color gradient where FFTLines grow;
* FFTLines - lines that depict the sound spectrum at the given instant simulating waves (inspired by Unknown Pleasures - Joy Division);
* The stars - sky objects that sparkle when certain Bins of the sound spectrum are filled;
* The musical background is here more complicated, we have two melodies and chords;
* Both melodies and chords follow a reference mode, accordingly to the sun's rules of life; 

Further informations can be found in the 'Presentation' pdf.

# VbrArt - Controls
## General 
**Switching between backgrounds** :
* Arduino Uno buttons;
* Up and Down arrows of the keyboard;

**Pointer position**:
* Leap Motion;
* Mouse;

**Pointer activation**:
* Leap Motion - distance from Leap Motion less than a given threshold;
* Mouse - mouse clicked;
 
## Background related 
**- vibratingPlate**
1. Arduino Uno - the potentiometer value regulates the frequency of the simulation;
2. the frequency of the simulation can be also variated by pressing the mouse - leftButton increase by 2 - rightButton decrease by 2;

**- vibratingWater**
1. the Leap Motion cursor, when activated, excitates the water;
2. when the mouse is pressed at a given position, it provides a stimulus; 

**- vibratingStrings**
1. Leap Motion cursor:
  * when activated around a string, it plucks it; 
  * it releases the string when deactivated;
2. Mouse:
  * when the mouse left button is pressed near the string, it plucks; 
  * it releases the string when the mouse left button is released;

**- vibratingSunset**
1. Leap Motion cursor:
  * when activated inside the sun, it changes it's modality of the sun's burning and the reference mode for music (**changeMode**); 
  * when deactivated inside the sun, it changes the color map colors and refills the sun matrix (**scrumble**);
2. Mouse: leftButton pressed - **changeMode** //// rightButton pressed - **scrumble**;
3. Keyboard: when left arrow of the keyboard is pressed - **scrumble**;

# VbrArt - Setup and booting

## Arduino Uno setup
**What is needed for the complete setup?**
* Arduino Uno;
* Arduino Breadboard;
* 4 Tact Switches;
* 4 green Leds;
* 1 Potentiometer - 10k linear;
* Resistances - 1 kOhm for switches, 150 Ohm for leds;
* Jumpers;
* The Arduino sketch that you can find in the repository;

With those elements it's possible to build the circuit depicted below:
<p align ="center" > <img width ="500" height ="280" src = "/readme_images/arduino_schematic.png"> </p>

The final implementation should look like this:
<p align ="center" > <img width ="600" height ="280" src = "/readme_images/arduino_real.jpg"> </p>

## Leap Motion setup
Simply connect Leap Motion to your laptop, **place the Leap Motion so that the green Led is pointed towards you**.
If you use the standalone application, all libraries are already included. 
If you run it on processing be sure to install Leap Motion for Processing.

## Boot the project
1. Open on Supercollider **MusicFrameworkVibrart.scd**, boot the server and run the code;
2. Wait until Supercollider has compiled;
3. Run Python script **main.py**, let it run indefinitely;
4. Run Processing code or open the standalone application;
5. Check if OSC messages are correctly functioning from Supercollider post window.

If step 5 is valid, then everything is correctly set for VbrArt. 
If not check the IP port and IP addresses.
Enjoy your play! 



