import java.util.Scanner;

class Board {
  private AbstractSpace[] board;
  
  public Board() {
    try {
      this.board = new AbstractSpace[40];
      File boardInfo = new File(dataPath("board.txt"));
      Scanner boardScan = new Scanner(boardInfo);
      
      File propertiesInfo = new File(dataPath("properties.txt"));
      Scanner propertyScan = new Scanner(propertiesInfo);
      
      File railroadsInfo = new File(dataPath("railroads.txt"));
      Scanner railroadScan = new Scanner(railroadsInfo);
      
      File utilitiesInfo = new File(dataPath("utilities.txt"));
      Scanner utilityScan = new Scanner(utilitiesInfo);
      
      File chanceInfo = new File(dataPath("chance.txt"));
      Scanner chanceScan = new Scanner(chanceInfo);
      
      File communityInfo = new File(dataPath("communitychest.txt"));
      Scanner communityScan = new Scanner(communityInfo);
      
      while(boardScan.hasNextLine()) {
        int i = 0;
        String line = boardScan.nextLine();
        String[] parts = split(line, ',');
        if(parts[1].equals("Property")) {
          String propertyLine = propertyScan.nextLine();
          String[] propertyArgs = split(propertyLine, ',');
          board[i] = new Property(propertyArgs[0],propertyArgs[1],Integer.parseInt(propertyArgs[2]).parseToInt(),propertyArgs[3],propertyArgs[4],propertyArgs[5],propertyArgs[6],propertyArgs[7],propertyArgs[8],propertyArgs[9],propertyArgs[10]);
          i++;
        }
      }
    }
    catch(Exception e) {
      System.out.println("file not found");
      this.board = new AbstractSpace[40]; 
    }
  }
}
