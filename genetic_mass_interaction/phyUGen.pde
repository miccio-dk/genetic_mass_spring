import java.util.Arrays;
import ddf.minim.UGen;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

import miPhysics.*;

float fric = 0.0003;


int maxListeningPt;

public class PhyUGen extends UGen
{
  private int sample_rate;
  private float oneOverSampleRate;
  public int offsX;
  public int offsY;
  private String listeningPoint;
  private phyGenome genome;
  private PhysicalModel mdl;

  // strat with ony one constructor for the function.
  public PhyUGen(int SR, double offsX, double offsY)
  {
    super();
    // initialize member vars
    this.sample_rate = SR;
    this.offsX = (int)offsX;
    this.offsY = (int)offsY;
    listeningPoint = "mass_5";

    // initialize random genome and model
    this.genome = new phyGenome();
    this.genome.randomize();
    generateModel();
  }

  public PhysicalModel getModel() {
    return this.mdl;
  }

  public phyGenome getGenome() {
    return this.genome;
  }

  public void setGenome(phyGenome genome) {
    //println("### input genome: " + genome);
    this.genome = new phyGenome(genome);
    generateModel();
  }


  public void generateModel() {
    Vect3D X0, V0;

    synchronized(lock) {
      this.mdl =  new PhysicalModel(sample_rate, displayRate, paramSystem.ALGO_UNITS);
      mdl.setGravity(0.000);
      mdl.setFriction(fric);
      //println("Model object : " + this.mdl);
      //println("Genome object : " + this.genome);
      
      // add masses
      for (phyGene gene : this.genome.genes) {
        //println("generating mass: " + gene.name);
        X0 = new Vect3D(gene.posX+this.offsX, gene.posY+this.offsY, 0.0);
        V0 = new Vect3D(0., 0., 0.);
        this.mdl.addOsc1D(gene.name, gene.masValue, gene.K_osc, gene.Z_osc, X0, V0);
      }

      // add springs
      for (phyGene gene : this.genome.genes) {
        for (String node2 : gene.conn) {
          if (node2 != null) {
            //println("generating spring: " + gene.name + " " + node2);
            this.mdl.addSpringDamper1D(gene.name, 0, gene.K, gene.Z, gene.name, node2);
          }
        }
      }
      this.mdl.init();
    }
  }



  /**
   * This routine will be called any time the sample rate changes.
   */
  protected void sampleRateChanged()
  {
    oneOverSampleRate = 1 / sampleRate();
    this.mdl.setSimRate((int)sampleRate());
  }
  

  @Override
    protected void uGenerate(float[] channels)
  {
    float sample;
    synchronized(lock) {
      this.mdl.computeStep();

      // calculate the sample value
      if (this.mdl.matExists(listeningPoint)) {
        sample =(float)(this.mdl.getMatPosition(listeningPoint).z * 0.001);
        if(Float.isNaN(sample)) {
          //println("NAN!!");  //<>//
          sample = 0;
        }
      } else {
        sample = 0;
      }
      Arrays.fill(channels, sample);
      currAudio = sample;
    }
  }
  
}
