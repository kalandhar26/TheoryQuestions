package solidprinciples.lsp.validexample2;

public class BitcoinPayment extends Payment implements CryptoPayment {
    @Override
    public void processPayment() {
        System.out.println("Processing Bitcoin payment");
    }

    @Override
    public void confirmBlockchainTransaction() {
        System.out.println("Confirming blockchain transaction");
    }

    // No refund method - which is correct for Bitcoin
}