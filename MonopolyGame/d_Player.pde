class Player {
  private int money;
  private int position;
  private boolean inJail;
  private String name;
  private boolean passedGo;
  private int turnCount;
  private Token token;    
  private int jailTurns;
  private boolean hasJailFreeCard;
  private ArrayList<AbstractSpace> assetsOwned;

  public Player(String name, int startingMoney, Token t) {
    this.name  = name;
    this.money = startingMoney;
    this.position = 0;
    this.inJail = false;
    this.turnCount = 1;
    this.token = t;
    this.assetsOwned = new ArrayList<AbstractSpace>();
  }
  
  public void incrementTurn() { 
    turnCount++; 
  } //<>//
  
  public int getTurnCount()   { 
    return turnCount; 
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
  
  public void setPosition(int index) {
    position = ((index % 40) + 40) % 40;
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
    inJail = true;
  }
  
  public void move(int steps) {
    passedGo = false;
    position += steps;
    if(position >= 40) {
      position -= 40;
      passedGo = true;
    }
  }

  public boolean isInJail() { 
    return inJail; 
  }
  
  public void releaseFromJail() { 
    inJail = false; 
    jailTurns = 0; 
  }
  
  public void incrementJailTurn(){ 
    jailTurns++; 
  }
  
  public int getJailTurns(){ 
    return jailTurns; 
  }
  
  public boolean hasPassedGo() {
    return passedGo;
  }
  
  public void giveJailFreeCard() {
   hasJailFreeCard = true; 
  }
  
  public boolean hasJailFreeCard() { 
    return hasJailFreeCard; 
  }
  
  public void useJailFreeCard() { 
    hasJailFreeCard = false; 
  }
  
  public ArrayList<AbstractSpace> getAssets() { 
    return assetsOwned; 
  }
  
  public void addAsset(AbstractSpace a) { 
    assetsOwned.add(a); 
  }
  
  public void removeAsset(AbstractSpace a) { 
    assetsOwned.remove(a); 
  }
  
  public boolean ownsFullColorGroup(String colorGroup, Board board) {
    for (int i = 0; i < 40; i++) {
      AbstractSpace space = board.getSpace(i);
      if (space instanceof Property) {
        Property p = (Property)space;
        if (p.getColorGroup().equals(colorGroup) && p.getOwner() != this)
          return false;
      }
    }
    return true;
  }
  
  public ArrayList<Property> getColorGroup(String colorGroup) {
  ArrayList<Property> group = new ArrayList<Property>();
    for (AbstractSpace space : assetsOwned) {
      if (space instanceof Property) {
        Property p = (Property)space;
        if (p.getColorGroup().equals(colorGroup))
          group.add(p);
      }
    }
    return group;
  }
}
