({
    doInit: function(component, event, helper) {
        // Enlazar con el método @AuraEnabled del controller de Apex
        var action = component.get("c.getFilteredProperties");

        // Pasar los parámetros esperados por el método getFilteredProperties
        action.setParams({
            searchKey: '',
            maxPrice: 0,
            bedrooms: 0,
            bathrooms: 0,
            pageSize: 12,
            pageNumber: 1
        });

        // Callback cuando la promesa de Apex responde
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);

            if (state === "SUCCESS") {
                var pagedResult = response.getReturnValue();
                // Asignar la lista de registros obtenida del wrapper PropertyPagedResult
                component.set("v.properties", pagedResult.records);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error("Error loading properties in Aura: ", errors);
            }
        });

        // Enviar la acción a la cola de ejecución de Salesforce
        $A.enqueueAction(action);
    },

    handleImageError: function(component, event, helper) {
        // Fallback dinámico si la imagen externa falla por CSP o URL rota
        event.target.src = 'https://s3-us-west-1.amazonaws.com/sfdc-demo/images/properties/house01.jpg';
    }
})