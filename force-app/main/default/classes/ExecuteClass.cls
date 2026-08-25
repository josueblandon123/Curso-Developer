DreamHouseDemo.consultarPropiedadesDestacadas(8000000);

////////----------------------------------------------------------------------------////////

// 1. Simulate search parameters (example: search 'Casa', max price 80000000, 2 beds, 1 bathroom, page 1)
String searchKey = 'Casa';
Decimal maxPrice = 80000000;
Integer bedrooms = 2;
Integer bathrooms = 1;
Integer pageSize = 6;
Integer pageNumber = 1;

// 2. Invocation of the controller's static method
PropertyController.PropertyPagedResult result = PropertyController.getFilteredProperties(
    searchKey, 
    maxPrice, 
    bedrooms, 
    bathrooms, 
    pageSize, 
    pageNumber
);

// 3. Inspection of results in the debug console
System.debug('=== PAGINATION RESULTS ===');
System.debug('Total records found: ' + result.totalItemCount);
System.debug('Total number of pages: ' + result.totalPages);
System.debug('Current page: ' + result.pageNumber);
System.debug('Records on this page: ' + result.records.size());

System.debug('=== RECORD DETAILS ===');
for (Property__c prop : result.records) {
    System.debug('Property: ' + prop.Name + ' | Price: $' + prop.Price__c + ' | Broker: ' + prop.Broker__r.Name);
}


////////----------------------------------------------------------------------------////////


// 1. Create property in memory (without Broker)
Property__c prop = new Property__c(
    Name = 'Test Property House',
    Price__c = 500000,
    Status__c = 'Sold'
);

List<Property__c> propertiesToValidate = new List<Property__c>{ prop };

// 2. Execute the Helper method directly
PropertyTriggerHelper.validateBrokerAssignment(propertiesToValidate);

// 3. Inspect whether the object caught the error using addError()
if (prop.hasErrors()) {
    System.debug(' Validation SUCCESS: The Helper successfully locked the record.');
    for (Database.Error err : prop.getErrors()) {
        System.debug(' Captured error message: ' + err.getMessage());
    }
} else {
    System.debug(' Validation FAILED: El registro no capturó el error esperado.');
}


////////----------------------------------------------------------------------------////////


// 1. Create and insert base record assigning the OwnerId of the logged-in user
Property__c originalProp = new Property__c(
    Name = 'Test Price Change House',
    Price__c = 100000,
    Status__c = 'Available',
    OwnerId = UserInfo.getUserId()
);
insert originalProp;

// 2. Simulate the "Old" and "New" states in memory
Map<Id, Property__c> oldMap = new Map<Id, Property__c>();
oldMap.put(originalProp.Id, originalProp.clone(true, true, true, true));

// Change the price to $130,000 (+30%)
Property__c updatedProp = originalProp;
updatedProp.Price__c = 130000;
List<Property__c> newList = new List<Property__c>{ updatedProp };

// 3. Execute the Helper method
PropertyTriggerHelper.createTasksOnPriceChange(newList, oldMap);

// 4. Check if the task was inserted
List<Task> createdTasks = [
    SELECT Id, Subject, Description, WhatId, OwnerId 
    FROM Task 
    WHERE WhatId = :originalProp.Id
];

System.debug('=== TASK GENERATION RESULT ===');
System.debug('Tasks created: ' + createdTasks.size());

if (!createdTasks.isEmpty()) {
    System.debug(' Task SUCCESS: ' + createdTasks[0].Subject);
    System.debug(' Assigned to Owner ID: ' + createdTasks[0].OwnerId);
} else {
    System.debug(' Task FAILED: No task was generated.');
}



////////----------------------------------------------------------------------------////////



// 1. Create and insert Broker
Broker__c broker = new Broker__c(
    Name = 'Corredor Test',
    Email__c = 'corredor.test@example.com',
    Status__c = 'Active'
);
insert broker;

// 2. Create and insert available property
Property__c prop = new Property__c(
    Name = 'Propiedad de Prueba SaleTriggerHelper',
    Price__c = 250000,
    Status__c = 'Available',
    Broker__c = broker.Id
);
insert prop;

// 3. Create and insert Buyer
Account buyer = new Account(Name = 'Comprador Test');
insert buyer;

// 4. Create and INSERT the Sale into the Database
Sale__c testSale = new Sale__c(
    Property__c = prop.Id,
    Buyer__c = buyer.Id,
    Broker__c = broker.Id,
    Close_Date__c = Date.today(),
    Sale_Price__c = 245000
);
insert testSale; // <-- Upon insertion, the SaleTrigger automatically invokes the Helper

// 5. Verify that the Sale was created and that the Property was updated
Sale__c insertedSale = [SELECT Id, Name, Sale_Price__c FROM Sale__c WHERE Id = :testSale.Id];
Property__c updatedProp = [SELECT Id, Status__c FROM Property__c WHERE Id = :prop.Id];

System.debug('=== RESULTS ===');
System.debug(' ID of the created sale: ' + insertedSale.Id + ' (' + insertedSale.Name + ')');
System.debug(' New property status: ' + updatedProp.Status__c);