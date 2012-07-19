public class AppAccountsController extends AppController {
    public List<TileGroup> tileGroups { get; private set; }
    
    public AppAccountsController() {
        List<Tile> tiles = new List<Tile>();
        
        // 1 - Get the Contacts
        List<Account> accounts = [SELECT Name,
                                  (SELECT Body, CreatedBy.Name, CreatedDate FROM Feeds WHERE Type = 'TextPost' ORDER BY CreatedDate DESC LIMIT 10),
                                  (SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1)
                                  FROM Account
                                  ORDER BY Name 
                                  LIMIT :Limits.getLimitQueryRows()];
        
        // 2  - Put the Contacts into a Tile
        for (Account account : accounts) {
            String imageUrl = null;
            if(account.Attachments.size() > 0) {
                imageUrl = '/servlet/servlet.FileDownload?file=' + account.Attachments[0].Id;
            }
            
            if (account.Feeds.size() > 0) {
                Tile tile = new Tile(account.Name, imageUrl, true, 'account_tile');
                tile.recordId = account.Id;
                tile.actionFeed = new List<String>();
                for (AccountFeed item : account.Feeds)
                    tile.actionFeed.add(item.CreatedBy.Name + ' @ ' + item.CreatedDate.format('dd/MM/yyyy hh:mm') + ' "' + item.Body);
                tiles.add(tile);
            }
            else {
            	Tile tile = new Tile(account.Name, imageUrl, 'account_tile');
            	tile.recordId = account.Id; 
                tiles.add(tile);
            }
        
            // 3 - Add the Tiles to a TileGroup
            tileGroups = new List<TileGroup>();
            tileGroups.add(new TileGroup('All Accounts', tiles));
            
            // 4 - Remove the gaps...
            tileGroups = fillTheGaps(tileGroups);
        }
    }
}