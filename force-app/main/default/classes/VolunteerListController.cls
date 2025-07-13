public without sharing class VolunteerListController {
    public Campaign campaign {get;set;}
    public List<String> errorMessageList {get;set;}
    public Boolean saveSuccessful {get;set;}
    //public CampaignWrapper cWrapper {get;set;}
    
    public VolunteerListController(ApexPages.StandardController controller){
        this.campaign = (Campaign)controller.getRecord();
        this.campaign = [select Id, Region__c, Venue_Name__c,  Website_Name__c, Tutor__r.Name, Patient_Coordinator__r.Name, Volunteer_Coordinator__r.Name,
            Tutor_Class_Feedback_Received__c, NumberOfContacts, StartDate, Start_Date_Day__c, Start_Time__c, End_Time__c,
            Number_of_Unused_Kits__c, Health_Safety_Issues__c, Tutor_Class_Notes__c
             from Campaign where Id = :this.campaign.Id];
        errorMessageList = new List<String>();
    }
    
    public List<Volunteer_Hours__c> volunteerHoursList {
        get {
            if (volunteerHoursList == null){
                volunteerHoursList = new List<Volunteer_Hours__c>();
                volunteerHoursList = [select Id,
                                      Volunteer_Abbreviated_Name__c, Contact__r.Email, Contact__r.MobilePhone,
                                      Volunteer_Status__c
                                    
                                     from Volunteer_Hours__c
                                     where Campaign__c = :campaign.Id];
            }
            return volunteerHoursList;
        }
        set;
    }
    
       
    public PageReference saveDetails(){
        try {
            
            if ( (ApexPages.hasMessages() && volunteerHoursList.size() > 0)/* || !isValid()*/) {
                saveSuccessful = false;
                errorMessageList.add('There are errors on page, which prevented your page from saving data. Please fix the errors and try again.');
                return null;
                
            } else {
                if (volunteerHoursList.size() > 0)  {
                    upsert volunteerHoursList;
                }
                saveSuccessful = true;
                errorMessageList.clear();
                return null;
            }
        }
        catch (DmlException e){
            saveSuccessful = false;
            system.debug('## error: ' + e.getMessage());
            errorMessageList.add('There is an error saving your record. Please contact your administrator: ' + e.getMessage());
            return null;
        }
    }
}