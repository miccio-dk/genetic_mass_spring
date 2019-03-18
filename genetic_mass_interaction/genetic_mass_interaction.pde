
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int displayRate = 60;

int mouseDragged = 0;

int maxRows = 6;
float spacingX = 100;
float spacingY = 200;
int xOffset= 100;
int yOffset= 100;
int radiusX = 100;
int radiusY = 20;

private Object lock = new Object();
float currAudio = 0;
int generation = 0;


PeasyCam cam;
 
float percsize = 200;

Minim minim;
Gain gain = new Gain();
Summer sum;
AudioOutput out;
int NUM_SPECIMEN = 24;
PhyUGen[] simUGen = new PhyUGen[NUM_SPECIMEN];

float speed = 0;
float pos = 100;

String selNode_name;
int selModel_i;


void setup()
{  
  // setup screen camera
  size(900, 700, P3D);   // or fullScreen(P3D,2);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);

  // setup audio lines
  minim = new Minim(this);
  out = minim.getLineOut();
  sum = new Summer();

  // spawn initial population
  for (int i=0; i<NUM_SPECIMEN; i++) {
    simUGen[i] = new PhyUGen(44100, xOffset + spacingY*(i/maxRows), yOffset + spacingX*(i%maxRows));
    // start the Gain at 0 dB, which means no change in amplitude
    gain = new Gain(0);
    simUGen[i].patch(sum);    
  }
  
  sum.patch(gain).patch(out);
  cam.setDistance(500);
  //minim.debugOn();
  sum.printInputs();
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
      if (isSpecimenSelected(simUGen[i], mouseX, mouseY, radiusX, radiusY)) {
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
  text("Last sample " + currAudio, 100, 160, 50);
  text("Generation " + generation, 100, 240, 50);


  // interaction
  // play currently hovered model
  engrave(mouseX, mouseY);
}


// excite (play)) model
void engrave(float mX, float mY) {
  String matName = "mass_" + int(mX%(spacingX) / 4);
  // println("exciting " + selModel_i + "." + matName);
  selNode_name = matName;
  if (selModel_i >= 0) {
    if (simUGen[selModel_i].mdl.matExists(matName)) {
      simUGen[selModel_i].mdl.triggerForceImpulse(matName, 0., 0., 15.);
    }
  }
}


boolean isSpecimenSelected(PhyUGen ugen, int x, int y, int radiusX, int radiusY) {
  if (ugen.center_x < x)
    if (ugen.center_x+radiusX > x)
      if (ugen.center_y-radiusY < y)
        if (ugen.center_y+radiusY > y)
          return true;
  return false;
}


void mouseReleased() {
  float mutationProb = 0;
  float mutationAmount = 0;
  if (selModel_i >= 0) {
    phyGenome genome = new phyGenome(simUGen[selModel_i].getGenome());
    println("#### parent genome # " + selModel_i + ": " + genome ); //<>//
    for (int i=0; i<NUM_SPECIMEN; i++) {
      //if(selModel_i != i) {
        // println("replacing specimen " + i);
        simUGen[i].setGenome(genome);
        // mutate/evolve
        simUGen[i].getGenome().mutate(mutationProb, mutationAmount);
        //simUGen[i].generateModel(xOffset + spacingY*(i/maxRows), yOffset + spacingX*(i%maxRows));
        mutationProb += 0.035;
        mutationAmount += 0.0075;
      //}
    }

    generation++;
    println("\n\nGeneration: " + generation + "\n\n");
    sum.printInputs();
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
