public with sharing class PropertyController {

    public class PropertyPagedResult {
        @AuraEnabled public Integer pageSize { get; set; }
        @AuraEnabled public Integer pageNumber { get; set; }
        @AuraEnabled public Integer totalItemCount { get; set; }
        @AuraEnabled public Integer totalPages { get; set; }
        @AuraEnabled public List<Property__c> records { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static PropertyPagedResult getFilteredProperties(
        String searchKey,
        Decimal maxPrice,
        Integer bedrooms,
        Integer bathrooms,
        Integer pageSize,
        Integer pageNumber
    ) {
        Integer pSize = (pageSize == null || pageSize < 1) ? 9 : pageSize;
        Integer pNumber = (pageNumber == null || pageNumber < 1) ? 1 : pageNumber;
        Integer offsetValue = (pNumber - 1) * pSize;

        // Dynamic construction of the WHERE clause
        String whereClause = 'WHERE Status__c != \'Sold\'';
        
        String key = '';
        if (String.isNotBlank(searchKey)) {
            key = '%' + String.escapeSingleQuotes(searchKey) + '%';
            whereClause += ' AND (Name LIKE :key OR Address__c LIKE :key)';
        }

        if (maxPrice != null && maxPrice > 0) {
            whereClause += ' AND Price__c <= :maxPrice';
        }

        if (bedrooms != null && bedrooms > 0) {
            whereClause += ' AND Bedrooms__c >= :bedrooms';
        }

        if (bathrooms != null && bathrooms > 0) {
            whereClause += ' AND Bathrooms__c >= :bathrooms';
        }

        // Dynamic queries using WITH USER_MODE (Modern Security Syntax)
        String countQuery = 'SELECT COUNT() FROM Property__c ' + whereClause + ' WITH USER_MODE';
        Integer totalItems = Database.countQuery(countQuery);

        String recordQuery = 'SELECT Id, Name, Price__c, Bedrooms__c, Bathrooms__c, Status__c, Picture_URL__c, Address__c, Broker__r.Name, Featured__c ' +
                            'FROM Property__c ' + 
                            whereClause + ' ' +
                            'WITH USER_MODE ' +
                            'ORDER BY Price__c ASC ' +
                            'LIMIT :pSize OFFSET :offsetValue';
        
        List<Property__c> propertyList = Database.query(recordQuery);

        // Structuring the Wrapper Response
        PropertyPagedResult result = new PropertyPagedResult();
        result.pageSize = pSize;
        result.pageNumber = pNumber;
        result.totalItemCount = totalItems;
        result.totalPages = (Integer) Math.ceil((Decimal) totalItems / pSize);
        result.records = propertyList;

        return result;
    }
}