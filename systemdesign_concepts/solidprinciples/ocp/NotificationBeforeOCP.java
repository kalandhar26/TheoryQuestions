package solidprinciples.ocp;

public class NotificationBeforeOCP {

    public void sendNotification(String type) {
        if (type.equals("Email")) {
            System.out.println("Sending Email Notification");
        } else if (type.equals("SMS")) {
            System.out.println("Sending SMS Notification");
        } else if (type.equals("OTP")) {
            System.out.println("Sending OTP Notification");
        }else{
            System.out.println("Informing through call IVR");
        }
    }

    public void sendNotificationMessage(String type){
        switch (type) {
            case "Email" -> System.out.println("Sending Email Notification");
            case "SMS" -> System.out.println("Sending SMS Notification");
            case "OTP" -> System.out.println("Sending OTP Notification");
            default -> System.out.println("Informing through call IVR");
        }
    }
}
