class Display {
  private Board board;
  private ArrayList<Player> players;
  private Dice dice;

  public Display(Board board, ArrayList<Player> players, Dice dice) {
    this.board = board;
    this.players = players;
    this.dice = dice;
  }

  public void drawBoard() {}
  public void drawSidebars() {}
  public void drawLog() {}
  public void drawDice() {}
  public void drawSpace() {}
}
