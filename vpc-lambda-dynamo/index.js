'use strict';


const AWS = require('aws-sdk');
const dynamo = new AWS.DynamoDB.DocumentClient();

const tableName = process.env.TABLE_NAME;

const createResponse = (statusCode, body) => {
  return {
    statusCode: statusCode,
    body: body
  }
};

exports.get = (event, context, callback) => {

  console.log(`EVENT: ${JSON.stringify(event)}`);
  let params = {
    TableName: tableName,
    Key: {
      id: event.body.id
    }
  };

  let dbGet = (params) => { return dynamo.get(params).promise() };

  dbGet(params).then( (data) => {
    if (!data.Item) {
      callback(null, createResponse(404, "ITEM NOT FOUND"));
      return;
    }
    console.log(`RETRIEVED ITEM SUCCESSFULLY WITH doc = ${JSON.stringify(data.Item.doc)}`);
    callback(null, createResponse(200, data.Item.doc));
  }).catch( (err) => {
    console.log(`GET ITEM FAILED FOR doc = ${params.Key.id}, WITH ERROR: ${err}`);
    callback(null, createResponse(500, err));
  });
};

exports.put = (event, context, callback) => {

  let item = {
    id: event.body.id,
    doc: event.body
  };

  let params = {
    TableName: tableName,
    Item: item
  };

  let dbPut = (params) => { return dynamo.put(params).promise() };

  dbPut(params).then( (data) => {
    console.log(`PUT ITEM SUCCEEDED WITH params = ${JSON.stringify(params)}`);
    callback(null, createResponse(200, null));
  }).catch( (err) => {
    console.log(`PUT ITEM FAILED FOR doc = ${JSON.stringify(params)}, WITH ERROR: ${err}`);
    callback(null, createResponse(500, err));
  });
};
