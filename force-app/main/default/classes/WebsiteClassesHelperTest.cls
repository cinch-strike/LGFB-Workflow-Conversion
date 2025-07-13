@isTest
private class WebsiteClassesHelperTest {

    @TestSetup
    static void setupTestData() {
        // Query for the existing 'Class' RecordType for Campaigns
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Class' AND SobjectType = 'Campaign' LIMIT 1];

        // Create Campaign records for testing
        List<Campaign> campaigns = new List<Campaign>{
            new Campaign(
                Name = 'Test Community Campaign',
                Status = 'Planned',
                Type = 'Class - Community',
                Online_Content_Type__c = 'Brow Focus',
                Website_Added__c = system.today(),
                RecordTypeId = rt.Id,
                StartDate = Date.today().addDays(10)
            ),
            new Campaign(
                Name = 'Test Online Campaign',
                Status = 'Planned',
                Type = 'Class - Online',
                Online_Content_Type__c = 'Brow Focus',
                Website_Added__c = system.today(),
                RecordTypeId = rt.Id,
                StartDate = Date.today().addDays(20)
            )
        };
        insert campaigns;
    }

    @isTest static void testGetCommunityClasses() {
        Test.startTest();
        List<Campaign> results = WebsiteClassesHelper.getCommunityClasses();
        Test.stopTest();

        System.assertEquals(1, results.size(), 'There should be 1 community class.');
    }

    @isTest static void testGetOnlineClasses() {
        Test.startTest();
        List<Campaign> results = WebsiteClassesHelper.getOnlineClasses();
        Test.stopTest();

        System.assertEquals(1, results.size(), 'There should be 1 online class.');
    }

    @isTest static void testGetClassProvinceValues() {
        Test.startTest();
        List<String> results = WebsiteClassesHelper.getClassProvinceValues();
        Test.stopTest();

        // Assert based on your setup data. Adjust the assertion as necessary.
        System.assertNotEquals(0, results.size(), 'There should be at least one province value.');
    }

    @isTest static void testGetTopicPicklistValues() {
        Test.startTest();
        List<String> results = WebsiteClassesHelper.getTopicPicklistValues();
        Test.stopTest();

        System.assertNotEquals(0, results.size(), 'There should be picklist values for the topic.');
    }
}