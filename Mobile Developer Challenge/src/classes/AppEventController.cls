public with sharing class AppEventController extends AppController {
    
    public string whoType { get; set; }
    public Id recordId { get; set; }
    public Contact contact { 
        get { 
            if(contact == null)
                contact = new Contact();
            return null;
        } 
        set;
    }
    public Lead lead { 
        get { 
            if(lead == null)
                lead = new Lead();
            return null;
        } 
        set; 
    }
    public String imageUrl { 
        get {
           if(imageUrl == null)
               imageUrl = '';
            return imageUrl;
        }
        set; 
    }
    
	public Event event {
		get {
			if (event == null && recordId != null) {
				event = [SELECT AccountId,ActivityDate,ActivityDateTime,Description,DurationInMinutes,EndDateTime,GroupEventType,IsAllDayEvent,IsArchived,IsChild,IsGroupEvent,IsPrivate,IsRecurrence,IsReminderSet,Location,OwnerId,ShowAs,StartDateTime,Subject,WhatId,WhoId
					FROM Event
					WHERE Id = :recordId
					LIMIT 1];
			}
			return event;
		}
		set;
	}

	public AppEventController() {
		recordId = ApexPages.currentPage().getParameters().get('id');        
        
        String whoId = event.whoId;
        
        if(whoId == null)
            return;
        
        if(whoId.startsWith(Schema.SObjectType.Lead.getKeyPrefix())) { 
            whoType = 'lead';
            list<Lead> leads = [SELECT firstName, lastName, (SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1) FROM Lead WHERE id = :whoId];
            lead = leads[0].clone();
            if(leads[0].Attachments != null && leads[0].Attachments.size() > 0)
                imageUrl = '/servlet/servlet.FileDownload?file=' + leads[0].Attachments[0].Id;
        }
        else if(whoId.startsWith(Schema.SObjectType.Contact.getKeyPrefix())) {
            whoType = 'contact';
            list<Contact> contacts = [SELECT FirstName, LastName, (SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1) FROM Contact WHERE id = :whoId];
            contact = contacts[0].clone();
            if(contacts[0].Attachments != null && contacts[0].Attachments.size() > 0)
                imageUrl = '/servlet/servlet.FileDownload?file=' + contacts[0].Attachments[0].Id;
        }
        
	}
}