@IsTest
public class VolunteerListControllerTest {
    static testmethod void testVolunteerList(){
        Campaign campaign = new Campaign(Name = 'TEst', StartDate = system.today(), IsActive = true, Status = 'In Progress');
        insert campaign;
        Account acct = new Account (Name = 'Test Account', Category__c = 'Other', Type = 'Corporate');
        insert acct;
        Contact con = new Contact (FirstName = 'test', LastName = 'Test', Category__c = 'Other', AccountId = acct.Id);
        insert con;
        CampaignMember cm = new CampaignMember(ContactId = con.Id, CampaignID = campaign.Id, Status = 'Completed');
        insert cm;
        Volunteer_Hours__c vh = new Volunteer_Hours__c();
        vh.Campaign__c = campaign.Id;
        vh.Contact__c = con.Id;
        // vh.Role__c = 'Class Assisting'; 
        vh.Volunteer_Status__c = 'Interested';
        insert vh;
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(campaign);
        VolunteerListController cont = new VolunteerListController(stdCon);
        List<Volunteer_Hours__c> vList = cont.volunteerHoursList;
        cont.saveDetails();
    }
}