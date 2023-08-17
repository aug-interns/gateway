import ballerina/http;
import Api_Gateway.Types;
import ballerina/log;

configurable Types:ApiResources resourceUrls = ?;

service /api on new http:Listener(9091) {

    isolated resource function post support/[string... paths](http:Request req) returns http:Response|http:ClientError {
        return forwardRequest(resourceUrls.supportService, paths, req);
    }

    isolated resource function get address/[string... paths](http:Request req) returns http:Response|http:ClientError {
        return forwardRequest(resourceUrls.addressService, paths, req);
    }

    isolated resource function get identity/[string... paths](http:Request req) returns http:Response|http:ClientError {
        return forwardRequest(resourceUrls.identityService, paths, req);
    }

    isolated resource function get police/[string... paths](http:Request req) returns http:Response|http:ClientError {
        return forwardRequest(resourceUrls.policeService, paths, req);
    }
}

isolated function getResourcePath(string[] paths) returns string {
    return paths.reduce( isolated function (string path, string next) returns string => path + "/" + next, "");
}

isolated function forwardRequest(string resourceUrl, string[] paths, http:Request req) returns http:Response {
    log:printInfo(req.getHeaderNames().toJsonString());
    http:Response response = new();
    response.statusCode = 500;
    do {
	    http:Client resourceClient = check new(resourceUrl);
        http:Response|http:ClientError res = resourceClient->forward(getResourcePath(paths), req);
        if (res is http:ClientError) {
            log:printError(res.toString());
        } else {
            response = res;
        }
    } on fail var e {
        log:printError(string`-------------- Http Client ${resourceUrl} Error ------------`);
        log:printError(e.toString());
    }
    return response;
}
