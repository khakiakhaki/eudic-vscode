const vscode = require("vscode");
const { exec } = require("child_process");
const fs = require("fs");
const os = require("os"); // Added: For platform-specific logic
const path = require("path"); // Added: For extracting executable name
let lastPid = 0;
function activate(context) {
  let disposable = vscode.commands.registerCommand(
    "eudic-translate.translate",
    async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor) {
        return;
      }

      let textToTranslate = editor.document.getText(editor.selection);

      if (!textToTranslate && editor.selection.isEmpty) {
        const position = editor.selection.active;
        const wordRange = editor.document.getWordRangeAtPosition(position);
        if (wordRange) {
          textToTranslate = editor.document.getText(wordRange);
        }
      }

      if (!textToTranslate) {
        vscode.window.showErrorMessage(
          "No text selected or no word under cursor."
        );
        return;
      }

      const config = vscode.workspace.getConfiguration("eudic");
      const binPath = config.get("exePath");

      if (!fs.existsSync(binPath)) {
        vscode.window.showErrorMessage(
          `Eudic binary path does not exist: ${binPath}`
        );
        return;
      }

      // Ensure binPath is quoted to handle spaces
      const command = `"${binPath}" -w "${textToTranslate}"`;
      exec(command, (error, stdout, stderr) => {
        if (error) {
          vscode.window.showErrorMessage(`Error executing command: ${stderr}`);
          return;
        }
        vscode.window.showInformationMessage(
          "Text sent to Eudic successfully."
        );

        // Attempt to activate Eudic window after a short delay
        setTimeout(() => {
          const platform = os.platform();
          let activateCommand = "";

          // Get the executable name without extension (e.g., "eudic" from "eudic.exe")
          const exeName = path.basename(binPath, path.extname(binPath));

          if (platform === "win32") {
            // Windows
            // PowerShell command to find the process by name and activate its main window
            // Using -NoProfile for faster startup, -NonInteractive to prevent prompts,
            // -ExecutionPolicy Bypass to avoid issues with restricted policies.
            // WScript.Shell AppActivate is used, targeting the process ID.
            activateCommand = `powershell -NoProfile -NonInteractive -EP Bypass -Command "if(${lastPid}){if(Get-Process -Id ${lastPid} -EA 0){(New-Object -ComObject WScript.Shell).AppActivate(${lastPid})|Out-Null;}}else{$p=@(Get-Process -Name '${exeName}' -EA 0)[0];(New-Object -ComObject WScript.Shell).AppActivate($p.Id)|Out-Null;$p.Id}"`;
          } else if (platform === "darwin") {
            // macOS
            // Attempt to derive application name from binPath (e.g., "Eudic" from "/Applications/Eudic.app/...")
            let appName = exeName; // Fallback to exeName
            const appPathMatch = binPath.match(/([^\/]+)\.app\//);
            if (appPathMatch && appPathMatch[1]) {
              appName = appPathMatch[1];
            }
            activateCommand = `osascript -e 'tell application "${appName}" to activate'`;
          }
          if (activateCommand) {
            exec(
              activateCommand,
              (activateError, activateStdout, activateStderr) => {
                if (platform === "win32") {
                  const stdoutTrimmed = activateStdout.trim();
                  if (stdoutTrimmed) {
                    lastPid = parseInt(stdoutTrimmed, 10);
                  }
                }
                if (activateError) {
                  // Log error to console, do not bother user with another message
                  console.error(
                    `Error attempting to activate Eudic window: ${activateStderr}`
                  );
                  if (activateStdout)
                    console.log(`Activation attempt stdout: ${activateStdout}`);
                } else {
                  if (activateStdout)
                    console.log(`Activation attempt stdout: ${activateStdout}`);
                  if (activateStderr)
                    console.warn(
                      `Activation attempt stderr: ${activateStderr}`
                    ); // Some tools output warnings to stderr
                }
              }
            );
          }
        }, 200); // 200ms delay to allow Eudic to process the command
      });
    }
  );

  context.subscriptions.push(disposable);
}

function deactivate() {
  lastEudicPid = null; // Clear cached PID when the extension deactivates
}

module.exports = {
  activate,
  deactivate,
};
