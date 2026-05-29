class Display {
  private Board board;
  private Player[] players;
  private Dice dice;

  public Display(Board board, Player[] players, Dice dice) {
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
