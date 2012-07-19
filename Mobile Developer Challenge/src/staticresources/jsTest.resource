function test(event) {

	event.preventDefault();
	var link = "https://c.na9.visual.force.com/apex/AppLeadView?id=00QE000000AxsuN";
	

	$("#app_content").fadeOut(800, function() {
		$("#app_content").load(link, function() {

                 	renderPage();
                 	$("#app_content").fadeIn(800, function() {                                  
                        	var myScroll = new iScroll("app_content", { bounce:false, useTransition:true});
                 	});
		});
	});

}