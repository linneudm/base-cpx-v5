UploadMethods = {

    Custom = {

        Video = {

            url = "https://your-custom-url.com/upload?api=API_KEY",

            field = "file",
            headers = {
                ["Authorization"] = "Key API_KEY"

            },

            error = {

                path = "success",
                value = false
            },

            success = {

                path = "url"
            },

            suffix = "webm",
        },

        Image = {

            url = "https://your-custom-url.com/upload?api=API_KEY",

            field = "file",
            headers = {
                ["Authorization"] = "Key API_KEY"

            },

            error = {

                path = "success",
                value = false
            },

            success = {

                path = "url"
            },

            suffix = "png",
        },

        Audio = {

            url = "https://your-custom-url.com/upload?api=API_KEY",

            field = "file",
            headers = {
                ["Authorization"] = "Key API_KEY"

            },

            error = {

                path = "success",
                value = false
            },

            success = {

                path = "url"
            },

            suffix = "mp3",
        },

    },

    Fivemanage = {

        Default = {

            url = "PRESIGNED_URL",

            field = "file",

            success = {

                path = "data.url"

            },

            sendPlayer = "metadata"

        },

    },

    LBUpload = {

        Default = {

            url = "https://BASE_URL/lb-upload/",

            field = "file",

            headers = {

                ["Authorization"] = "API_KEY"

            },

            error = {

                path = "success",

                value = false

            },

            success = {

                path = "link"

            },

            sendPlayer = "metadata"

        },

    },

    OldFivemanage = {

        Video = {

            url = "https://fmapi.net/api/v2/video",

            field = "file",

            headers = {

                ["Authorization"] = "API_KEY"

            },

            success = {

                path = "data.url"

            },

        },

        Image = {

            url = "https://fmapi.net/api/v2/image",

            field = "file",

            headers = {

                ["Authorization"] = "API_KEY"

            },

            success = {

                path = "data.url"

            }

        },

        Audio = {

            url = "https://fmapi.net/api/v2/audio",

            field = "file",

            headers = {

                ["Authorization"] = "API_KEY"

            },

            success = {

                path = "data.url"

            }

        },

    },

}
