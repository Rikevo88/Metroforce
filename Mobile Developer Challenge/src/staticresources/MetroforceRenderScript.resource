function AppHistory() {
	this.previousPages = new Array();

	this.addPage = function(title, address) {
		this.previousPages.push(new Array(title, address));
	}

	this.getLastPageTitle = function() {
		return this.previousPages[this.previousPages.length - 2][0];
	}

	this.getLastPageLink = function() {
		return this.previousPages[this.previousPages.length - 2][1];
	}
}

// Globals
var geoLatitude;
var geoLongitude;
var browserWidth;
var browserHeight;
var headerHeight;
var footerHeight;
var appHeight;
var tileGroupPadding;
var h2Height;
var numberOfTileRows;
var tileHeight;
var myScroll;
var appHistory;

function setGlobals() {
	browserWidth = window.innerWidth;
	browserHeight = window.innerHeight;

	headerHeight = Math.floor(browserHeight * 0.1);
	footerHeight = Math.floor(browserHeight * 0.05);
	appHeight = Math.floor(browserHeight * 0.85);
	tileGroupPadding = 30;
}
 
function setAppElements() {
	h2Height = $("h2").first().height();
	numberOfTileRows = (browserHeight < 800) ? 3 : (browserHeight < 1000) ? 4 : 5;
	tileHeight = Math.floor(((appHeight - h2Height) / numberOfTileRows) - 10);
}

function geolocation(callback) {
	if(navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(function(position) {
			geoLatitude = position.coords.latitude;
			geoLongitude = position.coords.longitude;
			callback();
		}, geolocationErrorHandler);
	}
	else {
		alert("geolocation not supported :(");
	}
}

function geolocationErrorHandler(error) {
	switch (error.code) {
		case error.PERMISSION_DENIED:
			alert("user did not share geolocation data");  
		break;  

		case error.POSITION_UNAVAILABLE:
			alert("could not detect current position");  
		break;  

		case error.TIMEOUT: 
			alert("retrieving position timed out");  
		break;  

		default: 
			alert("unknown error");  
		break;  
	}
}

function renderPage() {
	$("#app_header").height(headerHeight).css("margin-left", tileGroupPadding + "px").css("margin-right", tileGroupPadding + "px");
	$("#app_footer").height(footerHeight).css("margin-left", tileGroupPadding + "px").css("margin-right", tileGroupPadding + "px");

	$(".tile").height(tileHeight);
	$(".large_tile").width((tileHeight * 2) + 10);
	$(".small_tile").width(tileHeight);
	$(".tile_group").css("margin-left", tileGroupPadding + "px").height(appHeight);

	var appWidth = tileGroupPadding;

	if ($(".tile_group").size() > 0) {
	$(".tile_group").each(function(index) {
		var maxNumberOfCols = $(this).attr("data-max-cols");
		var $section = $(this).children("section");
		var numberOfChildRows = 0;
		var previousTileSmall = false;
		
		$section.children(".tile").each(function() {
			numberOfChildRows += (!previousTileSmall) ? 1 : 
				($(this).hasClass("large_tile")) ? 1 : 0;
			
			if ($(this).hasClass("small_tile") && previousTileSmall) {
				previousTileSmall = false;
			}
			else if ($(this).hasClass("small_tile")) {
				previousTileSmall = true;
			}
			else {
				previousTileSmall = false;
			}
		});

		var $numberOfChildren = $section.children(".tile").size();
//if (maxNumberOfCols == null) {
			var numberOfColumns = Math.ceil(numberOfChildRows / numberOfTileRows);
//                    }
//                    else {
//                        var numberOfColumns = maxNumberOfCols;
//                    }
		
		var columnWidth = (tileHeight * 2) + 20;
		var groupWidth = columnWidth * numberOfColumns;
		appWidth += (groupWidth + tileGroupPadding);

		$section.width(groupWidth).height((tileHeight + 10) * numberOfTileRows);
		$section.css("-moz-column-gap", 0).css("-webkit-column-gap", 0).css("column-gap", 0);
		$section.css({"-webkit-columns": (tileHeight * 2) + "px " + numberOfColumns});
	});
	}
	else {
		appWidth = browserWidth;
		$("#content_scroller").height(appHeight);
	}

	$("#content_scroller").width(appWidth);
	//$("#content_y_scroller").height(appHeight).css("max-height", appHeight);


	//load the list view of the tile clicked
	$("a").click(function(event){
		event.preventDefault();
		var link = $(this).attr("href");
		var pageTitle = $(this).attr("data-page-title");
		appHistory.addPage(pageTitle, link);

		$("#app_content").fadeOut(800, function() {
			$("#app_content").load(link, {latitude: geoLatitude, longitude: geoLongitude}, function() {
				$("#page_title").html(pageTitle);
				if (pageTitle == "{!$Label.AppName}") 
					$("#back_button").hide();
				else
					$("#back_button").show();
				$("#back_button_link").attr("href", appHistory.getLastPageLink());
				$("#back_button_link").attr("data-page-title", appHistory.getLastPageTitle());
				renderPage();
				$("#app_content").fadeIn(800, function() {                                  
					var myScroll = new iScroll("app_content", { bounce:false, useTransition:true});
				});
			});
		});
	});


	$(".tile > a").click(function(event){
		var child = $(this).find(">:first-child");
		var originalHeight = child.height();
		var originalWidth = child.width();
		child.animate({height: (child.height() - 10), width: (child.width() - 10)}, 200,
			function(){
				child.animate({height: originalHeight, width: originalWidth}, 200); 
			}
		);
	});

	$(".lead_transition").click(function(event){
		event.preventDefault();
		var link = $(this).attr("href");
		
		$("#app_content").fadeOut(250, function() {
			$('#AppNav').load('https://c.na9.visual.force.com/apex/AppNavigationPage', function() {
				$("#app_content").load(link, function() {
					renderPage();
					$("body").animate({backgroundColor:"#92CD00;"}, 500, function() {                                  
						var myScroll = new iScroll("app_content", { bounce:false, useTransition:true});
					});
				});
			});
		});
	});
}


$(document).ready(function() {
	appHistory = new AppHistory();
	appHistory.addPage("{!$Label.AppName}","{!URLFOR($Page.AppHome)}");
	$("#back_button").hide();
	setGlobals();
	geolocation(function() {
		$("#app_content").load("{!URLFOR($Page.AppHome)}", {latitude: geoLatitude, longitude: geoLongitude}, function() {
			setAppElements();
			renderPage();
			$("#app_content").fadeIn(800, function() {                                  
				var myScroll = new iScroll("app_content", { bounce:false, useTransition:true});
			});
		});
		document.addEventListener('touchmove', function (e) { e.preventDefault(); }, false); 
	});
});