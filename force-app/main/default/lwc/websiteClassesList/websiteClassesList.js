import { LightningElement, wire, track, api} from 'lwc';
import getCommunityClasses from '@salesforce/apex/WebsiteClassesHelper.getCommunityClasses';
import getOnlineClasses from '@salesforce/apex/WebsiteClassesHelper.getOnlineClasses';
import getClassProvinceValues from '@salesforce/apex/WebsiteClassesHelper.getClassProvinceValues';
import getTopicPicklistValues from '@salesforce/apex/WebsiteClassesHelper.getTopicPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



const communitycolumns = [
    { label: 'Region', fieldName: 'Region__c', type: 'text', wrapText: true },
    { label: 'Venue', fieldName: 'Venue_Name__c', type: 'text', wrapText: true },
    { label: 'When', fieldName: 'When__c', type: 'text', wrapText: true },
    { label: 'Participants', fieldName: 'Special_Class__c', type: 'text', wrapText: true},
    {
        label: 'Register', 
        type: 'button', 
        typeAttributes: {
            label: { fieldName: 'registerLabel' },
            name: 'register',
            variant: 'brand',
            title: 'Register',
            disabled: { fieldName: 'isFullCapacity' },
            value: 'register',
            iconPosition: 'center'
        },
        cellAttributes: {
            class: { fieldName: 'registerButtonClass' }
        }
    }
];

const onlinecolumns = [
    { 
        label: 'Content Type', 
        fieldName: 'Web_Link__c',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Online_Content_Type__c'
            }, 
            target: '_blank'
        }
    },
    { label: 'When', fieldName: 'When__c', type: 'text', wrapText: true },
    { label: 'Topic', fieldName: 'Topic__c', type: 'text', wrapText: true},
    { label: 'Participants', fieldName: 'Special_Class__c', type: 'text', wrapText: true},
    {
        label: 'Register', 
        type: 'button', 
        typeAttributes: {
            label: { fieldName: 'registerLabel' },
            name: 'register',
            variant: 'brand',
            title: 'Register',
            disabled: { fieldName: 'isFullCapacity' },
            value: 'register',
            iconPosition: 'center'
        },
        cellAttributes: {
            class: { fieldName: 'registerButtonClass' }
        }
    }
];


export default class DatatableExample extends LightningElement {
    @api classType;
    @api classTopic; 

    @track communityclasses = [];
    communitycolumns = communitycolumns;
    @track commProvinceOptions = [{ label: '', value: '' }]; 
    
    @track commProvinceValue;
    @track commMonthValue;
    @track commDayValue;
    
    
    @track onlineclasses = [];
    onlinecolumns = onlinecolumns;
    @track onlineTopicOptions = [{ label: '', value: '' }];
    
    @track onlineTopicValue;
    @track onlineMonthValue;
    @track onlineDayValue;

    @track isLoadingCommunityClasses = false;
    @track isLoadingOnlineClasses = false;

    @track activeTab = 'community';
    

    @wire(getCommunityClasses)
    wiredCommunityClasses({ error, data }) {
        this.isLoadingCommunityClasses = true;
        if (data) {
            this.isLoadingCommunityClasses = false;
            this.communityclasses = data.map(record => ({
                ...record,
                registerLabel: record.Full_Capacity_Reached__c ? 'At full capacity' : 'Register',
                isFullCapacity: record.Full_Capacity_Reached__c,
                isCommunityRecord: true,
                isOnlineRecord: false,
                registerButtonClass: record.Full_Capacity_Reached__c ? 'custom-register-button-disabled' : 'custom-register-button'
            }));
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Loading Error',
                    message: 'There is a problem loading class information. Please contact LGFB NZ',
                    variant: 'error',
                }),
            );
        }
    }

    @wire(getClassProvinceValues)
    wiredCommClassProvinceOptions({ error, data }) {
        if (data) {
            this.commProvinceOptions = [...this.commProvinceOptions, ...data.map(province => ({ label: province, value: province }))];
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Loading Error',
                    message: 'There is a problem loading class information. Please contact LGFB NZ',
                    variant: 'error',
                }),
            );
        }
    }

    
    
    @wire(getTopicPicklistValues)
    wiredOnlineTopicOptions({ error, data }) {
        if (data) {
            this.onlineTopicOptions = [...this.onlineTopicOptions, ...data.map(contenttype => ({ label: contenttype, value: contenttype }))];
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Loading Error',
                    message: 'There is a problem loading class information. Please contact LGFB NZ',
                    variant: 'error',
                }),
            );
        }
    }

    get filteredCommunityClasses() {
        return this.communityclasses.filter(communityClass => 
            (!this.commProvinceValue || communityClass.Class_Province__c === this.commProvinceValue) &&
            (!this.commMonthValue || communityClass.Campaign_Month__c === this.commMonthValue) &&
            (!this.commDayValue || communityClass.Start_Date_Day__c === this.commDayValue)
        );
    }

    @wire(getOnlineClasses)
    wiredOnlineClasses({ error, data }) {
        this.isLoadingOnlineClasses = true;
        if (data) {
            this.isLoadingOnlineClasses = false;
            this.onlineclasses = data.map(record => ({
                ...record,
                registerLabel: record.Full_Capacity_Reached__c ? 'At full capacity' : 'Register',
                isFullCapacity: record.Full_Capacity_Reached__c,
                isCommunityRecord: false,
                isOnlineRecord: true,
                registerButtonClass: record.Full_Capacity_Reached__c ? 'custom-register-button-disabled' : 'custom-register-button'
            }));
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Loading Error',
                    message: 'There is a problem loading class information. Please contact LGFB NZ',
                    variant: 'error',
                }),
            );
        }
    }

    get filteredOnlineClasses() { 
        return this.onlineclasses.filter(onlineClass => 
            (!this.onlineTopicValue || onlineClass.Topic__c === this.onlineTopicValue) &&
            (!this.onlineMonthValue || onlineClass.Campaign_Month__c === this.onlineMonthValue) &&
            (!this.onlineDayValue || onlineClass.Start_Date_Day__c === this.onlineDayValue)
        );
    }

    commDayOptions = [
        { label: '', value: '' },
        { label: 'Monday', value: 'Monday' },
        { label: 'Tuesday', value: 'Tuesday' },
        { label: 'Wednesday', value: 'Wednesday' },
        { label: 'Thursday', value: 'Thursday' },
        { label: 'Friday', value: 'Friday' },
        { label: 'Saturday', value: 'Saturday' },
        { label: 'Sunday', value: 'Sunday' }
    ];

    commMonthOptions = [
        { label: '', value: '' },
        { label: 'Jan', value: 'Jan' },
        { label: 'Feb', value: 'Feb' },
        { label: 'Mar', value: 'Mar' },
        { label: 'Apr', value: 'Apr' },
        { label: 'May', value: 'May' },
        { label: 'Jun', value: 'Jun' },
        { label: 'Jul', value: 'Jul' },
        { label: 'Aug', value: 'Aug' },
        { label: 'Sep', value: 'Sep' },
        { label: 'Oct', value: 'Oct' },
        { label: 'Nov', value: 'Nov' },
        { label: 'Dec', value: 'Dec' }
    ];

    onlineDayOptions = [
        { label: '', value: '' },
        { label: 'Monday', value: 'Monday' },
        { label: 'Tuesday', value: 'Tuesday' },
        { label: 'Wednesday', value: 'Wednesday' },
        { label: 'Thursday', value: 'Thursday' },
        { label: 'Friday', value: 'Friday' },
        { label: 'Saturday', value: 'Saturday' },
        { label: 'Sunday', value: 'Sunday' }
    ];

    onlineMonthOptions = [
        { label: '', value: '' },
        { label: 'Jan', value: 'Jan' },
        { label: 'Feb', value: 'Feb' },
        { label: 'Mar', value: 'Mar' },
        { label: 'Apr', value: 'Apr' },
        { label: 'May', value: 'May' },
        { label: 'Jun', value: 'Jun' },
        { label: 'Jul', value: 'Jul' },
        { label: 'Aug', value: 'Aug' },
        { label: 'Sep', value: 'Sep' },
        { label: 'Oct', value: 'Oct' },
        { label: 'Nov', value: 'Nov' },
        { label: 'Dec', value: 'Dec' }
    ];

    handleCommProvinceChange(event) {
        this.commProvinceValue = event.detail.value;
    }

    handleCommMonthChange(event) {
        this.commMonthValue = event.detail.value;
    }

    handleCommDayChange(event) {
        this.commDayValue = event.detail.value;
    }

    
    handleOnlineTopicChange(event) {
        this.onlineTopicValue = event.detail.value;
    }

    handleOnlineMonthChange(event) {
        this.onlineMonthValue = event.detail.value;
    }

    handleOnlineDayChange(event) {
        this.onlineDayValue = event.detail.value;
    }

    handleRegisterClick(event) {
        const url = event.target.dataset.url; // Get URL from data-url attribute
        window.open(url, "_blank"); // Open URL in a new tab
    }
    
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        if (action.name === 'register') {
            // Check if the registration URL is available
            if(row.Registration_URL__c) {
                // Open the Registration URL in a new tab
                window.open(row.Registration_URL__c, '_blank');
            } else {
                // Optionally, show a toast message if the URL is not available
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Registration Error',
                        message: 'No registration URL available.',
                        variant: 'error',
                    }),
                );
            }
        }
    }
    // for filtering

    connectedCallback() {
        if (this.classTopic != null && this.classTopic != ''){ // if topic is filled up, automatic online
            this.activeTab = 'online';
            // Convert the class topic to proper sentence case to display
            // Special handling for qa ==> Q&A
            if (this.classTopic.toLowerCase() == 'qa'){
                this.onlineTopicValue = 'Q&A';
            }
            else {
                var firstLetter = this.classTopic.substr(0,1);
                var restOfTopic = this.classTopic.substr(1);
                var correctedTopic = firstLetter.toUpperCase() + restOfTopic.toLowerCase();
                this.onlineTopicValue = correctedTopic;
            }
        }
        else if (this.classType === 'online') {
            this.activeTab = 'online';
        }
    }
}