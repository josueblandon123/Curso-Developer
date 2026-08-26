public with sharing class SaleTriggerHelper {

    /**
     * Update the property status to "Sold" when a sale is recorded.
     */
    public static void updatePropertyStatusToSold(List<Sale__c> newSales) {
        Set<Id> propertyIds = new Set<Id>();

        // Collect the IDs of the properties involved
        for (Sale__c sale : newSales) {
            if (sale.Property__c != null) {
                propertyIds.add(sale.Property__c);
            }
        }

        if (propertyIds.isEmpty()) {
            return;
        }

        // Check the properties to verify their current status.
        List<Property__c> propertiesToUpdate = [
            SELECT Id, Status__c 
            FROM Property__c 
            WHERE Id IN :propertyIds 
            WITH USER_MODE
        ];

        List<Property__c> updatedProperties = new List<Property__c>();

        // Change the status to 'Sold' only if it is not already sold.
        for (Property__c prop : propertiesToUpdate) {
            if (prop.Status__c != 'Sold') {
                prop.Status__c = 'Sold';
                updatedProperties.add(prop);
            }
        }

        // Run DML safely
        if (!updatedProperties.isEmpty()) {
            update as user updatedProperties;
        }
    }
}