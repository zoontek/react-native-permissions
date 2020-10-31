// Fetch list of Windows UWP App capabilites from the Microsoft docs
//
// The names of individual capabilites are in <strong> tag and follow cammelCase

const https = require('https');

https.get(
  'https://docs.microsoft.com/en-us/windows/uwp/packaging/app-capability-declarations',
  (res) => {
    res.setEncoding('utf8');
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    res.on('end', () => {
      parsePage(data);
    });
    res.on('error', (e) => {
      console.error(`Got error: ${e.message}`);
      process.exit(-1);
    });
  },
);

function parsePage(data) {
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
      if (char === char.toUpperCase()) constName += '_';
      constName += char.toUpperCase();
    }
    constName = constName.replace('WI_FI', 'WIFI');
    constName = constName.replace('VO_I_P', 'VOIP');
    results.push(`  ${constName}: 'windows.permission.${name}' as const,`);
  }
  const sorted = results.sort();
  for (const name of sorted) console.log(name);
}
