class Utility extends AbstractSpace {
  private int cost;
  private int mortgagePrice;
  private boolean mortgaged;
  private Player owner;

  public Utility(String name, int cost, int mortgagePrice) {
    this.name = name;
    this.cost = cost;
    this.mortgagePrice = mortgagePrice;
    this.mortgaged = false;
    this.owner = null;
  }
  
  public Player getOwner() {
    return owner;
  }
  
  public int calcRent(int diceTotal, int utilityCount) {
    if(utilityCount == 0)
      return 0;
    else if(utilityCount == 1)
      return 4 * diceTotal;
    else
      return 10 * diceTotal;
  }
  
  public boolean isMortgaged() {
    return mortgaged;
  }
  
  public void setMortgaged(boolean mortgaged) {
    this.mortgaged = mortgaged;
  }
  
  public int getMortgagePrice() {
    return mortgagePrice;
  }
  
  public void setOwner(Player p) {
    this.owner = p;
  }
  
  public void landOn(Player p, float buyThreshold, int diceTotal, int utilityCount) {
    if (owner == null) {
      println(p.getName() + " landed on unowned " + name + " ($" + cost + ")");
      if (cost <= p.getMoney() * buyThreshold) {
        p.payMoney(cost);
        owner = p;
        p.addAsset(this);
        println(p.getName() + " bought " + name);
      }
    } else if (owner != p && !mortgaged) {
      println(p.getName() + " owes $" + calcRent(diceTotal, utilityCount) + " to " + owner.getName());
    } else if (owner == p) {
      println(p.getName() + " owns " + name);
    }
  }
}
