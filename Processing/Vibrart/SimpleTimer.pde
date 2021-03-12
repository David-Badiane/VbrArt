// Simple timers to use with millis() function
class SimpleTimer{
// Members
int T;
int count;

// constructor
SimpleTimer(int timeGap){
  count= 0;
  this.T = timeGap;
}

// update
void updateCounter(){
count += 1;}
}
