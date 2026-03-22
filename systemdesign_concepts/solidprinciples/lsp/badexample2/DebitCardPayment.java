package solidprinciples.lsp.badexample2;

public class DebitCardPayment extends PaymentProcessor {
    @Override
    public void refundPayment() {
        System.out.println("Payment is refunded");
    }
}
