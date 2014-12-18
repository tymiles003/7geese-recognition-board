define [
    'underscore'
    'backbone'

    'cs!app/wrappers/Remote'
    'app/lib/backbone-tastypie'

    'cs!app/views/BoardView'
    'cs!app/views/LoginView'
    'cs!app/views/HeaderView'

], (template) ->

    _ = require 'underscore'
    Backbone = require 'backbone'

    BoardView = require 'cs!app/views/BoardView'
    LoginView = require 'cs!app/views/LoginView'
    HeaderView = require 'cs!app/views/HeaderView'

    Remote = require 'cs!app/wrappers/Remote'

    return class MainView extends Backbone.View
        remote: new Remote
        validFilterParams: ['team', 'user', 'badge', 'recipient', 'from', 'to']
        initialize: ->
            Q = @_parseGetParams()
            @secondaryView = null
            if 'username' not of Q or 'api_key' not of Q
                username = ""
                api_key = ""
            else
                username = Q.username
                api_key = Q.api_key

            promise = @remote.checkAuth username, api_key

            promise.done (data) =>
                @network = data.objects[0]
                Backbone.Tastypie.apiKey.username = username
                Backbone.Tastypie.apiKey.key = api_key
                @renderRecognitionBoard()

            .fail =>
                # In the future, we might want to implement an auto-login system.
                @currentView = new LoginView
                @currentView.render()
                @render()
                @currentView.on 'loginAccepted', @logInAccepted
            
            return

        getFilters: =>
            queryParams = @_parseGetParams()
            filterParams = {}
            for param in @validFilterParams
                filterParams[param] = queryParams[param] if param of queryParams

            filterParams

        render: ->
            ###
            This will render the MainView.
            ###
            @$el.html ''          
            @$el.append @secondaryView.render().el if @secondaryView?
            @$el.append @currentView.el if @currentView?
            

        _parseGetParams: ->
            query = {}
            search = location.search.substring(1).split("&")
            i = search.length;
            while (i--)
                pair = search[i].split '='
                query[pair[0]] = decodeURIComponent(pair[1])
            query

        logInAccepted: (data) =>
            ###
            Event handler for when the user logged in.

            @param object data: is a list of all recognitions that was given
                when the server successfully authenticated.
            ###

            @currentView.transitionOut =>
                Backbone.Tastypie.apiKey.username = data.username
                Backbone.Tastypie.apiKey.key = data.api_key
                @renderRecognitionBoard()
                

            return

        renderRecognitionBoard: (filters=null)=>
            if not filters?
                filters = @getFilters()
            @currentView?.onClose()
            @currentView?.remove()
            @currentView = new BoardView filters: filters
            @secondaryView?.remove()
            @secondaryView = new HeaderView currentDepartment: filters?.team, network: @network
            @.listenTo(@secondaryView, 'filter:department', @updateDepartmentFilter)
            @render()

        updateDepartmentFilter: (departmentId) =>
            # update url
            originalUrl = window.location.href
            newUrl = originalUrl
            if departmentId == 'all'
                newUrl = originalUrl.replace(/\&?team\=\/api\/v1\/team\/\d+\//, '')
            else
                if originalUrl.indexOf('team=') != -1
                    newUrl = originalUrl.replace(/(\&?)team\=\/api\/v1\/team\/\d+\//, "$1team=#{departmentId}")
                else if originalUrl.indexOf('?')
                    newUrl = originalUrl + "&team=#{departmentId}"
                else
                    newUrl = originalUrl + "?team=#{departmentId}"

            if history?.pushState?
                history?.pushState(null, null, newUrl)
            else
                window.location = newUrl

            # update the board
            @renderRecognitionBoard(if departmentId != 'all' then @getFilters() else team: '')


