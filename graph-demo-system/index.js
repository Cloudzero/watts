'use strict';

const AWSXRay = require('aws-xray-sdk');
const rules = {
  "rules": [ { "description": "Graph Demo System.", "service_name": "*", "http_method": "*", "url_path": "/objects/*", "fixed_target": 0, "rate": 0.05 } ],
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

  let params = {
    Body: JSON.stringify(event.body),
    Bucket: bucketName,
    Key: `examplekey_${Math.round((new Date()).getTime() / 1000)}`,
  };

  let s3PutObject = (params) => { return s3.putObject(params).promise() } ;

  console.log(`Bad Log: ${foo}`)

  s3PutObject(params).then( (data) => {
    console.log(`PutObject SUCCEEDED with DATA = ${data}`);
    callback(null, createResponse(200, null));
  }).catch( (err) => {
    console.log(`PutObject FAILED witd ERROR: ${err}`);
    callback(null, createResponse(500, err));
  });
};


exports.getObjects = (event, context, callback) => {

  const maxKeys = (event.queryParameters ? event.queryParameters.n : 100) || 100

  const params = {
    Bucket: bucketName,
    MaxKeys: maxKeys
  };

  const s3ListObjects = (params) => { return s3.listObjects(params).promise() } ;

  console.log(`Bad Log: ${foo}`)

  s3ListObjects(params).then( (data) => {
    console.log(`ListObjects SUCCEEDED with DATA = ${data}`);
    callback(null, createResponse(200, JSON.stringify(data)));
  }).catch( (err) => {
    console.log(`ListOBjects FAILED with ERROR: ${err}`);
    callback(null, createResponse(500, err));
  });
};
