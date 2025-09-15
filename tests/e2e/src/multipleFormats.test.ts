import { describe, expect, it } from "vitest";
import * as asserts from "./asserts";
import { Example } from "./example";

describe("msBuild", () => {
  it("Should build MultipleFormats project", () => {
    const example = new Example("multipleFormats");
    example.cleanProjectDir();
    const result = example.build();

    expect(result.stderr).toBe("");


    const files = [ 
      "app.json",
      "app-config.xml",
      "app-config.yaml",
      "simple.properties",
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