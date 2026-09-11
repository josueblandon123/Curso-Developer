@isTest
private class PropertyTriggerHelperTest {

    @testSetup
    static void setupData() {
        // Generar un broker para las pruebas
        DataFactory.createBroker('Broker de Prueba');
    }

    @isTest
    static void testValidateBrokerAssignment_Success() {
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());
        Broker__c broker = [SELECT Id FROM Broker__c LIMIT 1];

        Test.startTest();
        Property__c prop = DataFactory.createSingleProperty('Casa Vendida Con Broker', 200000, 'Sold', broker.Id);
        Test.stopTest();

        Assert.areNotEqual(null, prop.Id, 'The property record should be successfully inserted with an Id.');
        
        Property__c insertedProp = [SELECT Id, Status__c, Broker__c FROM Property__c WHERE Id = :prop.Id];
        Assert.areEqual('Sold', insertedProp.Status__c, 'The status should be Sold.');
        Assert.areEqual(broker.Id, insertedProp.Broker__c, 'The broker assigned should match the test broker.');
    }

    @isTest
    static void testValidateBrokerAssignment_ValidationError() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            Property__c prop = DataFactory.createSingleProperty('Casa Vendida Sin Broker', 200000, 'Sold', null);
        } catch (DmlException e) {
            exceptionThrown = true;
            Assert.isTrue(
                e.getMessage().contains('It is not possible to mark a property as "Sold"'),
                'The validation error message should match the trigger logic.'
            );
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'A DMLException should have been thrown due to missing Broker__c on Sold status.');
    }

    @isTest
    static void testCreateTasksOnPriceChange_SignificantChange() {
        // The mock is added because `createSingleProperty` performs an `INSERT` that triggers the `Queueable` in the `After Insert` event.
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());

        Broker__c broker = [SELECT Id FROM Broker__c LIMIT 1];
        Property__c prop = DataFactory.createSingleProperty('Propiedad Cambio Precio', 100000, 'Available', broker.Id);

        prop.Price__c = 120000;

        Test.startTest();
        update prop;
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id, Subject, WhatId, Priority FROM Task WHERE WhatId = :prop.Id];
        Assert.areEqual(1, tasksCreated.size(), 'One task must be created for each significant price change.');
        Assert.isTrue(tasksCreated[0].Subject.contains('Review significant price change'), 'The assignment subject line must match.');
        Assert.areEqual('High', tasksCreated[0].Priority, 'The task priority should be High');
    }

    @isTest
    static void testCreateTasksOnPriceChange_InsignificantChange() {
        // The mock is added because `createSingleProperty` performs an `INSERT` that triggers the `Queueable` in the `After Insert` event.
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());

        Broker__c broker = [SELECT Id FROM Broker__c LIMIT 1];
        Property__c prop = DataFactory.createSingleProperty('Propiedad Ajuste Menor', 100000, 'Available', broker.Id);

        prop.Price__c = 105000;

        Test.startTest();
        update prop;
        Test.stopTest();

        List<Task> tasksCreated = [SELECT Id FROM Task WHERE WhatId = :prop.Id];
        Assert.areEqual(0, tasksCreated.size(), 'No task should be created if the variation is less than 10%.');
    }

    @isTest
    static void testPropertyInsertTriggersQueueableExchangeRate() {
        Test.setMock(HttpCalloutMock.class, new ExchangeRateHttpCalloutMock());

        Broker__c broker = [SELECT Id FROM Broker__c LIMIT 1];

        Test.startTest();
        Property__c prop = DataFactory.createSingleProperty('Casa Nueva HNL', 100000, 'Available', broker.Id);
        Test.stopTest();

        Property__c updatedProp = [SELECT Id, HNL_Rate__c, Price_HNL__c FROM Property__c WHERE Id = :prop.Id];
        
        Assert.areEqual(26.81, updatedProp.HNL_Rate__c, 'The HNL rate should have been updated to 26.81 from the Callout.');
        Assert.areEqual(2681000, updatedProp.Price_HNL__c, 'The price in HNL should have been calculated correctly (100,000 * 26.81).');
    }
}