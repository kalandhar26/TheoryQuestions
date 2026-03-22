package solidprinciples.isp.badexample2;

// CreditCardProcessor forced to implement methods it doesn't use
public class CreditCardProcessor implements PaymentProcessor {

    @Override
    public void processCreditCard() {
        System.out.println("Processing credit card");
    }

    @Override
    public void refundPayment() {
        System.out.println("Refunding credit card payment");
    }


    @Override
    public void processPayPal() {
        System.out.println("Not used but forced to implement");
    }

    @Override
    public void processBankTransfer() {
        System.out.println("Not used but forced to implement");
    }

    @Override
    public void processCrypto() {
        System.out.println("Not used but forced to implement");
    }


    @Override
    public void voidTransaction() {
        System.out.println("Not used but forced to implement");
    }

    @Override
    public void generateInvoice() {
        System.out.println("Not used but forced to implement");
    }

    @Override
    public void sendReceipt() {
        System.out.println("Not used but forced to implement");
    }

    @Override
    public void reconcilePayment() {
        System.out.println("Not used but forced to implement");
    }

}
