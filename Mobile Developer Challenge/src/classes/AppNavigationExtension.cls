public class AppNavigationExtension {
    public AppNavigationExtension(ApexPages.StandardController stdController) {
        AppPageNameMap.urlStack.add(ApexPages.CurrentPage().getUrl());
    }
}