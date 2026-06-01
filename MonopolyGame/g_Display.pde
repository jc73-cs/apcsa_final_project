class Display {
  private ArrayList<Player> players;
  private Dice dice;
  private float boardX, boardY, boardSize;
  private float sidebarWidth = 300;
  private float[] spaceX, spaceY;
  private PImage boardImage;
  private PImage[] tokenImages;
  
  public Display(ArrayList<Player> players, Dice dice) {
    this.players = players;
    this.dice = dice;
    boardSize = height * 0.85;
    boardX = sidebarWidth;
    boardY = 10; 
    boardImage = loadImage("images/monopoly.png");
    tokenImages = new PImage[players.size()];
    tokenImages[0] = loadImage("images/car.png");
    tokenImages[1] = loadImage("images/thimble.png");
    tokenImages[0].resize(53, 40);
    tokenImages[1].resize(31, 40);
    spaceX = new float[40];
    spaceY = new float[40];
    calculateSpaceCoordinates();
  }
  
  private void calculateSpaceCoordinates() {
    float cornerSize = boardSize / 9.0;
    float spaceSize  = (boardSize - 2 * cornerSize) / 9.0;
    for (int i = 0; i <= 10; i++) {
      if (i == 0) {
        spaceX[i] = boardX + boardSize - cornerSize / 2;
        spaceY[i] = boardY + boardSize - cornerSize / 2;
      } 
      else {
        spaceX[i] = boardX + boardSize - cornerSize - (i - 0.5) * spaceSize;
        spaceY[i] = boardY + boardSize - cornerSize / 2;
      }
    }
    for (int i = 10; i <= 20; i++) {
      if (i == 10) {
        spaceX[i] = boardX + cornerSize / 2;
        spaceY[i] = boardY + boardSize - cornerSize / 2;
      } 
      else {
        spaceX[i] = boardX + cornerSize / 2;
        spaceY[i] = boardY + boardSize - cornerSize - (i - 10 - 0.5) * spaceSize;
      }
    }
    for (int i = 20; i <= 30; i++) {
      if (i == 20) {
        spaceX[i] = boardX + cornerSize / 2;
        spaceY[i] = boardY + cornerSize / 2;
      } 
      else {
        spaceX[i] = boardX + cornerSize + (i - 20 - 0.5) * spaceSize;
        spaceY[i] = boardY + cornerSize / 2;
      }
    }
    for (int i = 30; i <= 39; i++) {
      if (i == 30) {
        spaceX[i] = boardX + boardSize - cornerSize / 2;
        spaceY[i] = boardY + cornerSize / 2;
      }
      else {
        spaceX[i] = boardX + boardSize - cornerSize / 2;
        spaceY[i] = boardY + cornerSize + (i - 30 - 0.5) * spaceSize;
      }
    }
  }
  
  public void drawBoard() {
    imageMode(CORNER);
    image(boardImage, boardX, boardY, boardSize, boardSize);
  }
  
  public void drawTokens() {
    imageMode(CENTER);
    for (int i = 0; i < players.size(); i++) {
      Player p = players.get(i);
      Token t = p.getToken();
      float targetX = spaceX[p.getPosition()];
      float targetY = spaceY[p.getPosition()];
      t.update(targetX, targetY);
      image(tokenImages[i], t.screenX + (i * 15), t.screenY);
    }
    imageMode(CORNER);
  }
  
  public void drawSidebars() {
    if (players.size() > 0)
      drawPlayerSidebar(players.get(0), 0, sidebarWidth / 2);
    if (players.size() > 1)
      drawPlayerSidebar(players.get(1), boardX + boardSize, boardX + boardSize + sidebarWidth / 2);
  }
    
  private void drawPlayerSidebar(Player p, float x, float centerX) {
    fill(50);
    rect(x, 0, sidebarWidth, height);
    fill(255);
    textAlign(CENTER);
    textSize(16);
    text(p.getName(), centerX, 30);
    text("$" + p.getMoney(), centerX, 55);

    float y = 80;
    String[] colorGroups = {"brown", "lightBlue", "magenta", "orange", "red", "yellow", "green", "blue"};
    for (String colorGroup : colorGroups) {
      for (AbstractSpace space : p.getAssets()) {
        if (space instanceof Property) {
          Property prop = (Property)space;
          if (prop.getColorGroup().equals(colorGroup)) {
            fill(getColor(colorGroup));
            rect(x + 10, y, sidebarWidth - 20, 20);
            fill(0);
            textSize(11);
            textAlign(LEFT);
            String status;
            if (prop.isMortgaged()) {
              status = " [M]";
            } 
            else if (prop.getHouses() == 5) {
              status = " [H]";
            } 
            else if (prop.getHouses() > 0) {
              status = " [" + prop.getHouses() + "]";
            } 
            else {
              status = "";
            }
            text(prop.getName() + status, x + 15, y + 14);
            y += 25;
          }
        }
      }
    }
    fill(200);
    for (AbstractSpace space : p.getAssets()) {
      if (space instanceof Railroad) {
        Railroad r = (Railroad)space;
        rect(x + 10, y, sidebarWidth - 20, 20);
        fill(0);
        textSize(11);
        textAlign(LEFT);
        String status;
        if (r.isMortgaged()) {
          status = " [M]";
        } 
        else {
          status = "";
        }
        text(r.getName() + status, x + 15, y + 14);
        fill(200);
        y += 25;
      }
    }  
    fill(150, 200, 150);
    for (AbstractSpace space : p.getAssets()) {
      if (space instanceof Utility) {
        Utility u = (Utility)space;
        rect(x + 10, y, sidebarWidth - 20, 20);
        fill(0);
        textSize(11);
        textAlign(LEFT);
       String status;
        if (u.isMortgaged()) {
          status = " [M]";
        } 
        else {
          status = "";
        }
        text(u.getName() + status, x + 15, y + 14);
        fill(150, 200, 150);
        y += 25;
      }
    }

  }
  
  public void drawDice() {
  float barY = boardY + boardSize + 10;
  float barH = height - barY - 10;
  float sectionW = boardSize / 2;
    float sectionTurnsX = boardX;
    fill(30);
    rect(sectionTurnsX, barY, sectionW, barH);
    fill(255);
    textAlign(CENTER);
    textSize(14);
    text("Total Turns", sectionTurnsX + sectionW / 2, barY + barH * 0.4);
    textSize(32);
    int totalTurns = 0;
    for (Player p : players) {
      totalTurns += p.getTurnCount();
    }
    text(totalTurns, sectionTurnsX + sectionW / 2, barY + barH * 0.75);
    float sectionDiceX = boardX + sectionW;
    fill(30);
    rect(sectionDiceX, barY, sectionW, barH);
    fill(255);
    textAlign(CENTER);
    textSize(14);
    text("Dice", sectionDiceX + sectionW / 2, barY + barH * 0.4);
    textSize(32);
    text(dice.getDie1() + "  +  " + dice.getDie2() + "  =  " + dice.getTotal(), sectionDiceX + sectionW / 2, barY + barH * 0.75);
  }
  
  private color getColor(String colorGroup) {
    if (colorGroup.equals("brown")) 
      return color(139, 69, 19);
    else if (colorGroup.equals("lightBlue"))
      return color(173, 216, 230);
    else if (colorGroup.equals("magenta"))  
      return color(255, 0, 255);
    else if (colorGroup.equals("orange"))
      return color(255, 165, 0);
    else if (colorGroup.equals("red"))
      return color(255, 0, 0);
    else if (colorGroup.equals("yellow"))
      return color(255, 255, 0);
    else if (colorGroup.equals("green"))
      return color(0, 128, 0);
    else if (colorGroup.equals("blue"))
      return color(0, 0, 255);
    else
      return color(200);
  }
  
  public void draw() {
    drawBoard();
    drawTokens();
    drawSidebars();
    drawDice();
  }
}
