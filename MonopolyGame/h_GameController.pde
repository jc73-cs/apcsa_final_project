class GameController {
  private Player[] players;
  private Board board;
  private Dice dice;
  private Display display;
  private int currentPlayer;
  
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
    int steps = dice.getTotal();
    p.move(steps);
    AbstractSpace landed = board.getSpace(p.getPosition());
    if (landed instanceof Property) { ((Property)landed).landOn(p); }
    else if (landed instanceof Railroad) { ((Railroad)landed).landOn(p); }
    else if (landed instanceof Utility) { ((Utility)landed).landOn(p); }
    else if (landed instanceof Go) { ((Go)landed).landOn(p); }
    else if (landed instanceof GoToJail) { ((GoToJail)landed).landOn(p); }
    else if (landed instanceof Tax) { ((Tax)landed).landOn(p); }
    else if (landed instanceof Chance) { ((Chance)landed).landOn(p); }
    else if (landed instanceof CommunityChest) { ((CommunityChest)landed).landOn(p); }
    if(p.hasPassedGo())
      p.receiveMoney(200);
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
  Board board    = new Board();
  Dice dice      = new Dice();
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
