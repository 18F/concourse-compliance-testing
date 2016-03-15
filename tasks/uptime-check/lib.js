'use strict';

const fs = require('fs');
const request = require('request');


const lib = {
  getProjectJson() {
    const jsonPath = process.env.PROJECT_JSON || '../../../projects-json/projects.json';
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

  checkIfUp(uri, callback) {
    lib.headReq(uri, (err, res, body) => {
      callback(err, lib.isUp(res));
    });
  },

  checkLink(link) {
    lib.checkIfUp(link, (err, isUp) => {
      if (err || !isUp) {
        console.error(`${link} is NOT up.`);
      }
    });
  },

  checkLinkObj(projectName, linkObj) {
    const link = lib.getUrl(linkObj);
    if (link) {
      lib.checkLink(link);
    } else {
      console.error(`Malformed \`links\` for ${projectName}.`);
    }
  },

  checkProjects(projects) {
    projects.forEach((project) => {
      const links = project.links || [];
      if (links.length === 0) {
        console.error(`No \`links\` for ${project.name}.`);
      } else {
        links.forEach((linkObj) => {
          lib.checkLinkObj(project.name, linkObj);
        });
      }
    });
  }
};

module.exports = lib;
