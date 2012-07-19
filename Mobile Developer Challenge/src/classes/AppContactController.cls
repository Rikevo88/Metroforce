public with sharing class AppContactController extends AppController {
	public Id recordId { get; set; }
	public Contact contact {
		get {
			if (contact == null && recordId != null) {
				contact = [SELECT FirstName, LastName, Title, AccountId, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, MobilePhone,
							(SELECT Body FROM Feeds WHERE Type = 'TextPost'),
							(SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1)
					FROM Contact
					WHERE Id = :recordId
					LIMIT 1];
			}
			return contact;
		}
		set;
	}
	public String profilePictureUrl {
		get {
			if (profilePictureUrl == null) {
				if (contact.Attachments != null && contact.Attachments.size() > 0) {
					profilePictureUrl = '/servlet/servlet.FileDownload?file=' + contact.Attachments[0].Id;
				}
				else {
					profilePictureUrl = null;
				}
			}
			return profilePictureUrl;
		}
		private set;
	}
	
	public AppContactController() {
		recordId = ApexPages.currentPage().getParameters().get('id');
	}
}