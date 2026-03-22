package solidprinciples.isp.validexample1;

public class ReportService implements Reporting,Notifications {

    @Override
    public void generateReport() {
        System.out.println("Report Generated");
    }

    @Override
    public void exportData() {
        System.out.println("Data Exported");
    }

    @Override
    public void sendNotification() {
        System.out.println("Reports are sent to Email");
    }
}
