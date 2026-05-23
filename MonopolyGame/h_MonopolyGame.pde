class GameController {
  private Player[] players;
  private Board board;
  private int turnCount;
  private Dice dice;
  private Display display;
  private int currentPlayer;
  
  public GameController(Board b, Player[] players, Dice dice, Display display) {
    this.board = b;
    this.players = players;
    this.dice = dice;
    this.display = display;
    this.turnCount = 0;
    this.currentPlayer = 0;
  }
  
  public void advanceTurn() {
    Player p = players[currentPlayer];
    rollDice();
    int steps = dice.getTotal();
    p.move(steps);
    AbstractSpace landed = board[p.getPosition()];
    landed.landOn(p);
    if(p.hasPassedGo())
      p.receiveMoney(200);
    turnCount++;
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
      System.out.println("Game over after " + turnCount + " turns");
    }
  }
}
