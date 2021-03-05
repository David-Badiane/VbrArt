import toxi.color.*;

class CA {

  int[][] cells;     // An array of 0s and 1s 
  int generation;  // How many generations?
  int cols, rows;
  float angle;
  float radius;
  int w = 1;  // Dimensions of a cell
  int nStates = 255;
  int mode = 0;
  int mapwidth = 0;
  Vec2D center;
  Rect r;
  ToneMap toneMap;
  ColorGradient gradient = new ColorGradient();

  // Constructor of the CA at the center of the screen over a preset rectangle
  CA() {
    this.radius = 150;
    cols = (int) radius *2/w;
    rows = (int) radius *2/w;
    this.cells = new int[cols][rows];
    for (int i = 1; i < cols-1; i++) {
      for (int j = 1; j < rows-1; j++) {
        cells[i][j] = int(random(1));
      }
    }
    this.center = new Vec2D(width/2, height/2);
    this.r = new Rect (0,0,width, center.y + radius*0.25);
    
    gradient.addColorAt(0, NamedColor.BLACK);
    gradient.addColorAt(20, NamedColor.RED);
    gradient.addColorAt(142, NamedColor.YELLOW);
    gradient.addColorAt(205, NamedColor.WHITE);
    toneMap=new ToneMap(0, nStates-1, gradient);
  }
  
  // more elastic contructor of a circular CA ( always with a preset retangle)
  CA(float xCenter, float yCenter, float rad) {
    this.center = new Vec2D (xCenter, yCenter);
    this.radius = rad;
    cols =(int)rad*2/w;
    rows = (int)rad*2/w;;
    this.cells = new int[cols][rows];
    for (int i =1;i < cols-1;i++) {
      for (int j =1;j < rows-1;j++) {
        cells[i][j] = int(random(8));
      }
    }
    this.r = new Rect (0,0,width, center.y + radius*0.245);
    
    gradient.addColorAt(0, NamedColor.BLACK);
    gradient.addColorAt(7, NamedColor.FUCHSIA);
    gradient.addColorAt(40, NamedColor.RED);
    gradient.addColorAt(205, NamedColor.GOLDENROD);
    toneMap=new ToneMap(0, nStates-1, gradient);
}

CA(ColorGradient gradient) {
    this.w = 2;
    this.center = new Vec2D (width/2, height/2);
    this.radius = width;
    cols =width/w;
    rows = height/w;;
    this.cells = new int[cols][rows];
    for (int i =1;i < cols-1;i++) {
      for (int j =1;j < rows-1;j++) {
        cells[i][j] = int(random(8));
      }
    }
    this.r = new Rect (0,0,width, center.y + radius*0.3);
    this.gradient = gradient;
    toneMap=new ToneMap(0, nStates-1, gradient);
}

  // The process of creating the new generation
  void generate() {
    // First we create an empty array for the new values
    int[][] next = new int[cols][rows];
    int [] neighbors = new int [9];
    
    // Loop through every spot in our 2D array and check spots neighbors
    for (int x = 1; x < cols-1; x++) {
      for (int y = 1; y < rows-1; y++) {
        int counter = 0;
        // neighborhood inspection
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            neighbors[counter] = cells[x+i][y+j];
            counter += 1;
          }
        }
        for(int i = 0; i<=8; i++){
        // Rules of Life
          if (mode == 0) {
            if ((cells[x][y] == neighbors[i]-1)) {next[x][y] = (cells[x][y]+1)%nStates;}
          }
          if (mode == 1){
            if ((cells[x][y] == neighbors[i]-2)) {next[x][y] = (cells[x][y]+2)%nStates;}
            if ((cells[x][y] == neighbors[i]-1)) {next[x][y] = (cells[x][y]+1)%nStates;}

          }
          if (mode == 2){           
            if ((cells[x][y] == neighbors[i]-2)) {next[x][y] = ((cells[x][y]*cells[x][y]))%nStates;}
            if ((cells[x][y] == neighbors[i]-1)) {next[x][y] = (cells[x][y]+1)%nStates;}
          }
          if(mode == 3){
            if ((cells[x][y] == neighbors[i]-1)) {next[x][y] = (cells[x][y]+1)%nStates;}
            if ((cells[x][y] == neighbors[i]-2)) {next[x][y] = (cells[x][y]+2)%nStates;}
            if ((cells[x][y] == neighbors[i]-3)) {next[x][y] = (cells[x][y]+5)%nStates;}

          }
          if(mode == 4){
            if ((cells[x][y] == neighbors[i]))   {next[x][y] = (abs(cells[x][y]-1))%nStates;}
            if ((cells[x][y] == neighbors[i]-1)) {next[x][y] = (cells[x][y]+1)%nStates;}
            //if ((cells[x][y] == neighbors[i]-2)) {next[x][y] = ((cells[x][y]*cells[x][y]))%nStates;}
            if ((cells[x][y] == neighbors[i]-3)) {next[x][y] = ((cells[x][y]*counter))%nStates;}
          }
        }
      }
    }
    cells = next;
  }

  /*void changeRules(){
  for(int i = 0; i < ruleset.length; i++){
  ruleset[i] = (int) random(0,2);
  }
  }*/


  //void display() {
  //  fill(255);
  //  for (int i = 0; i < cols; i++) {
  //    for (int j = 0; j < rows; j++) {
      
  //    float coordx = center.x - radius + (2*radius/cols)*i;
  //    float coordy = center.y + radius - (2*radius/rows)*j;
  //    Vec2D pos = new Vec2D(coordx, coordy);
      
  //    fill(0);
  //    if (cells[i][j] == 1){ fill(255 ,160 ,16,155); colorMode(RGB);}
  //    if (cells[i][j] == 2){ fill(240 ,64 ,16,200); colorMode(RGB);}
  //    if (cells[i][j] == 3){ fill(192, 64, 16,200); colorMode(RGB);}
  //    if (cells[i][j] == 4){ fill(255 ,144, 0,100); colorMode(RGB);}
  //    if (cells[i][j] == 5){ fill(192 ,96 ,0,140); colorMode(RGB);}
  //    if (cells[i][j] == 6){ fill(160 ,48 ,16,170); colorMode(RGB);}
  //    if (cells[i][j] == 7){ fill(240 ,192 ,80,120); colorMode(RGB);}
  //    if (cells[i][j] == 8){ fill(240,208,128,110); colorMode(RGB);}
  //    if (cells[i][j] == 9){ fill(96 ,16 ,0,100); colorMode(RGB);}
  //    if (cells[i][j] == 0){fill(255,240,20); colorMode(RGB);}
      
  //    noStroke();
  //    if(pos.isInCircle(this.center, this.radius) == true){
  //      if(pos.isInRectangle(r) == true){
  //        rect(coordx, coordy, w, w);}};
  //      }
  //    }
  //  }
  
   void display() {
    for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
    float coordx = center.x - radius + (2*radius/cols)*i;
    float coordy = center.y + radius - (2*radius/rows)*j;
    Vec2D pos = new Vec2D(coordx, coordy);
      fill(toneMap.getARGBToneFor(cells[i][j]*(100-mapwidth)));
      noStroke();
      if(pos.isInCircle(this.center, this.radius*0.992) == true){
        if(pos.isInRectangle(r) == true){
          rect(coordx, coordy, 2*w, 2*w);}};
        }
      }
    }
    
  void displayA() {
    int A =0;
    for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
    float coordx = center.x - radius + (2*radius/cols)*i;
    float coordy = center.y + radius - (2*radius/rows)*j;
    Vec2D pos = new Vec2D(coordx, coordy);
    int c = toneMap.getARGBToneFor(cells[i][j]*(100-mapwidth));
      fill( c );
      noStroke();
      if(pos.isInCircle(this.center, this.radius*0.992) == true){
        if(pos.isInRectangle(r) == true){
          rect(coordx, coordy, 3*w, 3*w);}};
        }
      }
    }

void scrumble(int number){
  for(int i =0; i< this.cols;i++){
    for(int j=0; j<this.rows;j++){
    cells[i][j] = (int)random(number);
    }
  }
}
}
