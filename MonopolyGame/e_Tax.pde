class Tax extends AbstractSpace {
  private int amount;
  
  public Tax(String name, int amount) {
    this.name = name;
    this.amount = amount;
  }

  public void landOn(Player p) {
    p.payMoney(amount);
    println(p.getName() + " paid $" + amount + " for " + name);
    println(p.getName() + " now has $" + p.getMoney());
  }
}
