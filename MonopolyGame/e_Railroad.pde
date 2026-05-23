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
  
  public void landOn() {
    
  }
}
