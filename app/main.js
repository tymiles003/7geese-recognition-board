requirejs.config({
    shim: {
        'app/lib/jquery/jquery.masonry.min.js': ['jquery'],
        'app/lib/jquery/jquery.transit.min.js': ['jquery'],
        'app/lib/jquery/jquery.serializeobject.js': ['jquery'],
        'app/lib/jquery/jquery.jsonp.js': ['jquery'],
        'app/lib/backbone-tastypie.js': ['backbone']
    },
    paths: {
        requireLib     : "require",
        jquery         : "app/lib/jquery",
        underscore     : "app/lib/underscore",
        backbone       : "app/lib/backbone",
        moment         : "app/lib/moment",

        cs             : "plugins/cs",
        "coffee-script": "plugins/cs/coffee-script",
        lessc          : "plugins/lessc",
        less           : "plugins/lessc/less",
        text           : "plugins/text"
    }
});

define(['cs!app/app'], function () {
    var app = require('cs!app/app');
    return {
        init: function () {
            app.init();
        }
    }
});
