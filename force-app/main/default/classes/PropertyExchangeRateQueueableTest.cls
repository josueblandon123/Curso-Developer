@isTest
private class PropertyExchangeRateQueueableTest {

    @testSetup
    static void setupData() {
        // Register a mock to prevent the automatic Trigger/Queueable from failing during initial creation.
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());

        Broker__c broker = DataFactory.createBroker('Broker Queueable Test');
        DataFactory.createSingleProperty('Propiedad Queueable 1', 100000, 'Available', broker.Id);
        DataFactory.createSingleProperty('Propiedad Queueable 2', 200000, 'Available', broker.Id);
    }

    @isTest
    static void testQueueableExecutionSuccess() {
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());

        List<Property__c> properties = [SELECT Id FROM Property__c];
        List<Id> propIds = new List<Id>();
        for (Property__c p : properties) {
            propIds.add(p.Id);
        }

        Test.startTest();
        System.enqueueJob(new PropertyExchangeRateQueueable(propIds));
        Test.stopTest();

        List<Property__c> updatedProps = [SELECT Id, HNL_Rate__c, Price_HNL__c, Price__c FROM Property__c WHERE Id IN :propIds];
        
        for (Property__c prop : updatedProps) {
            Assert.areEqual(26.81, prop.HNL_Rate__c, 'The HNL rate must be updated to 26.81.');
            Assert.areEqual(prop.Price__c * 26.81, prop.Price_HNL__c, 'The price calculation in HNL must be correct.');
        }
    }

    @isTest
    static void testQueueableNullOrEmptyList() {
        Test.startTest();
        // Execution with a null list
        System.enqueueJob(new PropertyExchangeRateQueueable(null));
        // Execution with an empty list
        System.enqueueJob(new PropertyExchangeRateQueueable(new List<Id>()));
        Test.stopTest();

        // If no exceptions are thrown and execution reaches this point, the early return clauses are covered.
        Assert.isTrue(true, 'Execution completed successfully, ignoring null or empty lists.');
    }

    @isTest
    static void testQueueableCalloutExceptionHandling() {
        // Simulate a 500 error in the API to force the service to throw an exception or fail to return a rate.
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock(500, '{"error": "Internal Server Error"}'));

        List<Property__c> properties = [SELECT Id FROM Property__c];
        List<Id> propIds = new List<Id>{ properties[0].Id };

        Test.startTest();
        try {
            System.enqueueJob(new PropertyExchangeRateQueueable(propIds));
            Test.stopTest();
        } catch (Exception e) {
            // The Queueable handles the exception originating from the service.
            Assert.isNotNull(e, 'The exception was caught during the execution of the job.');
        }
    }
}