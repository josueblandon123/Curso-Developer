@isTest
public class DataFactory {

    /**
     * Create and insert a test broker.
     */
    public static Broker__c createBroker(String brokerName) {
        Broker__c broker = new Broker__c(
            Name = String.isNotBlank(brokerName) ? brokerName : 'Agente de Prueba',
            Email__c = 'testemail@email.com'
        );
        insert broker;
        return broker;
    }

    /**
     * Create and insert a list of test properties associated with a Broker.
     */
    public static List<Property__c> createProperties(Id brokerId, Integer count, String status) {
        List<Property__c> properties = new List<Property__c>();

        for (Integer i = 1; i <= count; i++) {
            properties.add(new Property__c(
                Name = 'Propiedad Test ' + i,
                Address__c = 'Calle Test ' + i,
                Price__c = 100000 * i,
                Bedrooms__c = i,
                Bathrooms__c = i,
                Status__c = String.isNotBlank(status) ? status : 'Available',
                Broker__c = brokerId
            ));
        }

        insert properties;
        return properties;
    }

    /**
     * A specific helper to populate the varied dataset used by PropertyControllerTest.
     */
    public static void setupPropertyControllerData() {
        Broker__c broker = createBroker('Agente Principal');

        List<Property__c> properties = new List<Property__c>{
            new Property__c(
                Name = 'Villa Sol',
                Address__c = 'Avenida Central 123',
                Price__c = 150000,
                Bedrooms__c = 3,
                Bathrooms__c = 2,
                Status__c = 'Available',
                Broker__c = broker.Id
            ),
            new Property__c(
                Name = 'Casa Lindo Mar',
                Address__c = 'Playa Hermosa 456',
                Price__c = 350000,
                Bedrooms__c = 4,
                Bathrooms__c = 3,
                Status__c = 'Available',
                Broker__c = broker.Id
            ),
            new Property__c(
                Name = 'Apartamento Centro',
                Address__c = 'Calle 50',
                Price__c = 500000,
                Bedrooms__c = 2,
                Bathrooms__c = 1,
                Status__c = 'Available',
                Broker__c = broker.Id
            ),
            // Property sold (to validate filter exclusion)
            new Property__c(
                Name = 'Propiedad Vendida',
                Address__c = 'Calle Vieja 789',
                Price__c = 100000,
                Bedrooms__c = 2,
                Bathrooms__c = 1,
                Status__c = 'Sold',
                Broker__c = broker.Id
            )
        };

        insert properties;
    }
}