// Copyright (c) 2016-present, CloudZero, Inc. All rights reserved.
// Licensed under the BSD-style license. See LICENSE file in the project root for full license information.

'use strict';

const createResponse = (statusCode, body) => {
  return {
    statusCode: statusCode,
    body: body
  }
};

exports.hello = (event, context, callback) => {
  console.log(`Hi There! ${JSON.stringify(event)}`);
  callback(null, createResponse(200, "Hello"));
};

