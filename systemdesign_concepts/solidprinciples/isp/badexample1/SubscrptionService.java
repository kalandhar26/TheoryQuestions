package solidprinciples.isp.badexample1;

public class SubscrptionService implements PaymentServiceBeforeISP {

    // Used Methods

    @Override
    public void createSubscription() {
        System.out.println("Subscription is created");
    }

    @Override
    public void cancelSubscription() {
        System.out.println("Subscription is cancelled");
    }

    @Override
    public void sendNotification() {
        System.out.println("Sent Notification for subscription or cancellation");
    }

    // UnUsed Methods

    @Override
    public void authorizePayment() {
        System.out.println("No need to use authorizePayment in SubscrptionService");
    }

    @Override
    public void capturePayment() {
        System.out.println("No need to use capturePayment in SubscrptionService");
    }

    @Override
    public void refundPayment() {
        System.out.println("No need to use refundPayment in SubscrptionService");
    }

    @Override
    public void voidPayment() {
        System.out.println("No need to use voidPayment in SubscrptionService");
    }


    @Override
    public void generateReport() {
        System.out.println("No need to use generateReport in SubscrptionService");
    }

    @Override
    public void exportData() {
        System.out.println("No need to use exportData in SubscrptionService");
    }


}
