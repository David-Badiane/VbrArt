# VbrArt

<p align ="center" > <img width ="450" height ="280" src = "/readme_images/first.png"> </p>

## Introduction

VbrArt is an interactive artistic installation created by David Badiane, Marco Donzelli and Miriam Papagno. It brings together four different worlds all linked to the ondulatory world of acoustics. The aim of this installation is to enhance the curiosity related to Music and its 'physicality' everywhere around us. 
The user can explore and enjot each world proposed.

## General structure
As said before, the user can choose between four different worlds, each of which represent an acoustic feature. 
Processing, Supercollider and Python frameworks are used to develop this project, they can be thought as blocks performing given tasks that commuincate one another using OSC protocol.
The graphic part and the user interaction (Leap Motion, Arduino 1, mouse) is managed by Processing, you can find any part of the code related to graphics in the folder 'Processing'. 
Supercollider handles the music framework of the entire project, you can find it in MusicFrameworkVibrart.scd.
In the last world proposed, Sunset, also Python is used in order to develop Markov chain able to generate chords sequences accordingly to a given harmony, introducing more intelligence in the musical side of the project, giving it a more natural footprint.


## Inside the scene
The four scenerios consist of four different backgrounds to choose through the electric circuit that models the arduino setup. If an Arduino 1 is not available, the choice ca be made through computer keyboard. In every background a physic representation of acoustic is depicted: in the first background clahdni pattern simulation on a plate is implemented; the second background consists of the simulation of a water drop; the third background represents an acoustic string instrument and the fourth background is related to the FFT of a sound, an important feature of the sound signal.
The user can play with one background at a time, giving vent to his creativity.
Interaction happens through Leap Motion tracking or MousePositions tracking.

Any further information can be found in the 'Presentation' power point.

Enjoy your play!
