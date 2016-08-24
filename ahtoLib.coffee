# vim:foldmethod=marker

ahtoLib =
    findMatches: (selector, min=1, max=Infinity) -> # {{{1
        ###
        # Find a certain number of matches, but throw an error if it's outside
        # the expected number. Defaults to exactly 1 match.
        ###
        matches = $(selector)

        if min <= matches.length <= max
            return matches
        else
            throw "#{matches.length} matches (expected #{min}-#{max})
                found for selector: #{selector}"

    safeParseInt: (s) -> # {{{1
        ###
        # Instead of returning NaN on failure like parseInt does, this throws an
        # error.
        ###
        n = parseInt(s)

        # Because apparently NaN != NaN...
        if isNaN(s)
            throw new Error("Unable to parse int from '#{s}'")
        else
            return n

    safeInterval: (func, wait, times) -> # {{{1
        # Source: http://www.thecodeship.com/web-development/alternative-to-javascript-evil-setinterval/
        # Changed a bit from there.
        interv = ((w, t) ->
            return (->
                if not t? or t-- > 0
                    setTimeout(interv, w)
                    try
                        # This is sorta the same thing as func()
                        func.call(null)
                    catch e
                        t = 0
                        # TODO: Why e.toString? Why not e?
                        throw e.toString()
            )
        )(wait, times)

        setTimeout(interv, wait)

    stringHashCode: (s) -> # {{{1
        hash = 0

        for i in s
            chr   = i.charCodeAt(0)
            hash  = ((hash << 5) - hash) + chr
            hash |= 0; # Convert to 32bit integer

        return hash

    randInt: (min, max) -> # {{{1
        ###
        # Generate a random integer between min and max.
        ###
        min + Math.floor(Math.random() * (max+1-min))

    numberWithCommas: (n) -> # {{{1
        return n.toString().replace(
            ///
                \B
                (?=
                    (\d{3})+
                    (?!\d)
                )
            ///g,
            ",",
        )


    exit: -> # {{{1
        # This is a very ugly hack.
        throw new Error 'Not an error just exiting early'

    setTimeout_: (wait, f) -> # {{{1
        ###
        # Because it makes more sense to have:
        #
        # setTimeout 200, ->
        #     # code
        #
        # Than:
        #
        # setTimeout((->
        #     # code
        # ), 200)
        #
        # (if you're using Javascript instead of Coffeescript, this might not
        # make sense to you. Sorry!)
        ###
        return setTimeout(f, wait)

    setInterval_: (wait, f) -> # {{{1
        ###
        # See setTimeout_ above.
        ###
        return setInterval(f, wait)

    injectScript: (f) -> # {{{1
        ###
        # Injects a script to run in the window's namespace.
        ###

        if typeof f == 'function'
            # Surround the function in parentheses and call it with no arguments.
            # Otherwise it'll just sit there, like this:
            # (foo) -> foo(13)
            # Instead of this:
            # ( (foo) -> foo(13) )()
            source = "(#{f})();"

        script = $("""
            <script type='application/javascript'>
                #{source}
            </script>
        """)

        # append script and immediately remove it to clean up
        $(document).append script
        script.remove()

    urlMatches: (regexp) -> # {{{1
        ###
        # Find out if the current URL of the page matches a given regex.
        ###
        return regexp.test window.location.href

    capitalizeWord: (word) -> # {{{1
        ###
        # "asdf" -> "Asdf"
        ###
        return word[0].toUpperCase() + word[1..]

    bookCase: (name) -> # {{{1
        ###
        # Changes a string like "the cat is on the table" to
        # "The Cat is on the Table"
        ###

        wordsToNotCapitalize = [
            'of', 'in', 'on', 'and', 'the', 'an', 'a', 'with', 'to', 'for', 'from',
            'be', 'is'
        ]

        name = name.split ' '

        for i, word of name
            if i == 0
                # Always capitalize the first word.
                name[i] = capitalizeWord word
            else if word not in wordsToNotCapitalize
                name[i] = capitalizeWord name[i]

        name = name.join ' '
        return name

    choice: (arr) -> # {{{1
        # Returns an element from an array at random.
        arr[Math.floor(Math.random() * arr.length)]

    choose: ahtoLib.choose

    lstrip: (s) -> # {{{1
        ###
        # >>> ahtoLib.lstrip """
        # ...    asdf
        # ...        asdf
        # ...    asdf
        # ... """
        # 'asdfasdfasdf'
        ###

    stringVariations: (s, multiline=false) -> # {{{1
        ###
        # Creates variations on a string.
        # 'foo (bar|baz) (qux|quux)'
        #       \/
        # ['foo bar qux',
        #  'foo baz qux',
        #  'foo bar quux',
        #  'foo baz quux']
        ###

        if multiline then s = ahtoLib.lstrip s

        # 'foo (bar|baz) (qux|quux)'
        #            \/
        # ['foo ', ['bar', 'baz'], ['qux', 'quux']]
        parsedString = s.split /[()]/
        parsedString = (for i in parsedString
                i = i.split '|'

                if i.length == 1
                    i[0]
                else i)

        results = []
        for v in parsedString
            console.log v, typeof v
            if results.length == 0
                if typeof v == 'string'
                    results.push v
                else if typeof v[0] == 'string'
                    results.push w for w in v
            else
                if typeof v == 'string'
                    results = (i+v for i in results)
                    console.log results
                else if typeof v[0] == 'string'
                    oldResults = results
                    results = []

                    for option in v
                        for oldResult in oldResults
                            results.push oldResult + option

                    console.log results
                else
                    throw "stringVariations: fail on #{v}"

        return results

    stringVariation: (s, multiline=false) -> # {{{1
        ahtoLib.choice(
            stringVariations(s, multiline))
