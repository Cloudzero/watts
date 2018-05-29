'use strict';


const AWS = require('aws-sdk');
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
    Body: "data",
    Bucket: bucketName,
    Key: event.body.key,
  };

  let s3PutObject = (params) => { return s3.putObject(params).promise() } ;

  s3PutObject(params).then( (data) => {
    console.log(`PUBLISH ITEM SUCCEEDED WITH data = ${JSON.stringify(data)}`);
    callback(null, createResponse(200, null));
  }).catch( (err) => {
    console.log(`PUBLISH ITEM FAILED FOR WITH ERROR: ${err}`);
    callback(null, createResponse(500, err));
  });
};
