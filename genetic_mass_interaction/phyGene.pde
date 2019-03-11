

public class phyGene
{
  public String name;
  public int posX, posY;
  public double masValue;
  public double K_osc, Z_osc;
  public double K, Z;
  public String[] conn;  
  
  public phyGene(String name, int conns)
  {
    this.name = name;
    this.conn = new String[conns];
  }
}
