'use strict';

const assert = require('assert');
const nock = require('nock');
const lib = require('../lib');

nock.disableNetConnect();

describe("uptime-check lib", () => {
  describe('.checkIfUp()', () => {
    [200, 201, 403].forEach((status) => {
      it("returns a Promise that resolves for a " + status, () => {
        const uri = 'https://example.com';

        nock(uri)
          .head('/')
          .reply(status, '');

        return lib.checkIfUp(uri);
      });
    });

    [404, 500].forEach((status) => {
      it("returns a Promise that rejects for " + status, () => {
        const uri = 'https://example.com';

        nock(uri)
          .head('/')
          .reply(status, '');

        // reverse the Promise
        // http://stackoverflow.com/a/28706900/358804
        return lib.checkIfUp(uri).then(
          () => {
            throw new Error("request should not succeed");
          },
          (err) => {
            return "request failed (as expected)";
          }
        );
      });
    });
  });

  describe('.checkProjects()', () => {
    it("returns an empty Array when no projects are passed", () => {
      assert.deepStrictEqual(lib.checkProjects([]), []);
    });
  });
});
