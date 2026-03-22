package solidprinciples.dip.validexample1;

public class TestPaymentService {

    public static void main(String[] args) {
        PaymentService service = new PaymentService();
        PaymentGateway gateway = new StripeGateway();
        service.processPayment(gateway,10.0);
        PaymentGateway gateway1 = new BankTransferGateway();
        service.processPayment(gateway1,20.0);
        PaymentGateway gateway2 = new PayPalGateway();
        service.processPayment(gateway2,30.0);
    }
}
