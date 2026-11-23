const {runSwiftPMPlugin} = require('./dist/commonjs/extras/swiftpm');
module.exports = (context) => runSwiftPMPlugin(__dirname, context);
