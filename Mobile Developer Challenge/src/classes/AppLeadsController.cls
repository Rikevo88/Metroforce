public class AppLeadsController extends AppController {
    public List<TileGroup> tileGroups { get; private set; }
    
    public AppLeadsController() {

        // 1 - Get the Leads
        List<Lead> leads = [SELECT FirstName, LastName,
                            (SELECT Body, CreatedBy.Name, CreatedDate FROM Feeds WHERE Type = 'TextPost' ORDER BY CreatedDate DESC LIMIT 10),
                            (SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1)
                            FROM Lead ORDER BY LastName
                            LIMIT :Limits.getLimitQueryRows()];
        
        // 2  - Put the Leads into a Tile
        List<Tile> tiles = new List<Tile>();
        
        for (Lead lead : leads) {
            String imageUrl = null;
            if(lead.Attachments.size() > 0) {
                imageUrl = '/servlet/servlet.FileDownload?file=' + lead.Attachments[0].Id;
            }
            
            if (lead.Feeds.size() > 0) {
                Tile tile = new Tile(lead.FirstName + ' ' + lead.LastName, imageUrl, true, 'lead_tile');
                tile.recordId = lead.Id;
                tile.actionFeed = new List<String>();
                for (LeadFeed item : lead.Feeds)
                    tile.actionFeed.add(item.CreatedBy.Name + ' @ ' + item.CreatedDate.format('dd/MM/yyyy hh:mm') + ' "' + item.Body);
                tiles.add(tile);
            }
            else {
            	Tile tile = new Tile(lead.FirstName + ' ' + lead.LastName, imageUrl,'lead_tile');
            	tile.recordId = lead.Id;
                tiles.add(tile);
            }
        
            // 3 - Add the Tiles to a TileGroup
            tileGroups = new List<TileGroup>();
            tileGroups.add(new TileGroup('All Leads', tiles));
            
            // 4 - Remove the gaps...
            tileGroups = fillTheGaps(tileGroups);
        }
        
    }
}