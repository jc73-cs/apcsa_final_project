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
  
  public Player getOwner() {
    return owner;
  }
  
  public int calcRent(int railroadCount) {
    return 25 * ((int) pow(2, railroadCount - 1));
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
    } 
    else if (owner != p) {
      int due = calcRent(railroadCount);
      p.payRent(due, owner);
      println(p.getName() + " pays $" + due + " to " + owner.getName());
    } 
    else {
      println(p.getName() + " owns " + name);
    }
  }
}
