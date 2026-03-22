package solidprinciples.isp.badexample1;

public interface PaymentServiceBeforeISP {

    void authorizePayment();
    void capturePayment();
    void refundPayment();
    void voidPayment();
    void createSubscription();
    void cancelSubscription();
    void generateReport();
    void exportData();
    void sendNotification();
}
