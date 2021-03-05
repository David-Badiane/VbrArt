//import ddf.minim.*;
//import ddf.minim.analysis.*;
//import processing.sound.*;

class FFTline{
  Vec2D ref;
  int maxH;
  float dx;
  float [] fftVals = new float[nBin];
  float nDisplayed = 100;
  
  FFTline(float [] spectrum){
    arrayCopy(spectrum, fftVals);
    //this.fftVals = spectrum;
    ref = new Vec2D(0,height);
    dx = width/(nDisplayed);
  }
  
  FFTline(float [] spectrum, Vec2D center){
    arrayCopy(spectrum, fftVals);
    //this.fftVals = spectrum;
    ref = center;
    dx = width/(nDisplayed);
  }
  
  void display(){
    fill(30,30,132,100);
    stroke(255,255,255,70);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i<nDisplayed+1;i++){
      if ( i == 0 || i == nDisplayed)   vertex(i*dx, ref.y);
      else    vertex(i*dx, ref.y - log(i*2+10)*10*fftVals[i+10]);
    }
    endShape();
  }
  
  void displayPolygon(){
    fill(30,30,132,50);
    stroke(255,255,255,70);
    strokeWeight(2);
    beginShape();
    float angle = 0;
    for (int i = 0; i<nDisplayed+1;i++){
     
      vertex(ref.x +cos(angle)*fftVals[i%20], ref.y - sin(angle)*log(i+10)*fftVals[i%20]);
      
      angle += TWO_PI / nDisplayed;
    }
    endShape();
  }
  
  void update(){
    ref.y -= 3; 
  }
  
  
}
