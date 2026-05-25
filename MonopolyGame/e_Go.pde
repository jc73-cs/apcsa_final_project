class Go extends AbstractSpace {
  public Go() { 
    this.name = "Go"; 
  }
  
  public void landOn(Player p) {
    println(p.getName() + " landed on Go");
    //handled in GameController
  }
}
