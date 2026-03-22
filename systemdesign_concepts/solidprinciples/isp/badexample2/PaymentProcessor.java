package solidprinciples.isp.badexample2;

// One giant interface that does everything - VIOLATES ISP
public interface PaymentProcessor {
    void processCreditCard();
    void processPayPal();
    void processBankTransfer();
    void processCrypto();
    void refundPayment();
    void voidTransaction();
    void generateInvoice();
    void sendReceipt();
    void reconcilePayment();
}