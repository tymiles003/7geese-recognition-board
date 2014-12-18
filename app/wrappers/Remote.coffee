define [
    'app/bin/settings'
    'app/lib/jquery/jquery.jsonp.js'
], ->
    settings = require 'app/bin/settings'

    return class Remote
        checkAuth: (username, apiToken) ->
            creds = {}
            query = "#{settings.hostname}/api/v1/networks/?callback=callback&limit=1"
            if username.length and apiToken.length
                creds.username = username
                creds.api_key = apiToken
                query = query + "&#{$.param creds}"
            return $.jsonp {url: query, dataType: 'jsonp', callback: 'callback'}         
        getJSON: (username, apiToken) ->
            query = "#{settings.hostname}/api/v1/feeds/recognition/?username=#{username}&api_key=#{apiToken}&format=jsonp&callback=?"

            return $.getJSON query
