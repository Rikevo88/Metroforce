public virtual class AppController {
    public String latitude {
        get {
            if (latitude == null) {
                String latHeader = ApexPages.currentPage().getHeaders().get('latitude');
                String latParam = ApexPages.currentPage().getParameters().get('latitude');
                
                latitude = (latHeader != null) ? latHeader : (latParam != null) ? latHeader : null;
            }
            return latitude;
        }
        set;
    }
    public String longitude { 
        get {
            if (longitude == null) {
                longitude = ApexPages.currentPage().getHeaders().get('longitude');
            }
            return longitude;
        }
        set;
    }
    public User user {
        get {
            if (user == null) {
                user = [SELECT FirstName, LastName, FullPhotoUrl, SmallPhotoUrl
                    FROM User 
                    WHERE Id = :UserInfo.getUserId() 
                    LIMIT 1];
            }
            return user;
        }
        set;
    }
    
    public List<TileGroup> fillTheGaps(List<TileGroup> groups) {
        List<TileGroup> groupsWithoutGaps = new List<TileGroup>();
        
        for (TileGroup tileGroup : groups) {
            TileGroup tileGroupWithoutGaps = tileGroup;
            List<Tile> tilesWithoutGaps = new List<Tile>();
        
            List<Tile> largeTilesForAfterGap = new List<Tile>();
            Boolean lastTileWasSmall = false;
            Integer numberOfTiles = tileGroup.tiles.size();
            Integer index = 1;
            for (Tile tile : tileGroup.tiles) {
                
                if (index == numberOfTiles) {
                    // Last Tile in the group
                    tilesWithoutGaps.add(tile);
                    
                    if (largeTilesForAfterGap.size() > 0) {
                        tilesWithoutGaps.addAll(largeTilesForAfterGap);
                        largeTilesForAfterGap.clear();
                    }
                }
                else if (lastTileWasSmall && !tile.largeTile) {
                    System.debug('Small Tile after small Tile');
                    // Small Tile after small Tile
                    tilesWithoutGaps.add(tile);
                    
                    if (largeTilesForAfterGap.size() > 0) {
                        tilesWithoutGaps.addAll(largeTilesForAfterGap);
                        largeTilesForAfterGap.clear();
                    }
                    
                    lastTileWasSmall = false;
                }
                else if (lastTileWasSmall && tile.largeTile) {
                    System.debug('Large Tile after small Tile');
                    // Large Tile after small Tile
                    largeTilesForAfterGap.add(tile);
                    //tilesWithoutGaps.add(tile);
                    /** Not sure yet... **/
                    //lastTileWasSmall = false;
                }
                else if (!lastTileWasSmall && !tile.largeTile) {
                    System.debug('First small Tile');
                    // First small Tile
                    tilesWithoutGaps.add(tile);
                    lastTileWasSmall = !tile.largeTile;
                }
                else {
                    System.debug('First large Tile');
                    // First large Tile
                    tilesWithoutGaps.add(tile);
                    lastTileWasSmall = !tile.largeTile;
                }
                
                ++index;
            }
            
            tileGroupWithoutGaps.tiles = tilesWithoutGaps;
            groupsWithoutGaps.add(tileGroupWithoutGaps);
        }
        
        return groupsWithoutGaps;
    }
}