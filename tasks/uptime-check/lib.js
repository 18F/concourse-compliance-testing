'use strict';

const fs = require('fs');
const rp = require('request-promise');


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

  // Returns a Promise that resolves for 2xx or 403 status codes. The rejection handler receives a string with the reason.
  checkIfUp(uri) {
    const promise = rp({
      uri: uri,
      method: 'HEAD'
    });

    // swallow 403 errors
    return promise.catch((reason) => {
      if (reason.response && reason.response.statusCode === 403) {
        return '';
      } else {
        throw new Error(`FAIL: ${uri} responds with "${reason.error.toString()}".`);
      }
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

  // returns a Promise, which resolves if it has links and they all respond successfully
  checkProject(project) {
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
    return projectPromise;
  },

  // returns an Array of Promises, one for each project
  checkProjects(projects) {
    return projects.map(lib.checkProject);
  },

  printLinkStatuses(projects) {
    lib.checkProjects(projects).forEach((promise) => {
      promise.then(null, console.error);
    });
  }
};

module.exports = lib;
