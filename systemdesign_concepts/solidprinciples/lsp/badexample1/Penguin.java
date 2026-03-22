package solidprinciples.lsp.badexample1;

// Penguin class is breaking the Liskov Principle. Whatever Parent Promised Child not able perform.
class Penguin extends BirdBeforeLSP{
    @Override
    public void fly() {
        throw new UnsupportedOperationException("Penguins can't fly");
    }
}
