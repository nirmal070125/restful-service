package guide.restful_service;

import ballerina.test;
import ballerina.net.http;
import ballerina.io;

string orderMgtServiceUrl;

http:HttpClient orderMgtServiceClient;

@test:beforeSuite {}
function init() {
    orderMgtServiceUrl = test:startService("OrderMgtService");
    orderMgtServiceClient = create http:HttpClient(orderMgtServiceUrl, {});
}

function addOrderDataProvider () (json[][]) {
    json[][] data = [[{"Order":{"ID":"100500", "Name":"XYZ", "Description":"Sample order."}}, {"status":"Order Created.",
                                                                                                  "orderId":"100500"}],
                     [{"Order":{"ID":"100600", "Name":"ABC", "Description":"Sample order."}}, {"status":"Order Created.",
                                                                                                  "orderId":"100600"}],
                     [{"Order":{"ID":"100500", "Name":"XYZ", "Description":"Sample order."}}, {"status":"Order Created.",
                                                                                                  "orderId":"100500"}]
                    ];
    return data;
}

@test:config{dataProvider:"addOrderDataProvider"}
function testAddOrder (json request, json response) {
    endpoint<http:HttpClient> httpEndpoint {
        orderMgtServiceClient;
    }

    http:OutRequest req = {};
    req.setJsonPayload(request);
    http:InResponse resp = {};
    resp, _ = httpEndpoint.post("/order", req);
    // status code assertion
    test:assertEquals(201, resp.statusCode, "incorrect status code");
    // http header assertion
    test:assertTrue(resp.getHeader("Location") != null, "http Location header is missing");
    var jsonRes, _ = resp.getJsonPayload();
    io:println(jsonRes);
    // response payload assertion
    test:assertEquals(jsonRes, response, "incorrect response payload");
}