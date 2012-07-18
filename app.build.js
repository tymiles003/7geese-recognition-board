({
    baseUrl: ".",
    name: "almond",
    paths: {
        requireLib: "require"
    },
    out: "require.js",
    include: [ "requireLib", "app/main" ],
    stubModules: ['cs', 'coffee-script', 'lessc', 'text', 'less']
})