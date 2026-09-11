public with sharing class CurrencyExchangeService {

    @TestVisible private static Quiddity mockQuiddity;

    public class ExchangeRateResponse {
        public String base;
        public String date_x;
        public Map<String, Decimal> rates;
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getHnlExchangeRate() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.exchangerate-api.com/v4/latest/USD');
        req.setMethod('GET');
        req.setTimeout(12000);

        try {
            HttpResponse response = http.send(req);
            if (response.getStatusCode() == 200) {
                ExchangeRateResponse rateData = (ExchangeRateResponse) JSON.deserialize(
                    response.getBody(), 
                    ExchangeRateResponse.class
                );

                if (rateData != null && rateData.rates != null && rateData.rates.containsKey('HNL')) {
                    return rateData.rates.get('HNL');
                } else {
                    throw new CalloutException('The "HNL" key is not present in the API response.');
                }
            } else {
                throw new CalloutException('The API responded with HTTP error code: ' + response.getStatusCode() + ' - Status: ' + response.getStatus());
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in CurrencyExchangeService (Line ' + e.getLineNumber() + '): ' + e.getMessage());

            // Allows injecting the context from tests or querying the actual execution context.
            Quiddity currentQuiddity = (Test.isRunningTest() && mockQuiddity != null) 
                ? mockQuiddity 
                : System.Request.getCurrent().getQuiddity();

            if (currentQuiddity == Quiddity.AURA) {
                AuraHandledException auraEx = new AuraHandledException(e.getMessage());
                auraEx.setMessage(e.getMessage());
                throw auraEx;
            } else {
                throw e;
            }
        }
    }
}