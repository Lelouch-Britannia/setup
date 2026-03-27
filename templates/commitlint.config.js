// Custom rule: every non-empty body line must start with "- "
const bodyBulletLines = {
  'body-bullet-lines': ({ body }) => {
    if (!body) return [false, 'body must not be empty — add bullet points for each change'];
    const lines = body.split('\n').filter((l) => l.trim() !== '');
    const invalid = lines.filter((l) => !l.match(/^- .+/));
    return invalid.length === 0
      ? [true]
      : [false, `body lines must start with "- ": \n  ${invalid.join('\n  ')}`];
  },
};

module.exports = {
  parserPreset: {
    parserOpts: {
      // Regex to match "Type: Summary"
      headerPattern: /^(Feat|Fix|Chore|Refactor|Docs|Test|Update): (.+)$/,
      headerCorrespondence: ['type', 'subject'],
    },
  },
  plugins: [
    {
      rules: bodyBulletLines,
    },
  ],
  rules: {
    // 1. Required blank line before body
    'body-leading-blank': [2, 'always'],
    'footer-leading-blank': [0],

    // 2. Body must not be empty
    'body-empty': [2, 'never'],

    // 3. Each body line must be a "- " bullet (custom rule)
    'body-bullet-lines': [2, 'always'],

    // 4. Enforce your specific types
    'type-enum': [
      2,
      'always',
      ['Feat', 'Fix', 'Chore', 'Refactor', 'Docs', 'Test', 'Update'],
    ],

    // 5. Ensure type is not empty
    'type-empty': [2, 'never'],

    // 6. Ensure summary (subject) is not empty
    'subject-empty': [2, 'never'],
  },
};
