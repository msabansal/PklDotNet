// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { describe, expect, it } from "vitest";
import * as asserts from "./asserts";
import { Example } from "./example";

describe("msBuild", () => {
  it("Should fail building projects with Pkl errors", () => {
    const example = new Example("errorHandling");
    example.cleanProjectDir();

    const result = example.build(false);

    expect(result.stderr).toBe("");


    const files = [ 
      "invalid.json"
    ];

    files.forEach(file => {
      example.expectBuildFile(file).toBeFalsy();
    });

    // The build should fail and have the right error with appropriate file
    asserts.expectLinesInLog(result.stdout, [
      ": error : Missing `}` delimiter.",
      "examples/errorHandling/invalid.pkl",
    ]);
  });
});