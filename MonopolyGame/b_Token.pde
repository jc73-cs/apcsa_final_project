class Token {
  public float screenX, screenY; 
  
  public Token() {
    this.screenX = 0;
    this.screenY = 0;
  }
  
  public void update(float targetX, float targetY) {
    screenX = lerp(screenX, targetX, 0.1);
    screenY = lerp(screenY, targetY, 0.1);
  }
  
  public boolean hasReached(float targetX, float targetY) {
    return dist(screenX, screenY, targetX, targetY) < 1.0;
  }
}
