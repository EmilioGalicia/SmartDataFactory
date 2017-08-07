/**
 * The purpose of this class is to generate records from 
 * any standard or custom object by describing its own metadata
 * @author Emilio Galicia
 */
public with sharing class DataFactory {
	
	//Map used to describe all metadata
	private static final Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();

	//Used to create random strings
	private static final String CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';

	/**
	 * Method used to create a single sObject from a specific type
	 * @param sObjApiName Name of sObject to create
	 * @return sObject
	 * @author Emilio Galicia
	 */
	public static sObject createRecord (String sObjApiName) {

		Schema.SObjectType targetObject = GLOBAL_DESCRIBE.get(sObjApiName);

		if (targetObject == null) {

			throw new DataFactoryException('Object does not match the configuration: ' + sObjApiName);
		
		}

		sObject obj = targetObject.newSObject();

		for (Schema.SObjectField field : targetObject.getDescribe().fields.getMap().values()) {

			processField(field, obj);

		}

		return obj;
	}

	/**
	 * Method used to create a list of sObject from a specific type
	 * @param sObjApiName Name of sObject to create
	 * @param quantity amount of records to create
	 * @return List<sObject>
	 * @author Emilio Galicia
	 */
	public static List<sObject> createRecords (String sObjApiName, Integer quantity) {

		List<sObject> lstResult = new List<sObject>();

		for (integer i = 0; i < quantity; i++) {

			lstResult.add(createRecord(sObjApiName));

		}

		return lstResult;
	}

	/**
	 * Method used to create a single sObject from a specific type
	 * @param field Name of field to set
	 * @param sObject current record to create
	 * @author Emilio Galicia
	 */
	private static void processField (Schema.SObjectField field, sObject obj) {

		Schema.DescribeFieldResult dfr = field.getDescribe();

		if ( dfr.isCreateable()  && ( !dfr.isNillable() && !dfr.isDefaultedOnCreate()) ) {

			// Validate field types
			// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_enum_Schema_DisplayType.htm
			
			if (dfr.getType() == Schema.DisplayType.BASE64) {

				obj.put(field, Blob.valueOf(generateRandomString(1)));

			} else if (dfr.getType() == Schema.DisplayType.COMBOBOX || 
						dfr.getType() == Schema.DisplayType.STRING ||
						dfr.getType() == Schema.DisplayType.ENCRYPTEDSTRING ||
						dfr.getType() == Schema.DisplayType.TEXTAREA) {

				obj.put(dfr.getName(), generateRandomString(dfr.getLength()));

			} else if (dfr.getType() == Schema.DisplayType.CURRENCY ||
						dfr.getType() == Schema.DisplayType.DOUBLE ||
						dfr.getType() == Schema.DisplayType.INTEGER ||
						dfr.getType() == Schema.DisplayType.PERCENT) {

				obj.put(dfr.getName(), dfr.getLength());

			} else if (dfr.getType() == Schema.DisplayType.DATE) {

				obj.put(dfr.getName(), Date.today());

			} else if (dfr.getType() == Schema.DisplayType.DATETIME) {

				obj.put(dfr.getName(), Datetime.now());

			} else if (dfr.getType() == Schema.DisplayType.EMAIL) {

				obj.put(dfr.getName(), generateRandomString(5) + '@email.com');

			} else if (dfr.getType() == Schema.DisplayType.PICKLIST ||
						dfr.getType() == Schema.DisplayType.MULTIPICKLIST) {

				for (Schema.PickListEntry ple : dfr.getPicklistValues()) {

					if (ple.isActive()) {

						obj.put(dfr.getName(), ple.getValue());

					}

				}

			} else if (dfr.getType() == Schema.DisplayType.PHONE) {

				obj.put(dfr.getName(), '555 555 5555');

			} else if (dfr.getType() == Schema.DisplayType.REFERENCE) {

				/**
				 * TODO
				 * implement validations for different type of lookups
				 */

				String referenceToObject = dfr.getReferenceTo()[0].getDescribe().getName();

				//watch out not to exceed DML limit
				sObject ref = createRecord(referenceToObject);
				insert ref;

				obj.put(dfr.getName(), ref.Id);

				
			}  else if (dfr.getType() == Schema.DisplayType.TIME) {

				obj.put(dfr.getName(), Datetime.now().time());

			} else if (dfr.getType() == Schema.DisplayType.URL) {

				obj.put(dfr.getName(), generateRandomString(5) + '.com');

			}
		}
	}

	/**
	 * Generates a random string based on a minimum length and maximum length
	 * @param  maxLength [description]
	 * @return String
	 */
	private static String generateRandomString (Integer maxLength) {
		 
		Integer minLength = 8;
		String result = '';

		for (integer i = 0; i < minLength && i < maxLength; i++) {

			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), CHARS.length());
			result += chars.substring(idx, idx+1);

		}

		return result;
	}

	/**
	 * Class used to throw an exception in DataFactory
	 */
	public class DataFactoryException extends Exception {}

}