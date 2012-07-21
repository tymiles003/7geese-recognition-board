# Getting Started

This relies heavily on Node.js.

You'd also need a few packages installed before you continue.
    
    # Note: may require root access.
    $ npm install -g coffee-script
    $ npm install -g less
    $ npm install -g simple-server

And then, there are some local dependencies required as well. Just use `npm` for that.

    $ npm install

Done.

## Development

Since a lot of the source code uses preprocessors, then it will also require automatically updating them when changs are made. Don't worry, only one command will solve all your problem.

    $ cake run

When you call that command, look closely at the output window, since it will be there that you will have to get the username and API Token in order to authenticate to the fake server that fires up.

### How This All Work

All the logic code for the recognition board is written in CoffeeScript. We also rely heavily on third party libraries, such as jQuery, Backbone.js, Underscore.js, and Moment.js, which are written in JavaScript. But other than those, everything else is written in CoffeeScript.

We use a dependency manager to save us from a lot of headache when managing all the `.coffee` files and third-party JavaScript libraries. More specifically, we use RequireJS, since it allows us to write modular code, instead of injecting dependencies onto the global namespace (a big no no).

The styles for the code is written in LESS.

Another interesting thing about this project is that we ensured *everything* is modular, even the templates and styles.

How?

RequireJS supports plugins that let you load more than just JavaScript, but as well as anything stored in plain text, such as HTML templates, styles, etc. (This is how we managed to write code in CoffeeScript.)

#### Loading Modules

Grabbing a module for you to use in your code is pretty simple. Here's how you would do so in CoffeeScript:

    define [
        'path/to/js/code/foo'
    ], ->
        foo = require 'foo'

Boom, you've loaded up a module `foo` written in JavaScript. As you notice, we leave off the `.js` extension, since it's strongly discouraged.

But what about CoffeeScript?

Same thing. Except, that you'd need a plugin. Fortunately, since our project uses CoffeeScript a lot, the plugin is already there for you.

Anyways, this is how it looks like to load something up with plugins:

    define [
        'cs!path/to/coffee/code/bar'
    ], ->
        bar = require 'bar'

Now, you've loaded up a module `bar` that's written in CoffeeScript. However, you've also loaded up another module as well. Can you guess what?

It's the plugin called `cs`. Yep, that counts as a module, even if it is used as a plugin. As a corollary, you can treat any module as a plugin.

OK, some more examples with plugins, but this time, with LESS.

    define [
        'lessc!path/to/less/code/style.less'
    ], ->
        # No need to use `require` here.

And the style will be loaded up and compiled. Pretty neat, non?

Same thing for templates--which I'm sure you'd use a lot for Backbone views.

    define [
        'text!path/to/template/code/view.html'
    ], ->
        template = require 'text!path/to/template/code/view.html'

### Testing on Another Server

Of course, would also want to test against on another server, such as the main remote one. In this case, you can set up a `local_settings.json` file. It has the properties outlined in the sample JSON data, below.

    {
        "hostname": "http://7geese.com",
        "no_fake_server": true
    }

Just a quick note: when setting the `hostname` property, be sure to leave off the trailing forward slash (`/`), just like in the example.

And also, the `no_fake_server` property is optional, but it's just something that prevents the fake server to start up when the property is set to `true`.

## Deploying

Since this entire system is static, you don't need any special servers. However, you will still have to do some trickery before sending it off to the end-user. But it's nothing too complex. It's just a single command and you should be ready to go.

And here's that magical command.

    $ cake dist

Boom. The compiled version should be ready for you in the `dist` folder.

### But What About Viewing the Built Version Without Even Opening the Dist Folder?

Don't worry, there is a command for that as well. And here it is.

    $ cake build-run

And you should be able to view the compiled version without having to open the index.html file in the compiled version.

Just be sure to call `cake run`, when you want to go back to developping.

## TODO

* Document the source code.