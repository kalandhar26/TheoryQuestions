package solidprinciples.lsp.validexample2;

public class PaymentService {
    
    public void processAnyPayment(Payment payment) {
        payment.processPayment();
    }
    
    public void refundIfPossible(Refundable payment) {
        payment.refundPayment();
    }
    
    public void confirmCryptoTransaction(CryptoPayment payment) {
        payment.confirmBlockchainTransaction();
    }
    
    public static void main(String[] args) {
        PaymentService service = new PaymentService();
        
        CreditCardPayment creditCard = new CreditCardPayment();
        service.processAnyPayment(creditCard);
        service.refundIfPossible(creditCard); // Works - credit cards are refundable
        
        BitcoinPayment bitcoin = new BitcoinPayment();
        service.processAnyPayment(bitcoin);
        service.confirmCryptoTransaction(bitcoin); // Works - bitcoin is crypto
        // service.refundIfPossible(bitcoin); // Won't compile - CORRECT!
    }
}