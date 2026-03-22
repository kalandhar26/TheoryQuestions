package solidprinciples.ocp;

public class NotificationViaIVR implements Notification{
    @Override
    public void send() {
        System.out.println("Sending IVR notification");
    }
}
