package solidprinciples.isp.validexample1;

public class SubscriptionService  implements SubscriptionOperations, Notifications{
    @Override
    public void sendNotification() {
        System.out.println("Notification sent");
    }

    @Override
    public void createSubscription() {
        System.out.println("subscription created");
    }

    @Override
    public void cancelSubscription() {
        System.out.println("subscription cancelled");
    }
}
