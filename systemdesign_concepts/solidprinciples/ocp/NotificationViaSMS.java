package solidprinciples.ocp;

public class NotificationViaSMS implements Notification{
    @Override
    public void send() {
        System.out.println("Sending SMS Notification");
    }
}
