package solidprinciples.isp.goodexample2;

// Specific payment method interfaces
public interface CreditCardProcessor extends PaymentMethodProcessor, Refundable, Voidable {
    // Credit cards support all these operations
}