package solidprinciples.lsp.badexample3;

// PayPal can't support all these operations
class PayPalPayment extends PaymentMethod {

    @Override
    public void process() {
        System.out.println("Payment Processed");
    }

    @Override
    public void refund() {
        System.out.println("Payment is refunded");
    }

    public void chargeback() {
        throw new UnsupportedOperationException("PayPal doesn't support chargebacks");
    }

    @Override
    public void voidTransaction() {
        System.out.println("Transaction is void");
    }
}
