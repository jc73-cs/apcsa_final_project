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
    rollDice();
    println("--- Turn " + p.getTurnCount() + " | " + p.getName() + " ---");
    println("Rolled: " + dice.getDie1() + " + " + dice.getDie2() + " = " + dice.getTotal());
    int steps = dice.getTotal();
    p.move(steps);
    println("Moved to: " + board.getSpace(p.getPosition()).getName());
    AbstractSpace landed = board.getSpace(p.getPosition());
    if (landed instanceof Property) { ((Property)landed).landOn(p, buyThresholds[currentPlayer]); }
    else if (landed instanceof Railroad) {
      Railroad r = (Railroad)landed;
      ((Railroad)landed).landOn(p, buyThresholds[currentPlayer], countRailroads(r.getOwner()));
    }
    else if (landed instanceof Utility) {
      Utility u = (Utility)landed;
      ((Utility)landed).landOn(p, buyThresholds[currentPlayer], dice.getTotal(), countUtilities(u.getOwner()));
    }
    else if (landed instanceof Go) { ((Go)landed).landOn(p); }
    else if (landed instanceof GoToJail) { ((GoToJail)landed).landOn(p); }
    else if (landed instanceof Tax) { ((Tax)landed).landOn(p); }
    else if (landed instanceof Chance) { ((Chance)landed).landOn(p); }
    else if (landed instanceof CommunityChest) { ((CommunityChest)landed).landOn(p); }
    if(p.hasPassedGo()) {
      println(p.getName() + " passed Go, collects $200");
      p.receiveMoney(200);
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
    println("Dice: " + dice.getDie1() + " + " + dice.getDie2() + " = " + dice.getTotal());
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
}

GameController gc;

void gameSetup() {
  size(1200, 800);
  Board board  = new Board();
  Dice dice = new Dice();
  Player[] players = new Player[] {
    new Player("Bot 1", 1500, new Token(0)),
    new Player("Bot 2", 1500, new Token(1))
  };
  Display display = new Display(board, players, dice);
  gc = new GameController(board, players, dice, display);
}

void gameDraw() {
  background(0);
  gc.draw();
}

void gameMousePressed() {
  gc.mousePressed();
}

void gameKeyPressed() {
  gc.mousePressed(); // or separate logic
}
