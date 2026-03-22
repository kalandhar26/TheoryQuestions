package solidprinciples.lsp.validexample3;

// Base class only promises what ALL payments can do
public abstract class PaymentMethod {
    public abstract void process();
    public abstract boolean supportsRefunds();
}