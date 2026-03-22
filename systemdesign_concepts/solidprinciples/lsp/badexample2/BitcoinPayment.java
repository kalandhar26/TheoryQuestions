package solidprinciples.lsp.badexample2;

public class BitcoinPayment extends PaymentProcessor{

    // BitCoinPayment breaks LSP - it can't refund like regular payments
    @Override
    public void refundPayment() {
        throw new UnsupportedOperationException("Bitcoin payments cannot be refunded");
    }
}
