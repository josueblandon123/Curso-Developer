trigger PropertyTrigger on Property__c (before insert, after Insert, before update, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            PropertyTriggerHandler.beforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            PropertyTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            PropertyTriggerHandler.afterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            PropertyTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}