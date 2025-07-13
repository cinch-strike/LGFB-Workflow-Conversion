/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ClassSummaryController_Test {

    static testMethod void testClassSummaryController() {
        // TO DO: implement unit test
         //RecordType recordType = [ select Id, Name, DeveloperName from RecordType 
            //where SObjectType = 'Account' and Name = 'Household' limit 1 ];
        Account acct = new Account (Name = 'Test Account', Category__c = 'Other', Type = 'Household');
        insert acct;
        Contact con = new Contact (FirstName = 'test', LastName = 'Test', Category__c = 'Other', AccountId = acct.Id);
        insert con;
        Campaign campaign = new Campaign(Name = 'Test', StartDate = system.today(), IsActive = true, Status = 'In Progress', Type = 'Class - Women');
        insert campaign;

        CampaignMember cm = new CampaignMember(ContactId = con.Id, CampaignID = campaign.Id, Status = 'Registered');
        insert cm;
        
        PageReference pRef = Page.ClassDetails;
        Test.setCurrentPage(pRef);
        
        ApexPages.currentPage().getParameters().put('id', campaign.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(campaign);
        ClassSummaryController cont = new ClassSummaryController(controller);
        cont.saveDetails();
        cont.printPdf();
        
    }
}