package solidprinciples.isp.goodexample2;

public class BitcoinProcessor implements CryptoProcessor {
    @Override
    public void processPayment() {
        System.out.println("Processing Bitcoin payment");
        confirmBlockchainTransaction();
    }

    private void confirmBlockchainTransaction() {
        System.out.println("Confirming on blockchain");
    }
    // No refund or void methods - which is correct for crypto
}