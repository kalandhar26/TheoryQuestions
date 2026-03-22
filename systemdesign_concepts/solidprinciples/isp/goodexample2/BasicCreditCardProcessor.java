package solidprinciples.isp.goodexample2;

// Now classes only implement what they need
public class BasicCreditCardProcessor implements CreditCardProcessor {

    @Override
    public void processPayment() {
        System.out.println("Processing credit card payment");
    }

    @Override
    public void refundPayment() {
        System.out.println("Refunding credit card payment");
    }

    @Override
    public void voidTransaction() {
        System.out.println("Voiding credit card transaction");
    }
}