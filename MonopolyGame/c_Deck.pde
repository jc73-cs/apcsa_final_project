class Deck {
  private ArrayList<Card> cards;

  public Deck(Scanner scan) {
    cards = new ArrayList<Card>();
    while (scan.hasNextLine()) {
      String line = scan.nextLine().trim();
      if (!line.isEmpty()) 
      cards.add(new Card(line));
    }
    java.util.Collections.shuffle(cards);
  }

  public Card drawCard() {
    if (cards.isEmpty()) java.util.Collections.shuffle(cards);
    Card c = cards.get(0);
    cards.remove(0);
    cards.add(c);
    return c;
  }
}
