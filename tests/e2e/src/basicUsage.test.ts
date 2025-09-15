import { describe, expect, it } from "vitest";
import * as asserts from "./asserts";
import { Example } from "./example";

describe("msBuild", () => {
  it("Should build basicUsage project", () => {
    const example = new Example("basicUsage");
    example.cleanProjectDir();
    const result = example.build();

    expect(result.stderr).toBe("");


    const files = [ 
      "config.json"
    ];

    files.forEach(file => {
      example.expectBuildFile(file).toBeTruthy();
    });

    example.publish();

     files.forEach(file => {
      example.expectPublishedFile(file).toBeTruthy();
    });

  });
});