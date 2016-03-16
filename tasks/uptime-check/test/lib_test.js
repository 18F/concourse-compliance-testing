'use strict';

const assert = require('assert');
const nock = require('nock');
const lib = require('../lib');

nock.disableNetConnect();

describe("uptime-check lib", () => {
  describe('.checkIfUp()', () => {
    [200, 201, 403].forEach((status) => {
      it("returns `true` for a " + status, (done) => {
        const uri = 'https://example.com';

        nock(uri)
          .head('/')
          .reply(status, '');

        lib.checkIfUp(uri).then(done, done);
      });
    });

    [404, 500].forEach((status) => {
      it("returns `false` for a " + status, (done) => {
        const uri = 'https://example.com';

        nock(uri)
          .head('/')
          .reply(status, '');

        lib.checkIfUp(uri).then(
          () => {
            done("request should not succeed");
          },
          (err) => {
            done();
          }
        );
      });
    });
  });
});
