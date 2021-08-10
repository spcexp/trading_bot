const API_SERVER         = process.env.VUE_APP_API_SERVER;
const WebpackShellPlugin = require("webpack-shell-plugin");

module.exports = {
    productionSourceMap: false,
    css:                 {
        loaderOptions: {
            sass: {
                additionalData: `@import "@/assets/scss/style.scss";`
            }
        }
    },
    devServer:           {
        proxy: {
            "^/api/v1.0": {
                target: API_SERVER
            },
        },
    },
    configureWebpack:    {
        plugins: [
            new WebpackShellPlugin({
                onBuildStart: ["echo Copy"],
                onBuildEnd:   [(process.env.VUE_APP_ENVIRONMENT === "staging") ? "cp ../staging/index.html ../templates/staging.html" : "cp ../static/index.html ../templates/index.html"]
            })
        ]
    }
};
