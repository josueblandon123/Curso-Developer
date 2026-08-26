public with sharing class SaleTriggerHandler {

    public static void afterInsert(List<Sale__c> newSales) {
        SaleTriggerHelper.updatePropertyStatusToSold(newSales);
    }
}