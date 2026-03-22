package solidprinciples.isp.validexample1;

public class PaymentService implements PaymentOperations {
    @Override
    public void authorizePayment() {
        System.out.println("Payment Authorized");
    }

    @Override
    public void capturePayment() {
        System.out.println("Payment Captured");
    }

    @Override
    public void refundPayment() {
        System.out.println("Payment refunded");
    }

    @Override
    public void voidPayment() {
        System.out.println("Payment Voided");
    }

}
