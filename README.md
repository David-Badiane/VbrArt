# VbrArt

<p align ="center" > <img width ="450" height ="280" src = "/readme_images/first.png"> </p>

## Introduction

VbrArt is an interactive artistic installation created by David Badiane, Marco Donzelli and Miriam Papagno. It brings together four different worlds all linked to the ondulatory world of acoustics. The aim of this installation is to enhance the curiosity related to Music and its 'physicality' everywhere around us. 

## General structure
The user can choose between four different worlds, each of which represent an acoustic feature. 
Processing, Supercollider and Python frameworks are used to develop this project, they can be thought as blocks performing given tasks that commuincate one another using OSC protocol.
<p align ="center" > <img width ="600" height ="280" src = "/readme_images/blockDiagram.PNG"> </p>
The graphic part and the user interaction (Leap Motion, Arduino Uno, mouse) are managed by <u>Processing<u>, you can find any part of the code related to graphics in the folder 'Processing'. 
<u>Supercollider<u> handles the music framework of the entire project, you can find it in MusicFrameworkVibrart.scd .
In the last world proposed, Sunset, also <u>Python<u> is used to develop a Markov chain able to generate chord sequences accordingly to a given harmony. 
The Python code introduces more intelligence in the musical side of the project, giving it a more natural footprint, you can find the main program main.py and the Data folder in the Python folder.

## Inside the scene
The four scenerios consist of four different backgrounds. 
In every background a physic representation of acoustic is depicted: 
* in the first background Chladni pattern simulation on a plate is implemented - <u>vibratingPlate<u>; 
* the second background consists of the simulation of a water drop - <u>vibratingWater<u>;
* the third background represents a five strings acoustic instrument - <u>vibratingStrings<u>;
* the fourth background depicts a sunset and relates its elements to the spectrum of a sound, creating a deeper, thoughtful environment - <u>vibratingSunset<u>.
The user can play with one background at a time, giving vent to his creativity.
Interaction happens through Leap Motion tracking or MousePositions tracking.

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
* 
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


Any further information can be found in the 'Presentation' power point.
Enjoy your play!
