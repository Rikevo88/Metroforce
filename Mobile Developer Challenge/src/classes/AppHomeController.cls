public class AppHomeController extends AppController {
    public List<TileGroup> tileGroups { get; private set; }
    
    public AppHomeController() {
        latitude = ApexPages.currentPage().getParameters().get('latitude');
        longitude = ApexPages.currentPage().getParameters().get('longitude');
        tileGroups = new List<TileGroup>();
        List<Tile> tiles = new List<Tile>();

        System.debug('lat = ' + latitude + ', lon = ' + longitude);
        
        if ((latitude != null && latitude != 'undefined') && (longitude != null && longitude != 'undefined')) {
            String contactsQuery = 'SELECT FirstName, LastName, Name, '
                                + '(SELECT Body, CreatedById, CreatedDate FROM Feeds WHERE Type = \'TextPost\' ORDER BY CreatedDate DESC LIMIT 10), '
                                + '(SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE \'%image%\' LIMIT 1) '
                                + 'FROM Contact '
                                + 'WHERE DISTANCE(Geolocation__c, GEOLOCATION('  + latitude + ', ' + longitude + '), \'mi\') <= 10 '
                                + 'ORDER BY LastName '
                                + 'LIMIT 10';
            List<Contact> nearContacts = Database.query(contactsQuery);
            
            String leadsQuery = 'SELECT FirstName, LastName, Name, '
                                + '(SELECT Body, CreatedById, CreatedDate FROM Feeds WHERE Type = \'TextPost\' ORDER BY CreatedDate DESC LIMIT 10), '
                                + '(SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE \'%image%\' LIMIT 1) '
                                + 'FROM Lead '
                                + 'WHERE DISTANCE(Geolocation__c, GEOLOCATION('  + latitude + ', ' + longitude + '), \'mi\') <= 10 '
                                + 'ORDER BY LastName '
                                + 'LIMIT 10';
            List<Lead> nearLeads = Database.query(leadsQuery);
            
            String accountsQuery = 'SELECT Name, '
                                + '(SELECT Body, CreatedById, CreatedDate FROM Feeds WHERE Type = \'TextPost\' ORDER BY CreatedDate DESC LIMIT 10), '
                                + '(SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE \'%image%\' LIMIT 1) '
                                + 'FROM Account '
                                + 'WHERE DISTANCE(Geolocation__c, GEOLOCATION('  + latitude + ', ' + longitude + '), \'mi\') <= 10 '
                                + 'LIMIT 10';
            List<Account> nearAccounts = Database.query(accountsQuery);
            
            Map<String, SObject> nearRecordsMap = new Map<String, SObject>();
            for (Contact contact : nearContacts) {
                if (!nearRecordsMap.containsKey(contact.LastName + ', ' + contact.FirstName + ' - ' + contact.Id)) {
                    nearRecordsMap.put(contact.LastName + ', ' + contact.FirstName + ' - ' + contact.Id, contact);
                }
            }
            for (Lead lead : nearLeads) {
                if (!nearRecordsMap.containsKey(lead.LastName + ', ' + lead.FirstName + ' - ' + lead.Id)) {
                    nearRecordsMap.put(lead.LastName + ', ' + lead.FirstName + ' - ' + lead.Id, lead);
                }
            }
            for (Account account : nearAccounts) {
                if (!nearRecordsMap.containsKey(account.Name + ' - ' + account.Id)) {
                    nearRecordsMap.put(account.Name + ' - ' + account.Id, account);
                }
            }
            
            List<String> nearRecordsList = new List<String>(nearRecordsMap.keySet());
            nearRecordsList.sort();
            
            // 2  - Put the Contacts into a Tile
            Integer i = 0;
            tiles = new List<Tile>();
            for (String key : nearRecordsList) {
                SObject record = nearRecordsMap.get(key);
                String cssStyle = (record.getsObjectType() == Account.sObjectType) ? 'account_tile' : 
                    (record.getsObjectType() == Lead.sObjectType) ? 'lead_tile' : 'contact_tile';
                
                List<Attachment> attachments = record.getSObjects('Attachments');
                String imageUrl = null;
                if(attachments != null && attachments.size() > 0) {
                    imageUrl = '/servlet/servlet.FileDownload?file=' + attachments[0].get('Id');
                }
                
                List<SObject> feeds = record.getSObjects('Feeds');
                if (feeds != null && feeds.size() > 0) {
                    Tile tile = new Tile((String)record.get('Name'), imageUrl, true, cssStyle);
                    tile.record = record;
                    tile.actionFeed = new List<String>();
                    
                    
                    list<String> userIds = new list<String>();
                    for(SObject item : feeds) {
                        userIds.add(String.ValueOf(item.get('CreatedById')));
                    }
                    
                    map<String, User> users = new map<String, User>( [SELECT Name FROM User where Id IN :userIds] );
                    
                    for (SObject item : feeds) {
                        tile.actionFeed.add(users.get(String.ValueOf(item.get('CreatedById'))).Name + ' @ ' + String.ValueOf(DateTime.ValueOf(item.get('CreatedDate')).format('dd/MM/yyyy hh:mm')) + ' "' + (String)item.get('Body')+'"');
                    }
                    tiles.add(tile);
                }
                else {
                	Tile tile = new Tile((String)record.get('Name'), imageUrl, cssStyle);
                	tile.record = record;
                    tiles.add(tile);
                }
                
                ++i;
            }
            
            // 3 - Add the Tiles to a TileGroup
            tileGroups.add(new TileGroup('Near By', tiles));
        }
        
        List<Event> events = [SELECT AccountId,ActivityDate,ActivityDateTime,Description,DurationInMinutes,EndDateTime,GroupEventType,IsAllDayEvent,IsArchived,IsChild,IsGroupEvent,IsPrivate,IsRecurrence,IsReminderSet,Location,OwnerId,ShowAs,StartDateTime,Subject,WhatId,WhoId 
                             FROM Event
                             WHERE ActivityDate <= :Date.today().addDays(7)
                             	AND EndDateTime >= :DateTime.now()
                             LIMIT 6];
        
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
        tileGroups.add(new TileGroup('Upcoming Events', tiles));
        
        // 4 - Remove the gaps...
        tileGroups = fillTheGaps(tileGroups);
    }
}