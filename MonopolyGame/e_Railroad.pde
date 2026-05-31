class Railroad extends AbstractSpace {
  private int cost;
  private int mortgagePrice;
  private boolean mortgaged;
  private Player owner;

  public Railroad(String name, int cost, int mortgagePrice) {
    this.name = name;
    this.cost = cost;
    this.mortgagePrice = mortgagePrice;
    this.mortgaged = false;
    this.owner = null;
  }
  
  public int getCost() {
    return cost;
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
  
  public Player getOwner() {
    return owner;
  }
  
  public int calcRent(int railroadCount) {
    return 25 * ((int) pow(2, railroadCount - 1));
  }
  
  public void setOwner(Player p) {
    this.owner = p;
  }
  
  public void landOn(Player p, float buyThreshold, int railroadCount) {
    if (owner == null) {
      println(p.getName() + " landed on unowned " + name + " ($" + cost + ")");
      if (cost <= p.getMoney() * buyThreshold) {
        p.payMoney(cost);
        owner = p;
        p.addAsset(this);
        println(p.getName() + " bought " + name);
      }
    } else if (owner != p && !mortgaged) {
      println(p.getName() + " owes $" + calcRent(railroadCount) + " to " + owner.getName());
    } else if (owner == p) {
      println(p.getName() + " owns " + name);
    }
  }
}
