package solidprinciples.srp;

public class TestProduct {

    public static void main(String[] args) {
        ProductBeforeSRP bsrp = new ProductBeforeSRP("soap",20.0);
        bsrp.saveProduct();
        bsrp.generateInvoice();


        ProductAfterSRP asrp = new ProductAfterSRP("soap1",21.0);
        System.out.println(asrp.getName()+" "+ asrp.getPrice());

        ProductRepository repo = new ProductRepository();
        repo.saveProduct(asrp);

        InvoiceGenerator invoice = new InvoiceGenerator();
        invoice.generateInvoice(asrp);

    }
}
