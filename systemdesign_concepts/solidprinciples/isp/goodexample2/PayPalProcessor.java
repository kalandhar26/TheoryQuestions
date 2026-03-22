package solidprinciples.isp.goodexample2;

public interface PayPalProcessor extends PaymentMethodProcessor, Refundable {
    // PayPal supports processing and refunds but not voiding
}
