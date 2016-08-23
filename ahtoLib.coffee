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

    xeger: (s) -> # {{{1
        ###
        # Okay so this is supposed to be a 'backwards regex'. Given a regex, it
        # will supposedly give you an array of all possible matches to that
        # regex. (obviously it would throw an error on '+', '*', etc.) But so
        # far it doesn't support many features at all. I'm adding features as
        # I need them. Here's a list of everything that works right now:
        #
        # - nothing
        ###

        throw 'Not working yet! Sorry!'

        # NOTE:
        # 'a (b|(c|d))' -> ['a ', ['b', ['c', 'd']]]
        # Might be easier to process from there.

        getClosingParenIndex = (s) -> # {{{2
            ###
            # Give it a string starting with '(' and it'll find the index of
            # the matching ')'. Returns -1 on failure.
            ###
            parenDepth = 0

            for i, char of s
                if s[i-1] == '\\' then continue

                if char == '('
                    parenDepth++
                else if char == ')'
                    parenDepth--

                    if parenDepth == 0
                        return i

            return -1

        splitByParens = (s) -> # {{{2
            ###
            # 'a (b|(c|d))' -> ['a ', ['b|', ['c|d']]]
            # NOT WORKING YET
            ###
            parsedString = []

            # This will get whittled down as we remove stuff.
            stringLeft = s

            while stringLeft.length > 0
                if (ref = stringLeft.indexOf '(') != -1
                    if stringLeft[ref-1] == '\\'
                        parsedString.push stringLeft[..ref-1]
                        stringLeft = stringLeft[ref..]
                        continue

                    parenIndicies = [ref, getClosingParenIndex s[i..]]

                    # Intentionally skip over the outermost '(' and ')' (the ones we
                    # just found)
                    substring = s[parenIndicies[0]+1 .. parenIndicies[1]-1]

                    # Intentionally skip over the '('
                    parsedString.push s[.. parenIndicies[0]-1]
                    stringLeft = stringLeft[parenIndicies[1]+1 ..]
