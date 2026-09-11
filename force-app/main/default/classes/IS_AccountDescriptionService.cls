/**
 * @description Servicio invocable desde otras clases para asignar una descripción
 *              genérica a un conjunto de cuentas (Account). Pensado para usarse, por
 *              ejemplo, desde un trigger handler o un batch, nunca directamente como
 *              lógica de trigger.
 * @author IA + revisión humana
 * @date 2026-09-11
 */
public with sharing class IS_AccountDescriptionService {

    /**
     * @description Excepción específica de este servicio para distinguir errores de
     *              entrada inválida de otros errores de DML/consulta.
     */
    public class IS_AccountDescriptionServiceException extends Exception {}

    private static final String GENERIC_DESCRIPTION = 'Cuenta actualizada automáticamente por el sistema.';

    /**
     * @description Asigna el texto de descripción genérico a las cuentas indicadas.
     *              Bulk-safe: una sola consulta y un solo DML sin importar el tamaño
     *              de la lista recibida. Si el usuario actual no tiene permiso de
     *              edición (FLS) sobre el campo Description, el método no realiza
     *              ningún cambio en lugar de fallar.
     * @param accountIds Ids de las cuentas a actualizar. No puede ser nulo ni vacío.
     * @return void
     */
    public static void setGenericDescription(List<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            throw new IS_AccountDescriptionServiceException('La lista de Ids de Account no puede ser nula ni vacía.');
        }

        // Sin acceso de edición al campo, no tiene sentido intentar el update.
        if (!Schema.sObjectType.Account.fields.Description.isUpdateable()) {
            return;
        }

        List<Account> accountsToUpdate = [
            SELECT Id, Description
            FROM Account
            WHERE Id IN :accountIds
        ];

        if (accountsToUpdate.isEmpty()) {
            return;
        }

        for (Account acc : accountsToUpdate) {
            acc.Description = GENERIC_DESCRIPTION;
        }

        update accountsToUpdate;
    }
}
