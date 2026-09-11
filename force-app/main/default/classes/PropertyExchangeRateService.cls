public class PropertyExchangeRateService {

    @future(callout=true)
    public static void updateExchangeRatesFuture(List<Id> propertyIds) {
        if (propertyIds == null || propertyIds.isEmpty()) {
            return;
        }

        Decimal hnlRate;
        try {
            // The rate is obtained through the service.
            hnlRate = CurrencyExchangeService.getHnlExchangeRate();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving HNL rate in Future method: ' + e.getMessage());
            hnlRate = null;
        }

        // Early return if the rate returned null or failed.
        if (hnlRate == null) {
            return;
        }

        // Query of records to be updated
        List<Property__c> propertiesToUpdate = [
            SELECT Id, Price__c, HNL_Rate__c, Price_HNL__c 
            FROM Property__c 
            WHERE Id IN :propertyIds
        ];

        for (Property__c prop : propertiesToUpdate) {
            prop.HNL_Rate__c = hnlRate;
            if (prop.Price__c != null) {
                prop.Price_HNL__c = prop.Price__c * hnlRate;
            }
        }

        if (!propertiesToUpdate.isEmpty()) {
            update propertiesToUpdate;
        }
    }
}