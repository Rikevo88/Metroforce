public class TileGroup {
    public String header { get; set; }
    public List<Tile> tiles { get; set; }
    
    public TileGroup(String header, List<Tile> tiles) {
        this.header = header;
        this.tiles = tiles;
    }
}