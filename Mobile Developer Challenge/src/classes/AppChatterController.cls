public class AppChatterController extends AppController {

    public List<TileGroup> tileGroups { get; private set; }
    
    public AppChatterController() {
        
        List<Tile> tiles = new List<Tile>();    
        
        List<FeedComment> comments = [SELECT CommentBody,CommentType,CreatedById,CreatedBy.Name,CreatedDate,FeedItemId,Id,InsertedById,IsDeleted,ParentId,RelatedRecordId FROM FeedComment ORDER BY CreatedDate DESC LIMIT :Limits.getLimitQueryRows()];
        
        list<String> insertedByIds = new list<String>();        
        for(FeedComment comment : comments) {
            insertedByIds.add(comment.InsertedById);
        }
        
        list<String> insertedByUserIds = new list<String>();       
        for(string id : insertedByIds) {
               if(id.startsWith(Schema.SObjectType.User.getKeyPrefix()))
                  insertedByUserIds.add(id);
        }
        
        map<String, user> userMap = new map<String, User>([SELECT FullPhotoUrl FROM User WHERE id IN :insertedByUserIds]);
        
        // 2  - Put the Contacts into a Tile
        tiles = new List<Tile>();
        for (FeedComment comment : comments) {
            String insertedByIdString = comment.InsertedById;
            if(insertedByIdString.startsWith(Schema.SObjectType.User.getKeyPrefix()))
                tiles.add(new Tile('Posted by ' + comment.CreatedBy.Name, userMap.get(comment.InsertedById).FullPhotoUrl, 'chatter_tile', comment));
            else
                tiles.add(new Tile('Posted by ' + comment.CreatedBy.Name, null, 'chatter_tile', comment));
        }

            
        // 3 - Add the Tiles to a TileGroup
        tileGroups = new list<TileGroup>();
        tileGroups.add(new TileGroup('Chatter Comment Feed', tiles));
        
        // 4 - Remove the gaps...
        tileGroups = fillTheGaps(tileGroups);
        
    }
}