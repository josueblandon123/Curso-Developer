@isTest
private class PropertyControllerTest2 {

    @testSetup
    static void setupData() {
        // We delegated the creation of records to the DataFactory
        DataFactory.setupPropertyControllerData();
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