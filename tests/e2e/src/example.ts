// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
import * as fs from "fs";
import { SpawnSyncReturns } from "node:child_process";
import * as path from "path";
import * as spawn from "cross-spawn";
import { Assertion, expect } from "vitest";
import { TEST_CONFIG } from "../test-setup";

export class Example {
  readonly projectDir: string;
  readonly projectFile: string;

  constructor(projectName: string, projectFile?: string) {
    const projectDir = path.normalize(path.join(__dirname, `../examples/${projectName}/`));
    
    if (!fs.existsSync(projectDir)) {
      throw new Error(`Example project directory does not exist: ${projectDir}`);
    }
    
    this.projectDir = projectDir;
    this.projectFile = path.join(projectDir, projectFile ?? `${projectName}.proj`);
  }

  public cleanProjectDir(): void {
    const result = spawn.sync("git", ["clean", "-dfx", "--", this.projectDir], {
      cwd: this.projectDir,
      stdio: "pipe",
      encoding: "utf-8",
    });

    if (result.status !== 0) {
      this.handleFailure("git", result);
    }
  }

  public clean(expectSuccess = true): SpawnSyncReturns<string> {
    return this.runMsBuild("clean", expectSuccess);
  }

  public build(expectSuccess = true): SpawnSyncReturns<string> {
    return this.runMsBuild("build", expectSuccess);
  }

  public expectBuildFile(relativeFilePath: string, targetFramework?: string | null): Assertion<boolean> {
    const filePath = this.resolveBuildFileRelativePath(relativeFilePath, false, targetFramework);
    return expect(fs.existsSync(filePath));
  }

  private resolveBuildFileRelativePath(relativeFilePath: string, published: boolean, targetFramework?: string | null): string {
    let intermediatePath = path.join(this.projectDir, "bin", "Debug", targetFramework ?? "net8.0");
    if (published) {
      intermediatePath = path.join(intermediatePath, "publish");
    }

    return path.join(intermediatePath, relativeFilePath);
  }

  public expectPublishedFile(relativeFilePath: string, targetFramework?: string | null): Assertion<boolean> {
    const filePath = this.resolveBuildFileRelativePath(relativeFilePath, true, targetFramework);
    return expect(fs.existsSync(filePath));
  }

  public publish(targetFramework?: string | null, expectSuccess = true): SpawnSyncReturns<string> {
    return this.runMsBuild("publish", expectSuccess, targetFramework);
  }

  private runMsBuild(verb: string, expectSuccess: boolean, targetFramework?: string | null): SpawnSyncReturns<string> {
    const runtimeSuffix = process.env.RuntimeSuffix;
    if (!runtimeSuffix) {
      throw new Error(
        "Please set the RuntimeSuffix environment variable to a .net runtime ID to run these tests. Possible values: win-x64, linux-x64, osx-x64",
      );
    }
    const result = spawn.sync(
      "dotnet",
      [
        verb,
        "--configuration",
        "Debug",
        `/p:PackageVersion=${TEST_CONFIG.packageVersion}`,
        `/p:RuntimeSuffix=${runtimeSuffix}`,
        targetFramework ? `/p:TargetFramework=${targetFramework}` : "",
        this.projectFile,
      ],
      {
        cwd: this.projectDir,
        stdio: "pipe",
        encoding: "utf-8",
        env: {
          ...process.env,
          DOTNET_NOLOGO: 'true'
        }
      },
    );

    if (expectSuccess && result.status !== 0) {
      this.handleFailure("MSBuild", result);
    }

    return result;
  }

  private handleFailure(tool: string, result: SpawnSyncReturns<string>) {
    if (result.stderr.length > 0) {
      throw new Error(`Unexpected StdErr content:\n${result.stderr}`);
    }

    if (result.stdout.length > 0) {
      throw new Error(`Unexpected StdOut content:\n${result.stdout}`);
    }

    throw new Error(`Unexpected ${tool} exit code: ${result.status}`);
  }

}
