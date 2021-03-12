// MAIN PROGRAM OF THE PROJECT

import toxi.geom.*;
import toxi.physics2d.*;
import oscP5.*;
import netP5.*;
import de.voidplus.leapmotion.*;

// --------------------------------------------- GENERAL -----------------------------------------------------------

int slowTau = 1000;           // set timers values and declare them
int midTau=500;
int fastTau=100;
boolean doOnce = false;
SimpleTimer slowT;
SimpleTimer midT;
SimpleTimer fastT;

VerletPhysics2D physics;     // declare the physics environment where our project takes place

// ------------------------------------------- Intro Screen --------------------------------------------------------

PFont font;
PFont font2;
ArrayList <WaterDrops> introTexture;
int introTime = 12500;

// ------------------------------------------- Leap Motion --------------------------------------------------------

LeapMotion leap;             // declare leapMotion and set threshold to enable click
float leapThreshold = 25;
boolean leapConnected = false;

// --------------------------------------------  Arduino  ---------------------------------------------------------

Arduino arduinoUno;         // declare Arduino
int scene = 4;

// --------------------------------------------    OSC    ---------------------------------------------------------

OscP5 oscP5;                      // declare OSCP5 sender, OSCP5 receiver
OscP5 oscR;
NetAddress ip_port;
NetAddress pyPort;                // NetAddress, set IP port number
int PORT = 57120;
int nBin = 512;                   // n° Bins of the spectrum
float[] spec = new float[nBin];   // spectrum, save Supercollider audio out FFT on Processing

// --------------------------------------------   SCENE    --------------------------------------------------------

Scenery scenario;       // this is the superClass of each Vibrating Element (VE) represented              


void setup(){  
  // ----------------------------------------------- TIMERS
  slowT = new SimpleTimer(slowTau);
  midT = new SimpleTimer(midTau);
  fastT= new SimpleTimer(fastTau);
  // ----------------------------------------------- PHYSICS
  physics = new VerletPhysics2D();
  physics.setWorldBounds(new Rect(0,0,width,height));
  
  // ----------------------------------------------- LEAP MOTION
  leap = new LeapMotion(this);
  
  // ----------------------------------------------- ARDUINO
   arduinoUno = new Arduino(this);
   
  // ----------------------------------------------- OSC
  oscP5 = new OscP5(this,12000);                    //  OSC SENDER
  ip_port = new NetAddress("127.0.0.1",PORT);
  pyPort = new NetAddress("127.0.0.1",57121);
  OscProperties properties= new OscProperties();    // OSC RECEIVER
  properties.setListeningPort(47120);               
  properties.setDatagramSize(5136);                 //5136 is the minimum 
  oscR = new OscP5(this, properties);
  for (int i= 0; i<nBin; i++)       {spec[i]= 0.0;} 
  
  //----------------------------------------------- SCENARIO - VibratingElement superclass
  font = createFont("Potra.ttf", 32);
  font2 = createFont("Potra.ttf", 14);
  textFont(font);
  introTexture = new ArrayList <WaterDrops>();
  introTexture.add(new WaterDrops(0.99));
  scenario = new Scenery();  
  size(720, 450);                    // size of our window
}

void draw(){
  // ----------------------------------- INTRO ------------------------------------------------
  if(!doOnce){
    Object [] args = {};
    OSCsendMessage("/Background/Init", args);
    doOnce = true;
  }
  
  if(millis() == introTime + 10000){
    introTexture.remove(0);
  }
  
  if(millis() < introTime){
    introTexture.get(0).propagate();
    fill(255);
    textAlign(CENTER, CENTER);
    text("VbrArt", width/2,height/2);
  }
  if(millis() > introTime && millis() < introTime + 5000){
    fill(0,0,0,20);
    rect(0,0,width,height);
  }
  if(millis() > introTime + 5000){
    // Set the Vibrating Element accordingly to the button pressed 
    if (arduinoUno.isConnected() == true){
      if(scene != arduinoUno.retrieve()[0]){
        scene = arduinoUno.retrieve()[0];
        scenario.buttonPressed(scene);
      }
    }
    
    // ----------------------------------- DRAW UPDATE --------------------------------------------
    if(scene > 3){
      scenario.buttonPressed(0); 
      scene =0;
    }
    // Update the scenario
    scenario.update();
    // update Leap Motion
    updateAndDisplayLeap(); 
    // update Mouse
    updateAndDisplayMouse();
  }
}

void keyPressed(){
  // KeyBoard controls - CHANGE SCENARIO WITH THE UP/DOWN ARROWS KEYS
  if(keyCode == UP){
    int value = (scenario.BUTTONSTATE +1)%4;
    scenario.buttonPressed(value);
  }
  if(keyCode == DOWN){
    if(scenario.BUTTONSTATE!=0){
      int value = (scenario.BUTTONSTATE -1)%4;
      scenario.buttonPressed(value);
    }
    else scenario.buttonPressed(3);
  }
  
  // change sun fillage with left arrow
  if ( scenario.BUTTONSTATE == 3 ){
        if(keyCode == LEFT){
           scenario.vibratingSunset.refillAndChangeColors();
      }
    }
}

// Mouse handling for various Scenarios
void mousePressed() {
  // set string plucking
  if ( scenario.BUTTONSTATE == 2){
    ArrayList<Strings> strings = scenario.vibratingStrings.strings;
    for (Strings s : strings){
      s.pluck(new Vec2D (mouseX, mouseY));
    }
  }
  // set sun mode change and sun fillage change
  if(scenario.BUTTONSTATE == 3){
    if(mouseButton == LEFT){
      CA sun = scenario.vibratingSunset.suns.get(0);
      scenario.vibratingSunset.suns.get(0).mode = (sun.mode+1)%5;
      scenario.vibratingSunset.nextMode();
      scenario.vibratingSunset.send();
      }
    if(mouseButton == RIGHT){
        scenario.vibratingSunset.refillAndChangeColors();
      }
    }
}

void mouseDragged() {
  // set the position of the plucked string particle to mouse position
  if ( scenario.BUTTONSTATE == 2){
    ArrayList<Strings> strings = scenario.vibratingStrings.strings;
    for (Strings s : strings){
      if (s.selectedParticle!=null) {
      // move selected particle to new mouse pos
        s.selectedParticle.set(mouseX,mouseY);
      }
    }
  } 
  // set mouse dragging continuous stimulus to water
  else if ( scenario.BUTTONSTATE == 1){
     float c3 = 500;
     if( mouseX > 0 && mouseX <width && mouseY > 0 && mouseY < height) 
     {scenario.vibratingWater.current.get(0)[mouseX][mouseY] = c3;}
  }
}

void mouseReleased() {
  // unlock the plucked particle if mouse is released
  if ( scenario.BUTTONSTATE == 2){
    ArrayList<Strings> strings = scenario.vibratingStrings.strings;
    for (Strings s : strings){
      if (s.selectedParticle!=null) {
          s.selectedParticle.unlock();
          s.selectedParticle=null;
      }
    }
  }
}


// Leap Motion handling function
void updateAndDisplayLeap(){
   if(scenario.BUTTONSTATE!=0 && leap.getHands().size() >0){
      ArrayList <Hand> hands = leap.getHands ();
      boolean state;
      for (int i = 0; i < hands.size(); i++ ) {
        PVector handStabilized = hands.get(i).getStabilizedPosition();
        if(handStabilized.z > leapThreshold){
          fill(0,255,0,100);
          state = true; 
        }
        else{
          fill(255,0,0,100);
          state = false;
        }
        scenario.sceneryCtrl(handStabilized,state);
        ellipse(handStabilized.x, handStabilized.y, 10,10);
      }
    }
  }
// check if LM is connected  
void leapOnConnect() {
  leapConnected = true;
}
// mouse handling function
void updateAndDisplayMouse(){
 if(scenario.BUTTONSTATE!=0){
    //boolean state;
    PVector loc = new PVector(mouseX, mouseY);
      if(mousePressed && loc.x >10 && loc.x< width-10 && loc.y >10 && loc.y < height-10){
        fill(0,255,0,100);
        //state = true; 
      }
      else{
        fill(255,0,0,100);
        //state = false;
      }
      ellipse(loc.x, loc.y, 5,5);
      if(scenario.BUTTONSTATE == 3){
        fill(255,255,255,100);
        textFont(font2);
        text(scenario.vibratingSunset.modesNames[scenario.vibratingSunset.modSelect], 14*width/15,height/20);
      }
    }
   else{
     textFont(font2);
     text(str(scenario.vibratingPlate.freq), 12*width/13,height/13);
     }
  }

// OSC functions    
// Sender - will be not called in the main, mostly called in each vibrating object send function
void OSCsendMessage(String address, Object [] args ){
  OscMessage msg = new OscMessage(address); 
  msg.setArguments(args);
  oscP5.send(msg, ip_port);
  //msg.print();
}
// Receiver - FFT
void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/fftArray")) {
    for (int i= 0; i<nBin; i++) {
      spec[i]= msg.get(i).floatValue();
    }
  }
}
// Sender to Python
void pyOSCsendMessage(String address, Object [] args ){
  OscMessage msg = new OscMessage(address); 
  msg.setArguments(args);
  oscP5.send(msg, pyPort);
  msg.print();
}
