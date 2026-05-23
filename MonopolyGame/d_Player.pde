class Player {
  private int money;
  private int position;
  private boolean inJail;
  private AbstractSpace[] properties;
  private String name;
  
  private int propertyCount;  // track how many properties owned

  public Player(String name, int startingMoney) {
    this.name  = name;
    this.money = startingMoney;
    this.position = 0;
    this.inJail = false;
    this.properties = new AbstractSpace[28];  // max buyable spaces on board
    this.propertyCount = 0;
  }

  public String getName()    { return name; }
  public int getMoney()      { return money; }
  public int getPosition()   { return position; }

  public void receiveMoney(int amount) { money += amount; }
  public void payMoney(int amount)     { money -= amount; }
  
  public void payRent(int amount, Player owner) {
    money -= amount;
    owner.receiveMoney(amount);
  }

  public void goToJail() {
    position = 10;
    inJail   = true;
  }

  // Used by Railroad/Utility rent calculations
  public int countRailroads() {
    int count = 0;
    for (int i = 0; i < propertyCount; i++) {
      if (properties[i] instanceof Railroad) count++;
    }
    return count;
  }

  public int countUtilities() {
    int count = 0;
    for (int i = 0; i < propertyCount; i++) {
      if (properties[i] instanceof Utility) count++;
    }
    return count;
  }
}
