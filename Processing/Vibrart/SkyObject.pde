// Stars or ufos implemented by two FFTlines in mode displayPolygon

class SkyObject{
  // Members
  ArrayList<FFTline> elements;
  int RES = 2;
  float[] vals = new float[nBin];
  Vec2D center;
  float reactivity;

  // Constructor
  SkyObject(Vec2D center, float rad, float[] spec){
    this.vals = spec;
    this.center = center;
    this.reactivity = random(10);
    elements = new ArrayList<FFTline>();
    for (int i =0; i<RES; i++){
      elements.add(new FFTline (vals, center));
    }
  }
  
  // update of the sars
  void update( float [] spec){
    arrayCopy(spec, vals);
    for ( FFTline e: elements){
      for ( int i = 0; i < nBin; i++) {} 
      e.fftVals = vals; // give vals
      e.displayPolygon(); // display
    }
  }
}
