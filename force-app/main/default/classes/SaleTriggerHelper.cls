public with sharing class SaleTriggerHelper {

    /**
     * Updates the property status to "Sold" and assigns the sale broker 
     * to the property when a sale is recorded.
     */
    public static void updatePropertyStatusToSold(List<Sale__c> newSales) {
        // Map property ID to its corresponding sale record for easy retrieval
        Map<Id, Sale__c> propertyIdToSaleMap = new Map<Id, Sale__c>();

        // Collect the IDs of the properties involved and map them to their sale
        for (Sale__c sale : newSales) {
            if (sale.Property__c != null) {
                propertyIdToSaleMap.put(sale.Property__c, sale);
            }
        }

        if (propertyIdToSaleMap.isEmpty()) {
            return;
        }

        // Query properties in USER_MODE
        List<Property__c> propertiesToUpdate = [
            SELECT Id, Status__c, Broker__c 
            FROM Property__c 
            WHERE Id IN :propertyIdToSaleMap.keySet() 
            WITH USER_MODE
        ];

        List<Property__c> updatedProperties = new List<Property__c>();

        // Change status to 'Sold' and update Broker__c if necessary
        for (Property__c prop : propertiesToUpdate) {
            Sale__c relatedSale = propertyIdToSaleMap.get(prop.Id);
            Boolean isModified = false;

            // Update status to Sold
            if (prop.Status__c != 'Sold') {
                prop.Status__c = 'Sold';
                isModified = true;
            }

            // Assign the Broker from Sale to Property if available
            if (relatedSale != null && relatedSale.Broker__c != null && prop.Broker__c != relatedSale.Broker__c) {
                prop.Broker__c = relatedSale.Broker__c;
                isModified = true;
            }

            if (isModified) {
                updatedProperties.add(prop);
            }
        }

        // Execute DML safely with error handling
        if (!updatedProperties.isEmpty()) {
            try {
                update as user updatedProperties;
            } catch (DmlException e) {
                // Attach error to incoming sale records to gracefully stop transaction
                for (Sale__c sale : newSales) {
                    sale.addError('Could not update the associated property: ' + e.getDmlMessage(0));
                }
            }
        }
    }
}