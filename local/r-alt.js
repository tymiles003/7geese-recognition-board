var fs = require('fs');
var path = require('path');
var globalLess = require('less');
var requireTemp = module.require;
eval(fs.readFileSync("./local/r.js", 'utf8'));