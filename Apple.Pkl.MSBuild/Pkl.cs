// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;

namespace Apple.Pkl.MSBuild;

public class Pkl : PklToolTask
{
    [Required]
    public ITaskItem SourceFile { get; set; }

    [Required]
    public ITaskItem OutputFile { get; set; }

    
    [Required]
    public ITaskItem Format { get; set; }

    protected override string GenerateCommandLineCommands()
    {
        var builder = new CommandLineBuilder(quoteHyphensOnCommandLine: false, useNewLineSeparator: false);

        builder.AppendSwitch("eval");

        builder.AppendSwitch("--output-path");
        builder.AppendFileNameIfNotNull(this.OutputFile);

        builder.AppendSwitch("--format");
        builder.AppendFileNameIfNotNull(this.Format);

        builder.AppendFileNameIfNotNull(this.SourceFile);

        return builder.ToString();
    }
}
