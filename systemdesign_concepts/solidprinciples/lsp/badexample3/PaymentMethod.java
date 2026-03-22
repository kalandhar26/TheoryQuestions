package solidprinciples.lsp.badexample3;

// Base class promises too much
public abstract class PaymentMethod {
    public abstract void process();
    public abstract void refund();
    public abstract void chargeback(); // Not all payments support chargebacks
    public abstract void voidTransaction(); // Not all payments support voiding
}