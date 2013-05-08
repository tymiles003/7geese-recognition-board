define [
    'text!templates/comments.html'
    'lessc!less/views/CommentsView.less'

    'cs!app/statics'

    'jquery'
    'backbone'
    'moment'
], ->
    Backbone = require 'backbone'
    $ = require 'jquery'
    moment = require 'moment'

    template = _.template require 'text!templates/comments.html'
    statics = require 'cs!app/statics'

    return class CommentsView extends Backbone.View
        initialize: ->
            @model.bind "change", @render
        render: =>
            data = @model.toJSON()
            data.replies ?= {totalItems: 0, items: []}
            comments = null

            if data.replies.items.length > statics.maxComments
                comments = data.replies.items.slice data.replies.items.length - statics.maxComments, data.replies.items.length
            else
                comments = data.replies.items

            if data.replies.items.length > 0
                @$el.html template
                    comments: comments
                    $: $
                    moment: moment
            else
                @$el.hide()
