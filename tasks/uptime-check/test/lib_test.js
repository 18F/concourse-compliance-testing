'use strict';

const assert = require('assert');
const nock = require('nock');
const lib = require('../lib');

nock.disableNetConnect();

// Returns a new Promise that resolves when the given `promise` rejects, and vice versa. Useful for tests that want to check for a rejected Promise.
const reversePromise = (promise) => {
  // http://stackoverflow.com/a/28706900/358804
  return promise.then(
    () => {
      throw new Error("request should not succeed");
    },
    () => {
      return "request failed (as expected)";
    }
  );
};

describe("uptime-check lib", () => {
  const stubAllRequests = (urls) => {
    urls.forEach((url) => {
      nock(url)
      .head('/')
      .reply(200, '');
    });
  };

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

        return reversePromise(lib.checkIfUp(uri));
      });
    });
  });

  describe('.getUrl()', () => {
    it("handles strings", () => {
      assert.strictEqual(lib.getUrl('https://foo.com'), 'https://foo.com');
    });

    it("handles objects", () => {
      assert.strictEqual(lib.getUrl({url: 'https://foo.com'}), 'https://foo.com');
    });
  });

  describe('.checkProject()', () => {
    it("returns only one Promise when there are multiple links", () => {
      const project = {
        name: "foo",
        links: [
          "https://foo.com",
          "https://bar.com"
        ]
      };

      stubAllRequests([
        "https://foo.com",
        "https://bar.com"
      ]);

      const promise = lib.checkProject(project);
      assert(promise instanceof Promise);
      return promise;
    });
  });

  describe('.checkProjects()', () => {
    it("returns an empty Array when no projects are passed", () => {
      assert.deepStrictEqual(lib.checkProjects([]), []);
    });

    it("returns a Promise for each project", () => {
      const projects = [
        {
          name: "foo",
          links: [
            "https://foo.com"
          ]
        },
        {
          name: "bar",
          links: [
            "https://bar.com",
            "https://baz.com"
          ]
        }
      ];

      stubAllRequests([
        "https://foo.com",
        "https://bar.com",
        "https://baz.com"
      ]);

      const promises = lib.checkProjects(projects);
      assert.strictEqual(promises.length, 2);
      return Promise.all(promises);
    });
  });
});
