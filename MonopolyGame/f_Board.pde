import java.util.Scanner;
import java.io.File;

class Board {
  private AbstractSpace[] board;
  private Deck chanceDeck;
  private Deck communityDeck;

  public Board() {
    try {
      this.board = new AbstractSpace[40];

      Scanner boardScan = new Scanner(new File(dataPath("board.txt")));
      Scanner propertyScan = new Scanner(new File(dataPath("properties.txt")));
      Scanner railroadScan = new Scanner(new File(dataPath("railroads.txt")));
      Scanner utilityScan = new Scanner(new File(dataPath("utilities.txt")));
      Scanner chanceScan = new Scanner(new File(dataPath("chance.txt")));
      Scanner communityScan = new Scanner(new File(dataPath("communitychest.txt")));

      chanceDeck = new Deck(chanceScan);
      communityDeck = new Deck(communityScan);

      int i = 0;
      while (boardScan.hasNextLine() && i < 40) {
        String line = boardScan.nextLine().trim();
        if (line.isEmpty()) continue;

        String[] parts = split(line, ',');
        String spaceName = parts[0].trim();
        String spaceType = parts[1].trim();

        if (spaceType.equals("Property")) {
          String[] p = split(propertyScan.nextLine(), ',');
          board[i] = new Property(p[0], p[1],
            int(p[2]), int(p[3]), int(p[4]), int(p[5]),
            int(p[6]), int(p[7]), int(p[8]), int(p[9]), int(p[10]));       
        } 
        else if (spaceType.equals("Railroad")) {
          String[] r = split(railroadScan.nextLine(), ',');
          board[i] = new Railroad(r[0], int(r[1]), int(r[2]));
        } 
        else if (spaceType.equals("Utility")) {
          String[] u = split(utilityScan.nextLine(), ',');
          board[i] = new Utility(u[0], int(u[1]), int(u[2]));  
        } 
        else if (spaceType.equals("CommunityChest")) {
          board[i] = new CommunityChest(spaceName, communityDeck);
        } 
        else if (spaceType.equals("Chance")) {
          board[i] = new Chance(spaceName, chanceDeck);
        } 
        else if (spaceType.equals("Tax")) {
          int taxAmount;
          if(spaceName.equals("Income Tax")) {
            taxAmount = 200;
          }
          else { 
            taxAmount = 100;
          }
          board[i] = new Tax(spaceName, taxAmount); 
        } 
        else if (spaceType.equals("Go")) {
          board[i] = new Go();
        }
        else if (spaceType.equals("Jail")) {
          board[i] = new Jail(); 
        }
        else if (spaceType.equals("GoToJail")) {
          board[i] = new GoToJail();    
        }
        else if (spaceType.equals("FreeParking")) { 
          board[i] = new FreeParking(); 
        }
        i++;
      }
    }
    catch (Exception e) {
      println("Board load error: " + e.getMessage());
      this.board = new AbstractSpace[40];
    }
  }

  public AbstractSpace getSpace(int index) {
    return board[((index % 40) + 40) % 40];
  }
  
  public Deck getChanceDeck() {
    return chanceDeck;
  }
  
  public Deck getCommunityDeck() {
    return communityDeck;
  }
}
