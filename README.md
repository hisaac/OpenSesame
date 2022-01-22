# OpenSesame

**🚧 OpenSesame is very much a work in progress 🚧**

OpenSesame is an app for opening links in macOS apps instead of the web browser.

## Currently supported Links/Apps

- Twitter links → Twitter.app
- Apple Music and iTunes links → Music.app
- Mac App Store links → Mac App Store
- Zoom links → Zoom

OpenSesame is also smart enough to expand shortlinks before attempting to open an app.

## Planned integrations

- Apple News → Web Browser
- Discord → Discord.app
- Spotify → Spotify.app
- Twitter → Tweetbot.app & Twitterrific.app
- Slack → Slack.app

## Known Issues

- Clicking links in Twitter.app will sometimes present an error window before opening in your browser as expected.
- Links handled by the browser sometimes open in the background when they should open in the foreground.

## Development

Please reach out if you would like to contribute! I don't have as much time as I'd like to work on this, so progress is slow. I'd love any help others could provide.

### Resources

- https://developer.apple.com/documentation/safariservices/safari_web_extensions/creating_a_safari_web_extension
- [Workaround Big Sur bug for setting default browser](https://lapcatsoftware.com/articles/default-browser-bs.html)

### ToDo

- Planned integrations (above)
- Add Settings UI
	- Add configuration of default fallback browser
	- Add ability to open certain types of links in different browsers/apps (hostname and regex matching)
	- Use an `NSPredicateEditor` to build rules
	- Customize shortlink handler with custom hostnames
	- Set OpenSesame as default browser from Settings UI
- Perhaps utilize Tim Johnsen's [OpenerManifest](https://github.com/timonus/OpenerManifest/) to help determine link types
- Speed up shortlink resolution
- Determine foreground/background state through `NSEvent`s
- Safari Extension
	- Other browsers too? (if possible)
- Migrate to [Tuist](https://github.com/tuist/tuist)
- Get a better app icon

### Attribution

- Icon image is [Upload by ProSymbols from the Noun Project](https://thenounproject.com/search/?q=link+arrow&i=521959)
