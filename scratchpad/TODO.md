TODO
----
- Use the controller pattern on the settings page
- Show current rate limit data and link to more info:
  https://developer.github.com/v3/#rate-limiting
- Better error handling; no alerts; show json responses from github's api
- Links to the files page should use `raw_url` of the gist response instead of
  querying the whole gist for a single file; need to incorporate that into
  `location.hash` on the file page.
