
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int displayRate = 60;

int mouseDragged = 0;

Minim minim;
Gain gain = new Gain();
Summer sum;
AudioOutput out;
int NUM_SPECIMEN = 36;
PhyUGen[] simUGen = new PhyUGen[NUM_SPECIMEN];

int maxRows = 6;
float spacingX = 150;
float spacingY = 120;
int xOffset= 20;
int yOffset= 60;
int radiusX = 150;
int radiusY = 75;

private Object lock = new Object();
float currAudio = 0;
int generation = 0;


PeasyCam cam;
 
float percsize = 200;

float speed = 0;
float pos = 100;

String selNode_name;
int selModel_i;
float force = 0;
float mutationProb = 0;
float mutationAmount = 0;


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
    simUGen[i] = new PhyUGen(44100, xOffset + spacingX*(i/maxRows), yOffset + spacingY*(i%maxRows));
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
        renderLinks(simUGen[i].getModel(), 250, 164, 164);
        //renderModelMasses(simUGen[i].getModel());
        // also store currently hovered ugen for later!
        selModel_i = i;
      } else {
        renderLinks(simUGen[i].getModel(), 28, 164, 250);
        //renderModelMasses(simUGen[i].getModel());
      }
    }
  }
  
  popMatrix();

  // show infos
  fill(255, 255, 255, 200);
  textSize(13); 
  text("Friction: " + fric, 50, 50, 50);
  text("Last Exct: " + selModel_i + "." + selNode_name, 50, 70, 50);
  text("Force: " + force, 50, 90, 50);

  text(" " + mouseX + "  " + mouseY, 400, 50, 50);
  
  text("Generation " + generation, 700, 50, 50);  
  text("Last sample " + Math.abs(currAudio), 700, 70, 50);

  text("Max mutation " + mutationProb + "  " + mutationAmount, 50, height-40, 50);

  // interaction
  // play currently hovered model
  engrave(mouseX, mouseY);
}


// excite (play)) model
void engrave(float mX, float mY) {
  String matName = "mass_" + int(mX%(spacingX) / 16);
  float curr_force = (float)(mY%(spacingY) / 5);
  // println("exciting " + selModel_i + "." + matName);
  selNode_name = matName;
  if (selModel_i >= 0) {
    if (simUGen[selModel_i].mdl.matExists(matName)) {
      simUGen[selModel_i].mdl.triggerForceImpulse(matName, 0., 0., curr_force);
      force = curr_force;
    }
  }
}


boolean isSpecimenSelected(PhyUGen ugen, int x, int y, int radiusX, int radiusY) {
  if (ugen.offsX < x)
    if (ugen.offsX+radiusX > x)
      if (ugen.offsY-radiusY < y)
        if (ugen.offsY+radiusY > y)
          return true;
  return false;
}


void mouseReleased() {
  mutationProb = 0;
  mutationAmount = 0;
  if (selModel_i >= 0) {
    phyGenome genome = new phyGenome(simUGen[selModel_i].getGenome());
    println("#### parent genome # " + selModel_i + ": " + genome );
    for (int i=0; i<NUM_SPECIMEN; i++) {
      //if(selModel_i != i) {
        // println("replacing specimen " + i);
        simUGen[i].setGenome(genome);
        // mutate/evolve
        simUGen[i].getGenome().mutate(mutationProb, mutationAmount);
        simUGen[i].generateModel();
        mutationProb += 0.025 * (1 + (float)generation/10);
        mutationAmount += 0.005 * (1 + (float)generation/10);
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
