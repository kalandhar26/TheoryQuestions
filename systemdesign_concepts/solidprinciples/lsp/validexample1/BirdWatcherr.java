package solidprinciples.lsp.validexample1;

public class BirdWatcherr {

    public void watchBirdEat(BirdAfterLSP bird) {
        bird.eat();
    }

    public void watchBirdFly(Flyable bird) {
        bird.fly();
    }

    public void watchBirdSwim(Swimmable bird) {
        bird.swim();
    }

    public static void main(String[] args) {
        BirdWatcherr watcher = new BirdWatcherr();

        Sparrow sparrow = new Sparrow();
        watcher.watchBirdEat(sparrow);
        watcher.watchBirdFly(sparrow);
//        watcher.watchBirdSwim(sparrow); // This won't compile, which is correct

        Penguiin penguin = new Penguiin();
        watcher.watchBirdEat(penguin);
        watcher.watchBirdSwim(penguin);
//        watcher.watchBirdFly(penguin); // This won't compile, which is correct
    }
}
