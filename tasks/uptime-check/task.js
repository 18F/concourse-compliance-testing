// usage:
//
//   PROJECT_JSON=path/to/projects.json node tasks/uptime-check/task.js

'use strict';

const fs = require('fs');
const request = require('request');


const getProjectJson = () => {
  const jsonPath = process.env.PROJECT_JSON || './projects-json/projects.json';
  const content = fs.readFileSync(jsonPath);
  return JSON.parse(content);
};

const getUrl = (linkObj) => {
  if (typeof linkObj == 'string') {
    return linkObj;
  } else {
    return linkObj.url;
  }
};

const headReq = (uri, callback) => {
  request.head(uri, callback);
};

const isSuccess = (res) => {
  return res.statusCode >= 200 && res.statusCode < 300;
};

const isUp = (res) => {
  return !!res && (isSuccess(res) || res.statusCode === 403);
};

const checkIfUp = (uri, callback) => {
  headReq(uri, (err, res, body) => {
    callback(err, isUp(res));
  });
};

const checkLink = (link) => {
  checkIfUp(link, (err, isUp) => {
    if (err || !isUp) {
      console.error(`${link} is NOT up.`);
    }
  });
};

const checkLinkObj = (linkObj) => {
  const link = getUrl(linkObj);
  if (link) {
    checkLink(link);
  } else {
    console.error(`Malformed \`links\` for ${project.name}.`);
  }
};


const json = getProjectJson();
json.results.forEach((project) => {
  const links = project.links || [];
  if (links.length === 0) {
    console.error(`No \`links\` for ${project.name}.`);
  } else {
    links.forEach(checkLinkObj);
  }
});
