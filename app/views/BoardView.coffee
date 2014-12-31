define [
    'backbone'
    'jquery'

    'lessc!less/views/BoardView.less'

    'app/lib/jquery/jquery.masonry.min.js'
    'cs!app/views/RecognitionView'
    'cs!app/collections/RecognitionsCollection'

    'text!templates/loading.html'
], ->
    Backbone = require 'backbone'
    $ = require 'jquery'

    RecognitionView = require 'cs!app/views/RecognitionView'
    RecognitionsCollection = require 'cs!app/collections/RecognitionsCollection'

    template = _.template require 'text!templates/loading.html'

    return class BoardView extends Backbone.View
        className: 'board-view'
        _lastWidth: null

        initialize: (options) ->
            $window = $ window
            @loaded = false
            @render()
            @recognitionsCollection = new RecognitionsCollection
            @recognitionsCollection.fetch 
                data: options.filters
                success: =>
                    @loaded = true
                    @render()
                    @recognitionsCollection.bind "add", @_prependNewRecognition

                    $(window).resize =>
                        @_handleAppWidthChange()
                        @centerBoard()
                        @_lastWidth = $window.width()

                    @timer = setInterval =>
                        @updateBoard()
                    , 30000

            _lastWidth = $window.width()

            
        _handleAppWidthChange: ->
            $window = $ window
            if @_lastWidth > 1094 and $window.width() <= 1094 or
            @_lastWidth <= 1094 and $window.width() > 1094
                @$el.masonry 'reload'

        centerBoard: ->
            $window = $ window

            recognitionViewWidth = @$el.find(".recognition-view").width()
            windowWidth          = $window.width()
            recognitionListWidth = ((windowWidth / (recognitionViewWidth + 10))|0) * recognitionViewWidth

            @$el.css "width": recognitionListWidth

            

        updateBoard: =>
            newRecognitions = new RecognitionsCollection
            successCallback = (collection, response) =>
                @recognitionsCollection.meta.offset = collection.meta.offset
                collection.each (model) =>
                    existingModel = @recognitionsCollection.get model.get("id")
                    if existingModel?
                        existingModel.set model.toJSON()
                    else
                        @recognitionsCollection.unshift model

                if collection.length
                    @$el.masonry 'reload'
            newRecognitions.fetch
                success: successCallback
                data:
                    poll: true
                    offset: @recognitionsCollection.meta.offset
        
        render: =>
            if not @loaded
                @$el.html template {}
            else
                @$el.html('')
                $ =>
                    @$el.css
                        opacity: 0
                        scale: 0.925

                    @recognitionsCollection.forEach (model) =>
                        @_addRecognition model

                    @$el.masonry
                        itemSelector: '.recognition-view'

                    @$el.transition
                        opacity: 1
                        scale: 1
                    , 500
                    , =>
                        @$el.find('.recognition-view').addClass('animate');

                @centerBoard()

        _prependNewRecognition: (model) =>
            @_addRecognition model, true
            @$el.masonry 'reload'

        _addRecognition: (model, prepend=false) =>
            recognitionView = new RecognitionView
                model: model

            recognitionView.render()
            if prepend then @$el.prepend(recognitionView.el) else @$el.append(recognitionView.el)
            recognitionView.$el.addClass 'animate'

        onClose: =>
            $(window).off('resize')
            clearInterval(@timer?)