class GameController {
  private Player[] players;
  private Board board;
  private Dice dice;
  private Display display;
  private int currentPlayer;
  private float[] buyThresholds = {0.5, 0.5};
  
  public GameController(Board b, Player[] players, Dice dice, Display display) {
    this.board = b;
    this.players = players;
    this.dice = dice;
    this.display = display;
    this.currentPlayer = 0;
  }
  
  public void advanceTurn() {
    Player p = players[currentPlayer];
    println("--- Turn " + p.getTurnCount() + " | " + p.getName() + " ---"); 
    boolean tookTurn = true;
    if (p.isInJail()) {
      if (p.hasJailFreeCard()) {
        p.useJailFreeCard();
        p.releaseFromJail();
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
          p.releaseFromJail();
          p.move(dice.getTotal());
          println(p.getName() + " rolled doubles, released from jail");
        } 
        else {
          p.incrementJailTurn();
          if (p.getJailTurns() >= 3) {
            p.payMoney(50);
            p.releaseFromJail();
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
      if (landed instanceof Property)            { ((Property)landed).landOn(p, buyThresholds[currentPlayer]); }
      else if (landed instanceof Railroad) {
        Railroad r = (Railroad)landed;
        r.landOn(p, buyThresholds[currentPlayer], countRailroads(r.getOwner()));
      }
      else if (landed instanceof Utility) {
        Utility u = (Utility)landed;
        u.landOn(p, buyThresholds[currentPlayer], dice.getTotal(), countUtilities(u.getOwner()));
      }
      else if (landed instanceof Go) { ((Go)landed).landOn(p); }
      else if (landed instanceof GoToJail) { ((GoToJail)landed).landOn(p); }
      else if (landed instanceof Tax) { ((Tax)landed).landOn(p); }
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
    p.incrementTurn();
    currentPlayer = (currentPlayer + 1) % players.length;
  }
  
  public boolean checkWin() {
   for(Player p: players) {
      if(p.getMoney() == 0)
        return true;
   }
   return false;
  }
  
  public void rollDice() {
    dice.roll();
  }
  
  public int countRailroads(Player p) {
    if (p == null) return 0;
    int count = 0;
    for (int i = 0; i < 40; i++) {
      AbstractSpace space = board.getSpace(i);
      if (space instanceof Railroad && ((Railroad)space).getOwner() == p) count++;
    }
    return count;
  }
  
  public int countUtilities(Player p) {
    if (p == null) return 0;
    int count = 0;
    for (int i = 0; i < 40; i++) {
      AbstractSpace space = board.getSpace(i);
      if (space instanceof Utility && ((Utility)space).getOwner() == p) count++;
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
      if (position <= r) return r;
    }
    return 5;
  }
  
  private int nearestUtility(int position) {
    if (position <= 12) return 12;
    if (position <= 28) return 28;    
    return 12;
  }
  
  private void applyCard(Player p, Card c) {
    String desc = c.description;
    
    if (desc.equals("Advance to Boardwalk.")) {
      moveToSpace(p, 39);      
    } 
    else if (desc.equals("Advance to Go (Collect $200).")) {
      p.setPosition(0);
      p.receiveMoney(200);
      println(p.getName() + " advances to Go, collects $200");  
    } 
    else if (desc.equals("Advance to Illinois Avenue. If you pass Go, collect $200.")) {
      moveToSpace(p, 24);  
    } 
    else if (desc.equals("Advance to St. Charles Place. If you pass Go, collect $200.")) {
      moveToSpace(p, 11);  
    } 
    else if (desc.equals("Take a trip to Reading Railroad. If you pass Go, collect $200.")) {
      moveToSpace(p, 5); 
    } 
    else if (desc.equals("Advance to the nearest Railroad. If unowned, you may buy it from the Bank. If owned, pay owner twice the rental to which they are otherwise entitled.")) {
      int nearest = nearestRailroad(p.getPosition());
      moveToSpace(p, nearest);
      Railroad r = (Railroad)board.getSpace(nearest);
      r.landOn(p, buyThresholds[currentPlayer], countRailroads(r.getOwner()));
    } 
    else if (desc.equals("Advance token to nearest Utility. If unowned, you may buy it from the Bank. If owned, throw dice and pay owner a total ten times amount thrown.")) {
      int nearest = nearestUtility(p.getPosition());
      moveToSpace(p, nearest);
      Utility u = (Utility)board.getSpace(nearest);
      u.landOn(p, buyThresholds[currentPlayer], dice.getTotal(), countUtilities(u.getOwner()));
    } 
    else if (desc.equals("Go to Jail. Go directly to Jail, do not pass Go, do not collect $200.")) {
      p.goToJail();
      println(p.getName() + " is sent to Jail!");  
    } 
    else if (desc.equals("Go Back 3 Spaces.")) {
      p.setPosition(p.getPosition() - 3);
      println(p.getName() + " goes back 3 spaces to " + board.getSpace(p.getPosition()).getName());
      AbstractSpace landed = board.getSpace(p.getPosition());
      if (landed instanceof Property)            { ((Property)landed).landOn(p, buyThresholds[currentPlayer]); }
      else if (landed instanceof Railroad) {
        Railroad r = (Railroad)landed;
        r.landOn(p, buyThresholds[currentPlayer], countRailroads(r.getOwner()));
      }
      else if (landed instanceof Utility) {
        Utility u = (Utility)landed;
        u.landOn(p, buyThresholds[currentPlayer], dice.getTotal(), countUtilities(u.getOwner()));
      }
      else if (landed instanceof Tax)            { ((Tax)landed).landOn(p); }
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
    else if (desc.equals("Get Out of Jail Free.")) {
      p.giveJailFreeCard();
      println(p.getName() + " receives Get Out of Jail Free card");
    } 
    else if (desc.equals("Bank pays you dividend of $50.")) {
      p.receiveMoney(50);
      println(p.getName() + " collects $50 dividend");
    } 
    else if (desc.equals("Your building loan matures. Collect $150.")) {
      p.receiveMoney(150);
      println(p.getName() + " collects $150 building loan");
    } 
    else if (desc.equals("Bank error in your favor. Collect $200.")) {
      p.receiveMoney(200);
      println(p.getName() + " collects $200 bank error");
    } 
    else if (desc.equals("Holiday fund matures. Receive $100.")) {
      p.receiveMoney(100);
      println(p.getName() + " collects $100 holiday fund");
    } 
    else if (desc.equals("Life insurance matures. Collect $100.")) {
      p.receiveMoney(100);
      println(p.getName() + " collects $100 life insurance");
    } 
    else if (desc.equals("Income tax refund. Collect $20.")) {
      p.receiveMoney(20);
      println(p.getName() + " collects $20 tax refund");
    } 
    else if (desc.equals("Receive $25 consultancy fee.")) {
      p.receiveMoney(25);
      println(p.getName() + " collects $25 consultancy fee"); 
    } 
    else if (desc.equals("You have won second prize in a beauty contest. Collect $10.")) {
      p.receiveMoney(10);
      println(p.getName() + " collects $10 beauty contest");
    } 
    else if (desc.equals("You inherit $100.")) {
      p.receiveMoney(100);
      println(p.getName() + " collects $100 inheritance");
    } 
    else if (desc.equals("From sale of stock you get $50.")) {
      p.receiveMoney(50);
      println(p.getName() + " collects $50 stock sale");  
    } 
    else if (desc.equals("Doctor's fee. Pay $50.")) {
      p.payMoney(50);
      println(p.getName() + " pays $50 doctor's fee"); 
    } 
    else if (desc.equals("Pay hospital fees of $100.")) {
      p.payMoney(100);
      println(p.getName() + " pays $100 hospital fee");
    } 
    else if (desc.equals("Pay school fees of $50.")) {
      p.payMoney(50);
      println(p.getName() + " pays $50 school fee");
    } 
    else if (desc.equals("Speeding fine $15.")) {
      p.payMoney(15);
      println(p.getName() + " pays $15 speeding fine");
    } 
    else if (desc.equals("Make general repairs on all your property. For each house pay $25. For each hotel pay $100.")) {
      int due = countBuildings(p, false) * 25 + countBuildings(p, true) * 100;
      p.payMoney(due);
      println(p.getName() + " pays $" + due + " for repairs"); 
    } 
    else if (desc.equals("You are assessed for street repair. $40 per house. $115 per hotel.")) {
      int due = countBuildings(p, false) * 40 + countBuildings(p, true) * 115;
      p.payMoney(due);
      println(p.getName() + " pays $" + due + " for street repair"); 
    } 
    else if (desc.equals("You have been elected Chairman of the  Board. Pay each player $50.")) {
      for (Player other : players) {
        if (other != p) {
          p.payRent(50, other);
          println(p.getName() + " pays $50 to " + other.getName());
        }
      }
    } 
    else if (desc.equals("It is your birthday. Collect $10 from every player.")) {
      for (Player other : players) {
        if (other != p) {
          other.payRent(10, p);
          println(other.getName() + " pays $10 to " + p.getName());
        }
      }
    } 
    else {
      println("Unhandled card: " + desc);
    }
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
  
  public Player[] getPlayers() { 
    return players; 
  }
}

GameController gc;

void gameSetup() {
  Board board = new Board();
  Dice dice = new Dice();
  Player[] players = new Player[] {
    new Player("Bot 1", 1500, new Token(0)),
    new Player("Bot 2", 1500, new Token(1))
  };
  Display display  = new Display(board, players, dice);
  gc = new GameController(board, players, dice, display);
}

void gameDraw() {
  background(0);
  gc.draw();
}

void gameMousePressed() {
  if (!gc.checkWin()) {
    gc.advanceTurn();
  } else {
    println("Game over!");
    // print winner
    for (Player p : gc.getPlayers()) {
      println(p.getName() + " finished with $" + p.getMoney());
    }
  }
}
