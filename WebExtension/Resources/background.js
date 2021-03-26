browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
	console.log("Received request: ", request);

	if (request.greeting === "hello") {
		sendResponse({ farewell: "goodbye" });
	}
});

browser.webRequest.onBeforeRequest.addListener((event) => {
	console.log(event);
// 	if (event.target.tagName === "A") {
// //		event.preventDefault();
// 		var href = event.target.getAttribute("href");
// 		console.log(href);
//
// 		safari.extension.dispatchMessage("clickedLinkEvent", {"url": href});
// 	}
});
