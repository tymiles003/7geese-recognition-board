var fs = require('fs');
var globalLess = require('less');
var requireTemp = module.require;
eval(fs.readFileSync('./r.js', 'utf8'));