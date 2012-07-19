public with sharing class AppMapController extends AppController {
	
	private class GeoMarker {
		public String postcode { get; set; }
		public String title { get; set; }
		public String objectType { get; set; }
		public String contactDetails { get; set; }
		public String address { 
			get {
				String a = '';
					if (street != null && street != '')
						a = street;
					if (city != null && city != '')
						a += (a == '') ? city : ', ' + city;
					if (state != null && state != '')
						a += (a == '') ? state : ', ' + state;
					if (postcode != null && postcode != '')
						a += (a == '') ? postcode : ', ' + postcode;
				return a;
			}			 
		}
		public String street { get; set; }
		public String city { get; set; }
		public String state { get; set; }
	}
	
	public List<GeoMarker> geoMarkers {
		get;
		set;
	}
	    
    public AppMapController() {
        latitude = ApexPages.currentPage().getParameters().get('latitude');
        longitude = ApexPages.currentPage().getParameters().get('longitude');
        geoMarkers = new List<GeoMarker>();
        
        if ((latitude != null && latitude != 'undefined') && (longitude != null && longitude != 'undefined')) {
            String contactsQuery = 'SELECT FirstName, LastName, Name, Account.Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, Phone '
                                + 'FROM Contact '
                                + 'WHERE DISTANCE(Geolocation__c, GEOLOCATION('  + latitude + ', ' + longitude + '), \'mi\') <= 10 '
                                + 'ORDER BY LastName '
                                + 'LIMIT 10';
            List<Contact> nearContacts = Database.query(contactsQuery);
            
            String leadsQuery = 'SELECT FirstName, LastName, Name, Company, Street, City, State, PostalCode, Phone '
                                + 'FROM Lead '
                                + 'WHERE DISTANCE(Geolocation__c, GEOLOCATION('  + latitude + ', ' + longitude + '), \'mi\') <= 10 '
                                + 'ORDER BY LastName '
                                + 'LIMIT 10';
            List<Lead> nearLeads = Database.query(leadsQuery);
            
            String accountsQuery = 'SELECT Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Phone '
                                + 'FROM Account '
                                + 'WHERE DISTANCE(Geolocation__c, GEOLOCATION('  + latitude + ', ' + longitude + '), \'mi\') <= 10 '
                                + 'LIMIT 10';
            List<Account> nearAccounts = Database.query(accountsQuery);
            
            for (Contact contact : nearContacts) {
                GeoMarker geo = new GeoMarker();
                geo.postcode = contact.MailingPostalCode;
                geo.title = contact.FirstName + ' ' + contact.LastName + ', ' + contact.Account.Name;
                geo.objectType = Schema.SObjectType.Contact.Label;
                geo.street = contact.MailingStreet;
                geo.city = contact.MailingCity;
                geo.state = contact.MailingState;
                geo.contactDetails = contact.Phone;
                geoMarkers.add(geo);
            }
            for (Lead lead : nearLeads) {
                GeoMarker geo = new GeoMarker();
                geo.postcode = lead.PostalCode;
                geo.title = lead.FirstName + ' ' + lead.LastName + ', ' + lead.Company;
                geo.objectType = Schema.SObjectType.Lead.Label;
                geo.street = lead.Street;
                geo.city = lead.City;
                geo.state = lead.State;
                geo.contactDetails = lead.Phone;
                geoMarkers.add(geo);
            }
            for (Account account : nearAccounts) {
                GeoMarker geo = new GeoMarker();
                geo.postcode = account.BillingPostalCode;
                geo.title = account.Name;
                geo.objectType = Schema.SObjectType.Account.Label;
                geo.street = account.BillingStreet;
                geo.city = account.BillingCity;
                geo.state = account.BillingState;
                geo.contactDetails = account.Phone;
                geoMarkers.add(geo);
            }
        }
    }
}