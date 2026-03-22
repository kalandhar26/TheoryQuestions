package solidprinciples.isp.validexample1;

public interface PaymentOperations {
    void authorizePayment();
    void capturePayment();
    void refundPayment();
    void voidPayment();
}
