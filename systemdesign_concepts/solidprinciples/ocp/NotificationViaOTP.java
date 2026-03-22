package solidprinciples.ocp;

public class NotificationViaOTP implements  Notification {
    @Override
    public void send() {
        System.out.println(" Sending OTP Notification");
    }
}
