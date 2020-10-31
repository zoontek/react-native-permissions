// Fetch list of Windows UWP App capabilites from the Microsoft docs
// The names of individual capabilites are in <strong> tag and follow camelCase

const https = require('https');
const {EOL} = require('os');

https.get(
  'https://docs.microsoft.com/en-us/windows/uwp/packaging/app-capability-declarations',
  (res) => {
    res.setEncoding('utf8');

    let data = '';

    res.on('error', ({message}) => {
      console.error(message);
      process.exit(-1);
    });

    res.on('data', (chunk) => {
      data += chunk;
    });

    res.on('end', () => parse(data));
  },
);

function parse(data) {
  const names = new Set();

  for (const match of data.match(/<strong>[a-z]+[a-zA-Z\.]*<\/strong>/gm)) {
    names.add(
      match.substr('<strong>'.length, match.length - '<strong>'.length - '</strong>'.length),
    );
  }

  const results = [];

  for (const name of names) {
    let constName = '';

    for (let i = 0; i < name.length; ++i) {
      const char = name.charAt(i);

      if (char === char.toUpperCase()) {
        constName += '_';
      }

      constName += char.toUpperCase();
    }

    constName = constName.replace('WI_FI', 'WIFI');
    constName = constName.replace('VO_I_P', 'VOIP');
    results.push(`${constName}: 'windows.permission.${name}',`);
  }

  console.log(results.sort().join(EOL));
}
