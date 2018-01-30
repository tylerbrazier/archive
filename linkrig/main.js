(function() {
  const repo = 'tylerbrazier/bookmarks'

  if (isNode()) {
    // for testing
    exports.extractHtml = extractHtml
  } else {
    setupListeners()
    loadBookmarksFromGh(repo)
  }

  function setupListeners() {
    document.getElementById('save-token')
      .addEventListener('click', () => {
        const textfield = document.getElementById('gh-token')
        saveGhToken(textfield.value)
        textfield.value = ''
      })
  }

  function loadBookmarksFromGh(repo) {
    const url = `https://api.github.com/repos/${repo}/contents/bookmarks.html`
    const div = document.getElementById('bookmarks')
    const fetchOpts = {
      method: 'GET',
      headers: new Headers({
        'Accept': 'application/vnd.github.v3+json',
      }),
    }

    fetch(url, fetchOpts)
      .then(res => res.text())
      .then(extractHtml)
      .then(html => div.innerHTML = html)
      .then(html => Array.from(div.children[0].children).map(dtToJs))
      .then(results => {/* TODO make results searchable, etc */})
      .catch(error)
  }

  // extracts and decodes html from github's content api response
  // https://developer.github.com/v3/repos/contents/
  function extractHtml(response) {
    try {
      var json = JSON.parse(response)
    } catch(err) {
      throw new Error('Unable to parse response as json: ' + response)
    }
    if (!json.content)
      throw new Error('No content on json: ' + response)

    const decoded = atob(json.content)
    const match = /<dl>[\s\S]*<\/dl>/i.exec(decoded)
    if (!match)
      throw new Error('No <DL> tags in: ' + decoded)

    return match[0].replace(/(<\/?p>|\n)/ig, '')
  }

  // For a single bookmark, returns object like:
  // {
  //   href: ...,
  //   title: ...,
  //   add_date: ...,
  //   last_modified: ...,
  // }
  //
  // For a folder, returns an object like:
  // {
  //   title: ...,
  //   add_date: ...,
  //   folder: [
  //     ...
  //   ]
  // }
  function dtToJs(dt) {
    if (dt.tagName !== 'DT')
      throw new Error('Expected <DT> element but found: ' + dt)

    const child = dt.children[0]
    if (child.tagName === 'A') {
      return {
        title: child.textContent,
        href: child.getAttribute('href'),
        add_date: child.getAttribute('add_date'),
        last_modified: child.getAttribute('last_modified'),
      }
    } else if (child.tagName === 'H3') {
      const dl = dt.children[1]
      if (!dl || dl.tagName !== 'DL')
        throw new Error('No DL element following folder: ' + child.textContent)
      return {
        title: child.textContent,
        add_date: child.getAttribute('add_date'),
        folder: Array.from(dl.children).map(dtToJs),
      }
    } else {
      throw new Error('Invalid element following <DT>: ' + child.tagName)
    }
  }

  function saveGhToken(token) {
    if (!token)
      return alert('No token')
    localStorage.setItem('linkrig-gh-token', token)
  }

  function isNode() {
    return (typeof window === 'undefined' && module && exports)
  }

  function error(err) {
    console.error(err)
  }
})()
