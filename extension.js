const vscode = require('vscode');
const { exec } = require('child_process');
const fs = require('fs');

function activate(context) {
    let disposable = vscode.commands.registerCommand('eudic-translate.translate', async () => {

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
            vscode.window.showErrorMessage('No text selected or no word under cursor.');
            return;
        }

        const config = vscode.workspace.getConfiguration('eudic');
        const binPath = config.get('binaryPath');

        if (!fs.existsSync(binPath)) {
            vscode.window.showErrorMessage(`Eudic binary path does not exist: ${binPath}`);
            return;
        }

        const command = `${binPath} -w "${textToTranslate}"`;
        exec(command, (error, stdout, stderr) => {
            if (error) {
                vscode.window.showErrorMessage(`Error executing command: ${stderr}`);
                return;
            }
            vscode.window.showInformationMessage('Text sent to Eudic successfully.');
        });
    });

    context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
};