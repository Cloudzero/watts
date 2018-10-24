'use strict';

const AWS = require('aws-sdk');
const sqs = new AWS.SQS();

const queue = process.env.QUEUE;

const createResponse = (statusCode, body) => {
  return {
    statusCode: statusCode,
    body: body
  }
};

exports.hello = (event, context, callback) => {
  console.log('Hi from SNS: ', event);
  callback(null, createResponse(200, "Hello"));
};

exports.fillQueue = (event, context, callback) => {
  console.log('Filling Queue')
  const params = {
    MessageBody: "Message in a Bottle",
    QueueUrl: queue
  }
  sqs.sendMessage(params, function(err, data) {
    if (err) console.log(err, err.stack); // an error occurred
    else     console.log(data);           // successful response
  });
  callback(null, createResponse(200, "On it"));
}
