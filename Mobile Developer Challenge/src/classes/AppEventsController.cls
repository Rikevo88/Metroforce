public class AppEventsController extends AppController {
    public List<TileGroup> tileGroups { get; private set; }
    
    public AppEventsController() {
        
        List<Tile> tiles = new List<Tile>();    
        
        List<Event> events = [SELECT AccountId,ActivityDate,ActivityDateTime,Description,DurationInMinutes,EndDateTime,GroupEventType,IsAllDayEvent,IsArchived,IsChild,IsGroupEvent,IsPrivate,IsRecurrence,IsReminderSet,Location,OwnerId,ShowAs,StartDateTime,Subject,WhatId,WhoId 
                             FROM Event
                             WHERE ActivityDate <= :Date.today().addDays(7)
                             	AND EndDateTime >= :DateTime.now()
                             LIMIT :Limits.getLimitQueryRows()];
        
        list<string> contactsId = new list<String>();
        list<string> leadsId = new list<String>();
        
        String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
        String leadPrefix = Schema.SObjectType.Lead.getKeyPrefix();
        
        for(Event event : events) {
              string whoIdString = event.WhoId;
            
              if(whoIdString.startsWith(contactPrefix))
                  contactsId.add(whoIdString);
              else if(whoIdString.startsWith(LeadPrefix))
                  leadsId.add(whoIdString);                    
        }
        
        map<String, Contact> contactsMap = new map<String, Contact>( [SELECT firstName, lastName, (SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1) FROM Contact WHERE id IN :contactsId LIMIT :Limits.getLimitQueryRows()] );
        map<String, Lead> leadsMap = new map<String, Lead>( [SELECT firstName, lastName, (SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1) FROM Lead WHERE id IN :leadsId LIMIT :Limits.getLimitQueryRows()] );
        
        // 2  - Put the Contacts into a Tile
        tiles = new List<Tile>();
        for (Event event : events) {
            String whoIdString = event.WhoId;
            String imageUrl = null;
                     
            if(whoIdString.startsWith(contactPrefix)) {
                
                if(contactsMap.get(whoIdString).Attachments != null && contactsMap.get(whoIdString).Attachments.size() > 0){}
                    imageUrl = '/servlet/servlet.FileDownload?file=' + contactsMap.get(whoIdString).Attachments[0].Id;
                
                tiles.add(new Tile('Event with ' + contactsMap.get(whoIdString).FirstName + ' ' + contactsMap.get(whoIdString).LastName, imageUrl, 'event_tile', event));
            }
            else if(whoIdString.startsWith(leadPrefix)) {
                
                if(leadsMap.get(whoIdString).Attachments != null && leadsMap.get(whoIdString).Attachments.size() > 0){}
                    imageUrl = '/servlet/servlet.FileDownload?file=' + leadsMap.get(whoIdString).Attachments[0].Id;
                    
                tiles.add(new Tile('Event with ' + leadsMap.get(whoIdString).FirstName + ' ' + leadsMap.get(whoIdString).LastName, imageUrl, 'event_tile', event));
            }
        }
        
        
        // 3 - Add the Tiles to a TileGroup
        tileGroups = new list<TileGroup>();
        tileGroups.add(new TileGroup('Upcoming Events', tiles));
        
        // 4 - Remove the gaps...
        tileGroups = fillTheGaps(tileGroups);
        
    }
}