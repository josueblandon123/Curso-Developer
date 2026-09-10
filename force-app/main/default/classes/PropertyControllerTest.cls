@isTest
private class PropertyControllerTest {

    @testSetup
    static void setupData() {
        // Create test broker if required by the relationship
        Broker__c testBroker = new Broker__c(
            Name = 'Test Agent',
            Email__c = 'testemail@email.com'
        );
        insert testBroker;

        // Create a list of properties with different combinations to test filters
        List<Property__c> properties = new List<Property__c>();

        properties.add(new Property__c(
            Name = 'Villa Sol',
            Address__c = 'Avenida Central 123',
            Price__c = 150000,
            Bedrooms__c = 3,
            Bathrooms__c = 2,
            Status__c = 'Available',
            Broker__c = testBroker.Id
        ));

        properties.add(new Property__c(
            Name = 'Casa Lindo Mar',
            Address__c = 'Playa Hermosa 456',
            Price__c = 350000,
            Bedrooms__c = 4,
            Bathrooms__c = 3,
            Status__c = 'Available',
            Broker__c = testBroker.Id
        ));

        properties.add(new Property__c(
            Name = 'Apartamento Centro',
            Address__c = 'Calle 50',
            Price__c = 500000,
            Bedrooms__c = 2,
            Bathrooms__c = 1,
            Status__c = 'Available',
            Broker__c = testBroker.Id
        ));

        // Property sold (must be ignored by the WHERE clause Status__c != 'Sold')
        properties.add(new Property__c(
            Name = 'Propiedad Vendida',
            Address__c = 'Calle Vieja 789',
            Price__c = 100000,
            Bedrooms__c = 2,
            Bathrooms__c = 1,
            Status__c = 'Sold',
            Broker__c = testBroker.Id
        ));

        insert properties;
    }

    @isTest
    static void testGetFilteredProperties_DefaultPagination() {
        Test.startTest();
        // Try sending null values ​​to validate the default values ​​(pSize = 9, pNumber = 1)
        PropertyController.PropertyPagedResult result = PropertyController.getFilteredProperties(
            null, null, null, null, null, null
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'The result must not be null');
        System.assertEquals(9, result.pageSize, 'The default page size should be 9');
        System.assertEquals(1, result.pageNumber, 'The default page number should be 1');
        System.assertEquals(3, result.totalItemCount, 'You should only count the 3 available properties');
        System.assertEquals(1, result.totalPages, 'There must be 1 page in total');
        System.assertEquals(3, result.records.size(), 'It must return the 3 available records');
    }

    @isTest
    static void testGetFilteredProperties_WithSearchKeyAndPriceFilter() {
        Test.startTest();
        // Filter by search text 'Villa' and maximum price 200,000
        PropertyController.PropertyPagedResult result = PropertyController.getFilteredProperties(
            'Villa', 200000, 2, 1, 5, 1
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'The result must not be null');
        System.assertEquals(1, result.totalItemCount, 'Only one property needs to match the criteria');
        System.assertEquals('Villa Sol', result.records[0].Name, 'Villa Sol must return');
    }

    @isTest
    static void testGetFilteredProperties_WithBedroomsAndBathroomsFilter() {
        Test.startTest();
        // Filter by minimum 4 bedrooms and 3 bathrooms
        PropertyController.PropertyPagedResult result = PropertyController.getFilteredProperties(
            '', 600000, 4, 3, 5, 1
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'The result must not be null');
        System.assertEquals(1, result.totalItemCount, 'Only Casa Lindo Mar has 4 beds and 3 baths');
        System.assertEquals('Casa Lindo Mar', result.records[0].Name, 'You must return to Casa Lindo Mar');
    }

    @isTest
    static void testGetFilteredProperties_CustomPagination() {
        Test.startTest();
        // Custom pagination: page size 2, page query 2
        PropertyController.PropertyPagedResult result = PropertyController.getFilteredProperties(
            '', 600000, 0, 0, 2, 2
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'The result must not be null');
        System.assertEquals(3, result.totalItemCount, 'There are 3 properties available in total');
        System.assertEquals(2, result.totalPages, 'With page size 2 and 3 records, there should be 2 pages');
        System.assertEquals(1, result.records.size(), 'Page 2 should contain only the 3rd remaining record');
    }
}