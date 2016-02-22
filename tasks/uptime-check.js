// usage:
//
//   PROJECT_JSON=path/to/projects.json node tasks/uptime-check.js

'use strict';

const fs = require('fs');
const needle = require('needle');


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
  const opts = {
    follow_max: 2
  };
  needle.head(uri, opts, callback).on('error', callback);
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


const json = getProjectJson();
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
