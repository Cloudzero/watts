'use strict';

const AWSXRay = require('aws-xray-sdk');
const rules = {
  "rules": [ { "description": "Player moves.", "service_name": "*", "http_method": "*", "url_path": "/api/move/*", "fixed_target": 0, "rate": 0.05 } ],
  "default": { "fixed_target": 1, "rate": 0.1 },
  "version": 1
}
AWSXRay.middleware.setSamplingRules(rules);
const AWS = AWSXRay.captureAWS(require('aws-sdk'));
const s3 = new AWS.S3();

const bucketName = process.env.BUCKET_NAME;

const createResponse = (statusCode, body) => {
  return {
    statusCode: statusCode,
    body: body
  }
};

exports.putObject = (event, context, callback) => {

  console.log(`event: ${JSON.stringify(event)}`);
  let params = {
    Body: JSON.stringify(event.body),
    Bucket: bucketName,
    Key: "exampleobject",
  };

  let s3PutObject = (params) => { return s3.putObject(params).promise() } ;

  s3PutObject(params).then( (data) => {
    console.log(`PUBLISH ITEM SUCCEEDED WITH data = ${data}`);
    callback(null, createResponse(200, null));
  }).catch( (err) => {
    console.log(`PUBLISH ITEM FAILED FOR WITH ERROR: ${err}`);
    callback(null, createResponse(500, err));
  });
};
