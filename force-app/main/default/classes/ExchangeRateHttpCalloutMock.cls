@isTest
public class ExchangeRateHttpCalloutMock implements HttpCalloutMock {

    private Integer statusCode;
    private String responseBody;

    // Default constructor (Successful 200 response with HNL and NIO)
    public ExchangeRateHttpCalloutMock() {
        this.statusCode = 200;
        this.responseBody = '{"base":"USD","date":"2026-09-10","rates":{"USD":1,"HNL":26.81,"NIO":36.75}}';
    }

    // Custom constructor to simulate any response or error
    public ExchangeRateHttpCalloutMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(this.statusCode);
        res.setBody(this.responseBody);
        return res;
    }
}