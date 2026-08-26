trigger SaleTrigger on Sale__c (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        SaleTriggerHandler.afterInsert(Trigger.new);
    }
}