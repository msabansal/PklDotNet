import { describe, expect, it } from "vitest";
import * as asserts from "./asserts";
import { Example } from "./example";

describe("msBuild", () => {
  it("Should build OutputStyles project", () => {
    const example = new Example("basicMultiTarget");
    example.cleanProjectDir();
    const result = example.build();

    expect(result.stderr).toBe("");


    const files = [ 
      "config.json"
    ];

    files.forEach(file => {
      example.expectBuildFile(file).toBeTruthy();
    });

    example.publish("net8.0");

     files.forEach(file => {
      example.expectPublishedFile(file, "net8.0").toBeTruthy();
    });

    example.publish("net472");

     files.forEach(file => {
      example.expectPublishedFile(file, "net472").toBeTruthy();
    });

  });
});