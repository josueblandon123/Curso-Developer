public with sharing class PropertyTriggerHelper {

    /**
     * Validates business rules in context Before (Insert / Update).
     */
    public static void validateBrokerAssignment(List<Property__c> newProperties) {
        for (Property__c prop : newProperties) {
            // Marking as "Sold" without an assigned Broker is not allowed.
            if (prop.Status__c == 'Sold' && prop.Broker__c == null) {
                prop.Broker__c.addError('It is not possible to mark a property as "Sold" without assigning a responsible Broker.');
            }
        }
    }

    /**
     * Generates automatic tasks in context After Update if the price varies significantly.
     */
    public static void createTasksOnPriceChange(List<Property__c> newProperties, Map<Id, Property__c> oldPropertyMap) {
        List<Task> tasksToInsert = new List<Task>();

        for (Property__c prop : newProperties) {
            Property__c oldProp = oldPropertyMap.get(prop.Id);

            if (oldProp != null && prop.Price__c != oldProp.Price__c) {
                Decimal oldPrice = oldProp.Price__c != null ? oldProp.Price__c : 0;
                Decimal newPrice = prop.Price__c != null ? prop.Price__c : 0;

                // Variation assessment >= 10%
                if (oldPrice > 0 && Math.abs(newPrice - oldPrice) / oldPrice >= 0.10) {
                    tasksToInsert.add(new Task(
                        Subject = 'Review significant price change: ' + prop.Name,
                        Description = 'The price changed from $' + oldPrice + ' to $' + newPrice,
                        WhatId = prop.Id,
                        OwnerId = prop.OwnerId,
                        Status = 'Not Started',
                        Priority = 'High'
                    ));
                }
            }
        }

        // Bulkified DML outside of loops
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}