browser.runtime.sendMessage({ greeting: "hello" }).then((response) => {
	console.log("Received response: ", response);
});

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
	console.log("Received request: ", request);
});

window.addEventListener("click", (event) => {
	handleWindowClick(event);
}, false);

function handleWindowClick(event) {
	const linkElement = findLinkElement(event.target);
	if (linkElement) {
		// event.preventDefault();
		console.log(linkElement.href);
	}
}

function findLinkElement(element) {
	if (element.tagName === "A") {
		return element;
	} else if (element.parentNode) {
		return this.findLinkElement(element.parentNode);
	} else {
		return null;
	}
}
