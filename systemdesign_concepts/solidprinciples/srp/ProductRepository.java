package solidprinciples.srp;

public class ProductRepository {

    public void saveProduct(ProductAfterSRP product) {
        // Logic to save product to the database
        System.out.println("Product is saved to database"+ product);
    }
}
