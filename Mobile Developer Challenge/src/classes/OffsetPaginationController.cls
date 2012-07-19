public with sharing class OffsetPaginationController extends AppController {

    public String testString { get { if(testString == null) testString = ''; return testString; } set; }

    public PageReference loadMoreRecords() {
    
        testString = 'loaded more records';
        
         List<Contact> contacts = [SELECT FirstName, LastName,
                                  (SELECT Body FROM Feeds WHERE Type = 'TextPost'),
                                  (SELECT BodyLength, ContentType, Description, Id, Name FROM Contact.Attachments)
                                  FROM Contact ORDER BY LastName LIMIT 25];
                                  
        Integer i = 0;
        List<Tile> tiles = new List<Tile>();
        for (Contact contact : contacts) {
            String imageUrl = null;
            if(contact.Attachments.size() > 0) {
                imageUrl = '/servlet/servlet.FileDownload?file=' + contact.Attachments[0].Id;
            }
            
            if (contact.Feeds.size() > 0) {
                Tile tile = new Tile(contact.FirstName + ' ' + contact.LastName, imageUrl, true);
                tile.actionFeed = new List<String>();
                for (ContactFeed item : contact.Feeds)
                    tile.actionFeed.add(item.Body);
                tiles.add(tile);
            }
            else
                tiles.add(new Tile(contact.FirstName + ' ' + contact.LastName, imageUrl));
            ++i;
        }
        
        tileGroups.add(new TileGroup('Contactss', tiles));
        
        return null;
    }

    public List<TileGroup> tileGroups { get; private set; }
    
    public OffsetPaginationController() {
        // 1 - Get the Contacts
        List<Contact> contacts = [SELECT FirstName, LastName,
                                  (SELECT Body FROM Feeds WHERE Type = 'TextPost'),
                                  (SELECT BodyLength, ContentType, Description, Id, Name FROM Contact.Attachments)
                                  FROM Contact ORDER BY LastName LIMIT 25];
        
        // 2  - Put the Contacts into a Tile
        Integer i = 0;
        List<Tile> tiles = new List<Tile>();
        for (Contact contact : contacts) {
            String imageUrl = null;
            if(contact.Attachments.size() > 0) {
                imageUrl = '/servlet/servlet.FileDownload?file=' + contact.Attachments[0].Id;
            }
            
            if (contact.Feeds.size() > 0) {
                Tile tile = new Tile(contact.FirstName + ' ' + contact.LastName, imageUrl, true);
                tile.actionFeed = new List<String>();
                for (ContactFeed item : contact.Feeds)
                    tile.actionFeed.add(item.Body);
                tiles.add(tile);
            }
            else
                tiles.add(new Tile(contact.FirstName + ' ' + contact.LastName, imageUrl));
            ++i;
        }
        
        // 3 - Add the Tiles to a TileGroup
        tileGroups = new List<TileGroup>();
        tileGroups.add(new TileGroup('Contacts', tiles));
        
        // 1 - Get the Leads
        List<Lead> leads = [SELECT FirstName, LastName FROM Lead ORDER BY LastName LIMIT 10];
        
        // 2  - Put the Contacts into a Tile
        i = 3;
        tiles = new List<Tile>();
        for (Lead lead : leads) {
            if (math.mod(i, 5) == 0) 
                tiles.add(new Tile(lead.FirstName + ' ' + lead.LastName, null, true, 'lead_tile'));
            else
                tiles.add(new Tile(lead.FirstName + ' ' + lead.LastName, null, false, 'lead_tile'));
            i++;
        }
        
        // 3 - Add the Tiles to a TileGroup
        tileGroups.add(new TileGroup('Leads', tiles));
        
        // 1 - Get the Accounts
        List<Account> accounts = [SELECT Name,
                                  (SELECT BodyLength, ContentType, Description, Id, Name FROM Account.Attachments)
                                  FROM Account ORDER BY Name LIMIT 10];
        
        // 2  - Put the Contacts into a Tile
        i = 1;
        tiles = new List<Tile>();
        for (Account account : accounts) {
            String imageUrl = null;
            if(account.Attachments.size() > 0) {
                imageUrl = '/servlet/servlet.FileDownload?file=' + account.Attachments[0].Id;
            }
            
            if (math.mod(i, 3) == 0)
                tiles.add(new Tile(account.Name, imageUrl, true, 'account_tile'));
            else
                tiles.add(new Tile(account.Name, imageUrl, false, 'account_tile'));
            ++i;
        }
        
        // 3 - Add the Tiles to a TileGroup
        tileGroups.add(new TileGroup('Accounts', tiles));
        
        // 4 - Remove the gaps...
        tileGroups = fillTheGaps(tileGroups);
    }

}