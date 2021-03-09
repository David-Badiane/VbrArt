import processing.serial.*;

// Class
class Arduino {

  // Serial connection
  Serial myPort;
  int serialPort;
  int baudrate=9600;
  int[] sensors = new int[2];

  // Constructor
  Arduino(PApplet Parent) {
  for(int i = 0; i < Serial.list().length; i++){
  if(Serial.list()[i].equals("/dev/cu.usbmodem14201")){
    serialPort = i;
     myPort= new Serial(Parent,Serial.list()[serialPort],baudrate);
    }
  }
    
  //println(Serial.list()[serialPort]);
  //  // Open Serial line
  }
  
  int[] retrieve() {
    while (myPort.available() > 0) {
    String val = myPort.readStringUntil('\n');
    if (val != null) {
      int vals[] = int(trim(split(val, ' ')));
      
        if(vals[0] != sensors[0]){
        sensors[0] = vals[0];
        }
        
        else if(vals[1] != sensors[1]){
        sensors[1] = vals[1];
        }
    }
    return sensors;
  }
  return sensors;
  }
  
  boolean isConnected(){    
    if(Serial.list()[serialPort].equals("/dev/cu.usbmodem14201")){return true;} 
    else{return false;}
  }
  
  
}
