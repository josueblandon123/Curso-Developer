@isTest
private class PropertyExchangeRateServiceTest {

    @testSetup
    static void setupData() {
        // Mock registered to prevent callout failures during initial insertion in setup.
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());

        Broker__c broker = DataFactory.createBroker('Broker Future Test');
        DataFactory.createSingleProperty('Casa Future 1', 100000, 'Available', broker.Id);
        DataFactory.createSingleProperty('Casa Future 2', 250000, 'Available', broker.Id);
    }

    @isTest
    static void testUpdateExchangeRatesFutureSuccess() {
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());

        List<Property__c> properties = [SELECT Id FROM Property__c];
        List<Id> propIds = new List<Id>();
        for (Property__c p : properties) {
            propIds.add(p.Id);
        }

        Test.startTest();
        // Invocation of the @future method
        PropertyExchangeRateService.updateExchangeRatesFuture(propIds);
        Test.stopTest();

        List<Property__c> updatedProps = [SELECT Id, HNL_Rate__c, Price_HNL__c, Price__c FROM Property__c WHERE Id IN :propIds];
        
        for (Property__c prop : updatedProps) {
            Assert.areEqual(26.81, prop.HNL_Rate__c, 'The HNL rate must have been updated to 26.81.');
            Assert.areEqual(prop.Price__c * 26.81, prop.Price_HNL__c, 'The price calculation in HNL must be correct.');
        }
    }

    @isTest
    static void testUpdateExchangeRatesFutureNullOrEmpty() {
        Test.startTest();
        // Test with null list and empty list (covers initial early returns)
        PropertyExchangeRateService.updateExchangeRatesFuture(null);
        PropertyExchangeRateService.updateExchangeRatesFuture(new List<Id>());
        Test.stopTest();

        Assert.isTrue(true, 'Execution completed cleanly for null or empty inputs.');
    }

    @isTest
    static void testUpdateExchangeRatesFutureWhenHnlRateIsNull() {
        // We clear the properties so that the rate is null before the test.
        List<Property__c> properties = [SELECT Id FROM Property__c];
        for (Property__c p : properties) {
            p.HNL_Rate__c = null;
            p.Price_HNL__c = null;
        }
        update properties;

        // Mock with a response that will trigger the exception and assign hnlRate = null.
        String jsonWithoutHnl = '{"base":"USD","date":"2026-09-11","rates":{"USD":1,"EUR":0.86}}';
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock(200, jsonWithoutHnl));

        List<Id> propIds = new List<Id>{ properties[0].Id };

        Test.startTest();
        PropertyExchangeRateService.updateExchangeRatesFuture(propIds);
        Test.stopTest();

        // We verify that the record has not been modified.
        Property__c propUnchanged = [SELECT Id, HNL_Rate__c FROM Property__c WHERE Id = :properties[0].Id];
        Assert.areEqual(null, propUnchanged.HNL_Rate__c, 'Records should not be updated when the HNL rate is zero.');
    }
}