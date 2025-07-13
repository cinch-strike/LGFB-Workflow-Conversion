public without sharing class ClassSummaryController {
       
    public Campaign campaign {get;set;}
    public List<String> errorMessageList {get;set;}
    public Boolean saveSuccessful {get;set;}
    public CampaignWrapper cWrapper {get;set;}
    
    public ClassSummaryController(ApexPages.StandardController controller){
        this.campaign = (Campaign)controller.getRecord();
        this.campaign = [select Id, Region__c, Venue_Name__c,  Website_Name__c, Tutor__r.Name, Patient_Coordinator__r.Name, Volunteer_Coordinator__r.Name,
            Tutor_Class_Feedback_Received__c, NumberOfContacts, StartDate, Start_Date_Day__c, Start_Time__c, End_Time__c,
            Number_of_Unused_Kits__c, Health_Safety_Issues__c, Tutor_Class_Notes__c
             from Campaign where Id = :this.campaign.Id];
         errorMessageList = new List<String>();
         saveSuccessful = false;
         cWrapper = new CampaignWrapper();
         cWrapper.numKits = Integer.valueOf(this.campaign.Number_of_Unused_Kits__c);
         cWrapper.healthSafety = this.campaign.Health_Safety_Issues__c;
         cWrapper.tutorNotes = this.campaign.Tutor_Class_Notes__c;
    }
    
    public List<SelectOption> campaignMemberStatusOptionList {
        get {
            if (campaignMemberStatusOptionList == null){
                campaignMemberStatusOptionList = new List<SelectOption>();
                List<CampaignMemberStatus> statusList = [select Id, Label, SortOrder from CampaignMemberStatus where CampaignId = :this.campaign.Id order by SortOrder asc];
                for (CampaignMemberStatus cms : statusList){
                    campaignMemberStatusOptionList.add(new SelectOption(cms.Label, cms.Label));
                }
            }
            return campaignMemberStatusOptionList;
        }
        set;
    }
    
    public List<CampaignMember> campaignMemberList {
        get {
            if(campaignMemberList == null){
                // DBANEZ: TO DO Make this dynamic SOQL and field set driven later in Visualforce
                campaignMemberList = [SELECT Id, ContactId, CampaignId, FirstName, LastName, Status,
                    MobilePhone, Phone, Email, 
                    Registration_Method__c, Registered_Date__c, Skin_Tone__c, Ethnicity2__c, Hair_Colour__c, Eyebrow_Colour__c,
                    Preferred_lipstick_shade__c, Support_Person__c, Product_Concerns__c, Hair_Loss__c, Preferred_Eyeshadow__c,
                    Previous_Participant__c, Preferences__c, Special_Requirements__c, Age_Attended__c, Attendee_Type__c
                    FROM CampaignMember WHERE CampaignId =:this.campaign.Id and Attendee_Type__c = 'Participant'];
            }
            return campaignMemberList;
        }
        set;
    }
    
    public List<Volunteer_Hours__c> volunteerHoursList {
        get {
            if (volunteerHoursList == null){
                volunteerHoursList = new List<Volunteer_Hours__c>();
                volunteerHoursList = [select Id,
                                      Online_First_Name__c,
                                      Online_Last_Name__c,
                                      Volunteer_Status__c,
                                      Online_Email__c, Online_Mobile__c,
                                      Volunteer_Hours__c,
                                      Comments__c 
                                     from Volunteer_Hours__c
                                     where Campaign__c = :campaign.Id];
            }
            return volunteerHoursList;
        }
        set;
    }
    
    public void addRow(){
        saveSuccessful = false;
        
        if(isValid()) {
            volunteerHoursList.add(new Volunteer_Hours__c(Campaign__c = campaign.Id));
        }
    }

    private boolean isValid() {
        boolean isValid = false;
        if (volunteerHoursList.size() > 0) {
            for (Volunteer_Hours__c vh : volunteerHoursList) {
                System.debug('vh' + vh);
                if (vh.Online_Email__c == null && vh.Online_Mobile__c == null) {
                    vh.Online_Email__c.addError('Mobile or Email must be specified.');
                    errorMessageList.add('Volunteer Hours : First Name & Last Name must be specified as well as either Mobile or Email.');
                    saveSuccessful = false;
                    //System.debug('all null');
                    isvalid = false;
                    break;               
                }  else {
                    isvalid = true;
                }
            }
        } else {
            isvalid = true;
        }
        
        System.debug('isvalid:' + isValid);
        return isvalid;
    }    
    
    public PageReference saveDetails(){
        try {
            
            if ( (ApexPages.hasMessages() && volunteerHoursList.size() > 0) || !isValid()) {
                saveSuccessful = false;
                errorMessageList.add('There are errors on page, which prevented your page from saving data. Please fix the errors and try again.');
                return null;
                
            } else {
                
                campaign.Number_of_Unused_Kits__c = cWrapper.numKits;
                campaign.Health_Safety_Issues__c = cWrapper.healthSafety;
                campaign.Tutor_Class_Notes__c = cWrapper.tutorNotes;
                update campaign;
                system.debug('##campaignMemberist: ' + campaignMemberList);
                update campaignMemberList;
                system.debug('##campaignMemberist: ' + campaignMemberList);
                
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
            errorMessageList.add('There is an error saving your record. Please contact your administrator: ' + e.getMessage());
            return null;
        }
        
        
    }
    
    public class CampaignWrapper {
        public Integer numKits {get;set;}
        public String healthSafety {get;set;}
        public String tutorNotes {get;set;}
        public CampaignWrapper(){
            numKits = null;
            healthSafety = null;
            tutorNotes = null;
        }
    }
    public PageReference printPdf(){
        PageReference pgr = Page.ClassDetailsPDF;
        pgr.getParameters().put('id', this.campaign.Id);
        pgr.setRedirect(false);
        return pgr;
    }
}