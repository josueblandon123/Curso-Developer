public with sharing class PropertyTriggerHandler {

    public static void beforeInsert(List<Property__c> newProperties) {
        PropertyTriggerHelper.validateBrokerAssignment(newProperties);
    }

    public static void beforeUpdate(List<Property__c> newProperties, Map<Id, Property__c> oldPropertyMap) {
        PropertyTriggerHelper.validateBrokerAssignment(newProperties);
    }

    public static void afterUpdate(List<Property__c> newProperties, Map<Id, Property__c> oldPropertyMap) {
        PropertyTriggerHelper.createTasksOnPriceChange(newProperties, oldPropertyMap);
    }
}