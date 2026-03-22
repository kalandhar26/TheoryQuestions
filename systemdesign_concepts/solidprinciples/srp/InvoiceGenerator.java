package solidprinciples.srp;

public class InvoiceGenerator {
    public void generateInvoice(ProductAfterSRP product){
        // logic to generate invoice
        System.out.println("Invoice generated for product: "+product.getName()+" with rupees "+product.getPrice());
    }
}
