package solidprinciples.ocp;

public class NotificationAfterOCP {
    public void sendNotification(Notification notification){
        notification.send();
    }
}
