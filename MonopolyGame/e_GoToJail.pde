class GoToJail extends AbstractSpace {
  public GoToJail() { 
    this.name = "Go To Jail"; 
  }
  
  public void landOn(Player p) {
    p.goToJail();
    println(p.getName() + " is sent to Jail!");
  }
}
