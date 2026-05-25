class Dice {
  private int die1;
  private int die2;
  private PImage face1;
  private PImage face2;
  
  public int getTotal()  { 
    return die1 + die2; 
  }

  public int getDie1() { 
    return die1; 
  }
  
  public int getDie2() { 
    return die2; 
  }
  
  public void roll() {
    die1 = 1 + (int) random(6);
    die2 = 1 + (int) random(6);
  }
  
  public boolean isDoubles() {
    return die1 == die2;
  }
}
