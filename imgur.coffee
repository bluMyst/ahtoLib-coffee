# jQuery needed

imgur =
    upload: (url, callback) ->
        clientID     = '4f712105dfe6eb1'
        clientSecret = '1cfedcf19ba29f58b7d7d49a62dd1f8771eb3ded'

        $.ajax 'https://api.imgur.com/3/image',
            method: 'POST'

            headers:
                Authorization: "Client-ID #{clientID}"
                Accept: 'application/json'

            data:
                image: url
                type: 'URL'

            success: callback

    testUpload: (url) ->
        @upload url, ->
            console.log 'args:', arguments

    uploadAndRedditPost: (imageUrl, subreddit) ->
        handleImgurUrl = (imgurUrl) ->
            console.log 'got url', imgurUrl
            #window.open imgurUrl
            # Can only open one window at a time on Chrome unless it's an
            # extension.
            console.log 'opening', "https://www.reddit.com/r/" +
                "#{subreddit}/submit?url=#{imgurUrl}"

            window.open "https://www.reddit.com/r/" +
                "#{subreddit}/submit?url=#{imgurUrl}"

        if @isAlreadyImgur imageUrl
            handleImgurUrl imageUrl
        else
            @upload imageUrl, (result) ->
                console.log 'callback!', result
                handleImgurUrl result.data.link

    isAlreadyImgur: (imageUrl) ->
        return /^(https?:\/\/)?[^/]*imgur\.com/i.test imageUrl
