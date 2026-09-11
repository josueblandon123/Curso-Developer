/**
 * @description Pruebas unitarias para IS_AccountDescriptionService: caso positivo,
 *              caso negativo (validación de entrada), caso bulk (200 registros) y
 *              caso de permisos (usuario sin FLS de edición sobre Description).
 * @author IA + revisión humana
 * @date 2026-09-11
 */
@isTest
private class IS_AccountDescriptionServiceTest {

    @isTest
    static void testSetGenericDescription_Success() {
        Account acc = new Account(Name = 'Cuenta de Prueba');
        insert acc;

        Test.startTest();
        IS_AccountDescriptionService.setGenericDescription(new List<Id>{ acc.Id });
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Description FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(
            'Cuenta actualizada automáticamente por el sistema.',
            updatedAcc.Description,
            'La cuenta debe quedar con la descripción genérica.'
        );
    }

    @isTest
    static void testSetGenericDescription_NullListThrowsException() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            IS_AccountDescriptionService.setGenericDescription(null);
        } catch (IS_AccountDescriptionService.IS_AccountDescriptionServiceException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Debe lanzarse una excepción cuando la lista de Ids es nula.');
    }

    @isTest
    static void testSetGenericDescription_BulkTwoHundredAccounts() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Cuenta Bulk ' + i));
        }
        insert accounts;

        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        Test.startTest();
        IS_AccountDescriptionService.setGenericDescription(accountIds);
        Test.stopTest();

        // Description es un Long Text Area: no se puede filtrar por SOQL, se compara en Apex.
        List<Account> updatedAccounts = [SELECT Id, Description FROM Account WHERE Id IN :accountIds];

        Integer accountsWithGenericDescription = 0;
        for (Account acc : updatedAccounts) {
            if (acc.Description == 'Cuenta actualizada automáticamente por el sistema.') {
                accountsWithGenericDescription++;
            }
        }
        Assert.areEqual(200, accountsWithGenericDescription, 'Las 200 cuentas deben quedar con la descripción genérica.');
    }

    @isTest
    static void testSetGenericDescription_NoFlsAccessDoesNotUpdate() {
        // Perfil sin permisos por defecto: todo el acceso a Account se otorga vía Permission Set.
        Profile minimalProfile = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];

        User restrictedUser = new User(
            FirstName = 'Test',
            LastName = 'RestrictedUser',
            Alias = 'trestr',
            Email = 'restricted.user@is.test.org',
            Username = 'restricted.user@is.test.org' + System.currentTimeMillis(),
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = minimalProfile.Id
        );
        insert restrictedUser;

        PermissionSet ps = new PermissionSet(Name = 'IS_AccDescTestAccess', Label = 'IS Account Description Test Access');
        insert ps;

        insert new ObjectPermissions(
            ParentId = ps.Id,
            SobjectType = 'Account',
            PermissionsRead = true,
            PermissionsCreate = true
        );

        // Lectura permitida, edición explícitamente denegada sobre Description.
        insert new FieldPermissions(
            ParentId = ps.Id,
            SobjectType = 'Account',
            Field = 'Account.Description',
            PermissionsRead = true,
            PermissionsEdit = false
        );

        insert new PermissionSetAssignment(AssigneeId = restrictedUser.Id, PermissionSetId = ps.Id);

        Id restrictedAccountId;

        System.runAs(restrictedUser) {
            Account acc = new Account(Name = 'Cuenta Sin FLS');
            insert acc;
            restrictedAccountId = acc.Id;

            Test.startTest();
            IS_AccountDescriptionService.setGenericDescription(new List<Id>{ acc.Id });
            Test.stopTest();
        }

        Account uncontrolledAcc = [SELECT Id, Description FROM Account WHERE Id = :restrictedAccountId];
        Assert.areEqual(
            null,
            uncontrolledAcc.Description,
            'Sin permiso de edición sobre Description, el servicio no debe modificar la cuenta.'
        );
    }
}
