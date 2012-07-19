public with sharing class AppPageNameMap{

    public String tab { get { if(tab==null) tab = '\t'; return tab; } set; }

    public Boolean isHomePage { get { return isHomePage(); }  set; }

    public String getPageTitle { get{ return getPageTitle(); } set; }

    public static map<String, String> pageNameMap {
        get {
            if(pageNameMap == null) {
            
                map<String, String> tempMap = new map<String, String>();
                tempMap.put('app', 'Metroforce');
                tempMap.put('appleads', 'Leads');
                tempMap.put('appleadview', 'Lead');
                
                pageNameMap = tempMap;
            }
            
            return pageNameMap;
        }
        private set;
    }
    
    public static list<String> urlStack {
        get {
            if(urlStack == null) {
                urlStack = new list<String>();
            }
            return urlStack;
        }
        set;
    }
      
    public AppPageNameMap() { }
    
    public string getPreviousPage() {
        
        if(urlStack == null || urlStack.Size()== 0)
            return 'No previous Page';
        
        return urlStack[urlStack.Size()-1];
    }
    
    public String getPageTitle(){
    
        String pageName = stripPageName(getPreviousPage());       
        pageName = pageName.toLowerCase();
        
        if(pageNameMap.containsKey(pageName))
            return pageNameMap.get(pageName);
                               
        return 'Page not Mapped';
    }
    
    public Boolean isHomePage() {
        
        String pageName = stripPageName(getPreviousPage());      
        pageName = pageName.toLowerCase();
                
        if(pageNameMap.containsKey(pageName))
            if(pageNameMap.get(pageName).equalsIgnoreCase('Metroforce'))
                return true;
                
        for(String page : pageNameMap.keySet()) {
            if(pageName.equalsIgnoreCase(page))
                if(pageNameMap.get(page).equalsIgnoreCase('Home'))
                    return true;
        }
    
        return false;
    }
    
    private String stripPageName(String pageUrl) {
    
        String tempString = pageUrl;
    
        if(pageUrl.contains('?'))
            tempString = pageUrl.substring(0, pageUrl.indexOf('?'));
        
        
        if(tempString.contains('apex/'))
            tempString = tempString.substring(tempString.indexOf('apex/')+5, tempString.length());
        
        return tempString;
    }
}