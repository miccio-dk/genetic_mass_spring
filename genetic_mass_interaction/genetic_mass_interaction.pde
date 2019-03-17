
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int displayRate = 60;

int mouseDragged = 0;

float spacing = 100;
int radius = 50;

int xOffset= 500;
int yOffset= 100;
int generation = 0;

private Object lock = new Object();


PeasyCam cam;

float percsize = 200;

Minim minim;
Gain gain = new Gain();
Summer sum;
AudioOutput out;
int NUM_SPECIMEN = 4;
PhyUGen[] simUGen = new PhyUGen[NUM_SPECIMEN];

float speed = 0;
float pos = 100;

String selNode_name;
int selModel_i;


void setup()
{  
  // setup screen camera
  size(800, 600, P3D);   // or fullScreen(P3D,2);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);

  // setup audio lines
  minim = new Minim(this);
  out = minim.getLineOut();
  sum = new Summer();

  // spawn initial population
  for (int i=0; i<NUM_SPECIMEN; i++) {
    simUGen[i] = new PhyUGen(44100, xOffset, yOffset + spacing*i);
    // start the Gain at 0 dB, which means no change in amplitude
    gain = new Gain(0);
    simUGen[i].patch(sum);    
  }
  
  sum.patch(gain).patch(out);
  cam.setDistance(500);
}


void draw()
{
  // draw models
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0);
  background(0);
  pushMatrix();
    
  selModel_i = -1;
  synchronized(lock) { 
    for (int i=0; i<NUM_SPECIMEN; i++) {
      if (isSpecimenSelected(simUGen[i], mouseX, mouseY, radius)) {
        renderLinks(simUGen[i].getModel(), 100, 255, 255);
        //renderModelMasses(simUGen[i].getModel());
        // also store currently hovered ugen for later!
        selModel_i = i;
      } else {
        renderLinks(simUGen[i].getModel(), 0, 0, 255);
        //renderModelMasses(simUGen[i].getModel());
      }
    }
  }
  
  popMatrix();

  // show infos
  fill(255);
  textSize(13); 
  text("Friction: " + fric, 100, 100, 50);
  text("Last Exct: " + selModel_i + "." + selNode_name, 100, 120, 50);
  text("Mouse: " + mouseX + " " + mouseY, 100, 140, 50);
  text("Generation " + generation, 100, 240, 50);

  // interaction
  // play currently hovered model
  engrave(mouseX, mouseY);
}


// excite (play)) model
void engrave(float mX, float mY) {
  String matName = "mass_" + int((mX - xOffset) / 4);
  // println("exciting " + selModel_i + "." + matName);
  if (selModel_i >= 0) {
    if (simUGen[selModel_i].mdl.matExists(matName)) {
      selNode_name = matName;
      simUGen[selModel_i].mdl.triggerForceImpulse(matName, 0., 0., 15.);
    }
  }
}


boolean isSpecimenSelected(PhyUGen ugen, int x, int y, int radius) {
  if (ugen.center_x-radius < x)
    if (ugen.center_x+radius > x)
      if (ugen.center_y-radius < y)
        if (ugen.center_y+radius > y)
          return true;
  return false;
}


void mouseReleased() {
  if (selModel_i >= 0) {
    phyGenome genome = simUGen[selModel_i].getGenome();
    for (int i=0; i<NUM_SPECIMEN; i++) {
      if(selModel_i != i) {
        // println("replacing specimen " + i);
        simUGen[i].setGenome(simUGen[selModel_i].getGenome());
        // mutate/evolve
      }
    }
    generation++;
  }
}


void keyPressed() {
  if (key == ' ') {
    for (int i=0; i<NUM_SPECIMEN; i++) {
      simUGen[i].mdl.setGravity(-0.001);
    }
  }
  if (keyCode == UP) {
    fric += 0.00005;
    synchronized(lock) {
      for (int i=0; i<NUM_SPECIMEN; i++) {
        simUGen[i].mdl.setFriction(fric);
      }
    }
    //println(fric);
  } else if (keyCode == DOWN) {
    fric -= 0.00005;
    fric = max(fric, 0);
    for (int i=0; i<NUM_SPECIMEN; i++) {
      simUGen[i].mdl.setFriction(fric);
    }
    //println(fric);
  }
}


void keyReleased() {
  if (key == ' ') {
    for (int i=0; i<NUM_SPECIMEN; i++) {
      simUGen[i].mdl.setGravity(0.000);
    }
  }
}
