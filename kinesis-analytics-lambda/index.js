'use strict';
console.log('Loading function');

exports.kinesisHandler = (event, context, callback) => {
  event.Records.forEach((record) => {
    // Kinesis data is base64 encoded so decode here
    const payload = new Buffer(record.kinesis.data, 'base64').toString('ascii');
    console.log('decoded record:', payload);
  });
  callback(null, `Successfully processed ${event.Records.length} records.`);
};


exports.analyticsHandler = (event, context, callback) => {
  console.log(`event: ${JSON.stringify(event)}`);
  event.records.forEach((record) => {
    // Kinesis analytics data is base64 encoded so decode here
    const payload = new Buffer(record.data, 'base64').toString('ascii');
    console.log('decoded analytics record:', payload);
  });
  callback(null, `Successfully processed ${event.records.length} analytics records.`);
};
