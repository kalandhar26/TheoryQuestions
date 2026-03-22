package solidprinciples.ocp;

public class TestNotification {

    public static void main(String[] args) {
        NotificationBeforeOCP bocp = new NotificationBeforeOCP();
        bocp.sendNotification("SMS");

        NotificationAfterOCP aocp = new NotificationAfterOCP();
        NotificationViaSMS notification = new NotificationViaSMS();
        aocp.sendNotification(notification);
    }
}
