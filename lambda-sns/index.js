'use strict';


const AWS = require('aws-sdk');
const sns = new AWS.SNS();

const topicArn = process.env.TOPIC_ARN;

const createResponse = (statusCode, body) => {
  return {
    statusCode: statusCode,
    body: body
  }
};

exports.publish = (event, context, callback) => {

  let params = {
    Message: JSON.stringify(event.body),
    TopicArn: topicArn
  };

  let snsPublish = (params) => { return sns.publish(params).promise() } ;

  snsPublish(params).then( (data) => {
    console.log(`PUBLISH ITEM SUCCEEDED WITH data = ${data}`);
    callback(null, createResponse(200, null));
  }).catch( (err) => {
    console.log(`PUBLISH ITEM FAILED FOR WITH ERROR: ${err}`);
    callback(null, createResponse(500, err));
  });
};
