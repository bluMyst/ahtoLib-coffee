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
        imgur.upload url, ->
            console.log 'args:', arguments

    uploadAndRedditPost: (imageUrl, subreddit) ->
        callback = (result) ->
            window.open result.data.link
            window.open "https://www.reddit.com/r/" +
                "#{subreddit}/submit?url=#{info.data.link}"

    isAlreadyImgur: (imageUrl) ->
