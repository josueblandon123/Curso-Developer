@isTest
private class CurrencyExchangeServiceTest {

    @testSetup
    static void setupData() {
        // Mock registered during setup to prevent the Trigger/Queueable from failing when inserting the test property.
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());
        
        Broker__c broker = DataFactory.createBroker('Broker Test Service');
        DataFactory.createSingleProperty('Propiedad Base Test', 100000, 'Available', broker.Id);
    }

    @isTest
    static void testGetHnlExchangeRateSuccess() {
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());

        Test.startTest();
        Decimal hnlRate = CurrencyExchangeService.getHnlExchangeRate();
        Test.stopTest();

        Assert.areEqual(26.81, hnlRate, 'The rate returned for HNL must match the Mock value (26.81).');
    }

    @isTest
    static void testGetHnlExchangeRateHttpError() {
        // Mock reused to simulate an HTTP 500 server error.
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock(500, '{"error": "Internal Server Error"}'));

        Test.startTest();
        try {
            CurrencyExchangeService.getHnlExchangeRate();
            Assert.fail('A CalloutException was expected due to the HTTP 500 response code.');
        } catch (CalloutException e) {
            Assert.isTrue(
                e.getMessage().contains('500'), 
                'The exception message must reference the HTTP 500 error code.'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testGetHnlExchangeRateMissingKey() {
        // Reused mock sending a valid JSON that does NOT contain the 'HNL' key.
        String jsonWithoutHnl = '{"base":"USD","date":"2026-09-10","rates":{"USD":1,"EUR":0.86}}';
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock(200, jsonWithoutHnl));

        Test.startTest();
        try {
            CurrencyExchangeService.getHnlExchangeRate();
            Assert.fail('A CalloutException was expected due to the absence of the HNL key in the JSON.');
        } catch (CalloutException e) {
            Assert.isTrue(
                e.getMessage().contains('HNL'), 
                'The exception message must indicate that the HNL key is missing.'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testGetHnlExchangeRateAuraContextError() {
        // Simulate an HTTP 500 error response.
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock(500, '{"error": "Internal Server Error"}'));
        
        // We force the execution context to AURA.
        CurrencyExchangeService.mockQuiddity = Quiddity.AURA;

        Test.startTest();
        try {
            CurrencyExchangeService.getHnlExchangeRate();
            Assert.fail('An AuraHandledException was expected when executing within the AURA context.');
        } catch (AuraHandledException e) {
            Assert.areNotEqual(null, e, 'The exception must be caught as an AuraHandledException.');
        } catch (Exception e) {
            Assert.fail('AuraHandledException was expected, but received: ' + e.getTypeName());
        }
        Test.stopTest();
    }
}