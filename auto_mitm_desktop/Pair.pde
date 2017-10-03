/* stores a pair of antonyms */

class Pair{
 private final String left;
  private final String right;

  public Pair(String left, String right) {
    this.left = left;
    this.right = right;
  }

  public String getLeft() { return left; }
  public String getRight() { return right; }

  @Override
  public int hashCode() { return left.hashCode() ^ right.hashCode(); }

  @Override
  public boolean equals(Object o) {
    if (!(o instanceof Pair)) return false;
    Pair pairo = (Pair) o;
    return this.left.equals(pairo.getLeft()) &&
           this.right.equals(pairo.getRight());
  } 
}