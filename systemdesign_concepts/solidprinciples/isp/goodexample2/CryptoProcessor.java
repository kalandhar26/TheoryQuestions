package solidprinciples.isp.goodexample2;

public interface CryptoProcessor extends PaymentMethodProcessor {
    // Crypto only supports processing, no refunds or voiding
}