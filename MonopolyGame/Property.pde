class Property extends AbstractSpace {
  private String name;
  private String colorGroup;
  private int cost;
  private int[] rent = new int[6];
  private int houses;
  private int buildingCost;
  private int mortgagePrice;
  private boolean mortgaged; 
  
  public Property(String name,String colorGroup, int cost,int baseRent,int house1,int house2,int house3,int house4,int hotel,int buildingCost,int mortgagePrice) {
    this.name = name;
    this.colorGroup = colorGroup;
    this.cost = cost;
    this.rent[0] = baseRent;
    this.rent[1] = house1;
    this.rent[2] = house2;
    this.rent[3] = house3;
    this.rent[4] = house4;
    this.rent[5] = hotel;
    this.houses = 0;
    this.buildingCost = buildingCost;
    this.mortgagePrice = mortgagePrice;
    this.mortgaged = false;
  }
}
