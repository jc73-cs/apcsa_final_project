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
  
  public void landOn(Player p, float buyThreshold, int diceTotal, int utilityCount) {
    if (owner == null) {
      println(p.getName() + " landed on unowned " + name + " ($" + cost + ")");
      if (cost <= p.getMoney() * buyThreshold) {
        p.payMoney(cost);
        owner = p;
        println(p.getName() + " bought " + name);
      }
    } 
    else if (owner != p) {
      int due = calcRent(diceTotal, utilityCount);
      p.payRent(due, owner);
      println(p.getName() + " pays $" + due + " to " + owner.getName());
    } 
    else {
      println(p.getName() + " owns " + name);
    }
  }
}
