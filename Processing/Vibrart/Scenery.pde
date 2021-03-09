class Scenery{
// MEMBERS
int BUTTONSTATE;
boolean doOnce = false;
boolean doOnceLeap = false;

Plate vibratingPlate;
WaterDrops vibratingWater;
Sunset vibratingSunset; 
VibString vibratingStrings;

// CONSTRUCTOR - we start with the plate
Scenery(){
this.BUTTONSTATE = 0;
vibratingPlate = new Plate();
vibratingWater = new WaterDrops();
vibratingStrings = new VibString();
vibratingSunset = new Sunset();
vibratingWater.die();                 // die() functions deallocate all the possible objects from each VE
vibratingStrings.die();
vibratingSunset.die();
}

void buttonPressed(int value){
    if(BUTTONSTATE == 0) {vibratingPlate.die();}
    if(BUTTONSTATE == 1) {vibratingWater.die();}
    if(BUTTONSTATE == 2) {vibratingStrings.die();}
    if(BUTTONSTATE == 3) {vibratingSunset.die();}

    
  this.BUTTONSTATE = value;
  
    if(BUTTONSTATE == 0) {vibratingPlate.create();}        // ceate() functions reallocate the objects for each VE
    if(BUTTONSTATE == 1) {vibratingWater.create();}
    if(BUTTONSTATE == 2) {vibratingStrings.create();}
    if(BUTTONSTATE == 3) {vibratingSunset.create();}

}

void update(){
  updateAndDisplayLeap();    // here we take care of Leap Motion
  
  switch(BUTTONSTATE){       // in ths switch we update each VE (Vibrating Element) 
  
    // ------------------------- vibratingPlate 
    case 0 :
      plateUpdate();
    break;
    
    // ------------------------- vibratingWater
    case 1:
       waterUpdate();
    break;
    
    // ------------------------- vibratingStrings
    case 2: 
      vibratingStrings.update();
    break;
    
    // ------------------------- vibratingSunset
    case 3: 
      vibratingSunset.update(); 
      break;
    }
  }
  
  void sceneryCtrl(PVector pos, boolean state){
    switch(BUTTONSTATE){
      case 0:
      break;
      
      // ----------------------------------------------------------------------- VIBRATING-WATER
      
      case 1:
      if(millis() >= fastT.count*fastT.T){// ----------------------------------- apply stimulus with leap
          if(state) {
            Vec2D stimPos = new Vec2D(constrain(pos.x,1,width-1) , constrain(pos.y,1,height-1));
            float stimAmp = constrain(pos.z-leapThreshold, 0, 10000);
            vibratingWater.stimulus(stimPos, stimAmp);
            vibratingWater.send(1, pos.x, pos.y);
           
            fastT.updateCounter();
            doOnce = false;
          }
          
          else{
            if(!doOnce){
            vibratingWater.send(0, pos.x, pos.y);
            doOnce = true;
            }
          }
           
        }
  
      break;
      
      // ----------------------------------------------------------------------- VIBRATING-STRINGS
      
      case 2:
      for (int i = vibratingStrings.strings.size()-1; i>=0; i--){ // ----------- cycle along the trings of the VE
        Strings s = vibratingStrings.strings.get(i);
        if(state) { // --------------------------------------------------------- If the leap Motion is set to Active, pluck Once
          if (!doOnceLeap){
            boolean isPlucked = s.pluckLeap(new Vec2D (pos.x, pos.y)); // ------ Checks if a particle of the string is selected Vec2D pos and locks it
            if(isPlucked) {vibratingStrings.send(abs(i-4));             // ------ if plucked send OSC message to SC
            doOnceLeap = true;
              }
            }
          if (s.selectedParticle!=null) {
            s.selectedParticle.set(pos.x,pos.y); // ---------------------------- if there is a selected particle, set it to pos
        }
        }
        else {      // --------------------------------------------------------- If the leap Motion is set to Active, free variables 
           if (s.selectedParticle!=null){        // ----------------------------
              s.selectedParticle.unlock();
              s.selectedParticle=null;
              doOnceLeap = false;
           }
        }
      }   
      break;
      // SUNSET
      case 3:
        Vec2D loc = new Vec2D(pos.x,pos.y);
          if(loc.isInCircle(vibratingSunset.suns.get(0).center, vibratingSunset.suns.get(0).radius*0.992) == true){
            if(loc.isInRectangle(vibratingSunset.suns.get(0).r) == true){
              if(state && doOnceLeap == false) {
                vibratingSunset.suns.get(0).mode = (vibratingSunset.suns.get(0).mode+1)%5;
                vibratingSunset.send();
                doOnce = true;
              }
              if(!state && doOnceLeap == false){
                vibratingSunset.suns.get(0).mapwidth = ( vibratingSunset.suns.get(0).mapwidth+1)%100;
                vibratingSunset.suns.get(0).scrumble((int) random( vibratingSunset.suns.get(0).mapwidth/2));    
              }
            }
            else {doOnceLeap = false;}
          }
      break;
    } 
  }
  
  // since the routines of the vibratingPlate and vibratingWater are more complicated,
  // they are written as functions
  
  void plateUpdate(){
    if (mousePressed == true && doOnce == false)   {
         if (mouseButton == LEFT) vibratingPlate.nextFreq(2);
         if (mouseButton == RIGHT) vibratingPlate.nextFreq(-2);
         doOnce = true;
         vibratingPlate.send();
        }
    
    if (arduinoUno.isConnected() == true){
        if(vibratingPlate.freq != floor(arduinoUno.retrieve()[1]*500./1024.)+20) {
          vibratingPlate.freq = floor(arduinoUno.retrieve()[1]*500./1024.)+20;
          vibratingPlate.send();
        }
      }
    if(mousePressed == false) {doOnce = false;};
    vibratingPlate.update();
  }
  
  void waterUpdate(){
    if(millis() >= fastT.count*fastT.T){
        // mouse Control
        if(mousePressed == true) {
          if(doOnce == false ){
          vibratingWater.stimulus(new Vec2D(mouseX, mouseY), 1000);  
          doOnce = true;
          }
          if(!leapConnected){
          vibratingWater.send(1, mouseX, mouseY);
          }
          
        }
        if(mousePressed == false) {
        if(!leapConnected){
          vibratingWater.send(0, mouseX, mouseY);
          }
          doOnce = false;
        }
         fastT.updateCounter();         
      }
      vibratingWater.propagate();
  }
}
