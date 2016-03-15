'use strict';

const assert = require('assert');
const nock = require('nock');
const lib = require('../../tasks/uptime-check/lib');

describe("uptime-check lib", () => {
  describe('.checkIfUp()', () => {
    [200, 201, 403].forEach((status) => {
      it("returns `true` for a " + status, (done) => {
        const uri = 'https://example.com';

        nock(uri)
          .head('/')
          .reply(status, '');

        lib.checkIfUp(uri, (err, isUp) => {
          assert(isUp);
          done(err);
        });
      });
    });

    [404, 500].forEach((status) => {
      it("returns `false` for a " + status, (done) => {
        const uri = 'https://example.com';

        nock(uri)
          .head('/')
          .reply(status, '');

        lib.checkIfUp(uri, (err, isUp) => {
          assert(!isUp);
          done(err);
        });
      });
    });
  });
});
