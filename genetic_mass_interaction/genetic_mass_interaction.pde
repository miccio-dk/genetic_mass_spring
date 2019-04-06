
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int displayRate = 15;

int mouseDragged = 0;

Minim minim;
Gain gain = new Gain();
Summer sum;
AudioOutput out;
int NUM_SPECIMEN = 25;
PhyUGen[] simUGen = new PhyUGen[NUM_SPECIMEN];

int maxRows = 5;
int xOffset= 100;
int yOffset= 150;

float spacingX = 150;
float spacingY = 120;
int radiusX = 170;
int radiusY = 85;

private Object lock = new Object();
float currAudio = 0;
int generation = 0;

int margin = 100;

float gain_lvl = 0;

PeasyCam cam;
 
float percsize = 200;

float speed = 0;
float pos = 100;

String selNode_name;
int selModel_i;
float force = 0;
float mutationProb = 0;
float mutationAmount = 0;


boolean beginUpdatingPop = false;
boolean fadingOut = false;
boolean fadingIn = false;
int oldTime;
int currTime;
int mutation_idx = 0;

int exitTimer = 0;
boolean isExiting = false;

phyGenome genome;

int t_trans = 250;

void setup()
{  
  // setup screen camera
  fullScreen(P3D,2);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  
  // distances
  spacingX = (width-xOffset) / (NUM_SPECIMEN / maxRows);
  spacingY = (height-yOffset) / maxRows;
  radiusX = int(spacingX - 50.0) / 2;
  radiusY = int(spacingY - 40.0) / 2;

  // setup audio lines
  minim = new Minim(this);
  out = minim.getLineOut();
  sum = new Summer();

  // spawn initial population
  for (int i=0; i<NUM_SPECIMEN; i++) {
    simUGen[i] = new PhyUGen(44100, xOffset + spacingX*(i/maxRows), yOffset + spacingY*(i%maxRows));
    simUGen[i].mdl.setFriction(fric);
    // start the Gain at 0 dB, which means no change in amplitude
    gain = new Gain(gain_lvl);
    simUGen[i].patch(sum);    
  }
  
  sum.patch(gain).patch(out);
  cam.setDistance(500);
  //minim.debugOn();
  //sum.printInputs();
}


void draw()
{
  // draw models
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0);
  background(0);
  frameRate(30);
  pushMatrix();
  
  float currentVolume = out.getGain();
  
  // Is it time to fade up
  if (fadingIn) {
    out.shiftGain(currentVolume, gain_lvl, 300); 
    fadingIn = false;
  } 
  // time to fade down
  else if (beginUpdatingPop && !fadingOut) {
    out.shiftGain(currentVolume, -80, 300);
    fadingOut = true; // we're already fading, don't do it again!
  } 
  
  // display pop
  selModel_i = -1;
  synchronized(lock) { 
    for (int i=0; i<NUM_SPECIMEN; i++) {
      if (isSpecimenSelected(simUGen[i], mouseX, mouseY, radiusX, radiusY)) {
        renderLinks(simUGen[i].getModel(), true, force, selNode_name);
        //renderModelMasses(simUGen[i].getModel());
        // also store currently hovered ugen for later!
        selModel_i = i;
      } else {
        renderLinks(simUGen[i].getModel(), false, 0, "");
        //renderModelMasses(simUGen[i].getModel());
      }
    }
  }
  
  // if evolving
  if(beginUpdatingPop) {
    currTime = millis();
    if((currTime - oldTime) > (t_trans / NUM_SPECIMEN)) {
      oldTime = currTime;
      // println("replacing specimen " + i);
      simUGen[mutation_idx].setGenome(genome);
      // mutate/evolve
      simUGen[mutation_idx].getGenome().mutate(mutationProb, mutationAmount);
      simUGen[mutation_idx].generateModel();
      
      mutationProb = 0.027 * (float)mutation_idx*1.3 * (1 + (float)generation/46);
      mutationAmount = 0.0054 * (float)mutation_idx*1.3 * (1 + (float)generation/46);
      
      if(mutationProb > 0.6) {
        mutationProb = 0.6;
      }
      if(mutationAmount > 0.2) {
        mutationAmount = 0.1;
      }
      
      simUGen[mutation_idx].mdl.setFriction(fric);
      mutation_idx++;
    }
    if(mutation_idx == NUM_SPECIMEN) {
      beginUpdatingPop = false;
      mutation_idx = 0;
      fadingIn = true;
    }
  }
  
  popMatrix();

  // show infos
  fill(255, 255, 255, 200);
  textSize(13); 
  text("friction: " + String.format("%.5f",fric), margin, margin, 50);
  text("last Exct: " + selModel_i + "." + selNode_name, margin, margin+20, 50);
  text("force: " + force, margin, margin+40, 50);

  text(" " + mouseX + "  " + mouseY, width/2 - 40, margin, 50);
  
  text("generation " + generation, width - 150 - margin, margin, 50);  
  text("last sample " + String.format("%.5f",Math.sqrt(Math.abs(currAudio))), width - 150 - margin, margin+20, 50);
  text("fps  " + frameRate, width - 150 - margin, margin+40, 50);

  text("max mutation " + String.format("%.2f",mutationProb) + "  " + String.format("%.2f",mutationAmount), margin, height-margin, 50);


  text("begin/fading  " + beginUpdatingPop + "/" + fadingIn, width - 150 - margin, height-margin, 50);


  // interaction
  // play currently hovered model
  engrave(mouseX, mouseY);
  
  
  // exit
  if(isExiting && millis() - exitTimer > 5000) {
    //exitTimer = millis();
    exit();
    //frameCount = -1;
  }
}


// excite (play)) model
void engrave(float mX, float mY) {
  float curr_force = (float)((mY-yOffset/2)%(spacingY) / 10);
  int mass_idx = int((mX-xOffset)%(spacingX) / 16);
  String matName = "mass_" + ((mass_idx != 5) ? mass_idx : mass_idx + (curr_force<10 ? 0 : 1));

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
  if (ugen.offsX-radiusX*0.25 < x)
    if (ugen.offsX+radiusX*1.75 > x)
      if (ugen.offsY-radiusY < y)
        if (ugen.offsY+radiusY > y)
          return true;
  return false;
}

void mousePressed() {
   if (mouseButton == RIGHT) {
     exitTimer = millis();
     isExiting = true;
   }
}


void mouseReleased() {
   if (mouseButton == RIGHT) {
     isExiting = false;
   }
  mutationProb = 0;
  mutationAmount = 0;

  if (selModel_i >= 0) {
    synchronized(lock) {
      beginUpdatingPop = true;
      genome = new phyGenome(simUGen[selModel_i].getGenome());
      println("#### parent genome # " + selModel_i + ": " + genome );
      
 
      generation++;
      println("\n\nGeneration: " + generation + "\n\n");
    }
  }
}


void keyPressed() {
  if (key == ' ') {
    for (int i=0; i<NUM_SPECIMEN; i++) {
      simUGen[i].mdl.setGravity(-0.001);
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e < 0) {
    fric += 0.00025;
    fric = min(fric, 0.01);
  } else {
    fric -= 0.00025;
    fric = max(fric, 0.00001);
  }
  
  synchronized(lock) {
    for (int i=0; i<NUM_SPECIMEN; i++) {
      simUGen[i].mdl.setFriction(fric);
    }
  }
}

void keyReleased() {
  if (key == ' ') {
    for (int i=0; i<NUM_SPECIMEN; i++) {
      simUGen[i].mdl.setGravity(0.000);
    }
  }
}
