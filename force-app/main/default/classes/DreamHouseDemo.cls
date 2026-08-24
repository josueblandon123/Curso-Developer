public class DreamHouseDemo {

    /**
     * Método para ejecutar directamente desde la Consola de Desarrollador.
     * Muestra las propiedades dentro de un rango de precio e imprime un resumen en el Log.
     */
    public static void consultarPropiedadesDestacadas(Decimal precioMaximo) {
        System.debug('=== INICIO DEMO: BÚSQUEDA DE PROPIEDADES EN DREAMHOUSE ===');
        
        // Consulta SOQL
        List<Property__c> propiedades = [
            SELECT Id, Name, Bedrooms__c, Bathrooms__c, Price__c, Status__c, Picture_URL__c
            FROM Property__c
            WHERE Price__c <= :precioMaximo
            ORDER BY Price__c ASC
            LIMIT 10
        ];

        System.debug('Total de propiedades encontradas: ' + propiedades.size());

        // Iteración e impresión para los alumnos
        for (Property__c prop : propiedades) {
            System.debug(
                'Propiedad: ' + prop.Name + 
                ' | Bedrooms: ' + prop.Bedrooms__c + 
                ' | Bathrooms: ' + prop.Bathrooms__c + 
                ' | Price: $' + prop.Price__c
            );
        }
        
        System.debug('=== FIN DE LA DEMOSTRACIÓN ===');
    }
}