public class PropertyExchangeRateQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> propertyIds;

    public PropertyExchangeRateQueueable(List<Id> propertyIds) {
        this.propertyIds = propertyIds;
    }

    public void execute(QueueableContext context) {
        if (propertyIds == null || propertyIds.isEmpty()) {
            return;
        }

        Decimal hnlRate;
        try {
            // Get the current HNL exchange rate via the service
            hnlRate = CurrencyExchangeService.getHnlExchangeRate();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving rate in Queueable: ' + e.getMessage());
            hnlRate = null;
        }

        // This line executes when an error occurs.
        if (hnlRate == null) {
            return;
        }

        // Get the newly created properties
        List<Property__c> propertiesToUpdate = [
            SELECT Id, Price__c, HNL_Rate__c, Price_HNL__c 
            FROM Property__c 
            WHERE Id IN :propertyIds
        ];

        // Assign the rate and calculate the value in HNL
        for (Property__c prop : propertiesToUpdate) {
            prop.HNL_Rate__c = hnlRate;
            if (prop.Price__c != null) {
                prop.Price_HNL__c = prop.Price__c * hnlRate;
            }
        }

        // Update the records in the database
        if (!propertiesToUpdate.isEmpty()) {
            update propertiesToUpdate;
        }
    }
}