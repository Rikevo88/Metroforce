public class AppContactsController extends AppController {
    public List<TileGroup> tileGroups { get; private set; }
    
    public AppContactsController() {
        List<Tile> tiles = new List<Tile>();
        
        // 1 - Get the Contacts
        List<Contact> contacts = [SELECT FirstName, LastName,
                                  (SELECT Body, Createdby.Name, CreatedDate FROM Feeds WHERE Type = 'TextPost' ORDER BY CreatedDate DESC LIMIT 10),
                                  (SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1)
                                  FROM Contact
                                  ORDER BY LastName
                                  LIMIT :Limits.getLimitQueryRows()];
        
        // 2  - Put the Contacts into a Tile
        for (Contact contact : contacts) {
            String imageUrl = null;
            if(contact.Attachments.size() > 0) {
                imageUrl = '/servlet/servlet.FileDownload?file=' + contact.Attachments[0].Id;
            }
            
            if (contact.Feeds.size() > 0) {
                Tile tile = new Tile(contact.FirstName + ' ' + contact.LastName, imageUrl, true);
                tile.recordId = contact.Id;
                tile.actionFeed = new List<String>();
                for (ContactFeed item : contact.Feeds)
                    tile.actionFeed.add(item.CreatedBy.Name + ' @ ' + item.CreatedDate.format('dd/MM/yyyy hh:mm') + ' "' + item.Body);
                tiles.add(tile);
            }
            else {
            	Tile tile = new Tile(contact.FirstName + ' ' + contact.LastName, imageUrl);
            	tile.recordId = contact.Id;
                tiles.add(tile);
            }
        
            // 3 - Add the Tiles to a TileGroup
            tileGroups = new List<TileGroup>();
            tileGroups.add(new TileGroup('All Contacts', tiles));
            
            // 4 - Remove the gaps...
            tileGroups = fillTheGaps(tileGroups);
        }
    }
}