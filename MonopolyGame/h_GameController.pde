class GameController {
  private ArrayList<Player> players;
  private Board board;
  private Dice dice;
  private Display display;
  private int currentPlayer;
  private float[] buyThresholds = {1,1};
  
  public GameController(Board b, ArrayList<Player> players, Dice dice, Display display) {
    this.board = b;
    this.players = players;
    this.dice = dice;
    this.display = display;
    this.currentPlayer = 0;
  }
  
  public void advanceTurn() {
  Player p = players.get(currentPlayer);
    println("--- Turn " + p.getTurnCount() + " | " + p.getName() + " ---"); 
    boolean tookTurn = true;
    if (p.isInJail()) {
      if (p.hasJailFreeCard()) {
        p.useJailFreeCard();
        p.leaveJail();
        println(p.getName() + " used Get Out of Jail Free card");
        rollDice();
        println("Rolled: " + dice.getDie1() + " + " + dice.getDie2() + " = " + dice.getTotal());
        p.move(dice.getTotal());
        tookTurn = true;
      }
      else {
        rollDice();
        println("Rolled: " + dice.getDie1() + " + " + dice.getDie2() + " = " + dice.getTotal());
        if (dice.isDoubles()) {
          p.leaveJail();
          p.move(dice.getTotal());
          println(p.getName() + " rolled doubles, released from jail");
        } 
        else {
          p.incrementJailTurn();
          if (p.getJailTurns() >= 3) {
            handlePayment(p, 50, null);
            p.leaveJail();
            p.move(dice.getTotal());
            println(p.getName() + " paid $50 fine, released from jail");
          } 
          else {
            println(p.getName() + " is in jail, turn skipped");
            tookTurn = false;
          }
        }
      }
    } 
    else {
      rollDice();
      println("Rolled: " + dice.getDie1() + " + " + dice.getDie2() + " = " + dice.getTotal());
      p.move(dice.getTotal());
    }
    
    if (tookTurn) {
      println("Moved to: " + board.getSpace(p.getPosition()).getName());
      AbstractSpace landed = board.getSpace(p.getPosition());
      if (landed instanceof Property) {
        Property property = (Property)landed;
        property.landOn(p, buyThresholds[currentPlayer]);
        if (property.getOwner() != null && property.getOwner() != p && !property.isMortgaged())
          handlePayment(p, property.calcRent(), property.getOwner());
      } 
      else if (landed instanceof Railroad) {
        Railroad r = (Railroad)landed;
        r.landOn(p, buyThresholds[currentPlayer], countRailroads(r.getOwner()));
        if (r.getOwner() != null && r.getOwner() != p && !r.isMortgaged())
          handlePayment(p, r.calcRent(countRailroads(r.getOwner())), r.getOwner());
      } 
      else if (landed instanceof Utility) {
        Utility u = (Utility)landed;
        u.landOn(p, buyThresholds[currentPlayer], dice.getTotal(), countUtilities(u.getOwner()));
        if (u.getOwner() != null && u.getOwner() != p && !u.isMortgaged())
          handlePayment(p, u.calcRent(dice.getTotal(), countUtilities(u.getOwner())), u.getOwner());
      }
      else if (landed instanceof Go) { 
        ((Go)landed).landOn(p); 
      }
      else if (landed instanceof GoToJail) { 
        ((GoToJail)landed).landOn(p); 
      }
      else if (landed instanceof Tax) {
        ((Tax)landed).landOn(p);
        handlePayment(p, ((Tax)landed).getAmount(), null);
      }
      else if (landed instanceof Chance) {
        Card c2 = board.getChanceDeck().drawCard();
        println(p.getName() + " draws Chance: " + c2.description);
        applyCard(p, c2);
      }
      else if (landed instanceof CommunityChest) {
        Card c2 = board.getCommunityDeck().drawCard();
        println(p.getName() + " draws Community Chest: " + c2.description);
        applyCard(p, c2);
      }
      if (p.hasPassedGo()) {
        println(p.getName() + " passed Go, collects $200");
        p.receiveMoney(200);
      }
    }  
    println(p.getName() + " now has $" + p.getMoney());
    buildHouses(p);
    unmortgage(p);
    p.incrementTurn();
    currentPlayer = (currentPlayer + 1) % players.size();
  }
  
  public boolean checkWin() {
    if (players.size() == 1) {
      Player winner = players.get(0);
      println(players.get(0).getName() + " wins!");
      println("Final net worth: $" + calcNetWorth(winner));
      return true;
    }
    return false;
  }
  
  public void rollDice() {
    dice.roll();
  }
  
  public int countRailroads(Player p) {
    if (p == null) 
      return 0;
    int count = 0;
    for (int i = 0; i < 40; i++) {
      AbstractSpace space = board.getSpace(i);
      if (space instanceof Railroad && ((Railroad)space).getOwner() == p) 
        count++;
    }
    return count;
  }
  
  public int countUtilities(Player p) {
    if (p == null) 
      return 0;
    int count = 0;
    for (int i = 0; i < 40; i++) {
      AbstractSpace space = board.getSpace(i);
      if (space instanceof Utility && ((Utility)space).getOwner() == p)
        count++;
    }
    return count;
  }
  
  private void moveToSpace(Player p, int destination) {
    if (destination < p.getPosition()) {
      p.receiveMoney(200);
      println(p.getName() + " passed Go, collects $200");
    }
    p.setPosition(destination);
    println(p.getName() + " moved to " + board.getSpace(destination).getName());
  }
  
  private int countBuildings(Player p, boolean hotels) {
    int count = 0;
    for (int i = 0; i < 40; i++) {
      AbstractSpace space = board.getSpace(i);
      if (space instanceof Property) {
        Property prop = (Property)space;
        if (prop.getOwner() == p) {
          if (hotels && prop.getHouses() == 5) count++;
          else if (!hotels && prop.getHouses() < 5) count += prop.getHouses();
        }
      }
    }
    return count;
  }
  
  private int nearestRailroad(int position) {
    int[] railroads = {5, 15, 25, 35};
    for (int r : railroads) {
      if (position <= r) 
        return r;
    }
    return 5;
  }
  
  private int nearestUtility(int position) {
    if (position <= 12) 
      return 12;
    if (position <= 28) 
      return 28;    
    return 12;
  }
  
  private void buildHouses(Player p) {
    String[] colorGroups = {"brown", "lightBlue", "magenta", "orange", "red", "yellow", "green", "blue"};
    for (String colorGroup : colorGroups) {
      if (p.ownsFullColorGroup(colorGroup, this.board)) {
        distributeHouses(p, colorGroup);
      }
    }
  }
  
  private void distributeHouses(Player p, String colorGroup) {
    ArrayList<Property> group = p.getColorGroup(colorGroup);
    boolean built = true;
    while (built) {
      built = false;
      int minHouses = 5;
      for (Property property : group) {
        minHouses = min(minHouses, property.getHouses());
      }
      for (Property property : group) {
        if (property.getHouses() == minHouses && property.getHouses() < 5) {
          if (property.getBuildingCost() <= p.getMoney() * buyThresholds[currentPlayer]) {
            property.setHouses(property.getHouses() + 1);
            p.payMoney(property.getBuildingCost());
            println(p.getName() + " built a house on " + property.getName());
            built = true;
          }
        }
      }
    }
  }
  
  private void applyCard(Player p, Card c) {
    String d = c.description;
    
    if (d.equals("Advance to Boardwalk.")) {
      moveToSpace(p, 39);
      ((Property)board.getSpace(39)).landOn(p, buyThresholds[currentPlayer]);
    } 
    else if (d.equals("Advance to Go (Collect $200).")) {
      p.setPosition(0);
      p.receiveMoney(200);
      println(p.getName() + " advances to Go, collects $200");  
    } 
    else if (d.equals("Advance to Illinois Avenue. If you pass Go, collect $200.")) {
      moveToSpace(p, 24);  
      ((Property)board.getSpace(24)).landOn(p, buyThresholds[currentPlayer]);
    } 
    else if (d.equals("Advance to St. Charles Place. If you pass Go, collect $200.")) {
      moveToSpace(p, 11);  
      ((Property)board.getSpace(11)).landOn(p, buyThresholds[currentPlayer]);
    } 
    else if (d.equals("Take a trip to Reading Railroad. If you pass Go, collect $200.")) {
      moveToSpace(p, 5); 
      Railroad r = (Railroad)board.getSpace(5);
      r.landOn(p, buyThresholds[currentPlayer], countRailroads(r.getOwner()));
    } 
    else if (d.equals("Advance to the nearest Railroad. If unowned, you may buy it from the Bank. If owned, pay owner twice the rental to which they are otherwise entitled.")) {
      int nearest = nearestRailroad(p.getPosition());
      moveToSpace(p, nearest);
      Railroad r = (Railroad)board.getSpace(nearest);
      r.landOn(p, buyThresholds[currentPlayer], countRailroads(r.getOwner()) + 1);
    } 
    else if (d.equals("Advance token to nearest Utility. If unowned, you may buy it from the Bank. If owned, throw dice and pay owner a total ten times amount thrown.")) {
      int nearest = nearestUtility(p.getPosition());
      moveToSpace(p, nearest);
      Utility u = (Utility)board.getSpace(nearest);
      u.landOn(p, buyThresholds[currentPlayer], dice.getTotal(), 2);
    } 
    else if (d.equals("Go to Jail. Go directly to Jail, do not pass Go, do not collect $200.")) {
      p.goToJail();
      println(p.getName() + " is sent to Jail!");  
    } 
    else if (d.equals("Go Back 3 Spaces.")) {
      p.setPosition(p.getPosition() - 3);
      println(p.getName() + " goes back 3 spaces to " + board.getSpace(p.getPosition()).getName());
      AbstractSpace landed = board.getSpace(p.getPosition());
      if (landed instanceof Property) { 
        ((Property)landed).landOn(p, buyThresholds[currentPlayer]); 
      }
      else if (landed instanceof Railroad) {
        Railroad r = (Railroad)landed;
        r.landOn(p, buyThresholds[currentPlayer], countRailroads(r.getOwner()));
      }
      else if (landed instanceof Utility) {
        Utility u = (Utility)landed;
        u.landOn(p, buyThresholds[currentPlayer], dice.getTotal(), countUtilities(u.getOwner()));
      }
      else if (landed instanceof Tax) { 
        ((Tax)landed).landOn(p); 
      }
      else if (landed instanceof Chance) {
        Card c2 = board.getChanceDeck().drawCard();
        println(p.getName() + " draws Chance: " + c2.description);
        applyCard(p, c2);
      }
      else if (landed instanceof CommunityChest) {
        Card c2 = board.getCommunityDeck().drawCard();
        println(p.getName() + " draws Community Chest: " + c2.description);
        applyCard(p, c2);
      }
    } 
    else if (d.equals("Get Out of Jail Free.")) {
      p.giveJailFreeCard();
      println(p.getName() + " receives Get Out of Jail Free card");
    } 
    else if (d.equals("Bank pays you dividend of $50.")) {
      p.receiveMoney(50);
      println(p.getName() + " collects $50 dividend");
    } 
    else if (d.equals("Your building loan matures. Collect $150.")) {
      p.receiveMoney(150);
      println(p.getName() + " collects $150 building loan");
    } 
    else if (d.equals("Bank error in your favor. Collect $200.")) {
      p.receiveMoney(200);
      println(p.getName() + " collects $200 bank error");
    } 
    else if (d.equals("Holiday fund matures. Receive $100.")) {
      p.receiveMoney(100);
      println(p.getName() + " collects $100 holiday fund");
    } 
    else if (d.equals("Life insurance matures. Collect $100.")) {
      p.receiveMoney(100);
      println(p.getName() + " collects $100 life insurance");
    } 
    else if (d.equals("Income tax refund. Collect $20.")) {
      p.receiveMoney(20);
      println(p.getName() + " collects $20 tax refund");
    } 
    else if (d.equals("Receive $25 consultancy fee.")) {
      p.receiveMoney(25);
      println(p.getName() + " collects $25 consultancy fee"); 
    } 
    else if (d.equals("You have won second prize in a beauty contest. Collect $10.")) {
      p.receiveMoney(10);
      println(p.getName() + " collects $10 beauty contest");
    } 
    else if (d.equals("You inherit $100.")) {
      p.receiveMoney(100);
      println(p.getName() + " collects $100 inheritance");
    } 
    else if (d.equals("From sale of stock you get $50.")) {
      p.receiveMoney(50);
      println(p.getName() + " collects $50 stock sale");  
    } 
    else if (d.equals("Doctor's fee. Pay $50.")) {
      handlePayment(p, 50, null);
      println(p.getName() + " pays $50 doctor's fee"); 
    } 
    else if (d.equals("Pay hospital fees of $100.")) {
      handlePayment(p, 100, null);
      println(p.getName() + " pays $100 hospital fee");
    } 
    else if (d.equals("Pay school fees of $50.")) {
      handlePayment(p, 50, null);
      println(p.getName() + " pays $50 school fee");
    } 
    else if (d.equals("Speeding fine $15.")) {
      handlePayment(p, 15, null);
      println(p.getName() + " pays $15 speeding fine");
    } 
    else if (d.equals("Make general repairs on all your property. For each house pay $25. For each hotel pay $100.")) {
      int due = countBuildings(p, false) * 25 + countBuildings(p, true) * 100;
      handlePayment(p, countBuildings(p, false) * 25 + countBuildings(p, true) * 100, null);
      handlePayment(p, countBuildings(p, false) * 40 + countBuildings(p, true) * 115, null);
      println(p.getName() + " pays $" + due + " for repairs"); 
    } 
    else if (d.equals("You are assessed for street repair. $40 per house. $115 per hotel.")) {
      int due = countBuildings(p, false) * 40 + countBuildings(p, true) * 115;
      handlePayment(p, countBuildings(p, false) * 25 + countBuildings(p, true) * 100, null);
      handlePayment(p, countBuildings(p, false) * 40 + countBuildings(p, true) * 115, null);
      println(p.getName() + " pays $" + due + " for street repair"); 
    } 
    else if (d.equals("You have been elected Chairman of the  Board. Pay each player $50.")) {
      for (Player other : players) {
        if (other != p) {
          handlePayment(p, 50, other);
          println(p.getName() + " pays $50 to " + other.getName());
        }
      }
    } 
    else if (d.equals("It is your birthday. Collect $10 from every player.")) {
      for (Player other : players) {
        if (other != p) {
          handlePayment(other, 10, p);
          println(other.getName() + " pays $10 to " + p.getName());
        }
      }
    } 
    else {
      println("Card not found: " + d);
    }
  }
  
  private void unmortgage(Player p) {
    for (AbstractSpace space : p.getAssets()) {
      if (space instanceof Property) {
        Property property = (Property)space;
        if (property.isMortgaged()) {
          int unmortgageCost = (int)(property.getMortgagePrice() * 1.1);
          if (unmortgageCost <= p.getMoney() * buyThresholds[currentPlayer]) {
            property.setMortgaged(false);
            p.payMoney(unmortgageCost);
            println(p.getName() + " unmortgaged " + property.getName() + " for $" + unmortgageCost);
          }
        }
      }
      else if (space instanceof Railroad) {
        Railroad r = (Railroad)space;
        if (r.isMortgaged()) {
          int unmortgageCost = (int)(r.getMortgagePrice() * 1.1);
          if (unmortgageCost <= p.getMoney() * buyThresholds[currentPlayer]) {
            r.setMortgaged(false);
            p.payMoney(unmortgageCost);
            println(p.getName() + " unmortgaged " + r.getName() + " for $" + unmortgageCost);
          }
        }
      }
      else if (space instanceof Utility) {
        Utility u = (Utility)space;
        if (u.isMortgaged()) {
          int unmortgageCost = (int)(u.getMortgagePrice() * 1.1);
          if (unmortgageCost <= p.getMoney() * buyThresholds[currentPlayer]) {
            u.setMortgaged(false);
            p.payMoney(unmortgageCost);
            println(p.getName() + " unmortgaged " + u.getName() + " for $" + unmortgageCost);
          }
        }
      }
    }
  }
  
  private void mortgageToCover(Player p, int amount) {
    mortgageRailroadsUtilities(p, amount);
    if (p.getMoney() < amount) 
      mortgageIncompleteProperties(p, amount);
    if (p.getMoney() < amount) 
      sellHousesCheap(p, amount);
    if (p.getMoney() < amount) 
      mortgagePropertiesCheap(p, amount);
    if (p.getMoney() < amount) 
      sellHousesExpensive(p, amount);
  }
  
  private void mortgageRailroadsUtilities(Player p, int amount) {
    for (AbstractSpace space : p.getAssets()) {
      if (p.getMoney() >= amount) 
        break;
      if (space instanceof Railroad) {
        Railroad r = (Railroad)space;
        if (!r.isMortgaged()) {
          r.setMortgaged(true);
          p.receiveMoney(r.getMortgagePrice());
          println(p.getName() + " mortgaged " + r.getName() + " for $" + r.getMortgagePrice());
        }
      } 
      else if (space instanceof Utility) {
        Utility u = (Utility)space;
        if (!u.isMortgaged()) {
          u.setMortgaged(true);
          p.receiveMoney(u.getMortgagePrice());
          println(p.getName() + " mortgaged " + u.getName() + " for $" + u.getMortgagePrice());
        }
      }
    }
  }
  
  private void mortgageIncompleteProperties(Player p, int amount) {
    for (AbstractSpace space : p.getAssets()) {
      if (p.getMoney() >= amount) 
        break;
      if (space instanceof Property) {
        Property property = (Property)space;
        if (!property.isMortgaged() && property.getHouses() == 0 && !p.ownsFullColorGroup(property.getColorGroup(), board)) {
          property.setMortgaged(true);
          p.receiveMoney(property.getMortgagePrice());
          println(p.getName() + " mortgaged " + property.getName() + " for $" + property.getMortgagePrice());
        }
      }
    }
  }
  
  private void sellHousesCheap(Player p, int amount) {
    String[] colorGroups = {"brown", "lightBlue", "magenta", "orange", "red", "yellow", "green", "blue"};
    for (String colorGroup : colorGroups) {
      if (p.getMoney() >= amount) 
        break;
      if (p.ownsFullColorGroup(colorGroup, board)) {
        ArrayList<Property> group = p.getColorGroup(colorGroup);
        boolean sold = true;
        while (sold && p.getMoney() < amount) {
          sold = false;
          int maxHouses = 0;
          for (Property property : group) {
            maxHouses = max(maxHouses, property.getHouses());
          }
          for (Property property : group) {
            if (property.getHouses() == maxHouses && property.getHouses() > 0) {
              property.setHouses(property.getHouses() - 1);
              p.receiveMoney(property.getBuildingCost() / 2);
              println(p.getName() + " sold a house on " + property.getName());
              sold = true;
              break;
            }
          }
        }
      }
    }
  }
  
  private void mortgagePropertiesCheap(Player p, int amount) {
    String[] colorGroups = {"brown", "lightBlue", "magenta", "orange", "red", "yellow", "green", "blue"};
    for (String colorGroup : colorGroups) {
      if (p.getMoney() >= amount) break;
      ArrayList<Property> group = p.getColorGroup(colorGroup);
      for (Property property : group) {
        if (p.getMoney() >= amount) break;
        if (!property.isMortgaged() && property.getHouses() == 0) {
          property.setMortgaged(true);
          p.receiveMoney(property.getMortgagePrice());
          println(p.getName() + " mortgaged " + property.getName() + " for $" + property.getMortgagePrice());
        }
      }
    }
  }
  
  private void sellHousesExpensive(Player p, int amount) {
    String[] colorGroups = {"blue", "green", "yellow", "red", "orange", "magenta", "lightBlue", "brown"};
    for (String colorGroup : colorGroups) {
      if (p.getMoney() >= amount) break;
      if (p.ownsFullColorGroup(colorGroup, board)) {
        ArrayList<Property> group = p.getColorGroup(colorGroup);
        boolean sold = true;
        while (sold && p.getMoney() < amount) {
          sold = false;
          int maxHouses = 0;
          for (Property property : group) {
            maxHouses = max(maxHouses, property.getHouses());
          }
          for (Property property : group) {
            if (property.getHouses() == maxHouses && property.getHouses() > 0) {
              property.setHouses(property.getHouses() - 1);
              p.receiveMoney(property.getBuildingCost() / 2);
              println(p.getName() + " sold a house on " + property.getName());
              sold = true;
              break;
            }
          }
        }
      }
    }
  }
  
  private void handlePayment(Player p, int amount, Player creditor) {
    if (p.getMoney() < amount) {
      mortgageToCover(p, amount);
    }
    if (p.getMoney() >= amount) {
      p.payMoney(amount);
      if (creditor != null) creditor.receiveMoney(amount);
    } else {
      handleBankruptcy(p, creditor);
    }
  }
  
  private void handleBankruptcy(Player p, Player p2) {
    println(p.getName() + " is bankrupt!");
    for (AbstractSpace space : p.getAssets()) {
      if (space instanceof Property) {
        Property property = (Property)space;
        property.setOwner(p2);
        if (p2 != null) 
          p2.addAsset(property);
        property.setHouses(0);
      } 
      else if (space instanceof Railroad) {
        Railroad r = (Railroad)space;
        r.setOwner(p2);
        if (p2 != null) 
          p2.addAsset(r);
      } 
      else if (space instanceof Utility) {
        Utility u = (Utility)space;
        u.setOwner(p2);
        if (p2 != null) p2.addAsset(u);
      }
      if (p2 == null) {
        if (space instanceof Property)  { 
          ((Property)space).setOwner(null); 
        }
        else if (space instanceof Railroad) { 
          ((Railroad)space).setOwner(null); 
        }
        else if (space instanceof Utility)  { 
          ((Utility)space).setOwner(null); 
        }
      }
    }
    if (p2 != null) {
      p2.receiveMoney(p.getMoney());
    }
    p.setMoney(0);
    players.remove(p);
    if (currentPlayer >= players.size()) {
      currentPlayer = 0;
    }
  }
  
  private int calcNetWorth(Player p) {
    int total = p.getMoney();
    for (AbstractSpace space : p.getAssets()) {
      if (space instanceof Property) {
        Property prop = (Property)space;
        total += prop.getMortgagePrice();
        total += prop.getHouses() * (prop.getBuildingCost() / 2);
      } else if (space instanceof Railroad) {
        Railroad r = (Railroad)space;
        total += r.getMortgagePrice();
      } else if (space instanceof Utility) {
        Utility u = (Utility)space;
        total += u.getMortgagePrice();
      }
    }
    return total;
  }

  public void mousePressed() {
    if(checkWin() == false) {
      advanceTurn();
    }
    else {
      System.out.println("Game over");
    }
  }
  
  public void draw() {
    display.drawBoard();
    display.drawSidebars();
    display.drawDice();
    display.drawLog();
  }
  
  public ArrayList<Player> getPlayers() { 
    return players; 
  }
}

GameController gameControl;
PImage gameboard;

void gameSetup() {
  Board board = new Board();
  gameboard = loadImage(dataPath("images/monopoly.png"));
  gameboard.resize(800, 0); 
  Dice dice = new Dice();
  ArrayList<Player> players = new ArrayList<Player>();
  players.add(new Player("Bot 1", 1500, new Token(0)));
  players.add(new Player("Bot 2", 1500, new Token(1)));
  Display display = new Display(board, players, dice);
  gameControl = new GameController(board, players, dice, display);

}

void gameDraw() {
  background(0);
  image(gameboard, 200, 0);
  gameControl.draw();
}

void gameMousePressed() {
  if (!gameControl.checkWin()) {
    gameControl.advanceTurn();
  } else {
    println("Game over!");
    for (Player p : gameControl.getPlayers()) {
      println(p.getName() + " finished with $" + p.getMoney());
    }
  }
}
