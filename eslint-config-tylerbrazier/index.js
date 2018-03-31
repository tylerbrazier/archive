module.exports = {
  // http://eslint.org/docs/rules/
  extends: 'eslint:recommended',
  rules: {
    'no-console': 'off',
    'no-unused-vars': [ 'error', { args:'none' } ], //allow unused fn args
    'radix': [ 'error', 'always' ],

    // style related stuff (warn)
    'indent': [ 'warn', 2 ],
    'max-len': [ 'warn', { code:80, ignoreUrls:true } ],
    'linebreak-style': [ 'warn', 'unix' ],
    'semi': [ 'warn', 'never' ],
    'comma-dangle': [ 'warn', 'always-multiline' ],
  },
};
