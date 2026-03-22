package solidprinciples.ocp;

public class NotificationViaEmail implements Notification{
    @Override
    public void send() {
        System.out.println();
    }
}
