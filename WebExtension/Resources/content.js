browser.runtime.sendMessage({ greeting: "hello" }).then((response) => {
	console.log("Received response: ", response);
});

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
	console.log("Received request: ", request);
});

// browser.webRequest.onBeforeRequest.addListener(function(p1: browser.webRequest._OnBeforeRequestDetails){ console.log(p1); }, undefined, undefined)

browser.webRequest.onBeforeRequest.addListener((event) => {
	console.log(event);
// 	if (event.target.tagName === "A") {
// //		event.preventDefault();
// 		var href = event.target.getAttribute("href");
// 		console.log(href);
//
// 		safari.extension.dispatchMessage("clickedLinkEvent", {"url": href});
// 	}
}, null, null);
