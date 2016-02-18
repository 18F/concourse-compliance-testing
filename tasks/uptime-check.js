'use strict';

const fs = require('fs');
const url = require('url');
const http = require('http');
const https = require('https');

const content = fs.readFileSync('./projects-json/projects.json');
const json = JSON.parse(content);

const getUrl = (linkObj) => {
  if (typeof linkObj == 'string') {
    return linkObj;
  } else {
    return linkObj.url;
  }
};

const getReqModule = (protocol) => {
  if (protocol === 'https:') {
    return https;
  } else {
    return http;
  }
};

const headReq = (uri, callback) => {
  let opts = url.parse(uri);
  opts.method = 'HEAD';
  const req = getReqModule(opts.protocol).request(opts, (res) => {
    callback(null, res);
  }).on('error', callback);
  req.end();
};

const isSuccess = (res) => {
  return (res.statusCode >= 200 && res.statusCode < 300) || res.statusCode === 403;
};

const checkIfUp = (uri, callback) => {
  headReq(uri, (err, res) => {
    if (err) {
      callback(err)
    } else {
      callback(null, isSuccess(res))
    }
  });
};

json.results.forEach((project) => {
  if (project.links) {
    project.links.forEach((linkObj) => {
      const link = getUrl(linkObj);
      if (link) {
        checkIfUp(link, (err, isUp) => {
          if (err || !isUp) {
            console.error(`${link} is NOT up`);
          }
        });
      } else {
        console.error(`Malformed \`links\` for ${project.name}`);
      }
    });
  }
});
