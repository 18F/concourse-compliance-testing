'use strict';

const fs = require('fs');
const request = require('request');


const lib = {
  getProjectJson() {
    const jsonPath = process.env.PROJECT_JSON;
    if (!jsonPath) {
      throw new Error("Please set PROJECT_JSON.");
    }
    const content = fs.readFileSync(jsonPath);
    return JSON.parse(content);
  },

  getUrl(linkObj) {
    if (typeof linkObj == 'string') {
      return linkObj;
    } else {
      return linkObj.url;
    }
  },

  headReq(uri, callback) {
    request.head(uri, callback);
  },

  isSuccess(res) {
    return res.statusCode >= 200 && res.statusCode < 300;
  },

  isUp(res) {
    return !!res && (lib.isSuccess(res) || res.statusCode === 403);
  },

  // Returns a Promise. The rejection handler receives a string with the reason.
  checkIfUp(uri) {
    return new Promise((resolve, reject) => {
      lib.headReq(uri, (err, res, body) => {
        if (err) {
          reject(`FAIL: ${uri} responds with ${err.toString()}.`);
        } else if (!lib.isUp(res)) {
          reject(`FAIL: ${uri} gives a status of ${res.statusCode}.`);
        } else {
          resolve();
        }
      });
    });
  },

  // returns a Promise
  checkLinkObj(projectName, linkObj) {
    const link = lib.getUrl(linkObj);
    if (link) {
      return lib.checkIfUp(link);
    } else {
      return Promise.reject(`Malformed \`links\` for ${projectName}.`);
    }
  },

  // returns an Array of Promises
  checkProjects(projects) {
    const promises = [];
    projects.forEach((project) => {
      const links = project.links || [];
      let projectPromise;
      if (links.length === 0) {
        projectPromise = Promise.reject(`No \`links\` for ${project.name}.`);
      } else {
        const linkPromises = links.map((linkObj) => {
          return lib.checkLinkObj(project.name, linkObj);
        });
        projectPromise = Promise.all(linkPromises);
      }
      promises.push(projectPromise);
    });

    return promises;
  },

  printLinkStatuses(projects) {
    lib.checkProjects(projects).forEach((promise) => {
      promise.then(null, console.error);
    });
  }
};

module.exports = lib;
