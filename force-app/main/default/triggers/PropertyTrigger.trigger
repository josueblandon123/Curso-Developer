trigger PropertyTrigger on Property__c (before insert, before update, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            PropertyTriggerHandler.beforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            PropertyTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            PropertyTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}