public class AppLeadExtension {

    public Lead lead;
    
    public AppLeadExtension(ApexPages.StandardController stdController) {
        this.lead = (Lead)stdController.getRecord();
    }
    
    public AppLeadExtension() {
    
        AppPageNameMap.urlStack.add(ApexPages.CurrentPage().getUrl());
    }
    
    public PageReference saveRecord() {
        
        update this.lead;

        return new PageReference('/apex/appleadview' + '?id='+lead.Id);
    }
    
    public PageReference testSave() {
        update lead;
        return null;
    }
    
}