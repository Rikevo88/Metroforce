public with sharing class AppLeadController extends AppController {
	public Id recordId { get; set; }
	public Lead lead {
		get {
			if (lead == null && recordId != null) {
				lead = [SELECT City,Company,Email,FirstName,Industry,LastName,LeadSource,Phone,PostalCode,Street,Title,Website,
							(SELECT Body FROM Feeds WHERE Type = 'TextPost' ORDER BY CreatedDate DESC LIMIT 10),
							(SELECT BodyLength, ContentType, Description, Id, Name FROM Attachments WHERE ContentType LIKE '%image%' LIMIT 1)
					FROM Lead
					WHERE Id = :recordId
					LIMIT 1];
			}
			return lead;
		}
		set;
	}
	public String profilePictureUrl {
		get {
			if (profilePictureUrl == null) {
				if (lead.Attachments != null && lead.Attachments.size() > 0) {
					profilePictureUrl = '/servlet/servlet.FileDownload?file=' + lead.Attachments[0].Id;
				}
				else {
					profilePictureUrl = null;
				}
			}
			return profilePictureUrl;
		}
		private set;
	}
	
	public AppLeadController() {
		recordId = ApexPages.currentPage().getParameters().get('id');
	}
}