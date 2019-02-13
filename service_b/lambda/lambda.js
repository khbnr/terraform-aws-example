// dependencies
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

async function lambdaHandleEvent(event, context) {

  let key = event['Records'][0]['s3']['object']['key'];
  let bucketName = event['Records'][0]['s3']['bucket']['name'];

  if (!bucketName || !key) {
    console.log("Unable to retrieve bucket or key information from the event");
  }

  console.log("Incoming event from bucket " + bucketName +": File uploaded: " + key);
}

module.exports = {
  lambdaHandleEvent:  lambdaHandleEvent
};
