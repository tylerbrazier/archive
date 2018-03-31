# eslint-config-tylerbrazier

**Deprecated. Will probably use [StandardJS](https://standardjs.com/) instead**

<http://eslint.org/docs/developer-guide/shareable-configs>

### Usage

#### For a project:

    npm install --save-dev eslint eslint-config-tylerbrazier

Add a `.eslintrc.js`:

    module.exports = {
      env: {
        node: true, // or browser:true for client side js
        es6: true,
      },
      extends: 'tylerbrazier',
    };

Put a separate `.eslintrc.js` with `env: { browser:true, ... }` in the root
of the client side code.

In `package.json`:

    "scripts": {
      "lint": "eslint"
    }

Then to lint a file or whole directory:

    npm run lint <file or dir>

#### Or for one-off usage:

    npm install -g eslint eslint-config-tylerbrazier
    eslint -c tylerbrazier --env node,es6 <file>

### Rules
No semicolons because

- You can code faster without the extra boilerplate
- Take advantage of the ASI feature. It's there so why not use it?
- `no-unreachable` and `no-unexpected-multiline` protect you from the edge cases
  (those rules are already enabled by `eslint:recommended`)
- <http://blog.izs.me/post/2353458699/an-open-letter-to-javascript-leaders-regarding>
