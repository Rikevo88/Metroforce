public class Tile {
    public String header { get; set; }
    public String imageUrl { get; set; }
    public Boolean largeTile { get; set; }
    public String tileStyle { get; set; }
    public List<String> actionFeed { get; set; }
    public String actionText { get; set; }
    public String recordId { get; set; }
    public SObject record { 
    	get; 
    	set {
    		record = value;
    		recordId = value.Id;
    	} 
	}
    
    public Event event {
    	get {
    		if (record != null)
    			return (Event)record;
			return null;
    	}
    }
    
    public Tile(String header, String imageUrl) {
        this.header = header;
        this.imageUrl = imageUrl;
        this.largeTile = false;
        this.tileStyle = null;
    }
    
    public Tile(String header, String imageUrl, Boolean largeTile) {
        this.header = header;
        this.imageUrl = imageUrl;
        this.largeTile = largeTile;
        this.tileStyle = null;
    }
    
    public Tile(String header, String imageUrl, String tileStyle) {
        this.header = header;
        this.imageUrl = imageUrl;
        this.largeTile = false;
        this.tileStyle = tileStyle;
    }
    
    public Tile(String header, String imageUrl, Boolean largeTile, String tileStyle) {
        this.header = header;
        this.imageUrl = imageUrl;
        this.largeTile = largeTile;
        this.tileStyle = tileStyle;
    }
    
    /*
     * @author Richrd Evans
     * @desdcription Testing record ids on tiles
     */
    public Tile(String header, String imageUrl, String tileStyle, String recordId) {
        this.header = header;
        this.imageUrl = imageUrl;
        this.largeTile = false;
        this.tileStyle = tileStyle;
        this.recordId = recordId;
    }
    
    /*
     * @author Richrd Evans
     * @desdcription Testing record ids on tiles
     */
    public Tile(String header, String imageUrl, String tileStyle, SObject record) {
        this.header = header;
        this.imageUrl = imageUrl;
        this.largeTile = false;
        this.tileStyle = tileStyle;
        this.recordId = record.Id;
        this.record = record;
    }
}