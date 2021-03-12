// constants won't change. They're used here to set pin numbers:
const int buttLedNumber = 4;
const int buttonPin[buttLedNumber] = {2, 3, 4, 5}; // the number of the pushbutton pin
const int ledPin[buttLedNumber] = {6, 7, 8, 9}; // the number of the LED pin

// Variables will change:
int ledState[buttLedNumber] = {LOW, LOW, LOW, LOW}; // the current state of the output pin
int lastButtonState[buttLedNumber] = {LOW, LOW, LOW, LOW}; // the previous reading from the input pin
int count = 0;
int sensorValue = 0;    //initialization of sensor variable, equivalent to EMA Y
float EMA_a = 0.4;      //initialization of EMA alpha
int EMA_S = 0;          //initialization of EMA S
int sceneNum = 0;
int lastSceneNum;
int lastSensorValue;

//Functions prototype:
//void switchDebounce(unsigned long &lastDebounceTime, unsigned long &debounceDelay, int &ledState, int &buttonState, int &lastButtonState, int &reading, int count);

// the following variables are unsigned longs because the time, measured in
// milliseconds, will quickly become a bigger number than can be stored in an int.
unsigned long lastDebounceTime[buttLedNumber]; // the last time the output pin was toggled
unsigned long debounceDelay = 50; // the debounce time; increase if the output flickers

void setup() {

  //Set the leds pins as outputs
  for(int i = 0; i < buttLedNumber; i++){
  pinMode(buttonPin[i], INPUT);
  }
  
  //Set the leds pins as outputs 
    for(int i = 0; i < buttLedNumber; i++){
  pinMode(ledPin[i], OUTPUT);
  }

  
  // set initial LED state
  for(int i = 0; i < buttLedNumber; i++){
  digitalWrite(ledPin[i], ledState[i]);
  }

   Serial.begin(9600);   //Start the serial monitor

   EMA_S = analogRead(A0);
}

void loop() {
  if (count > buttLedNumber - 1){
    count = 0;
  }
  // int sceneNum;
  // read the state of the switch into a local variable:
  int reading = digitalRead(buttonPin[count]);

  if (reading != lastButtonState[count]) {
    // reset the debouncing timer
    lastDebounceTime[count] = millis();
  }

  if (millis() - lastDebounceTime[count] > debounceDelay){
     if(reading == HIGH) {
      for(int i = 0; i < buttLedNumber; i++) {
        if (i == count) {
          ledState[i] = HIGH;
          sceneNum = i;
          }
          else {
          ledState[i] = LOW;
            }
          
        }    
     }
  }

  // set the LEDs:  
  digitalWrite(ledPin[count], ledState[count]);

  sensorValue = analogRead(A0);
  
  EMA_S = (EMA_a*sensorValue) + ((1-EMA_a)*EMA_S);
  
  if(sceneNum != lastSceneNum || EMA_S != lastSensorValue) {
    Serial.print(sceneNum);
    Serial.print(' ');
    Serial.print(EMA_S);
    Serial.print('\n');
    lastSceneNum = sceneNum;
    lastSensorValue = EMA_S;
    delay(50);
  }

  // save the reading. Next time through the loop, it'll be the lastButtonState:
  lastButtonState[count] = reading;
  count += 1;
}
