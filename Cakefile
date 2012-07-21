child_process = require 'child_process'
async         = require 'async'
findit        = require 'findit'
fs            = require 'fs'
path          = require 'path'
mkdirp        = require 'mkdirp'
watch         = require 'watch'
beautify      = require './cake-modules/beautify.js'
uglify        = require 'uglify-js'

outputStdout = (data) ->
    console.log data.toString('utf8').trim()

spawnChild = (command, args) ->
    process = child_process.spawn command, args

    process.stdout.on 'data', outputStdout
    process.stderr.on 'data', outputStdout

    return process

cleanCompiledLess = (cb) ->
    rm = spawnChild 'rm', ['-rf', 'less/.compiled']
    rm.on 'exit', ->
        if cb?
            cb()

buildLessFiles = (callback) ->

    lessPending = 0
    doneReading = false

    lessDone = ->
        lessPending--
        if doneReading and not lessPending and callback?
            callback()

    startLessc = (dir, file, outputFile) ->
        lessPending++
        mkdirp dir, '0777', ->
            lessc = spawnChild 'lessc', [ file, outputFile ]
            lessc.on 'exit', ->
                lessDone()

    cleanCompiledLess ->
        mkdirp "#{__dirname}/less/.compiled", "0777", (err, made) ->
            unless fs.readdirSync("#{__dirname}/less/").length > 1
                lessPending++
                doneReading = true
                lessDone()
                return

            if err?
                throw err

            finder = findit.find "#{__dirname}/less"

            finder.on 'file', (file, stat) ->
                relativeFilename = file.substr "#{__dirname}/less/".length
                outputFilename = "#{__dirname}/less/.compiled/#{relativeFilename}"
                outputDir = outputFilename.substr 0, outputFilename.lastIndexOf '/'
                isLess = path.extname(file) is '.less'

                if isLess
                    startLessc outputDir, file, outputFilename

            finder.on 'end', ->
                doneReading = true

cleanBuild = (cb) ->
    async.waterfall [
        (callback) ->
            make = spawnChild 'make', ['clean']
            make.on 'exit', ->
                callback null

        (callback) ->
            cleanCompiledLess ->
                if cb?
                    cb()
    ]

buildStaticLess = (cb) ->
    mkdirp "#{__dirname}/bin/css", "0777", (err, made) ->
        lessc = spawnChild 'lessc', [ "#{__dirname}/less/static/style.less", "#{__dirname}/bin/css/style.css", '--yui-compress' ]

        lessc.on 'exit', ->
            console.log "Less files built."
            if cb?
                cb()

        return lessc

watchLess = ->
    buildStaticLess ->
        createMonitor = (dir) ->
            watch.createMonitor dir, (monitor) ->
                monitor.on "created", ->
                    buildStaticLess()

                monitor.on "changed", (f, curr, prev) ->
                    unless curr.mtime.getTime() == prev.mtime.getTime()
                        buildStaticLess()

                monitor.on "removed", ->
                    buildStaticLess()

        createMonitor "#{__dirname}/less/static"
        createMonitor "#{__dirname}/less/lib"

writeProductionSettings = (cb) ->
    settingsjsDir = "#{__dirname}/app/bin"

    mkdirp settingsjsDir, "0777", (err, made) ->
        productionSettingsFilename = "#{__dirname}/settings/production.json"

        productionSettings = JSON.parse fs.readFileSync productionSettingsFilename, 'utf8'

        outputJs = "define([], function () { return #{JSON.stringify productionSettings}; });"

        fs.writeFileSync "#{settingsjsDir}/settings.js", outputJs, "utf8"

        cb()

doBuild = (cb) ->
    async.waterfall [
        (callback) ->
            cleanBuild ->
                callback null

        (callback) ->
            buildLessFiles ->
                callback null

        (callback) ->
            buildStaticLess ->
                callback null

        (callback) ->
            writeProductionSettings ->
                callback null

        (callback) ->
            cp = child_process.spawn 'cp', [ 'local/require.js', 'require.js' ]
            cp.on 'exit', ->
                callback null
                
        (callback) ->
            rjs = spawnChild 'node', [ 
                'local/r-alt.js'
                '-o'

                "app.build.js"
            ]

            rjs.on 'exit', ->
                callback null

        (callback) ->
            if cb?
                cb()
    ]

writeDevelopmentSettings = (cb) ->
    settingsjsDir = "#{__dirname}/app/bin"

    mkdirp settingsjsDir, "0777", (err, made) ->

        productionSettingsFilename  = "#{__dirname}/settings/production.json"
        developmentSettingsfilename = "#{__dirname}/settings/development.json"
        localSettingsFilename       = "#{__dirname}/local_settings.json"

        productionSettings = JSON.parse fs.readFileSync productionSettingsFilename, 'utf8'
        developmentSettings = JSON.parse fs.readFileSync developmentSettingsfilename, 'utf8'

        # Override all settings from production, since we will not need them
        # during development.
        for k, v of developmentSettings
            productionSettings[k] = v

        # Check if the local setting file exists.
        fs.lstat localSettingsFilename, (err, stats) ->
            if not err and stats.isFile()
                localSettings = JSON.parse fs.readFileSync localSettingsFilename, 'utf8'

                # And if so, override settings outlined in local
                # settings.
                for k, v of localSettings
                    productionSettings[k] = v

            outputJs = "define([],function (){return #{JSON.stringify productionSettings};});"
            outputJs = beautify.js_beautify outputJs

            fs.writeFileSync "#{settingsjsDir}/settings.js", outputJs, 'utf8'
            cb()

runDevelopment = ->
    callbacks = []

    fs.readFile "#{__dirname}/local_settings.json", 'utf8', (err, localSettings) ->
        unless err?
            localSettings = JSON.parse localSettings
        else
            localSettings = {}

        unless localSettings.no_fake_server
            sampleServer = spawnChild "coffee", ["#{__dirname}/sample-server/server.coffee"]

        simpleServer = spawnChild 'simple-server'

task 'build-run', 'Build all script files, compile the static LESS, and run the server.', ->
    doBuild ->
        simpleServer = spawnChild 'simple-server'

task 'dist', 'Prepare the project for distribution.', ->
    doBuild ->
        make = spawnChild 'make', ['dist']

task 'uglify', 'Take all files inside the .js directory and minify them.', ->
    parser    = uglify.parser
    processor = uglify.uglify

    finder    = findit.find "#{__dirname}/js"

    finder.on 'file', (file, stat) ->
        distPath  = "#{path.dirname path.dirname file}/dist/js/#{path.basename file}"
        
        js        = fs.readFileSync file, 'utf8'
        ast       = parser.parse js
        ast       = processor.ast_mangle ast
        ast       = processor.ast_squeeze ast
        finalCode = processor.gen_code ast

        fs.writeFileSync distPath, finalCode, 'utf8'

task 'clean', 'Clear out all the unnecessary stuff.', ->
    cleanBuild()

task 'clean:all', 'Clear out all the unnecessary stuff, inscluding the node_modules folder.', ->
    async.waterfall [
        (callback) ->
            cleanBuild ->
                callback()

        (callback) ->
            rm = spawnChild 'rm', ['-rf', 'node_modules']
            rm.on 'exit', ->
    ]

task 'run', 'Run a server.', ->
    async.waterfall [
        (callback) ->
            writeDevelopmentSettings ->
                callback null

        (callback) ->
            rm = child_process.spawn 'rm', [ '-f', './require.js' ]
            rm.on 'exit', ->
                callback null

        (callback) ->
            cp = child_process.spawn 'cp', [ './local/require.js', './require.js' ]
            cp.on 'exit', ->
                callback null

        (callback) ->
            watchLess()
            runDevelopment()
    ]
