class Tax extends AbstractSpace {
  private int amount;
  
  public Tax(String name, int amount) {
    this.name = name;
    this.amount = amount;
  }
  
  public int getAmount() {
    return amount; 
  }

  public void landOn(Player p) {
    println(p.getName() + " paid $" + amount + " for " + name);  
  }
}
