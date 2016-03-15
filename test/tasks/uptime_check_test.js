'use strict';

const assert = require('assert');
const nock = require('nock');
const lib = require('../../tasks/uptime-check/lib');

describe("uptime-check lib", () => {
  describe('.checkIfUp()', () => {
    it("returns `true` for a 200", (done) => {
      const uri = 'https://example.com';

      nock(uri)
        .head('/')
        .reply(200, {});

      lib.checkIfUp(uri, (err, isUp) => {
        assert(isUp);
        done(err);
      });
    });
  });
});
