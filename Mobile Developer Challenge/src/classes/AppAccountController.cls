public with sharing class AppAccountController extends AppController {	
	public Id recordId { get; set; }
	public Account account {
		get {
			if (account == null && recordId != null) {
				account = [SELECT Name, Type, AnnualRevenue, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, NumberOfEmployees, Website, Phone, Fax, Description, 
							(SELECT Body FROM Feeds WHERE Type = 'TextPost' ORDER BY CreatedDate DESC LIMIT 10),
							(SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1)
					FROM Account
					WHERE Id = :recordId
					LIMIT 1];
			}
			return account;
		}
		set;
	}
	public String profilePictureUrl {
		get {
			if (profilePictureUrl == null) {
				if (account.Attachments != null && account.Attachments.size() > 0) {
					profilePictureUrl = '/servlet/servlet.FileDownload?file=' + account.Attachments[0].Id;
				}
				else {
					profilePictureUrl = null;
				}
			}
			return profilePictureUrl;
		}
		private set;
	}
	
	public AppAccountController() {
		recordId = ApexPages.currentPage().getParameters().get('id');
	}
}