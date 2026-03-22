package solidprinciples.lsp.validexample1;

public class Penguiin extends BirdAfterLSP implements Swimmable {

    @Override
    public void eat() {
        System.out.println("penguin can eat");
    }

    @Override
    public void swim() {
        System.out.println("penguin can swim");
    }
}
