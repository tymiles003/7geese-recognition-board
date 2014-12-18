define [
    'lessc!less/views/HeaderView.less'
    'text!templates/header.html'

    'underscore'
    'backbone'

    'cs!app/views/BoardView'
    'cs!app/views/LoginView'

    'app/lib/select2.min.js'

    'app/bin/settings'
], (template) ->

    _ = require 'underscore'
    Backbone = require 'backbone'
    template = _.template require 'text!templates/header.html'
    settings = require 'app/bin/settings'

    return class HeaderView extends Backbone.View
        className: "header-view"
        events:
            'change .js-department': 'onChangeDepartment'
            'click .settings-btn': 'toggleDepartmentForm'

        initialize: (options) =>
            @options = options
            @settingsBtnShown = false
            @departmentsShown = false
            @timeout = 3000
            @departments = []
            @getDepartments()
            $(document).mousemove(@onMouseMove)

        onMouseMove: =>
            @lastMoved = new Date().getTime()
            if not @settingsBtnShown
                @$('.settings-btn').show().css('display', 'inline-block')
                @settingsBtnShown = true
                setTimeout(@checkShouldHide, @timeout)

        checkShouldHide: =>
            if @departmentsShown
                return

            diff = new Date().getTime() - @lastMoved
            if diff > @timeout 
                @$('.settings-btn').hide()
                @$('.department-form').hide()
                @settingsBtnShown = false
                @departmentsShown = false
            else:
                setTimeout(@checkShouldHide, @timeout - diff)

        toggleDepartmentForm: =>
            @departmentsShown = not @departmentsShown
            @$('.department-form').toggle()
            @checkShouldHide()

        render: =>
            @$el.html template {}

            @$('.js-department').select2(
                multiple: false
                placeholder: 'Select a department...'
                escapeMarkup: (m) -> m
                # formatSearching: null
                width: 300
                query: (query) =>
                    if query.term.length == 0
                        all = id: 'all', text: "All Departments"
                        return query.callback(results: _.union([all], @departments))
                    results = _.filter(@departments, (d) ->
                        d.text.toLowerCase().indexOf(query.term.toLowerCase()) != -1
                    )
                    return query.callback(results: results)
            )

            @

        # @method searchDepartmentsApi
        getDepartments: =>
            headers = {}
            url = settings.hostname + "/api/v1/team/"
            if Backbone.Tastypie.apiKey and Backbone.Tastypie.apiKey.username.length and Backbone.Tastypie.apiKey.key.length
                creds = {username: Backbone.Tastypie.apiKey.username, api_key: Backbone.Tastypie.apiKey.key}
                url = "#{url}?#{$.param creds}"
            $.ajax(
                url: url
                headers: headers
                data:
                    limit: 5
                    activated: true
            ).done( (data) =>
                @departments = _.map(data.objects, (model) ->
                    id: model.resource_uri
                    text: model.name
                )

                current = _.find(data.objects, (model) => model.resource_uri == @options.currentDepartment)
                @setDepartment(current)
            )

        onChangeDepartment: =>
            @trigger('filter:department', @$('.js-department').select2('data').id)

        setDepartment: (department) =>
            if department
                @$('.department').html(department.name)
                @$('.js-department').select2('data',
                    id: department.resource_uri
                    text: department.name
                )
            else
                @$('.department').html(@options.network.name)