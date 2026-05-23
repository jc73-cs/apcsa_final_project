class Player {
  private int money;
  private int position;
  private boolean inJail;
  private AbstractSpace[] properties;
  private String name;
  private int railroads;
  private int utilities;
  private boolean passedGo;
  
  private int propertyCount;

  public Player(String name, int startingMoney) {
    this.name  = name;
    this.money = startingMoney;
    this.position = 0;
    this.inJail = false;
    this.properties = new AbstractSpace[28];
    this.propertyCount = 0;
  }

  public String getName() { 
    return name; 
  }
  
  public int getMoney() { 
    return money; 
  }
  
  public int getPosition() { 
    return position; 
  }

  public void receiveMoney(int amount) { 
    money += amount; 
  }
  public void payMoney(int amount) { 
    money -= amount; 
  }
  
  public void payRent(int amount, Player owner) {
    money -= amount;
    owner.receiveMoney(amount);
  }

  public void goToJail() {
    position = 10;
    inJail   = true;
  }

  public void addRailroad() { 
    railroads++; 
  }
  public void addUtility()  { 
    utilities++;  
  }
  
  public int countRailroads() { 
    return railroads; 
  }
  
  public int countUtilities() { 
    return utilities;  
  }
  
  public void move(int steps) {
    passedGo = false;
    position += steps;
    if(position >= 40) {
      position -= 40;
      passedGo = true;
    }
  }
  
  public boolean hasPassedGo() {
    return passedGo;
  }
}
