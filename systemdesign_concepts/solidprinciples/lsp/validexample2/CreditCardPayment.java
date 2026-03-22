package solidprinciples.lsp.validexample2;

public class CreditCardPayment extends Payment implements Refundable {
    @Override
    public void processPayment() {
        System.out.println("Processing credit card payment");
    }

    @Override
    public void refundPayment() {
        System.out.println("Refunding credit card payment");
    }
}
