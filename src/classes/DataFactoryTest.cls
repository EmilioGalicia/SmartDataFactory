/**
 * The purpose of this class is to test the DataFactory.cls methods
 * @author Emilio Galicia
 */
@isTest
private class DataFactoryTest {

	/**
	 * Tests a success scenario generating data
	 */
	@isTest
	static void test_generateData () {

		// Verify there's no data initially
		System.assertEquals(new List<Contact>(), [SELECT Id FROM Contact], 'Proof there are no records in the DB');
		System.assertEquals(new List<Account>(), [SELECT Id FROM Account], 'Proof there are no records in the DB');
		System.assertEquals(new List<Opportunity>(), [SELECT Id FROM Opportunity], 'Proof there are no records in the DB');
		System.assertEquals(new List<Lead>(), [SELECT Id FROM Lead], 'Proof there are no records in the DB');
		System.assertEquals(new List<Task>(), [SELECT Id FROM Task], 'Proof there are no records in the DB');

		// insert the data
		Test.startTest();
		List<Contact> lstContacts = (List<Contact>)DataFactory.createRecords('Contact', 20);
		List<Account> lstAccounts = (List<Account>)DataFactory.createRecords('Account', 20);
		List<Opportunity> lstOpportunities = (List<Opportunity>)DataFactory.createRecords('Opportunity', 20);
		List<Lead> lstLeads = (List<Lead>)DataFactory.createRecords('Lead', 20);
		List<Task> lstTasks = (List<Task>)DataFactory.createRecords('Task', 20);
		insert lstContacts;
		insert lstAccounts;
		insert lstOpportunities;
		insert lstLeads;
		insert lstTasks;
		Test.stopTest();

		// Verify records exists
		System.assertEquals(20, [SELECT Id FROM Contact].size(), 'Proof that the records were created in DB');
		System.assertEquals(20, [SELECT Id FROM Account].size(), 'Proof that the records were created in DB');
		System.assertEquals(20, [SELECT Id FROM Opportunity].size(), 'Proof that the records were created in DB');
		System.assertEquals(20, [SELECT Id FROM Lead].size(), 'Proof that the records were created in DB');
		System.assertEquals(20, [SELECT Id FROM Task].size(), 'Proof that the records were created in DB');

	}

	/**
	 * Tests an scenario with no existing object
	 */
	@isTest
	static void test_dataFactoryException () {

		// Verify there's no data initially
		System.assertEquals(new List<Contact>(), [SELECT Id FROM Contact], 'Proof there are no records in the DB');

		// cause the error
		Test.startTest();
		//pass an incorrect api name
		try {

			List<Contact> lstContacts = (List<Contact>)DataFactory.createRecords('Contacts', 100);
			insert lstContacts;

		} catch (DataFactory.DataFactoryException dfe) {

			System.assertEquals(dfe.getMessage(), 
				'Object does not match the configuration: Contacts', 'Proof that the error is properly handled');

		}
		
		
		Test.stopTest();

		// Verify still no records were created
		System.assertEquals(new List<Contact>(), [SELECT Id FROM Contact], 'Proof there are no records in the DB');

	}
}