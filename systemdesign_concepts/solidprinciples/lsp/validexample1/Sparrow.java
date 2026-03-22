package solidprinciples.lsp.validexample1;

public class Sparrow extends BirdAfterLSP implements Flyable{
    @Override
    public void eat() {
        System.out.println("Sparrow can eat");
    }

    @Override
    public void fly() {
        System.out.println("Sparrow can fly");
    }
}
