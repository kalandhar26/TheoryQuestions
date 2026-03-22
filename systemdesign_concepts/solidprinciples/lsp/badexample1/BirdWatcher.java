package solidprinciples.lsp.badexample1;

public class BirdWatcher {

    public  void watchBirdFly(BirdBeforeLSP bird){
        bird.fly();
    }

    public static void main(String[] args) {
        BirdWatcher watcher = new BirdWatcher();

        BirdBeforeLSP sparrow = new BirdBeforeLSP();
        watcher.watchBirdFly(sparrow); // Works fine

        Penguin penguin = new Penguin();
        watcher.watchBirdFly(penguin); // Throw an exception
    }
}
