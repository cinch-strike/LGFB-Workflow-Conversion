public with sharing class WebsiteClassesHelper {
    @AuraEnabled(cacheable=true)
	public static List<Campaign> getCommunityClasses() {
        Date todaysDate = system.today();
        return [SELECT Id, Region__c, Web_Link__c, Venue_Name__c, When__c, Special_Class__c, Class_Province__c, Campaign_Month__c, Start_Date_Day__c, Full_Capacity_Reached__c, Registration_URL__c, Campaign_No__c
                FROM Campaign
                WHERE Status = 'Planned'
                AND (Type = 'Class - Women' OR Type = 'Class - Community')
                AND Website_Added__c != NULL
                AND RecordType.Name = 'Class'
                AND StartDate >= :todaysDate
                ORDER BY StartDate ASC
                LIMIT 50000
                ];
    }

    @AuraEnabled(cacheable=true)
	public static List<Campaign> getOnlineClasses() {
        Date todaysDate = system.today();
        return [SELECT Id, Online_Content_Type__c, Web_Link__c, When__c, Online_Speaker__c, Special_Class__c, Topic__c, Campaign_Month__c, Start_Date_Day__c, Full_Capacity_Reached__c, Registration_URL__c, Campaign_No__c
                FROM Campaign
                WHERE Status = 'Planned'
                AND Type = 'Class - Online'
                AND Website_Added__c != NULL
                AND RecordType.Name = 'Class'
                AND StartDate >= :todaysDate
                ORDER BY StartDate ASC
                LIMIT 50000
                ];
    }

    
    @AuraEnabled(cacheable=true)
    public static List<String> getClassProvinceValues() {
        List<String> provinceValues = new List<String>();
        Set<String> uniqueProvinces = new Set<String>();
        List<Campaign> commClassesList = getCommunityClasses();
        for (Campaign camp : commClassesList) {
            uniqueProvinces.add(camp.Class_Province__c);
        }
        provinceValues.addAll(uniqueProvinces);
        provinceValues.sort();
        return provinceValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTopicPicklistValues() {
        List<String> picklistValues = new List<String>();
    
        // Describe the Campaign object
        SObjectType campaignType = Schema.getGlobalDescribe().get('Campaign');
        DescribeSObjectResult campaignDescribe = campaignType.getDescribe();
    
        // Get the field describe result for the Region__c field
        SObjectField topicField = campaignDescribe.fields.getMap().get('Topic__c');
        DescribeFieldResult topicFieldDescribe = topicField.getDescribe();
    
        // Loop through the picklist values and add them to the list
        for (Schema.PicklistEntry p : topicFieldDescribe.getPicklistValues()) {
            picklistValues.add(p.getLabel()); 
        }
    
        return picklistValues;
    }
}