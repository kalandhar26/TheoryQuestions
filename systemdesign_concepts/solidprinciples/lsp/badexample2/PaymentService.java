package solidprinciples.lsp.badexample2;

public class PaymentService {

    public void handleRefund(PaymentProcessor payment) {
        payment.refundPayment();
    }

    public static void main(String[] args) {
        PaymentService service = new PaymentService();

        PaymentProcessor creditCard = new PaymentProcessor();
        service.handleRefund(creditCard); // Works fine

        DebitCardPayment debitCard = new DebitCardPayment();
        service.handleRefund(debitCard); // Works fine

        BitcoinPayment bitcoin = new BitcoinPayment();
        service.handleRefund(bitcoin); // Throws exception - BREAKS LSP!

        // The Problem
        /*  The BitcoinPayment class promises to be a PaymentProcessor but
        can't deliver on the refund functionality that all payment processors
        should have. This breaks the contract. */
    }
}