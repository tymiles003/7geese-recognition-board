({
    baseUrl: ".",
    name: "almond",
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
    },
    out: "require.js",
    include: [ "requireLib", "app/main" ],
    stubModules: ['cs', 'coffee-script', 'lessc', 'text', 'less']
})