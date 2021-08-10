import axios  from "axios";
import store  from "../store";
import router from "../router";

const instance = axios.create({
    baseURL: "/api/v1.0/"
});

instance.interceptors.response.use(
    response => {
        return response;
    },
    err => {
        console.log(err);
        return Promise.reject(err);
    }
);

export default instance;